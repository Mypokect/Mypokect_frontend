import 'package:dio/dio.dart';

import '../infrastructure/models/reminder.dart';
import 'calendar_api.dart';

/// Normalized failure used by calendar feature
class AppFailure implements Exception {
  final int? code;
  final String message;
  final bool retriable;
  final Map<String, List<String>>? fieldErrors;

  const AppFailure({
    this.code,
    required this.message,
    this.retriable = false,
    this.fieldErrors,
  });
}

class CalendarRepository {
  final CalendarApi _api;

  CalendarRepository(this._api);

  Future<List<Reminder>> fetchByRange({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    try {
      return await _api.getReminders(start: startUtc, end: endUtc);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Reminder> create({
    required String title,
    double? amount,
    String? category,
    String? note,
    required DateTime dueDateUtc,
    required String timezone,
    required String recurrence,
    Map<String, dynamic>? recurrenceParams,
    required int notifyOffsetMinutes,
  }) async {
    try {
      return await _api.createReminder(
        title: title,
        amount: amount,
        category: category,
        note: note,
        dueDate: dueDateUtc,
        timezone: timezone,
        recurrence: recurrence,
        recurrenceParams: recurrenceParams,
        notifyOffsetMinutes: notifyOffsetMinutes,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Reminder> update({
    required int id,
    String? title,
    double? amount,
    String? category,
    String? note,
    DateTime? dueDateUtc,
    String? timezone,
    String? recurrence,
    Map<String, dynamic>? recurrenceParams,
    int? notifyOffsetMinutes,
    String? status,
  }) async {
    try {
      return await _api.updateReminder(
        id: id,
        title: title,
        amount: amount,
        category: category,
        note: note,
        dueDate: dueDateUtc,
        timezone: timezone,
        recurrence: recurrence,
        recurrenceParams: recurrenceParams,
        notifyOffsetMinutes: notifyOffsetMinutes,
        status: status,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _api.deleteReminder(id);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Reminder> markPaid({
    required int id,
    DateTime? occurrenceDateUtc,
    double? amountPaid,
    String? note,
  }) async {
    try {
      return await _api.markAsPaid(
        id: id,
        occurrenceDate: occurrenceDateUtc,
        amountPaid: amountPaid,
        note: note,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppFailure _mapError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 401) {
      return const AppFailure(
        code: 401,
        message: 'Sesión expirada. Inicia sesión nuevamente.',
        retriable: false,
      );
    }

    if (status == 422) {
      Map<String, List<String>>? fieldErrors;
      if (data is Map<String, dynamic> && data['errors'] is Map) {
        fieldErrors = (data['errors'] as Map).map((key, value) {
          final list = (value as List).map((e) => e.toString()).toList();
          return MapEntry(key.toString(), list);
        });
      }
      return AppFailure(
        code: 422,
        message: 'Hay errores en algunos campos.',
        retriable: false,
        fieldErrors: fieldErrors,
      );
    }

    final isNetwork = e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown;

    return AppFailure(
      code: status,
      message: isNetwork
          ? 'Error de conexión. Verifica tu internet.'
          : 'Ocurrió un error inesperado. Intenta de nuevo.',
      retriable: isNetwork,
    );
  }
}
