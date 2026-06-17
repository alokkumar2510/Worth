import 'package:freezed_annotation/freezed_annotation.dart';

part 'expected_income.freezed.dart';
part 'expected_income.g.dart';

@freezed
class ExpectedIncome with _$ExpectedIncome {
  const factory ExpectedIncome({
    required String id,
    required String source,
    required double amount,
    required String status, // pending | received | expired
    DateTime? expectedDate,
    String? receivedTransactionId,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('pending') String syncStatus,
  }) = _ExpectedIncome;

  factory ExpectedIncome.fromJson(Map<String, dynamic> json) => _$ExpectedIncomeFromJson(json);
}
