// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String?,
      fromAccountId: json['fromAccountId'] as String?,
      toAccountId: json['toAccountId'] as String?,
      personId: json['personId'] as String?,
      investmentId: json['investmentId'] as String?,
      voidedTransactionId: json['voidedTransactionId'] as String?,
      notes: json['notes'] as String?,
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble(),
      units: (json['units'] as num?)?.toDouble(),
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'category': instance.category,
      'fromAccountId': instance.fromAccountId,
      'toAccountId': instance.toAccountId,
      'personId': instance.personId,
      'investmentId': instance.investmentId,
      'voidedTransactionId': instance.voidedTransactionId,
      'notes': instance.notes,
      'pricePerUnit': instance.pricePerUnit,
      'units': instance.units,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
