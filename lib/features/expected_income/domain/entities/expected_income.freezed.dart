// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expected_income.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExpectedIncome _$ExpectedIncomeFromJson(Map<String, dynamic> json) {
  return _ExpectedIncome.fromJson(json);
}

/// @nodoc
mixin _$ExpectedIncome {
  String get id => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending | received | expired
  DateTime? get expectedDate => throw _privateConstructorUsedError;
  String? get receivedTransactionId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExpectedIncomeCopyWith<ExpectedIncome> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpectedIncomeCopyWith<$Res> {
  factory $ExpectedIncomeCopyWith(
          ExpectedIncome value, $Res Function(ExpectedIncome) then) =
      _$ExpectedIncomeCopyWithImpl<$Res, ExpectedIncome>;
  @useResult
  $Res call(
      {String id,
      String source,
      double amount,
      String status,
      DateTime? expectedDate,
      String? receivedTransactionId,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class _$ExpectedIncomeCopyWithImpl<$Res, $Val extends ExpectedIncome>
    implements $ExpectedIncomeCopyWith<$Res> {
  _$ExpectedIncomeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? amount = null,
    Object? status = null,
    Object? expectedDate = freezed,
    Object? receivedTransactionId = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expectedDate: freezed == expectedDate
          ? _value.expectedDate
          : expectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      receivedTransactionId: freezed == receivedTransactionId
          ? _value.receivedTransactionId
          : receivedTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$ExpectedIncomeImplCopyWith<$Res>
    implements $ExpectedIncomeCopyWith<$Res> {
  factory _$$ExpectedIncomeImplCopyWith(_$ExpectedIncomeImpl value,
          $Res Function(_$ExpectedIncomeImpl) then) =
      __$$ExpectedIncomeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String source,
      double amount,
      String status,
      DateTime? expectedDate,
      String? receivedTransactionId,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class __$$ExpectedIncomeImplCopyWithImpl<$Res>
    extends _$ExpectedIncomeCopyWithImpl<$Res, _$ExpectedIncomeImpl>
    implements _$$ExpectedIncomeImplCopyWith<$Res> {
  __$$ExpectedIncomeImplCopyWithImpl(
      _$ExpectedIncomeImpl _value, $Res Function(_$ExpectedIncomeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? amount = null,
    Object? status = null,
    Object? expectedDate = freezed,
    Object? receivedTransactionId = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$ExpectedIncomeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      expectedDate: freezed == expectedDate
          ? _value.expectedDate
          : expectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      receivedTransactionId: freezed == receivedTransactionId
          ? _value.receivedTransactionId
          : receivedTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$ExpectedIncomeImpl implements _ExpectedIncome {
  const _$ExpectedIncomeImpl(
      {required this.id,
      required this.source,
      required this.amount,
      required this.status,
      this.expectedDate,
      this.receivedTransactionId,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.syncStatus = 'pending'});

  factory _$ExpectedIncomeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpectedIncomeImplFromJson(json);

  @override
  final String id;
  @override
  final String source;
  @override
  final double amount;
  @override
  final String status;
// pending | received | expired
  @override
  final DateTime? expectedDate;
  @override
  final String? receivedTransactionId;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String syncStatus;

  @override
  String toString() {
    return 'ExpectedIncome(id: $id, source: $source, amount: $amount, status: $status, expectedDate: $expectedDate, receivedTransactionId: $receivedTransactionId, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpectedIncomeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expectedDate, expectedDate) ||
                other.expectedDate == expectedDate) &&
            (identical(other.receivedTransactionId, receivedTransactionId) ||
                other.receivedTransactionId == receivedTransactionId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      source,
      amount,
      status,
      expectedDate,
      receivedTransactionId,
      notes,
      createdAt,
      updatedAt,
      syncStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpectedIncomeImplCopyWith<_$ExpectedIncomeImpl> get copyWith =>
      __$$ExpectedIncomeImplCopyWithImpl<_$ExpectedIncomeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpectedIncomeImplToJson(
      this,
    );
  }
}

abstract class _ExpectedIncome implements ExpectedIncome {
  const factory _ExpectedIncome(
      {required final String id,
      required final String source,
      required final double amount,
      required final String status,
      final DateTime? expectedDate,
      final String? receivedTransactionId,
      final String? notes,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String syncStatus}) = _$ExpectedIncomeImpl;

  factory _ExpectedIncome.fromJson(Map<String, dynamic> json) =
      _$ExpectedIncomeImpl.fromJson;

  @override
  String get id;
  @override
  String get source;
  @override
  double get amount;
  @override
  String get status;
  @override // pending | received | expired
  DateTime? get expectedDate;
  @override
  String? get receivedTransactionId;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get syncStatus;
  @override
  @JsonKey(ignore: true)
  _$$ExpectedIncomeImplCopyWith<_$ExpectedIncomeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
