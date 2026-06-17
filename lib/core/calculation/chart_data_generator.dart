import 'package:drift/drift.dart';
import '../../database/database.dart' as db;

class ChartDataGenerator {
  final db.AppDatabase _db;

  ChartDataGenerator(this._db);

  // 1. Net Worth Trend
  Future<List<MapEntry<DateTime, double>>> getNetWorthTrend() async {
    final query = _db.select(_db.snapshots)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.snapshotDate, mode: OrderingMode.asc)]);
    final list = await query.get();
    return list.map((s) => MapEntry(s.snapshotDate, s.netWorth)).toList();
  }

  // 2. Monthly Growth Rate (Percent delta month-over-month)
  Future<List<MapEntry<DateTime, double>>> getMonthlyGrowth() async {
    final query = _db.select(_db.snapshots)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.snapshotDate, mode: OrderingMode.asc)]);
    final list = await query.get();
    
    final List<MapEntry<DateTime, double>> growth = [];
    for (int i = 1; i < list.length; i++) {
      final prev = list[i - 1].netWorth;
      final current = list[i].netWorth;
      final rate = prev != 0 ? ((current - prev) / prev) * 100 : 0.0;
      growth.add(MapEntry(list[i].snapshotDate, rate));
    }
    return growth;
  }

  // 3. Asset Allocation
  Future<Map<String, double>> getAssetAllocation() async {
    final Map<String, double> allocation = {};

    // Accounts (Cash / Bank / Wallet)
    final accQuery = _db.select(_db.accounts).join([
      innerJoin(
        _db.accountBalanceCaches,
        _db.accountBalanceCaches.accountId.equalsExp(_db.accounts.id),
      ),
    ])..where(_db.accounts.type.equals('credit').not() & _db.accounts.isArchived.equals(0));
    final accRows = await accQuery.get();
    for (final row in accRows) {
      final acc = row.readTable(_db.accounts);
      final cache = row.readTable(_db.accountBalanceCaches);
      if (cache.cashBalance > 0) {
        allocation[acc.name] = (allocation[acc.name] ?? 0.0) + cache.cashBalance;
      }
    }

    // Investments
    final invQuery = _db.select(_db.investments).join([
      innerJoin(
        _db.investmentBalanceCaches,
        _db.investmentBalanceCaches.investmentId.equalsExp(_db.investments.id),
      ),
    ])..where(_db.investments.isArchived.equals(0));
    final invRows = await invQuery.get();
    for (final row in invRows) {
      final inv = row.readTable(_db.investments);
      final cache = row.readTable(_db.investmentBalanceCaches);
      final value = (inv.marketValue ?? 0.0) * cache.unitsHeld;
      if (value > 0) {
        allocation[inv.name] = (allocation[inv.name] ?? 0.0) + value;
      }
    }

    // Receivables
    final recQuery = _db.select(_db.people).join([
      innerJoin(
        _db.personBalanceCaches,
        _db.personBalanceCaches.personId.equalsExp(_db.people.id),
      ),
    ])..where(_db.people.isArchived.equals(0));
    final recRows = await recQuery.get();
    for (final row in recRows) {
      final person = row.readTable(_db.people);
      final cache = row.readTable(_db.personBalanceCaches);
      if (cache.receivableBalance > 0) {
        allocation[person.name] = (allocation[person.name] ?? 0.0) + cache.receivableBalance;
      }
    }

    return allocation;
  }

  // 4. Liability Allocation
  Future<Map<String, double>> getLiabilityAllocation() async {
    final Map<String, double> allocation = {};

    // Credit Cards
    final ccQuery = _db.select(_db.accounts).join([
      innerJoin(
        _db.accountBalanceCaches,
        _db.accountBalanceCaches.accountId.equalsExp(_db.accounts.id),
      ),
    ])..where(_db.accounts.type.equals('credit') & _db.accounts.isArchived.equals(0));
    final ccRows = await ccQuery.get();
    for (final row in ccRows) {
      final acc = row.readTable(_db.accounts);
      final cache = row.readTable(_db.accountBalanceCaches);
      if (cache.liabilityBalance > 0) {
        allocation[acc.name] = (allocation[acc.name] ?? 0.0) + cache.liabilityBalance;
      }
    }

    // Debts
    final debtQuery = _db.select(_db.people).join([
      innerJoin(
        _db.personBalanceCaches,
        _db.personBalanceCaches.personId.equalsExp(_db.people.id),
      ),
    ])..where(_db.people.isArchived.equals(0));
    final debtRows = await debtQuery.get();
    for (final row in debtRows) {
      final person = row.readTable(_db.people);
      final cache = row.readTable(_db.personBalanceCaches);
      if (cache.liabilityBalance > 0) {
        allocation[person.name] = (allocation[person.name] ?? 0.0) + cache.liabilityBalance;
      }
    }

    return allocation;
  }

  // 5. Investment Allocation (Grouped by Asset Category / Type)
  Future<Map<String, double>> getInvestmentAllocation() async {
    final Map<String, double> allocation = {};

    final query = _db.select(_db.investments).join([
      innerJoin(
        _db.investmentBalanceCaches,
        _db.investmentBalanceCaches.investmentId.equalsExp(_db.investments.id),
      ),
    ])..where(_db.investments.isArchived.equals(0));

    final rows = await query.get();
    for (final row in rows) {
      final inv = row.readTable(_db.investments);
      final cache = row.readTable(_db.investmentBalanceCaches);
      final value = (inv.marketValue ?? 0.0) * cache.unitsHeld;
      if (value > 0) {
        // Group by Investment type (e.g., Gold, Stocks, Crypto, Mutual Funds)
        final category = inv.type;
        allocation[category] = (allocation[category] ?? 0.0) + value;
      }
    }
    return allocation;
  }

  // 6. Income vs Expense (Grouped by Year-Month)
  Future<List<IncomeVsExpenseData>> getIncomeVsExpense() async {
    // We select non-voided income and expense transactions
    final query = _db.select(_db.transactions)
      ..where((tbl) => tbl.type.equals('income') | tbl.type.equals('expense'))
      ..where((tbl) => tbl.voidedTransactionId.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.asc)]);

    final list = await query.get();
    final Map<String, IncomeVsExpenseData> monthlyData = {};

    for (final tx in list) {
      final date = tx.transactionDate;
      // Key format: YYYY-MM
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      final current = monthlyData[key] ?? IncomeVsExpenseData(
        period: key,
        income: 0.0,
        expense: 0.0,
      );

      if (tx.type == 'income') {
        monthlyData[key] = current.copyWith(income: current.income + tx.amount);
      } else {
        monthlyData[key] = current.copyWith(expense: current.expense + tx.amount);
      }
    }

    return monthlyData.values.toList();
  }
}

class IncomeVsExpenseData {
  final String period;
  final double income;
  final double expense;

  IncomeVsExpenseData({
    required this.period,
    required this.income,
    required this.expense,
  });

  IncomeVsExpenseData copyWith({
    String? period,
    double? income,
    double? expense,
  }) {
    return IncomeVsExpenseData(
      period: period ?? this.period,
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }
}
