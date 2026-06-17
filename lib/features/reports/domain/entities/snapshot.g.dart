// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SnapshotImpl _$$SnapshotImplFromJson(Map<String, dynamic> json) =>
    _$SnapshotImpl(
      id: json['id'] as String,
      snapshotDate: DateTime.parse(json['snapshotDate'] as String),
      netWorth: (json['netWorth'] as num).toDouble(),
      assets: (json['assets'] as num).toDouble(),
      liabilities: (json['liabilities'] as num).toDouble(),
      receivables: (json['receivables'] as num).toDouble(),
      investedCapital: (json['investedCapital'] as num).toDouble(),
      expectedIncome: (json['expectedIncome'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$SnapshotImplToJson(_$SnapshotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'snapshotDate': instance.snapshotDate.toIso8601String(),
      'netWorth': instance.netWorth,
      'assets': instance.assets,
      'liabilities': instance.liabilities,
      'receivables': instance.receivables,
      'investedCapital': instance.investedCapital,
      'expectedIncome': instance.expectedIncome,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
