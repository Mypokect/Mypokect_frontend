// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

_$ReminderImpl _$$ReminderImplFromJson(Map<String, dynamic> json) =>
    _$ReminderImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      category: json['category'] as String?,
      note: json['note'] as String?,
  dueDate: DateTime.parse(json['due_date'] as String),
  dueDateLocal: DateTime.parse(json['due_date_local'] as String),
      timezone: json['timezone'] as String,
      recurrence: json['recurrence'] as String,
  recurrenceParams: json['recurrence_params'] as Map<String, dynamic>?,
  notifyOffsetMinutes: (json['notify_offset_minutes'] as num).toInt(),
      status: json['status'] as String,
  isRecurring: json['is_recurring'] as bool? ?? false,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ReminderImplToJson(_$ReminderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'amount': instance.amount,
      'category': instance.category,
      'note': instance.note,
      'due_date': instance.dueDate.toIso8601String(),
      'due_date_local': instance.dueDateLocal.toIso8601String(),
      'timezone': instance.timezone,
      'recurrence': instance.recurrence,
      'recurrence_params': instance.recurrenceParams,
      'notify_offset_minutes': instance.notifyOffsetMinutes,
      'status': instance.status,
      'is_recurring': instance.isRecurring,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
