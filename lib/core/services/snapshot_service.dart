import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../providers/dependency_provider.dart';
import '../providers/mock_database.dart';
import '../providers/app_providers.dart';

class SnapshotService {
  final Ref _ref;
  final _uuid = const Uuid();

  SnapshotService(this._ref);

  AppDatabase get _db => _ref.read(realDatabaseProvider);
  bool get _isMock => _ref.read(mockModeProvider);

  // Automatically creates a monthly snapshot based on current financial position
  Future<Snapshot> createSnapshot() async {
    final now = DateTime.now();
    final snapshotDate = DateTime(now.year, now.month, now.day);
    
    double netWorth = 0.0;
    double assets = 0.0;
    double liabilities = 0.0;
    double receivables = 0.0;
    double investedCapital = 0.0;
    double expectedIncome = 0.0;

    if (_isMock) {
      final state = _ref.read(mockDatabaseProvider);
      netWorth = state.netWorth;
      assets = state.totalAssets;
      liabilities = state.totalLiabilities;
      
      // Calculate receivables
      for (final p in state.people) {
        if (p.isArchived == 0) {
          receivables += state.getPersonReceivableBalance(p.id);
        }
      }

      investedCapital = state.totalInvestedCapital;
      expectedIncome = state.totalExpectedIncome;

      final snapshot = Snapshot(
        id: _uuid.v4(),
        snapshotDate: snapshotDate,
        netWorth: netWorth,
        assets: assets,
        liabilities: liabilities,
        receivables: receivables,
        investedCapital: investedCapital,
        expectedIncome: expectedIncome,
        createdAt: now.toUtc(),
        updatedAt: now.toUtc(),
        syncStatus: 'pending',
      );

      final notifier = _ref.read(mockDatabaseProvider.notifier);
      notifier.state = notifier.state.copyWith(
        snapshots: [...notifier.state.snapshots, snapshot],
      );
      return snapshot;
    } else {
      final calc = _ref.read(realFinancialCalculatorServiceProvider);
      netWorth = await calc.calculateNetWorth();
      assets = await calc.calculateAssets();
      liabilities = await calc.calculateLiabilities();
      receivables = await calc.calculateReceivables();
      investedCapital = await calc.calculateInvestmentPrincipal();
      expectedIncome = await calc.calculateExpectedIncome();

      final id = _uuid.v4();
      final companion = SnapshotsCompanion(
        id: Value(id),
        snapshotDate: Value(snapshotDate),
        netWorth: Value(netWorth),
        assets: Value(assets),
        liabilities: Value(liabilities),
        receivables: Value(receivables),
        investedCapital: Value(investedCapital),
        expectedIncome: Value(expectedIncome),
        createdAt: Value(now.toUtc()),
        updatedAt: Value(now.toUtc()),
        syncStatus: const Value('pending'),
      );

      await _db.into(_db.snapshots).insert(companion);
      
      return Snapshot(
        id: id,
        snapshotDate: snapshotDate,
        netWorth: netWorth,
        assets: assets,
        liabilities: liabilities,
        receivables: receivables,
        investedCapital: investedCapital,
        expectedIncome: expectedIncome,
        createdAt: now.toUtc(),
        updatedAt: now.toUtc(),
        syncStatus: 'pending',
      );
    }
  }

  // Retrieves snapshot for a specific month and year
  Future<Snapshot?> getSnapshot(DateTime date) async {
    if (_isMock) {
      final state = _ref.read(mockDatabaseProvider);
      try {
        return state.snapshots.firstWhere(
          (s) => s.snapshotDate.year == date.year && s.snapshotDate.month == date.month,
        );
      } catch (_) {
        return null;
      }
    } else {
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
      final query = _db.select(_db.snapshots)
        ..where((tbl) => tbl.snapshotDate.isBiggerOrEqualValue(startOfMonth) & tbl.snapshotDate.isSmallerOrEqualValue(endOfMonth));
      final item = await query.getSingleOrNull();
      if (item == null) return null;
      return Snapshot(
        id: item.id,
        snapshotDate: item.snapshotDate,
        netWorth: item.netWorth,
        assets: item.assets,
        liabilities: item.liabilities,
        receivables: item.receivables,
        investedCapital: item.investedCapital,
        expectedIncome: item.expectedIncome,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        syncStatus: item.syncStatus,
      );
    }
  }

