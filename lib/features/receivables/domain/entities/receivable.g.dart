// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receivable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceivableImpl _$$ReceivableImplFromJson(Map<String, dynamic> json) =>
    _$ReceivableImpl(
      id: json['id'] as String,
      personName: json['personName'] as String,
      amount: (json['amount'] as num).toDouble(),
      phone: json['phone'] as String?,
      whatsApp: json['whatsApp'] as String?,
      borrowDate: json['borrowDate'] == null
          ? null
          : DateTime.parse(json['borrowDate'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      upiId: json['upiId'] as String?,
      bankName: json['bankName'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      notes: json['notes'] as String?,
      isArchived: (json['isArchived'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: json['syncStatus'] as String? ?? 'pending',
    );

Map<String, dynamic> _$$ReceivableImplToJson(_$ReceivableImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'personName': instance.personName,
      'amount': instance.amount,
      'phone': instance.phone,
      'whatsApp': instance.whatsApp,
      'borrowDate': instance.borrowDate?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'upiId': instance.upiId,
      'bankName': instance.bankName,
      'accountHolderName': instance.accountHolderName,
      'notes': instance.notes,
      'isArchived': instance.isArchived,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': instance.syncStatus,
    };
