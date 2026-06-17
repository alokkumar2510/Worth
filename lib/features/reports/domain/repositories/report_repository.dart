import '../entities/snapshot.dart';

abstract class ReportRepository {
  Stream<List<Snapshot>> watchAllSnapshots();
  Future<List<Snapshot>> getAllSnapshots();
  Future<Snapshot?> getSnapshotById(String id);
  Future<void> createSnapshot(Snapshot snapshot);
  Future<void> updateSnapshot(Snapshot snapshot);
  Future<void> deleteSnapshot(String id);
  Future<Map<String, double>> getAssetAllocation();
  Future<Map<String, double>> getLiabilityAllocation();
}
