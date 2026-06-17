import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/snapshot.dart' as domain;
import '../../domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final db.AppDatabase _database;

  ReportRepositoryImpl(this._database);

  domain.Snapshot _toDomain(db.Snapshot entity) {
    return domain.Snapshot(
      id: entity.id,
      snapshotDate: entity.snapshotDate,
      netWorth: entity.netWorth,
      assets: entity.assets,
      liabilities: entity.liabilities,
      receivables: entity.receivables,
      investedCapital: entity.investedCapital,
      expectedIncome: entity.expectedIncome,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  db.SnapshotsCompanion _toCompanion(domain.Snapshot entity) {
    return db.SnapshotsCompanion(
      id: Value(entity.id),
      snapshotDate: Value(entity.snapshotDate),
      netWorth: Value(entity.netWorth),
      assets: Value(entity.assets),
      liabilities: Value(entity.liabilities),
      receivables: Value(entity.receivables),
      investedCapital: Value(entity.investedCapital),
      expectedIncome: Value(entity.expectedIncome),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncStatus: Value(entity.syncStatus),
    );
  }

  @override
  Stream<List<domain.Snapshot>> watchAllSnapshots() {
    return (_database.select(_database.snapshots)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.snapshotDate, mode: OrderingMode.desc)]))
        .watch()
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<domain.Snapshot>> getAllSnapshots() async {
    final list = await (_database.select(_database.snapshots)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.snapshotDate, mode: OrderingMode.desc)]))
        .get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<domain.Snapshot?> getSnapshotById(String id) async {
    final query = _database.select(_database.snapshots)..where((tbl) => tbl.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> createSnapshot(domain.Snapshot snapshot) async {
    await _database.into(_database.snapshots).insert(_toCompanion(snapshot));
  }

  @override
  Future<void> updateSnapshot(domain.Snapshot snapshot) async {
    final dbSnapshot = db.Snapshot(
      id: snapshot.id,
      snapshotDate: snapshot.snapshotDate,
      netWorth: snapshot.netWorth,
      assets: snapshot.assets,
      liabilities: snapshot.liabilities,
      receivables: snapshot.receivables,
      investedCapital: snapshot.investedCapital,
      expectedIncome: snapshot.expectedIncome,
      createdAt: snapshot.createdAt,
      updatedAt: snapshot.updatedAt,
      syncStatus: snapshot.syncStatus,
    );
    await _database.update(_database.snapshots).replace(dbSnapshot);
  }

  @override
  Future<void> deleteSnapshot(String id) async {
    final query = _database.delete(_database.snapshots)..where((tbl) => tbl.id.equals(id));
    await query.go();
  }

  @override
  Future<Map<String, double>> getAssetAllocation() async {
    final Map<String, double> allocation = {};

    // 1. Account Caches
    final accountsQuery = _database.select(_database.accounts).join([
      innerJoin(
        _database.accountBalanceCaches,
        _database.accountBalanceCaches.accountId.equalsExp(_database.accounts.id),
      ),
    ]);
    final accountRows = await accountsQuery.get();
    for (final row in accountRows) {
      final account = row.readTable(_database.accounts);
      final cache = row.readTable(_database.accountBalanceCaches);
      if (account.type != 'credit' && cache.cashBalance > 0) {
        allocation[account.name] = (allocation[account.name] ?? 0.0) + cache.cashBalance;
      }
    }

    // 2. Investment Caches
    final investmentsQuery = _database.select(_database.investments).join([
      innerJoin(
        _database.investmentBalanceCaches,
        _database.investmentBalanceCaches.investmentId.equalsExp(_database.investments.id),
      ),
    ]);
    final investmentRows = await investmentsQuery.get();
    for (final row in investmentRows) {
      final investment = row.readTable(_database.investments);
      final cache = row.readTable(_database.investmentBalanceCaches);
      final value = (investment.marketValue ?? 0.0) * cache.unitsHeld;
      if (value > 0) {
        allocation[investment.name] = (allocation[investment.name] ?? 0.0) + value;
      }
    }

    return allocation;
  }

  @override
  Future<Map<String, double>> getLiabilityAllocation() async {
    final Map<String, double> allocation = {};

    // 1. Credit Card Accounts
    final creditQuery = _database.select(_database.accounts).join([
      innerJoin(
        _database.accountBalanceCaches,
        _database.accountBalanceCaches.accountId.equalsExp(_database.accounts.id),
      ),
    ]);
    final creditRows = await creditQuery.get();
    for (final row in creditRows) {
      final account = row.readTable(_database.accounts);
      final cache = row.readTable(_database.accountBalanceCaches);
      if (account.type == 'credit' && cache.liabilityBalance > 0) {
        allocation[account.name] = (allocation[account.name] ?? 0.0) + cache.liabilityBalance;
      }
    }

    // 2. Personal Debts (Debtor People)
    final debtsQuery = _database.select(_database.people).join([
      innerJoin(
        _database.personBalanceCaches,
        _database.personBalanceCaches.personId.equalsExp(_database.people.id),
      ),
    ]);
    final debtRows = await debtsQuery.get();
    for (final row in debtRows) {
      final person = row.readTable(_database.people);
      final cache = row.readTable(_database.personBalanceCaches);
      if (cache.liabilityBalance > 0) {
        allocation[person.name] = (allocation[person.name] ?? 0.0) + cache.liabilityBalance;
      }
    }

    return allocation;
  }
}
