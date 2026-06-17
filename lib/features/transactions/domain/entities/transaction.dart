import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String type, // income | expense | transfer | borrow_money | repay_money | lend_money | recover_money | investment_buy | investment_sell | expected_income_received | interest_accrued | void
    required double amount,
    String? category,
    String? fromAccountId,
    String? toAccountId,
    String? personId,
    String? investmentId,
    String? voidedTransactionId,
    String? notes,
    double? pricePerUnit,
    double? units,
    required DateTime transactionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('pending') String syncStatus,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
