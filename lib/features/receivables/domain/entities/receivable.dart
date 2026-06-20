import 'package:freezed_annotation/freezed_annotation.dart';

part 'receivable.freezed.dart';
part 'receivable.g.dart';

@freezed
class Receivable with _$Receivable {
  const factory Receivable({
    required String id,
    required String personName,
    required double amount,
    String? phone,
    String? whatsApp,
    DateTime? borrowDate,
    DateTime? dueDate,
    String? upiId,
    String? bankName,
    String? accountHolderName,
    String? notes,
    required int isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('pending') String syncStatus,
  }) = _Receivable;

  factory Receivable.fromJson(Map<String, dynamic> json) => _$ReceivableFromJson(json);
}
