// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sip.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Sip _$SipFromJson(Map<String, dynamic> json) {
  return _Sip.fromJson(json);
}

/// @nodoc
mixin _$Sip {
  String get id => throw _privateConstructorUsedError;
  String get investmentId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get frequency =>
      throw _privateConstructorUsedError; // monthly | weekly | quarterly
  int get sipDate =>
      throw _privateConstructorUsedError; // day of month (1-31) or day of week (1-7)
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  int get autoCreate => throw _privateConstructorUsedError; // 0 = No, 1 = Yes
  int get isActive =>
      throw _privateConstructorUsedError; // 0 = Inactive, 1 = Active
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this Sip to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SipCopyWith<Sip> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SipCopyWith<$Res> {
  factory $SipCopyWith(Sip value, $Res Function(Sip) then) =
      _$SipCopyWithImpl<$Res, Sip>;
  @useResult
  $Res call(
      {String id,
      String investmentId,
      double amount,
      String frequency,
      int sipDate,
      DateTime startDate,
      DateTime? endDate,
      int autoCreate,
      int isActive,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class _$SipCopyWithImpl<$Res, $Val extends Sip> implements $SipCopyWith<$Res> {
  _$SipCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? investmentId = null,
    Object? amount = null,
    Object? frequency = null,
    Object? sipDate = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? autoCreate = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      investmentId: null == investmentId
          ? _value.investmentId
          : investmentId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      sipDate: null == sipDate
          ? _value.sipDate
          : sipDate // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoCreate: null == autoCreate
          ? _value.autoCreate
          : autoCreate // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SipImplCopyWith<$Res> implements $SipCopyWith<$Res> {
  factory _$$SipImplCopyWith(_$SipImpl value, $Res Function(_$SipImpl) then) =
      __$$SipImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String investmentId,
      double amount,
      String frequency,
      int sipDate,
      DateTime startDate,
      DateTime? endDate,
      int autoCreate,
      int isActive,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class __$$SipImplCopyWithImpl<$Res> extends _$SipCopyWithImpl<$Res, _$SipImpl>
    implements _$$SipImplCopyWith<$Res> {
  __$$SipImplCopyWithImpl(_$SipImpl _value, $Res Function(_$SipImpl) _then)
      : super(_value, _then);

  /// Create a copy of Sip
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? investmentId = null,
    Object? amount = null,
    Object? frequency = null,
    Object? sipDate = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? autoCreate = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$SipImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      investmentId: null == investmentId
          ? _value.investmentId
          : investmentId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      sipDate: null == sipDate
          ? _value.sipDate
          : sipDate // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoCreate: null == autoCreate
          ? _value.autoCreate
          : autoCreate // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SipImpl implements _Sip {
  const _$SipImpl(
      {required this.id,
      required this.investmentId,
      required this.amount,
      required this.frequency,
      required this.sipDate,
      required this.startDate,
      this.endDate,
      required this.autoCreate,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt,
      this.syncStatus = 'pending'});

  factory _$SipImpl.fromJson(Map<String, dynamic> json) =>
      _$$SipImplFromJson(json);

  @override
  final String id;
  @override
  final String investmentId;
  @override
  final double amount;
  @override
  final String frequency;
// monthly | weekly | quarterly
  @override
  final int sipDate;
// day of month (1-31) or day of week (1-7)
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final int autoCreate;
// 0 = No, 1 = Yes
  @override
  final int isActive;
// 0 = Inactive, 1 = Active
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String syncStatus;

  @override
  String toString() {
    return 'Sip(id: $id, investmentId: $investmentId, amount: $amount, frequency: $frequency, sipDate: $sipDate, startDate: $startDate, endDate: $endDate, autoCreate: $autoCreate, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SipImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.investmentId, investmentId) ||
                other.investmentId == investmentId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.sipDate, sipDate) || other.sipDate == sipDate) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.autoCreate, autoCreate) ||
                other.autoCreate == autoCreate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      investmentId,
      amount,
      frequency,
      sipDate,
      startDate,
      endDate,
      autoCreate,
      isActive,
      createdAt,
      updatedAt,
      syncStatus);

  /// Create a copy of Sip
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SipImplCopyWith<_$SipImpl> get copyWith =>
      __$$SipImplCopyWithImpl<_$SipImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SipImplToJson(
      this,
    );
  }
}

abstract class _Sip implements Sip {
  const factory _Sip(
      {required final String id,
      required final String investmentId,
      required final double amount,
      required final String frequency,
      required final int sipDate,
      required final DateTime startDate,
      final DateTime? endDate,
      required final int autoCreate,
      required final int isActive,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String syncStatus}) = _$SipImpl;

  factory _Sip.fromJson(Map<String, dynamic> json) = _$SipImpl.fromJson;

  @override
  String get id;
  @override
  String get investmentId;
  @override
  double get amount;
  @override
  String get frequency; // monthly | weekly | quarterly
  @override
  int get sipDate; // day of month (1-31) or day of week (1-7)
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  int get autoCreate; // 0 = No, 1 = Yes
  @override
  int get isActive; // 0 = Inactive, 1 = Active
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get syncStatus;

  /// Create a copy of Sip
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SipImplCopyWith<_$SipImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
