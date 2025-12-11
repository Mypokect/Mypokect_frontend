// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Reminder _$ReminderFromJson(Map<String, dynamic> json) {
  return _Reminder.fromJson(json);
}

/// @nodoc
mixin _$Reminder {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double? get amount => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  DateTime get dueDateLocal => throw _privateConstructorUsedError;
  String get timezone => throw _privateConstructorUsedError;
  String get recurrence => throw _privateConstructorUsedError;
  Map<String, dynamic>? get recurrenceParams =>
      throw _privateConstructorUsedError;
  int get notifyOffsetMinutes => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReminderCopyWith<Reminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReminderCopyWith<$Res> {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) then) =
      _$ReminderCopyWithImpl<$Res, Reminder>;
  @useResult
  $Res call(
      {int id,
      String title,
      double? amount,
      String? category,
      String? note,
      DateTime dueDate,
      DateTime dueDateLocal,
      String timezone,
      String recurrence,
      Map<String, dynamic>? recurrenceParams,
      int notifyOffsetMinutes,
      String status,
      bool isRecurring,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$ReminderCopyWithImpl<$Res, $Val extends Reminder>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = freezed,
    Object? category = freezed,
    Object? note = freezed,
    Object? dueDate = null,
    Object? dueDateLocal = null,
    Object? timezone = null,
    Object? recurrence = null,
    Object? recurrenceParams = freezed,
    Object? notifyOffsetMinutes = null,
    Object? status = null,
    Object? isRecurring = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDateLocal: null == dueDateLocal
          ? _value.dueDateLocal
          : dueDateLocal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      recurrence: null == recurrence
          ? _value.recurrence
          : recurrence // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceParams: freezed == recurrenceParams
          ? _value.recurrenceParams
          : recurrenceParams // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      notifyOffsetMinutes: null == notifyOffsetMinutes
          ? _value.notifyOffsetMinutes
          : notifyOffsetMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReminderImplCopyWith<$Res>
    implements $ReminderCopyWith<$Res> {
  factory _$$ReminderImplCopyWith(
          _$ReminderImpl value, $Res Function(_$ReminderImpl) then) =
      __$$ReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      double? amount,
      String? category,
      String? note,
      DateTime dueDate,
      DateTime dueDateLocal,
      String timezone,
      String recurrence,
      Map<String, dynamic>? recurrenceParams,
      int notifyOffsetMinutes,
      String status,
      bool isRecurring,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$ReminderImplCopyWithImpl<$Res>
    extends _$ReminderCopyWithImpl<$Res, _$ReminderImpl>
    implements _$$ReminderImplCopyWith<$Res> {
  __$$ReminderImplCopyWithImpl(
      _$ReminderImpl _value, $Res Function(_$ReminderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = freezed,
    Object? category = freezed,
    Object? note = freezed,
    Object? dueDate = null,
    Object? dueDateLocal = null,
    Object? timezone = null,
    Object? recurrence = null,
    Object? recurrenceParams = freezed,
    Object? notifyOffsetMinutes = null,
    Object? status = null,
    Object? isRecurring = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ReminderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      dueDateLocal: null == dueDateLocal
          ? _value.dueDateLocal
          : dueDateLocal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      timezone: null == timezone
          ? _value.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String,
      recurrence: null == recurrence
          ? _value.recurrence
          : recurrence // ignore: cast_nullable_to_non_nullable
              as String,
      recurrenceParams: freezed == recurrenceParams
          ? _value._recurrenceParams
          : recurrenceParams // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      notifyOffsetMinutes: null == notifyOffsetMinutes
          ? _value.notifyOffsetMinutes
          : notifyOffsetMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      isRecurring: null == isRecurring
          ? _value.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReminderImpl implements _Reminder {
  const _$ReminderImpl(
      {required this.id,
      required this.title,
      this.amount,
      this.category,
      this.note,
      required this.dueDate,
      required this.dueDateLocal,
      required this.timezone,
      required this.recurrence,
      final Map<String, dynamic>? recurrenceParams,
      required this.notifyOffsetMinutes,
      required this.status,
      this.isRecurring = false,
      required this.createdAt,
      required this.updatedAt})
      : _recurrenceParams = recurrenceParams;

  factory _$ReminderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReminderImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final double? amount;
  @override
  final String? category;
  @override
  final String? note;
  @override
  final DateTime dueDate;
  @override
  final DateTime dueDateLocal;
  @override
  final String timezone;
  @override
  final String recurrence;
  final Map<String, dynamic>? _recurrenceParams;
  @override
  Map<String, dynamic>? get recurrenceParams {
    final value = _recurrenceParams;
    if (value == null) return null;
    if (_recurrenceParams is EqualUnmodifiableMapView) return _recurrenceParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final int notifyOffsetMinutes;
  @override
  final String status;
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Reminder(id: $id, title: $title, amount: $amount, category: $category, note: $note, dueDate: $dueDate, dueDateLocal: $dueDateLocal, timezone: $timezone, recurrence: $recurrence, recurrenceParams: $recurrenceParams, notifyOffsetMinutes: $notifyOffsetMinutes, status: $status, isRecurring: $isRecurring, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.dueDateLocal, dueDateLocal) ||
                other.dueDateLocal == dueDateLocal) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.recurrence, recurrence) ||
                other.recurrence == recurrence) &&
            const DeepCollectionEquality()
                .equals(other._recurrenceParams, _recurrenceParams) &&
            (identical(other.notifyOffsetMinutes, notifyOffsetMinutes) ||
                other.notifyOffsetMinutes == notifyOffsetMinutes) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      amount,
      category,
      note,
      dueDate,
      dueDateLocal,
      timezone,
      recurrence,
      const DeepCollectionEquality().hash(_recurrenceParams),
      notifyOffsetMinutes,
      status,
      isRecurring,
      createdAt,
      updatedAt);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      __$$ReminderImplCopyWithImpl<_$ReminderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReminderImplToJson(
      this,
    );
  }
}

abstract class _Reminder implements Reminder {
  const factory _Reminder(
      {required final int id,
      required final String title,
      final double? amount,
      final String? category,
      final String? note,
      required final DateTime dueDate,
      required final DateTime dueDateLocal,
      required final String timezone,
      required final String recurrence,
      final Map<String, dynamic>? recurrenceParams,
      required final int notifyOffsetMinutes,
      required final String status,
      final bool isRecurring,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$ReminderImpl;

  factory _Reminder.fromJson(Map<String, dynamic> json) =
      _$ReminderImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  double? get amount;
  @override
  String? get category;
  @override
  String? get note;
  @override
  DateTime get dueDate;
  @override
  DateTime get dueDateLocal;
  @override
  String get timezone;
  @override
  String get recurrence;
  @override
  Map<String, dynamic>? get recurrenceParams;
  @override
  int get notifyOffsetMinutes;
  @override
  String get status;
  @override
  bool get isRecurring;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
