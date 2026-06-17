// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liability.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiabilityImpl _$$LiabilityImplFromJson(Map<String, dynamic> json) =>
    _$LiabilityImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      outstandingAmount: (json['outstandingAmount'] as num).toDouble(),
      notes: json['notes'] as String?,
      isArchived: (json['isArchived'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$LiabilityImplToJson(_$LiabilityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'outstandingAmount': instance.outstandingAmount,
      'notes': instance.notes,
      'isArchived': instance.isArchived,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
