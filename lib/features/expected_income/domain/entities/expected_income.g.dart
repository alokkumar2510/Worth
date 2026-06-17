// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expected_income.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpectedIncomeImpl _$$ExpectedIncomeImplFromJson(Map<String, dynamic> json) =>
    _$ExpectedIncomeImpl(
      id: json['id'] as String,
      source: json['source'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      expectedDate: json['expectedDate'] == null
          ? null
          : DateTime.parse(json['expectedDate'] as String),
      receivedTransactionId: json['receivedTransactionId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$ExpectedIncomeImplToJson(
        _$ExpectedIncomeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'source': instance.source,
      'amount': instance.amount,
      'status': instance.status,
      'expectedDate': instance.expectedDate?.toIso8601String(),
      'receivedTransactionId': instance.receivedTransactionId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
