import 'package:dio/dio.dart';
import 'models/reminder.dart';

/// API client for calendar/reminders endpoints
class CalendarApi {
  final Dio _dio;
  final String baseUrl;

  CalendarApi({
    required Dio dio,
    required this.baseUrl,
  }) : _dio = dio;

  /// Get reminders within a date range
  Future<List<Reminder>> getReminders({
    required DateTime start,
    required DateTime end,
    String? status,
  }) async {
    final response = await _dio.get(
      '$baseUrl/reminders',
      queryParameters: {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        if (status != null) 'status': status,
      },
    );

    final List<dynamic> data = response.data['data'] as List<dynamic>;
    return data.map((json) => Reminder.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Get a single reminder by ID
  Future<Reminder> getReminder(int id) async {
    final response = await _dio.get('$baseUrl/reminders/$id');
    return Reminder.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Create a new reminder
  Future<Reminder> createReminder({
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
    final response = await _dio.post(
      '$baseUrl/reminders',
      data: {
        'title': title,
        if (amount != null) 'amount': amount,
        if (category != null) 'category': category,
        if (note != null) 'note': note,
        'due_date': dueDate.toIso8601String(),
        'timezone': timezone,
        'recurrence': recurrence,
        if (recurrenceParams != null) 'recurrence_params': recurrenceParams,
        'notify_offset_minutes': notifyOffsetMinutes,
        'status': 'pending',
      },
    );

    return Reminder.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Update an existing reminder
  Future<Reminder> updateReminder({
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
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (amount != null) data['amount'] = amount;
    if (category != null) data['category'] = category;
    if (note != null) data['note'] = note;
    if (dueDate != null) data['due_date'] = dueDate.toIso8601String();
    if (timezone != null) data['timezone'] = timezone;
    if (recurrence != null) data['recurrence'] = recurrence;
    if (recurrenceParams != null) data['recurrence_params'] = recurrenceParams;
    if (notifyOffsetMinutes != null) data['notify_offset_minutes'] = notifyOffsetMinutes;
    if (status != null) data['status'] = status;

    final response = await _dio.patch(
      '$baseUrl/reminders/$id',
      data: data,
    );

    return Reminder.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Delete a reminder
  Future<void> deleteReminder(int id) async {
    await _dio.delete('$baseUrl/reminders/$id');
  }

  /// Mark a reminder as paid
  Future<Reminder> markAsPaid({
    required int id,
    DateTime? occurrenceDate,
    double? amountPaid,
    String? note,
  }) async {
    final data = <String, dynamic>{};
    if (occurrenceDate != null) {
      data['occurrence_date'] = occurrenceDate.toIso8601String();
    }
    if (amountPaid != null) data['amount_paid'] = amountPaid;
    if (note != null) data['note'] = note;

    final response = await _dio.post(
      '$baseUrl/reminders/$id/mark-paid',
      data: data,
    );

    return Reminder.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
