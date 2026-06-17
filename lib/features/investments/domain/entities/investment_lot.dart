import 'package:freezed_annotation/freezed_annotation.dart';

part 'investment_lot.freezed.dart';
part 'investment_lot.g.dart';

@freezed
class InvestmentLot with _$InvestmentLot {
  const factory InvestmentLot({
    required String id,
    required String investmentId,
    required String buyTransactionId,
    required double unitsPurchased,
    required double unitsRemaining,
    required double costPerUnit,
    required DateTime purchaseDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('pending') String syncStatus,
  }) = _InvestmentLot;

  factory InvestmentLot.fromJson(Map<String, dynamic> json) => _$InvestmentLotFromJson(json);
}
