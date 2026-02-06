import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/calendar_repository.dart';
import '../infrastructure/models/reminder.dart';
import '../services/notifications/local_notifications.dart';
import 'calendar_controller.dart';

/// Reminder form state
class ReminderFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final Map<String, List<String>>? fieldErrors;

  ReminderFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.fieldErrors,
  });

  ReminderFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    Map<String, List<String>>? fieldErrors,
  }) {
    return ReminderFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

/// Reminder controller for CRUD operations
class ReminderController extends StateNotifier<ReminderFormState> {
  final CalendarRepository _repository;
  final LocalNotificationsService _notificationService;
  final Ref _ref;

  ReminderController({
    required CalendarRepository repository,
    required LocalNotificationsService notificationService,
    required Ref ref,
  })  : _repository = repository,
        _notificationService = notificationService,
        _ref = ref,
        super(ReminderFormState());

  /// Create a new reminder
  Future<Reminder?> createReminder({
    required String title,
    double? amount,
    String? category,
    String? note,
    required DateTime dueDate,
    required String timezone,
    required String recurrence,
    Map<String, dynamic>? recurrenceParams,
    required int notifyOffsetMinutes,
  }) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    try {
      final reminder = await _repository.create(
        title: title,
        amount: amount,
        category: category,
        note: note,
        dueDateUtc: dueDate.toUtc(),
        timezone: timezone,
        recurrence: recurrence,
        recurrenceParams: recurrenceParams,
        notifyOffsetMinutes: notifyOffsetMinutes,
      );

      // Schedule local notifications
      final notificationDateTime = reminder.dueDateLocal.subtract(
        Duration(minutes: reminder.notifyOffsetMinutes),
      );
      final body = reminder.amount != null 
          ? 'Monto: \$${reminder.amount!.toStringAsFixed(0)}'
          : 'Recordatorio de pago';
      
      await _notificationService.scheduleReminderNotifications(
        reminder.id,
        notificationDateTime,
        reminder.title,
        body,
      );

      // Refresh calendar
      _ref.read(calendarControllerProvider.notifier).refresh();

      state = state.copyWith(isLoading: false, isSuccess: true);
      return reminder;
    } on AppFailure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return null;
    }
  }

  /// Update an existing reminder
  Future<Reminder?> updateReminder({
    required int id,
    String? title,
    double? amount,
    String? category,
    String? note,
    DateTime? dueDate,
    String? timezone,
    String? recurrence,
    Map<String, dynamic>? recurrenceParams,
    int? notifyOffsetMinutes,
  }) async {
    state = state.copyWith(isLoading: true, error: null, fieldErrors: null);

    try {
      final reminder = await _repository.update(
        id: id,
        title: title,
        amount: amount,
        category: category,
        note: note,
        dueDateUtc: dueDate?.toUtc(),
        timezone: timezone,
        recurrence: recurrence,
        recurrenceParams: recurrenceParams,
        notifyOffsetMinutes: notifyOffsetMinutes,
      );

      // Reschedule local notifications
      final notificationDateTime = reminder.dueDateLocal.subtract(
        Duration(minutes: reminder.notifyOffsetMinutes),
      );
      final body = reminder.amount != null 
          ? 'Monto: \$${reminder.amount!.toStringAsFixed(0)}'
          : 'Recordatorio de pago';
      
      await _notificationService.cancelReminderNotifications(id);
      await _notificationService.scheduleReminderNotifications(
        reminder.id,
        notificationDateTime,
        reminder.title,
        body,
      );

      // Refresh calendar
      _ref.read(calendarControllerProvider.notifier).refresh();

      state = state.copyWith(isLoading: false, isSuccess: true);
      return reminder;
    } on AppFailure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return null;
    }
  }

  /// Delete a reminder
  Future<bool> deleteReminder(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.delete(id);

      // Cancel local notifications
      await _notificationService.cancelReminderNotifications(id);

      // Refresh calendar
      _ref.read(calendarControllerProvider.notifier).refresh();

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } on AppFailure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return false;
    }
  }

  /// Mark a reminder as paid
  Future<Reminder?> markAsPaid({
    required int id,
    DateTime? occurrenceDate,
    double? amountPaid,
    String? note,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final reminder = await _repository.markPaid(
        id: id,
        occurrenceDateUtc: occurrenceDate?.toUtc(),
        amountPaid: amountPaid,
        note: note,
      );

      // Cancel local notifications
      await _notificationService.cancelReminderNotifications(id);

      // Refresh calendar
      _ref.read(calendarControllerProvider.notifier).refresh();

      state = state.copyWith(isLoading: false, isSuccess: true);
      return reminder;
    } on AppFailure catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        fieldErrors: e.fieldErrors,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
      return null;
    }
  }

  /// Reset state
  void reset() {
    state = ReminderFormState();
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('422')) {
      return 'Datos inválidos. Por favor verifica los campos.';
    } else if (error.toString().contains('401') || error.toString().contains('403')) {
      return 'No autorizado. Por favor inicia sesión nuevamente.';
    } else if (error.toString().contains('Network')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    return 'Error inesperado. Intenta nuevamente.';
  }
}

/// Provider for ReminderController
final reminderControllerProvider =
    StateNotifierProvider<ReminderController, ReminderFormState>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  final notificationService = LocalNotificationsService();
  
  return ReminderController(
    repository: repository,
    notificationService: notificationService,
    ref: ref,
  );
});

/// Provider to get a specific reminder by ID
final reminderProvider = FutureProvider.family<Reminder, int>((ref, id) async {
  final api = ref.watch(calendarApiProvider);
  final reminder = await api.getReminder(id);
  return reminder;
});