  // Compares two months and returns comparative difference
  Future<MonthComparison> compareMonths(DateTime first, DateTime second) async {
    final snap1 = await getSnapshot(first);
    final snap2 = await getSnapshot(second);

    final n1 = snap1?.netWorth ?? 0.0;
    final n2 = snap2?.netWorth ?? 0.0;
    final a1 = snap1?.assets ?? 0.0;
    final a2 = snap2?.assets ?? 0.0;
    final l1 = snap1?.liabilities ?? 0.0;
    final l2 = snap2?.liabilities ?? 0.0;
    final r1 = snap1?.receivables ?? 0.0;
    final r2 = snap2?.receivables ?? 0.0;
    final p1 = snap1?.investedCapital ?? 0.0;
    final p2 = snap2?.investedCapital ?? 0.0;
    final e1 = snap1?.expectedIncome ?? 0.0;
    final e2 = snap2?.expectedIncome ?? 0.0;

    return MonthComparison(
      netWorth1: n1,
      netWorth2: n2,
      netWorthDiff: n2 - n1,
      assets1: a1,
      assets2: a2,
      assetsDiff: a2 - a1,
      liabilities1: l1,
      liabilities2: l2,
      liabilitiesDiff: l2 - l1,
      receivables1: r1,
      receivables2: r2,
      receivablesDiff: r2 - r1,
      principal1: p1,
      principal2: p2,
      principalDiff: p2 - p1,
      expectedIncome1: e1,
      expectedIncome2: e2,
      expectedIncomeDiff: e2 - e1,
    );
  }

  // Calculates percentage growth of net worth between two months
  Future<double> getGrowthRate(DateTime first, DateTime second) async {
    final snap1 = await getSnapshot(first);
    final snap2 = await getSnapshot(second);

    if (snap1 == null || snap1.netWorth == 0.0) {
      return 0.0;
    }
    final snap2NetWorth = snap2?.netWorth ?? 0.0;
    return ((snap2NetWorth - snap1.netWorth) / snap1.netWorth) * 100.0;
  }

