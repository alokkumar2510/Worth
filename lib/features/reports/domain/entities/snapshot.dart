import 'package:freezed_annotation/freezed_annotation.dart';

part 'snapshot.freezed.dart';
part 'snapshot.g.dart';

@freezed
class Snapshot with _$Snapshot {
  const factory Snapshot({
    required String id,
    required DateTime snapshotDate,
    required double netWorth,
    required double assets,
    required double liabilities,
    required double receivables,
    required double investedCapital,
    required double expectedIncome,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default('pending') String syncStatus,
  }) = _Snapshot;

  factory Snapshot.fromJson(Map<String, dynamic> json) => _$SnapshotFromJson(json);
}
