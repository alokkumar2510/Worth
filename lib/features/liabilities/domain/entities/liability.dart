import 'package:freezed_annotation/freezed_annotation.dart';

part 'liability.freezed.dart';
part 'liability.g.dart';

@freezed
class Liability with _$Liability {
  const factory Liability({
    required String id,
    required String name,
    required String type, // credit_card | personal_loan | mortgage | other
    required double outstandingAmount,
    String? notes,
    required int isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('pending') String syncStatus,
  }) = _Liability;

  factory Liability.fromJson(Map<String, dynamic> json) => _$LiabilityFromJson(json);
}