  // Lazily checks and backfills snapshots for all completed months since the last snapshot
  Future<void> triggerLazySnapshots() async {
    if (_isMock) return;
    
    final now = DateTime.now();
    final oldestTx = await (_db.select(_db.transactions)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.transactionDate, mode: OrderingMode.asc)])
          ..limit(1))
        .getSingleOrNull();

    if (oldestTx == null) return;

    final DateTime startTimeline = oldestTx.transactionDate;
    final latestSnapshot = await (_db.select(_db.snapshots)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.snapshotDate, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();

    DateTime checkDate;
    if (latestSnapshot == null) {
      checkDate = DateTime(startTimeline.year, startTimeline.month, 1);
    } else {
      checkDate = DateTime(latestSnapshot.snapshotDate.year, latestSnapshot.snapshotDate.month + 1, 1);
    }

    final DateTime currentMonthStart = DateTime(now.year, now.month, 1);
    while (checkDate.isBefore(currentMonthStart)) {
      final lastDayOfMonth = DateTime(checkDate.year, checkDate.month + 1, 0, 23, 59, 59);
      
      // Calculate fields manually for snapshots history
      final txs = await (_db.select(_db.transactions)
            ..where((tbl) => tbl.transactionDate.isSmallerOrEqualValue(lastDayOfMonth) & tbl.type.equals('void').not() & tbl.voidedTransactionId.isNull()))
          .get();

      double cashBalances = 0.0;
      final Map<String, double> accountBalances = {};
      final Map<String, double> personReceivables = {};
      final Map<String, double> personLiabilities = {};
      final Map<String, List<_LotState>> investmentLots = {};

      final accounts = await _db.select(_db.accounts).get();
      final Map<String, String> accountTypes = {for (var a in accounts) a.id: a.type};

      for (final tx in txs) {
        if (tx.fromAccountId != null) {
          final current = accountBalances[tx.fromAccountId!] ?? 0.0;
          accountBalances[tx.fromAccountId!] = current - tx.amount;
        }
        if (tx.toAccountId != null) {
          final current = accountBalances[tx.toAccountId!] ?? 0.0;
          accountBalances[tx.toAccountId!] = current + tx.amount;
        }

        if (tx.personId != null) {
          switch (tx.type) {
            case 'borrow_money':
              personLiabilities[tx.personId!] = (personLiabilities[tx.personId!] ?? 0.0) + tx.amount;
              break;
            case 'repay_money':
              personLiabilities[tx.personId!] = (personLiabilities[tx.personId!] ?? 0.0) - tx.amount;
              break;
            case 'lend_money':
              personReceivables[tx.personId!] = (personReceivables[tx.personId!] ?? 0.0) + tx.amount;
              break;
            case 'recover_money':
              personReceivables[tx.personId!] = (personReceivables[tx.personId!] ?? 0.0) - tx.amount;
              break;
          }
        }

        if (tx.investmentId != null) {
          final invId = tx.investmentId!;
          if (tx.type == 'investment_buy') {
            final lots = investmentLots[invId] ?? [];
            final unitsVal = tx.units ?? tx.amount;
            final priceVal = tx.pricePerUnit ?? 1.0;
            lots.add(_LotState(tx.id, unitsVal, unitsVal * priceVal, unitsVal));
            investmentLots[invId] = lots;
          } else if (tx.type == 'investment_sell') {
            double sellUnitsRemaining = tx.units ?? tx.amount;
            final lots = investmentLots[invId] ?? [];
            for (final lot in lots) {
              if (sellUnitsRemaining <= 0) break;
              if (lot.unitsRemaining > 0) {
                final double consumed = lot.unitsRemaining >= sellUnitsRemaining ? sellUnitsRemaining : lot.unitsRemaining;
                lot.unitsRemaining -= consumed;
                sellUnitsRemaining -= consumed;
              }
            }
          }
        }
      }

      double cashAssets = 0.0;
      double creditLiabilities = 0.0;
      accountBalances.forEach((accId, bal) {
        final isCredit = accountTypes[accId] == 'credit';
        if (isCredit) {
          if (bal < 0) creditLiabilities += bal.abs();
        } else {
          cashAssets += bal;
        }
      });

      double receivables = personReceivables.values.fold(0.0, (sum, val) => sum + (val > 0 ? val : 0.0));
      double liabilities = personLiabilities.values.fold(0.0, (sum, val) => sum + (val > 0 ? val : 0.0)) + creditLiabilities;

      double investedCapital = 0.0;
      investmentLots.forEach((_, lots) {
        for (final lot in lots) {
          if (lot.unitsRemaining > 0) {
            investedCapital += (lot.unitsRemaining / lot.unitsPurchased) * lot.costBasis;
          }
        }
      });

       final pendingExpected = await (_db.select(_db.expectedIncomes)
            ..where((tbl) => tbl.createdAt.isSmallerOrEqualValue(lastDayOfMonth) & tbl.status.equals('pending')))
          .get();
      final double expectedIncomeSum = pendingExpected.fold(0.0, (sum, item) => sum + item.amount);

      final double totalAssets = cashAssets + receivables + investedCapital;
      final double totalLiabilities = liabilities;
      final double netWorth = totalAssets - totalLiabilities;

      await _db.into(_db.snapshots).insert(SnapshotsCompanion(
            id: Value(_uuid.v4()),
            snapshotDate: Value(lastDayOfMonth),
            netWorth: Value(netWorth),
            assets: Value(totalAssets),
            liabilities: Value(totalLiabilities),
            receivables: Value(receivables),
            investedCapital: Value(investedCapital),
            expectedIncome: Value(expectedIncomeSum),
            createdAt: Value(DateTime.now().toUtc()),
            updatedAt: Value(DateTime.now().toUtc()),
          ));

      checkDate = DateTime(checkDate.year, checkDate.month + 1, 1);
    }
  }
}

class MonthComparison {
  final double netWorth1;
  final double netWorth2;
  final double netWorthDiff;
  final double assets1;
  final double assets2;
  final double assetsDiff;
  final double liabilities1;
  final double liabilities2;
  final double liabilitiesDiff;
  final double receivables1;
  final double receivables2;
  final double receivablesDiff;
  final double principal1;
  final double principal2;
  final double principalDiff;
  final double expectedIncome1;
  final double expectedIncome2;
  final double expectedIncomeDiff;

  MonthComparison({
    required this.netWorth1,
    required this.netWorth2,
    required this.netWorthDiff,
    required this.assets1,
    required this.assets2,
    required this.assetsDiff,
    required this.liabilities1,
    required this.liabilities2,
    required this.liabilitiesDiff,
    required this.receivables1,
    required this.receivables2,
    required this.receivablesDiff,
    required this.principal1,
    required this.principal2,
    required this.principalDiff,
    required this.expectedIncome1,
    required this.expectedIncome2,
    required this.expectedIncomeDiff,
  });
}

class _LotState {
  final String buyTxId;
  final double unitsPurchased;
  final double costBasis;
  double unitsRemaining;

  _LotState(this.buyTxId, this.unitsPurchased, this.costBasis, this.unitsRemaining);
}
