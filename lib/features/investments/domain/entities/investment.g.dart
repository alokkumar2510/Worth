// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvestmentImpl _$$InvestmentImplFromJson(Map<String, dynamic> json) =>
    _$InvestmentImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      symbol: json['symbol'] as String?,
      marketValue: (json['marketValue'] as num?)?.toDouble(),
      marketValueUpdatedAt: json['marketValueUpdatedAt'] == null
          ? null
          : DateTime.parse(json['marketValueUpdatedAt'] as String),
      isArchived: (json['isArchived'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$InvestmentImplToJson(_$InvestmentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'symbol': instance.symbol,
      'marketValue': instance.marketValue,
      'marketValueUpdatedAt': instance.marketValueUpdatedAt?.toIso8601String(),
      'isArchived': instance.isArchived,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
