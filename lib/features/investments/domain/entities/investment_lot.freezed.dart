// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'investment_lot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InvestmentLot _$InvestmentLotFromJson(Map<String, dynamic> json) {
  return _InvestmentLot.fromJson(json);
}

/// @nodoc
mixin _$InvestmentLot {
  String get id => throw _privateConstructorUsedError;
  String get investmentId => throw _privateConstructorUsedError;
  String get buyTransactionId => throw _privateConstructorUsedError;
  double get unitsPurchased => throw _privateConstructorUsedError;
  double get unitsRemaining => throw _privateConstructorUsedError;
  double get costPerUnit => throw _privateConstructorUsedError;
  DateTime get purchaseDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;

  /// Serializes this InvestmentLot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvestmentLot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvestmentLotCopyWith<InvestmentLot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvestmentLotCopyWith<$Res> {
  factory $InvestmentLotCopyWith(
          InvestmentLot value, $Res Function(InvestmentLot) then) =
      _$InvestmentLotCopyWithImpl<$Res, InvestmentLot>;
  @useResult
  $Res call(
      {String id,
      String investmentId,
      String buyTransactionId,
      double unitsPurchased,
      double unitsRemaining,
      double costPerUnit,
      DateTime purchaseDate,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class _$InvestmentLotCopyWithImpl<$Res, $Val extends InvestmentLot>
    implements $InvestmentLotCopyWith<$Res> {
  _$InvestmentLotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvestmentLot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? investmentId = null,
    Object? buyTransactionId = null,
    Object? unitsPurchased = null,
    Object? unitsRemaining = null,
    Object? costPerUnit = null,
    Object? purchaseDate = null,
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
      buyTransactionId: null == buyTransactionId
          ? _value.buyTransactionId
          : buyTransactionId // ignore: cast_nullable_to_non_nullable
              as String,
      unitsPurchased: null == unitsPurchased
          ? _value.unitsPurchased
          : unitsPurchased // ignore: cast_nullable_to_non_nullable
              as double,
      unitsRemaining: null == unitsRemaining
          ? _value.unitsRemaining
          : unitsRemaining // ignore: cast_nullable_to_non_nullable
              as double,
      costPerUnit: null == costPerUnit
          ? _value.costPerUnit
          : costPerUnit // ignore: cast_nullable_to_non_nullable
              as double,
      purchaseDate: null == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
abstract class _$$InvestmentLotImplCopyWith<$Res>
    implements $InvestmentLotCopyWith<$Res> {
  factory _$$InvestmentLotImplCopyWith(
          _$InvestmentLotImpl value, $Res Function(_$InvestmentLotImpl) then) =
      __$$InvestmentLotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String investmentId,
      String buyTransactionId,
      double unitsPurchased,
      double unitsRemaining,
      double costPerUnit,
      DateTime purchaseDate,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus});
}

/// @nodoc
class __$$InvestmentLotImplCopyWithImpl<$Res>
    extends _$InvestmentLotCopyWithImpl<$Res, _$InvestmentLotImpl>
    implements _$$InvestmentLotImplCopyWith<$Res> {
  __$$InvestmentLotImplCopyWithImpl(
      _$InvestmentLotImpl _value, $Res Function(_$InvestmentLotImpl) _then)
      : super(_value, _then);

  /// Create a copy of InvestmentLot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? investmentId = null,
    Object? buyTransactionId = null,
    Object? unitsPurchased = null,
    Object? unitsRemaining = null,
    Object? costPerUnit = null,
    Object? purchaseDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
  }) {
    return _then(_$InvestmentLotImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      investmentId: null == investmentId
          ? _value.investmentId
          : investmentId // ignore: cast_nullable_to_non_nullable
              as String,
      buyTransactionId: null == buyTransactionId
          ? _value.buyTransactionId
          : buyTransactionId // ignore: cast_nullable_to_non_nullable
              as String,
      unitsPurchased: null == unitsPurchased
          ? _value.unitsPurchased
          : unitsPurchased // ignore: cast_nullable_to_non_nullable
              as double,
      unitsRemaining: null == unitsRemaining
          ? _value.unitsRemaining
          : unitsRemaining // ignore: cast_nullable_to_non_nullable
              as double,
      costPerUnit: null == costPerUnit
          ? _value.costPerUnit
          : costPerUnit // ignore: cast_nullable_to_non_nullable
              as double,
      purchaseDate: null == purchaseDate
          ? _value.purchaseDate
          : purchaseDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
class _$InvestmentLotImpl implements _InvestmentLot {
  const _$InvestmentLotImpl(
      {required this.id,
      required this.investmentId,
      required this.buyTransactionId,
      required this.unitsPurchased,
      required this.unitsRemaining,
      required this.costPerUnit,
      required this.purchaseDate,
      required this.createdAt,
      required this.updatedAt,
      this.syncStatus = 'pending'});

  factory _$InvestmentLotImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvestmentLotImplFromJson(json);

  @override
  final String id;
  @override
  final String investmentId;
  @override
  final String buyTransactionId;
  @override
  final double unitsPurchased;
  @override
  final double unitsRemaining;
  @override
  final double costPerUnit;
  @override
  final DateTime purchaseDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String syncStatus;

  @override
  String toString() {
    return 'InvestmentLot(id: $id, investmentId: $investmentId, buyTransactionId: $buyTransactionId, unitsPurchased: $unitsPurchased, unitsRemaining: $unitsRemaining, costPerUnit: $costPerUnit, purchaseDate: $purchaseDate, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvestmentLotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.investmentId, investmentId) ||
                other.investmentId == investmentId) &&
            (identical(other.buyTransactionId, buyTransactionId) ||
                other.buyTransactionId == buyTransactionId) &&
            (identical(other.unitsPurchased, unitsPurchased) ||
                other.unitsPurchased == unitsPurchased) &&
            (identical(other.unitsRemaining, unitsRemaining) ||
                other.unitsRemaining == unitsRemaining) &&
            (identical(other.costPerUnit, costPerUnit) ||
                other.costPerUnit == costPerUnit) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
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
      buyTransactionId,
      unitsPurchased,
      unitsRemaining,
      costPerUnit,
      purchaseDate,
      createdAt,
      updatedAt,
      syncStatus);

  /// Create a copy of InvestmentLot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvestmentLotImplCopyWith<_$InvestmentLotImpl> get copyWith =>
      __$$InvestmentLotImplCopyWithImpl<_$InvestmentLotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvestmentLotImplToJson(
      this,
    );
  }
}

abstract class _InvestmentLot implements InvestmentLot {
  const factory _InvestmentLot(
      {required final String id,
      required final String investmentId,
      required final String buyTransactionId,
      required final double unitsPurchased,
      required final double unitsRemaining,
      required final double costPerUnit,
      required final DateTime purchaseDate,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String syncStatus}) = _$InvestmentLotImpl;

  factory _InvestmentLot.fromJson(Map<String, dynamic> json) =
      _$InvestmentLotImpl.fromJson;

  @override
  String get id;
  @override
  String get investmentId;
  @override
  String get buyTransactionId;
  @override
  double get unitsPurchased;
  @override
  double get unitsRemaining;
  @override
  double get costPerUnit;
  @override
  DateTime get purchaseDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get syncStatus;

  /// Create a copy of InvestmentLot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvestmentLotImplCopyWith<_$InvestmentLotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
