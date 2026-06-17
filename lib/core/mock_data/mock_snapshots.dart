import 'package:uuid/uuid.dart';
import '../../database/database.dart';

List<Snapshot> getMockSnapshots(DateTime now) {
  final uuid = const Uuid();
  final snapshots = <Snapshot>[];
  
  // 5 months ago
  final m5 = DateTime(now.year, now.month - 4, 0);
  snapshots.add(Snapshot(
    id: uuid.v4(),
    snapshotDate: m5,
    netWorth: 120000,
    assets: 135000,
    liabilities: 15000,
    receivables: 5000,
    investedCapital: 40000,
    expectedIncome: 10000,
    createdAt: m5.toUtc(),
    updatedAt: m5.toUtc(),
    syncStatus: 'synced',
  ));

  // 4 months ago
  final m4 = DateTime(now.year, now.month - 3, 0);
  snapshots.add(Snapshot(
    id: uuid.v4(),
    snapshotDate: m4,
    netWorth: 135000,
    assets: 155000,
    liabilities: 20000,
    receivables: 8000,
    investedCapital: 48000,
    expectedIncome: 12000,
    createdAt: m4.toUtc(),
    updatedAt: m4.toUtc(),
    syncStatus: 'synced',
  ));

  // 3 months ago
  final m3 = DateTime(now.year, now.month - 2, 0);
  snapshots.add(Snapshot(
    id: uuid.v4(),
    snapshotDate: m3,
    netWorth: 155000,
    assets: 173000,
    liabilities: 18000,
    receivables: 10000,
    investedCapital: 60000,
    expectedIncome: 8000,
    createdAt: m3.toUtc(),
    updatedAt: m3.toUtc(),
    syncStatus: 'synced',
  ));

  // 2 months ago
  final m2 = DateTime(now.year, now.month - 1, 0);
  snapshots.add(Snapshot(
    id: uuid.v4(),
    snapshotDate: m2,
    netWorth: 180000,
    assets: 205000,
    liabilities: 25000,
    receivables: 7000,
    investedCapital: 72000,
    expectedIncome: 15000,
    createdAt: m2.toUtc(),
    updatedAt: m2.toUtc(),
    syncStatus: 'synced',
  ));

  // 1 month ago
  final m1 = DateTime(now.year, now.month, 0);
  snapshots.add(Snapshot(
    id: uuid.v4(),
    snapshotDate: m1,
    netWorth: 210000,
    assets: 235000,
    liabilities: 25000,
    receivables: 10000,
    investedCapital: 85000,
    expectedIncome: 20000,
    createdAt: m1.toUtc(),
    updatedAt: m1.toUtc(),
    syncStatus: 'synced',
  ));

  return snapshots;
}
