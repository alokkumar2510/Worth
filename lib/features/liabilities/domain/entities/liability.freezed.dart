// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'liability.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Liability _$LiabilityFromJson(Map<String, dynamic> json) {
  return _Liability.fromJson(json);
}

/// @nodoc
mixin _$Liability {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // credit_card | personal_loan | mortgage | other
  double get outstandingAmount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int get isArchived => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this Liability to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Liability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiabilityCopyWith<Liability> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiabilityCopyWith<$Res> {
  factory $LiabilityCopyWith(Liability value, $Res Function(Liability) then) =
      _$LiabilityCopyWithImpl<$Res, Liability>;
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      double outstandingAmount,
      String? notes,
      int isArchived,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class _$LiabilityCopyWithImpl<$Res, $Val extends Liability>
    implements $LiabilityCopyWith<$Res> {
  _$LiabilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Liability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? outstandingAmount = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      outstandingAmount: null == outstandingAmount
          ? _value.outstandingAmount
          : outstandingAmount // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LiabilityImplCopyWith<$Res>
    implements $LiabilityCopyWith<$Res> {
  factory _$$LiabilityImplCopyWith(
          _$LiabilityImpl value, $Res Function(_$LiabilityImpl) then) =
      __$$LiabilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String type,
      double outstandingAmount,
      String? notes,
      int isArchived,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class __$$LiabilityImplCopyWithImpl<$Res>
    extends _$LiabilityCopyWithImpl<$Res, _$LiabilityImpl>
    implements _$$LiabilityImplCopyWith<$Res> {
  __$$LiabilityImplCopyWithImpl(
      _$LiabilityImpl _value, $Res Function(_$LiabilityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Liability
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? outstandingAmount = null,
    Object? notes = freezed,
    Object? isArchived = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$LiabilityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      outstandingAmount: null == outstandingAmount
          ? _value.outstandingAmount
          : outstandingAmount // ignore: cast_nullable_to_non_nullable
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
class _$LiabilityImpl implements _Liability {
  const _$LiabilityImpl(
      {required this.id,
      required this.name,
      required this.type,
      required this.outstandingAmount,
      this.notes,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt,
      this.syncStatus = 'pending'});

  factory _$LiabilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiabilityImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
// credit_card | personal_loan | mortgage | other
  @override
  final double outstandingAmount;
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
    return 'Liability(id: $id, name: $name, type: $type, outstandingAmount: $outstandingAmount, notes: $notes, isArchived: $isArchived, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiabilityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.outstandingAmount, outstandingAmount) ||
                other.outstandingAmount == outstandingAmount) &&
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
  int get hashCode => Object.hash(runtimeType, id, name, type,
      outstandingAmount, notes, isArchived, createdAt, updatedAt, syncStatus);

  /// Create a copy of Liability
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiabilityImplCopyWith<_$LiabilityImpl> get copyWith =>
      __$$LiabilityImplCopyWithImpl<_$LiabilityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiabilityImplToJson(
      this,
    );
  }
}

abstract class _Liability implements Liability {
  const factory _Liability(
      {required final String id,
      required final String name,
      required final String type,
      required final double outstandingAmount,
      final String? notes,
      required final int isArchived,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String syncStatus}) = _$LiabilityImpl;

  factory _Liability.fromJson(Map<String, dynamic> json) =
      _$LiabilityImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type; // credit_card | personal_loan | mortgage | other
  @override
  double get outstandingAmount;
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

  /// Create a copy of Liability
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiabilityImplCopyWith<_$LiabilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
