// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receivable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Receivable _$ReceivableFromJson(Map<String, dynamic> json) {
  return _Receivable.fromJson(json);
}

/// @nodoc
mixin _$Receivable {
  String get id => throw _privateConstructorUsedError;
  String get personName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int get isArchived => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this Receivable to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Receivable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceivableCopyWith<Receivable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceivableCopyWith<$Res> {
  factory $ReceivableCopyWith(
          Receivable value, $Res Function(Receivable) then) =
      _$ReceivableCopyWithImpl<$Res, Receivable>;
  @useResult
  $Res call(
      {String id,
      String personName,
      double amount,
      String? notes,
      int isArchived,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class _$ReceivableCopyWithImpl<$Res, $Val extends Receivable>
    implements $ReceivableCopyWith<$Res> {
  _$ReceivableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Receivable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? personName = null,
    Object? amount = null,
    Object? notes = freezed,
    Object? isArchived = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      personName: null == personName
          ? _value.personName
          : personName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ReceivableImplCopyWith<$Res>
    implements $ReceivableCopyWith<$Res> {
  factory _$$ReceivableImplCopyWith(
          _$ReceivableImpl value, $Res Function(_$ReceivableImpl) then) =
      __$$ReceivableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String personName,
      double amount,
      String? notes,
      int isArchived,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class __$$ReceivableImplCopyWithImpl<$Res>
    extends _$ReceivableCopyWithImpl<$Res, _$ReceivableImpl>
    implements _$$ReceivableImplCopyWith<$Res> {
  __$$ReceivableImplCopyWithImpl(
      _$ReceivableImpl _value, $Res Function(_$ReceivableImpl) _then)
      : super(_value, _then);

  /// Create a copy of Receivable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? personName = null,
    Object? amount = null,
    Object? notes = freezed,
    Object? isArchived = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$ReceivableImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      personName: null == personName
          ? _value.personName
          : personName // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _value.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
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
class _$ReceivableImpl implements _Receivable {
  const _$ReceivableImpl(
      {required this.id,
      required this.personName,
      required this.amount,
      this.notes,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      this.syncStatus = 'pending'});

  factory _$ReceivableImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceivableImplFromJson(json);

  @override
  final String id;
  @override
  final String personName;
  @override
  final double amount;
  @override
  final String? notes;
  @override
  final int isArchived;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String syncStatus;

  @override
  String toString() {
    return 'Receivable(id: $id, personName: $personName, amount: $amount, notes: $notes, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceivableImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.personName, personName) ||
                other.personName == personName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, personName, amount, notes,
      isArchived, createdAt, updatedAt, syncStatus);

  /// Create a copy of Receivable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceivableImplCopyWith<_$ReceivableImpl> get copyWith =>
      __$$ReceivableImplCopyWithImpl<_$ReceivableImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceivableImplToJson(
      this,
    );
  }
}

abstract class _Receivable implements Receivable {
  const factory _Receivable(
      {required final String id,
      required final String personName,
      required final double amount,
      final String? notes,
      required final int isArchived,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String syncStatus}) = _$ReceivableImpl;

  factory _Receivable.fromJson(Map<String, dynamic> json) =
      _$ReceivableImpl.fromJson;

  @override
  String get id;
  @override
  String get personName;
  @override
  double get amount;
  @override
  String? get notes;
  @override
  int get isArchived;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get syncStatus;

  /// Create a copy of Receivable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceivableImplCopyWith<_$ReceivableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
