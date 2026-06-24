// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get id => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // income | expense | transfer | borrow_money | repay_money | lend_money | recover_money | investment_buy | investment_sell | expected_income_received | interest_accrued | void
  double get amount => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get fromAccountId => throw _privateConstructorUsedError;
  String? get toAccountId => throw _privateConstructorUsedError;
  String? get personId => throw _privateConstructorUsedError;
  String? get investmentId => throw _privateConstructorUsedError;
  String? get voidedTransactionId => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double? get pricePerUnit => throw _privateConstructorUsedError;
  double? get units => throw _privateConstructorUsedError;
  DateTime get transactionDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get syncStatus => throw _privateConstructorUsedError;
  String? get fundingSource => throw _privateConstructorUsedError;
  String? get fundingLiabilityId => throw _privateConstructorUsedError;
  String? get fundingDetails => throw _privateConstructorUsedError;
  String? get transactionUuid => throw _privateConstructorUsedError;
  String? get operationUuid => throw _privateConstructorUsedError;
  String? get sourceRecordId => throw _privateConstructorUsedError;
  String? get fundSource => throw _privateConstructorUsedError;
  String? get sourceAccount => throw _privateConstructorUsedError;
  String? get ownershipType => throw _privateConstructorUsedError;
  String? get liabilityType => throw _privateConstructorUsedError;
  String? get transactionCategory => throw _privateConstructorUsedError;
  String? get sipId => throw _privateConstructorUsedError;
  int? get executionMonth => throw _privateConstructorUsedError;
  int? get executionYear => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String id,
      String type,
      double amount,
      String? category,
      String? fromAccountId,
      String? toAccountId,
      String? personId,
      String? investmentId,
      String? voidedTransactionId,
      String? notes,
      double? pricePerUnit,
      double? units,
      DateTime transactionDate,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus,
      String? fundingSource,
      String? fundingLiabilityId,
      String? fundingDetails,
      String? transactionUuid,
      String? operationUuid,
      String? sourceRecordId,
      String? fundSource,
      String? sourceAccount,
      String? ownershipType,
      String? liabilityType,
      String? transactionCategory,
      String? sipId,
      int? executionMonth,
      int? executionYear});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? category = freezed,
    Object? fromAccountId = freezed,
    Object? toAccountId = freezed,
    Object? personId = freezed,
    Object? investmentId = freezed,
    Object? voidedTransactionId = freezed,
    Object? notes = freezed,
    Object? pricePerUnit = freezed,
    Object? units = freezed,
    Object? transactionDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
    Object? fundingSource = freezed,
    Object? fundingLiabilityId = freezed,
    Object? fundingDetails = freezed,
    Object? transactionUuid = freezed,
    Object? operationUuid = freezed,
    Object? sourceRecordId = freezed,
    Object? fundSource = freezed,
    Object? sourceAccount = freezed,
    Object? ownershipType = freezed,
    Object? liabilityType = freezed,
    Object? transactionCategory = freezed,
    Object? sipId = freezed,
    Object? executionMonth = freezed,
    Object? executionYear = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      fromAccountId: freezed == fromAccountId
          ? _value.fromAccountId
          : fromAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      toAccountId: freezed == toAccountId
          ? _value.toAccountId
          : toAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      personId: freezed == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String?,
      investmentId: freezed == investmentId
          ? _value.investmentId
          : investmentId // ignore: cast_nullable_to_non_nullable
              as String?,
      voidedTransactionId: freezed == voidedTransactionId
          ? _value.voidedTransactionId
          : voidedTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      pricePerUnit: freezed == pricePerUnit
          ? _value.pricePerUnit
          : pricePerUnit // ignore: cast_nullable_to_non_nullable
              as double?,
      units: freezed == units
          ? _value.units
          : units // ignore: cast_nullable_to_non_nullable
              as double?,
      transactionDate: null == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
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
      fundingSource: freezed == fundingSource
          ? _value.fundingSource
          : fundingSource // ignore: cast_nullable_to_non_nullable
              as String?,
      fundingLiabilityId: freezed == fundingLiabilityId
          ? _value.fundingLiabilityId
          : fundingLiabilityId // ignore: cast_nullable_to_non_nullable
              as String?,
      fundingDetails: freezed == fundingDetails
          ? _value.fundingDetails
          : fundingDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionUuid: freezed == transactionUuid
          ? _value.transactionUuid
          : transactionUuid // ignore: cast_nullable_to_non_nullable
              as String?,
      operationUuid: freezed == operationUuid
          ? _value.operationUuid
          : operationUuid // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceRecordId: freezed == sourceRecordId
          ? _value.sourceRecordId
          : sourceRecordId // ignore: cast_nullable_to_non_nullable
              as String?,
      fundSource: freezed == fundSource
          ? _value.fundSource
          : fundSource // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceAccount: freezed == sourceAccount
          ? _value.sourceAccount
          : sourceAccount // ignore: cast_nullable_to_non_nullable
              as String?,
      ownershipType: freezed == ownershipType
          ? _value.ownershipType
          : ownershipType // ignore: cast_nullable_to_non_nullable
              as String?,
      liabilityType: freezed == liabilityType
          ? _value.liabilityType
          : liabilityType // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionCategory: freezed == transactionCategory
          ? _value.transactionCategory
          : transactionCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      sipId: freezed == sipId
          ? _value.sipId
          : sipId // ignore: cast_nullable_to_non_nullable
              as String?,
      executionMonth: freezed == executionMonth
          ? _value.executionMonth
          : executionMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      executionYear: freezed == executionYear
          ? _value.executionYear
          : executionYear // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      double amount,
      String? category,
      String? fromAccountId,
      String? toAccountId,
      String? personId,
      String? investmentId,
      String? voidedTransactionId,
      String? notes,
      double? pricePerUnit,
      double? units,
      DateTime transactionDate,
      DateTime createdAt,
      DateTime updatedAt,
      String syncStatus,
      String? fundingSource,
      String? fundingLiabilityId,
      String? fundingDetails,
      String? transactionUuid,
      String? operationUuid,
      String? sourceRecordId,
      String? fundSource,
      String? sourceAccount,
      String? ownershipType,
      String? liabilityType,
      String? transactionCategory,
      String? sipId,
      int? executionMonth,
      int? executionYear});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? amount = null,
    Object? category = freezed,
    Object? fromAccountId = freezed,
    Object? toAccountId = freezed,
    Object? personId = freezed,
    Object? investmentId = freezed,
    Object? voidedTransactionId = freezed,
    Object? notes = freezed,
    Object? pricePerUnit = freezed,
    Object? units = freezed,
    Object? transactionDate = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? syncStatus = null,
    Object? fundingSource = freezed,
    Object? fundingLiabilityId = freezed,
    Object? fundingDetails = freezed,
    Object? transactionUuid = freezed,
    Object? operationUuid = freezed,
    Object? sourceRecordId = freezed,
    Object? fundSource = freezed,
    Object? sourceAccount = freezed,
    Object? ownershipType = freezed,
    Object? liabilityType = freezed,
    Object? transactionCategory = freezed,
    Object? sipId = freezed,
    Object? executionMonth = freezed,
    Object? executionYear = freezed,
  }) {
    return _then(_$TransactionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      fromAccountId: freezed == fromAccountId
          ? _value.fromAccountId
          : fromAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      toAccountId: freezed == toAccountId
          ? _value.toAccountId
          : toAccountId // ignore: cast_nullable_to_non_nullable
              as String?,
      personId: freezed == personId
          ? _value.personId
          : personId // ignore: cast_nullable_to_non_nullable
              as String?,
      investmentId: freezed == investmentId
          ? _value.investmentId
          : investmentId // ignore: cast_nullable_to_non_nullable
              as String?,
      voidedTransactionId: freezed == voidedTransactionId
          ? _value.voidedTransactionId
          : voidedTransactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      pricePerUnit: freezed == pricePerUnit
          ? _value.pricePerUnit
          : pricePerUnit // ignore: cast_nullable_to_non_nullable
              as double?,
      units: freezed == units
          ? _value.units
          : units // ignore: cast_nullable_to_non_nullable
              as double?,
      transactionDate: null == transactionDate
          ? _value.transactionDate
          : transactionDate // ignore: cast_nullable_to_non_nullable
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
      fundingSource: freezed == fundingSource
          ? _value.fundingSource
          : fundingSource // ignore: cast_nullable_to_non_nullable
              as String?,
      fundingLiabilityId: freezed == fundingLiabilityId
          ? _value.fundingLiabilityId
          : fundingLiabilityId // ignore: cast_nullable_to_non_nullable
              as String?,
      fundingDetails: freezed == fundingDetails
          ? _value.fundingDetails
          : fundingDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionUuid: freezed == transactionUuid
          ? _value.transactionUuid
          : transactionUuid // ignore: cast_nullable_to_non_nullable
              as String?,
      operationUuid: freezed == operationUuid
          ? _value.operationUuid
          : operationUuid // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceRecordId: freezed == sourceRecordId
          ? _value.sourceRecordId
          : sourceRecordId // ignore: cast_nullable_to_non_nullable
              as String?,
      fundSource: freezed == fundSource
          ? _value.fundSource
          : fundSource // ignore: cast_nullable_to_non_nullable
              as String?,
      sourceAccount: freezed == sourceAccount
          ? _value.sourceAccount
          : sourceAccount // ignore: cast_nullable_to_non_nullable
              as String?,
      ownershipType: freezed == ownershipType
          ? _value.ownershipType
          : ownershipType // ignore: cast_nullable_to_non_nullable
              as String?,
      liabilityType: freezed == liabilityType
          ? _value.liabilityType
          : liabilityType // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionCategory: freezed == transactionCategory
          ? _value.transactionCategory
          : transactionCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      sipId: freezed == sipId
          ? _value.sipId
          : sipId // ignore: cast_nullable_to_non_nullable
              as String?,
      executionMonth: freezed == executionMonth
          ? _value.executionMonth
          : executionMonth // ignore: cast_nullable_to_non_nullable
              as int?,
      executionYear: freezed == executionYear
          ? _value.executionYear
          : executionYear // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.id,
      required this.type,
      required this.amount,
      this.category,
      this.fromAccountId,
      this.toAccountId,
      this.personId,
      this.investmentId,
      this.voidedTransactionId,
      this.notes,
      this.pricePerUnit,
      this.units,
      required this.transactionDate,
      required this.createdAt,
      required this.updatedAt,
      this.syncStatus = 'pending',
      this.fundingSource,
      this.fundingLiabilityId,
      this.fundingDetails,
      this.transactionUuid,
      this.operationUuid,
      this.sourceRecordId,
      this.fundSource,
      this.sourceAccount,
      this.ownershipType,
      this.liabilityType,
      this.transactionCategory,
      this.sipId,
      this.executionMonth,
      this.executionYear});

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
// income | expense | transfer | borrow_money | repay_money | lend_money | recover_money | investment_buy | investment_sell | expected_income_received | interest_accrued | void
  @override
  final double amount;
  @override
  final String? category;
  @override
  final String? fromAccountId;
  @override
  final String? toAccountId;
  @override
  final String? personId;
  @override
  final String? investmentId;
  @override
  final String? voidedTransactionId;
  @override
  final String? notes;
  @override
  final double? pricePerUnit;
  @override
  final double? units;
  @override
  final DateTime transactionDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final String syncStatus;
  @override
  final String? fundingSource;
  @override
  final String? fundingLiabilityId;
  @override
  final String? fundingDetails;
  @override
  final String? transactionUuid;
  @override
  final String? operationUuid;
  @override
  final String? sourceRecordId;
  @override
  final String? fundSource;
  @override
  final String? sourceAccount;
  @override
  final String? ownershipType;
  @override
  final String? liabilityType;
  @override
  final String? transactionCategory;
  @override
  final String? sipId;
  @override
  final int? executionMonth;
  @override
  final int? executionYear;

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, category: $category, fromAccountId: $fromAccountId, toAccountId: $toAccountId, personId: $personId, investmentId: $investmentId, voidedTransactionId: $voidedTransactionId, notes: $notes, pricePerUnit: $pricePerUnit, units: $units, transactionDate: $transactionDate, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus, fundingSource: $fundingSource, fundingLiabilityId: $fundingLiabilityId, fundingDetails: $fundingDetails, transactionUuid: $transactionUuid, operationUuid: $operationUuid, sourceRecordId: $sourceRecordId, fundSource: $fundSource, sourceAccount: $sourceAccount, ownershipType: $ownershipType, liabilityType: $liabilityType, transactionCategory: $transactionCategory, sipId: $sipId, executionMonth: $executionMonth, executionYear: $executionYear)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.fromAccountId, fromAccountId) ||
                other.fromAccountId == fromAccountId) &&
            (identical(other.toAccountId, toAccountId) ||
                other.toAccountId == toAccountId) &&
            (identical(other.personId, personId) ||
                other.personId == personId) &&
            (identical(other.investmentId, investmentId) ||
                other.investmentId == investmentId) &&
            (identical(other.voidedTransactionId, voidedTransactionId) ||
                other.voidedTransactionId == voidedTransactionId) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.pricePerUnit, pricePerUnit) ||
                other.pricePerUnit == pricePerUnit) &&
            (identical(other.units, units) || other.units == units) &&
            (identical(other.transactionDate, transactionDate) ||
                other.transactionDate == transactionDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.fundingSource, fundingSource) ||
                other.fundingSource == fundingSource) &&
            (identical(other.fundingLiabilityId, fundingLiabilityId) ||
                other.fundingLiabilityId == fundingLiabilityId) &&
            (identical(other.fundingDetails, fundingDetails) ||
                other.fundingDetails == fundingDetails) &&
            (identical(other.transactionUuid, transactionUuid) ||
                other.transactionUuid == transactionUuid) &&
            (identical(other.operationUuid, operationUuid) ||
                other.operationUuid == operationUuid) &&
            (identical(other.sourceRecordId, sourceRecordId) ||
                other.sourceRecordId == sourceRecordId) &&
            (identical(other.fundSource, fundSource) ||
                other.fundSource == fundSource) &&
            (identical(other.sourceAccount, sourceAccount) ||
                other.sourceAccount == sourceAccount) &&
            (identical(other.ownershipType, ownershipType) ||
                other.ownershipType == ownershipType) &&
            (identical(other.liabilityType, liabilityType) ||
                other.liabilityType == liabilityType) &&
            (identical(other.transactionCategory, transactionCategory) ||
                other.transactionCategory == transactionCategory) &&
            (identical(other.sipId, sipId) || other.sipId == sipId) &&
            (identical(other.executionMonth, executionMonth) ||
                other.executionMonth == executionMonth) &&
            (identical(other.executionYear, executionYear) ||
                other.executionYear == executionYear));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        type,
        amount,
        category,
        fromAccountId,
        toAccountId,
        personId,
        investmentId,
        voidedTransactionId,
        notes,
        pricePerUnit,
        units,
        transactionDate,
        createdAt,
        updatedAt,
        syncStatus,
        fundingSource,
        fundingLiabilityId,
        fundingDetails,
        transactionUuid,
        operationUuid,
        sourceRecordId,
        fundSource,
        sourceAccount,
        ownershipType,
        liabilityType,
        transactionCategory,
        sipId,
        executionMonth,
        executionYear
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String id,
      required final String type,
      required final double amount,
      final String? category,
      final String? fromAccountId,
      final String? toAccountId,
      final String? personId,
      final String? investmentId,
      final String? voidedTransactionId,
      final String? notes,
      final double? pricePerUnit,
      final double? units,
      required final DateTime transactionDate,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String syncStatus,
      final String? fundingSource,
      final String? fundingLiabilityId,
      final String? fundingDetails,
      final String? transactionUuid,
      final String? operationUuid,
      final String? sourceRecordId,
      final String? fundSource,
      final String? sourceAccount,
      final String? ownershipType,
      final String? liabilityType,
      final String? transactionCategory,
      final String? sipId,
      final int? executionMonth,
      final int? executionYear}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override // income | expense | transfer | borrow_money | repay_money | lend_money | recover_money | investment_buy | investment_sell | expected_income_received | interest_accrued | void
  double get amount;
  @override
  String? get category;
  @override
  String? get fromAccountId;
  @override
  String? get toAccountId;
  @override
  String? get personId;
  @override
  String? get investmentId;
  @override
  String? get voidedTransactionId;
  @override
  String? get notes;
  @override
  double? get pricePerUnit;
  @override
  double? get units;
  @override
  DateTime get transactionDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get syncStatus;
  @override
  String? get fundingSource;
  @override
  String? get fundingLiabilityId;
  @override
  String? get fundingDetails;
  @override
  String? get transactionUuid;
  @override
  String? get operationUuid;
  @override
  String? get sourceRecordId;
  @override
  String? get fundSource;
  @override
  String? get sourceAccount;
  @override
  String? get ownershipType;
  @override
  String? get liabilityType;
  @override
  String? get transactionCategory;
  @override
  String? get sipId;
  @override
  int? get executionMonth;
  @override
  int? get executionYear;
  @override
  @JsonKey(ignore: true)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
