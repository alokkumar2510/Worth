// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SipImpl _$$SipImplFromJson(Map<String, dynamic> json) => _$SipImpl(
      id: json['id'] as String,
      investmentId: json['investmentId'] as String,
      amount: (json['amount'] as num).toDouble(),
      frequency: json['frequency'] as String,
      sipDate: (json['sipDate'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      autoCreate: (json['autoCreate'] as num).toInt(),
      isActive: (json['isActive'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$SipImplToJson(_$SipImpl instance) => <String, dynamic>{
      'id': instance.id,
      'investmentId': instance.investmentId,
      'amount': instance.amount,
      'frequency': instance.frequency,
      'sipDate': instance.sipDate,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'autoCreate': instance.autoCreate,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
