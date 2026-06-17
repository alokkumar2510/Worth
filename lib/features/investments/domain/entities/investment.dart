import 'package:freezed_annotation/freezed_annotation.dart';

part 'investment.freezed.dart';
part 'investment.g.dart';

@freezed
class Investment with _$Investment {
  const factory Investment({
    required String id,
    required String name,
    required String type, // stock | mutual_fund | etf | gold | crypto | bond | fd | other
    String? symbol,
    double? marketValue,
    DateTime? marketValueUpdatedAt,
    required int isArchived,
    String? notes,
    DateTime? purchaseDate,
    String? purchaseTime,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('pending') String syncStatus,
  }) = _Investment;

  factory Investment.fromJson(Map<String, dynamic> json) => _$InvestmentFromJson(json);
}
