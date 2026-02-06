import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

/// Reminder model representing a payment/obligation reminder
///
/// The backend API uses snake_case keys.
///
/// Freezed generates the JSON helpers in `reminder.g.dart`; we
/// adapt their implementation there to snake_case.
@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required int id,
    required String title,
    double? amount,
    String? category,
    String? note,
    required DateTime dueDate,
    required DateTime dueDateLocal,
    required String timezone,
    required String recurrence,
    Map<String, dynamic>? recurrenceParams,
    required int notifyOffsetMinutes,
    required String status,
    @Default(false) bool isRecurring,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) => _$ReminderFromJson(json);
}

/// Enum for reminder recurrence types
enum RecurrenceType {
  @JsonValue('none')
  none,
  @JsonValue('monthly')
  monthly,
}

/// Enum for reminder status
enum ReminderStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('paid')
  paid,
}

/// Extension for RecurrenceType
extension RecurrenceTypeX on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.none:
        return 'Una vez';
      case RecurrenceType.monthly:
        return 'Mensual';
    }
  }
}

/// Extension for ReminderStatus
extension ReminderStatusX on ReminderStatus {
  String get displayName {
    switch (this) {
      case ReminderStatus.pending:
        return 'Pendiente';
      case ReminderStatus.paid:
        return 'Pagado';
    }
  }
}
