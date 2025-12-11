import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../infrastructure/calendar_api.dart';
import '../infrastructure/calendar_repository.dart';
import '../infrastructure/models/reminder.dart';
import '../infrastructure/local/reminder_cache.dart';
import '../../../Services/base_url.dart';

/// Calendar state
class CalendarState {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final tc.CalendarFormat format;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<Reminder> reminders;
  final bool isLoading;
  final String? error;

  CalendarState({
    required this.focusedDay,
    this.selectedDay,
    this.format = tc.CalendarFormat.month,
    required this.rangeStart,
    required this.rangeEnd,
    this.reminders = const [],
    this.isLoading = false,
    this.error,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    tc.CalendarFormat? format,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    List<Reminder>? reminders,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      format: format ?? this.format,
      rangeStart: rangeStart ?? this.rangeStart,
      rangeEnd: rangeEnd ?? this.rangeEnd,
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get reminders for a specific day
  List<Reminder> getRemindersForDay(DateTime day) {
    return reminders.where((reminder) {
      final reminderDate = reminder.dueDateLocal;
      return reminderDate.year == day.year &&
          reminderDate.month == day.month &&
          reminderDate.day == day.day;
    }).toList();
  }

  /// Count pending reminders for a day
  int countPendingForDay(DateTime day) {
    return getRemindersForDay(day)
        .where((r) => r.status == 'pending')
        .length;
  }
}

/// Calendar controller using Riverpod
class CalendarController extends StateNotifier<CalendarState> {
  final CalendarRepository _repository;
  final ReminderCache _cache;
  final String _userId;

  CalendarController({
    required CalendarRepository repository,
    required ReminderCache cache,
    required String userId,
  })  : _repository = repository,
        _cache = cache,
        _userId = userId,
        super(CalendarState(
          focusedDay: DateTime.now(),
          rangeStart: DateTime.now().subtract(const Duration(days: 30)),
          rangeEnd: DateTime.now().add(const Duration(days: 60)),
        )) {
    loadReminders();
  }

  /// Load reminders for current range
  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Try to load from cache first
      final cached = await _cache.getReminders(
        state.focusedDay,
        userId: _userId,
      );
      if (cached != null && cached.isNotEmpty) {
        state = state.copyWith(
          reminders: cached,
          isLoading: false,
        );
      }

      // Fetch from API
      final reminders = await _repository.fetchByRange(
        startUtc: state.rangeStart.toUtc(),
        endUtc: state.rangeEnd.toUtc(),
      );

      // Update cache
      await _cache.saveReminders(
        state.focusedDay,
        reminders,
        userId: _userId,
      );

      state = state.copyWith(
        reminders: reminders,
        isLoading: false,
      );
    } on AppFailure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'No se pudieron cargar los recordatorios.',
      );
    }
  }

  /// Change focused day
  void changeFocusedDay(DateTime day) {
    state = state.copyWith(focusedDay: day, selectedDay: day);
    
    // Update range if needed
    if (_updateRangeIfNeeded(day)) {
      loadReminders();
    }
  }

  /// Select a day
  void selectDay(DateTime day) {
    state = state.copyWith(selectedDay: day);
  }

  /// Change calendar format
  void changeFormat(tc.CalendarFormat format) {
    state = state.copyWith(format: format);
    if (_updateRangeIfNeeded(state.focusedDay)) {
      loadReminders();
    }
  }

  /// Update range if focused day is outside current range
  bool _updateRangeIfNeeded(DateTime day) {
    if (day.isBefore(state.rangeStart) || day.isAfter(state.rangeEnd)) {
      final newStart = DateTime(day.year, day.month, 1).subtract(const Duration(days: 15));
      final newEnd = DateTime(day.year, day.month + 1, 0).add(const Duration(days: 15));

      state = state.copyWith(
        rangeStart: newStart,
        rangeEnd: newEnd,
      );
      return true;
    }
    return false;
  }

  /// Refresh reminders
  Future<void> refresh() async {
    await _cache.invalidate();
    await loadReminders();
  }

  /// Go to today
  void goToToday() {
    final today = DateTime.now();
    changeFocusedDay(today);
  }

  /// Get events for a day (for TableCalendar)
  List<Reminder> getEventsForDay(DateTime day) {
    return state.getRemindersForDay(day);
  }
}

/// Provider for CalendarController
final calendarControllerProvider =
    StateNotifierProvider<CalendarController, CalendarState>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  final cache = ReminderCache();

  return CalendarController(
    repository: repository,
    cache: cache,
    userId: 'anonymous',
  );
});

/// Provider for CalendarApi
final calendarApiProvider = Provider<CalendarApi>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${BaseUrl.apiUrl}v1/calendar',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      // La app guarda el token bajo la clave 'toke' (histórico),
      // pero aceptamos también 'token' por si se corrige en el futuro.
      final token = prefs.getString('token') ?? prefs.getString('toke');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));

  dio.interceptors.add(_RetryInterceptor(dio: dio, maxRetries: 2));

  // Logger seguro (no imprime Authorization)
  dio.interceptors.add(LogInterceptor(
    request: true,
    requestHeader: false,
    requestBody: true,
    responseHeader: false,
    responseBody: true,
  ));

  return CalendarApi(
    dio: dio,
    baseUrl: '${BaseUrl.apiUrl}v1/calendar',
  );
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final api = ref.watch(calendarApiProvider);
  return CalendarRepository(api);
});

class _RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  _RetryInterceptor({required this.dio, this.maxRetries = 2});

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;
    final currentRetries = (requestOptions.extra['retries'] as int?) ?? 0;

    if (currentRetries >= maxRetries) {
      return handler.next(err);
    }

    requestOptions.extra['retries'] = currentRetries + 1;
    final delay = Duration(milliseconds: 300 * (1 << currentRetries));
    await Future.delayed(delay);

    try {
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      return true;
    }
    return false;
  }
}
