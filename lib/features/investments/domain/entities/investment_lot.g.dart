// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_lot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestmentLotImpl _$$InvestmentLotImplFromJson(Map<String, dynamic> json) =>
    _$InvestmentLotImpl(
      id: json['id'] as String,
      investmentId: json['investmentId'] as String,
      buyTransactionId: json['buyTransactionId'] as String,
      unitsPurchased: (json['unitsPurchased'] as num).toDouble(),
      unitsRemaining: (json['unitsRemaining'] as num).toDouble(),
      costPerUnit: (json['costPerUnit'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$InvestmentLotImplToJson(_$InvestmentLotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'investmentId': instance.investmentId,
      'buyTransactionId': instance.buyTransactionId,
      'unitsPurchased': instance.unitsPurchased,
      'unitsRemaining': instance.unitsRemaining,
      'costPerUnit': instance.costPerUnit,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
