import 'package:drift/drift.dart';
import '../database.dart';

class SnapshotRepository {
  final AppDatabase _db;
  SnapshotRepository(this._db);

  Stream<List<Snapshot>> watchAllSnapshots() {
    return (_db.select(_db.snapshots)..orderBy([(tbl) => OrderingTerm(expression: tbl.snapshotDate, mode: OrderingMode.asc)])).watch();
  }

  Future<List<Snapshot>> getAllSnapshots() {
    return (_db.select(_db.snapshots)..orderBy([(tbl) => OrderingTerm(expression: tbl.snapshotDate, mode: OrderingMode.asc)])).get();
  }

  Future<Snapshot?> getSnapshotForDate(DateTime date) {
    // Return snapshot for a specific year and month
    return (_db.select(_db.snapshots)
          ..where((tbl) => tbl.snapshotDate.year.equals(date.year) & tbl.snapshotDate.month.equals(date.month)))
        .getSingleOrNull();
  }

  Future<void> insertSnapshot(SnapshotsCompanion companion) {
    return _db.into(_db.snapshots).insert(companion);
  }
}
