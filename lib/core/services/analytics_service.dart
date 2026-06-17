import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart' as db;
import '../providers/app_providers.dart';

// --- Data Models for Insights ---

class MonthlyGrowthItem {
  final String month; // YYYY-MM
  final double netWorth;
  final double growthAmount;
  final double growthPercentage;

  MonthlyGrowthItem({
    required this.month,
    required this.netWorth,
    required this.growthAmount,
    required this.growthPercentage,
  });
}

class NetWorthGrowthSummary {
  final double initialNetWorth;
  final double currentNetWorth;
  final double totalGrowthAmount;
  final double totalGrowthPercentage;
  final List<MonthlyGrowthItem> monthlyProgression;

  NetWorthGrowthSummary({
    required this.initialNetWorth,
    required this.currentNetWorth,
    required this.totalGrowthAmount,
    required this.totalGrowthPercentage,
    required this.monthlyProgression,
  });
}

class IncomeGrowthItem {
  final String month;
  final double totalIncome;
  final double growthAmount;
  final double growthPercentage;

  IncomeGrowthItem({
    required this.month,
    required this.totalIncome,
    required this.growthAmount,
    required this.growthPercentage,
  });
}

class ExpenseGrowthItem {
  final String month;
  final double totalExpense;
  final double growthAmount;
  final double growthPercentage;

  ExpenseGrowthItem({
    required this.month,
    required this.totalExpense,
    required this.growthAmount,
    required this.growthPercentage,
  });
}

class SavingsRateItem {
  final String month;
  final double income;
  final double expense;
  final double savings;
  final double savingsRate;

  SavingsRateItem({
    required this.month,
    required this.income,
    required this.expense,
    required this.savings,
    required this.savingsRate,
  });
}

class InvestmentGrowthItem {
  final String month;
  final double investedCapital;
  final double growthAmount;
  final double growthPercentage;

  InvestmentGrowthItem({
    required this.month,
    required this.investedCapital,
    required this.growthAmount,
    required this.growthPercentage,
  });
}

// --- Analytics Service ---

class AnalyticsService {
  final db.AppDatabase _db;

  AnalyticsService(this._db);

  // Helper to extract a safe YYYY-MM key from SQLite date values
  String _formatDateToMonth(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  // 1. Monthly Growth (Month-over-Month Net Worth percentage change)
  Future<List<MonthlyGrowthItem>> getMonthlyGrowthMoM() async {
    // SQLite aggregation query: retrieve snapshots ordered by date
    final rows = await _db.customSelect(
      "SELECT snapshot_date, net_worth FROM snapshots "
      "ORDER BY snapshot_date ASC"
    ).get();

    final List<MonthlyGrowthItem> list = [];
    double prevNetWorth = 0.0;

    for (final row in rows) {
      final int dateSecs = row.read<int>('snapshot_date');
      final double netWorth = row.read<double>('net_worth');
      
      final date = DateTime.fromMillisecondsSinceEpoch(
        dateSecs > 10000000000 ? dateSecs : dateSecs * 1000
      );
      final monthStr = _formatDateToMonth(date);

      double growthAmount = 0.0;
      double growthPercentage = 0.0;

      if (list.isNotEmpty) {
        growthAmount = netWorth - prevNetWorth;
        growthPercentage = prevNetWorth != 0.0 ? (growthAmount / prevNetWorth) * 100.0 : 0.0;
      }

      list.add(MonthlyGrowthItem(
        month: monthStr,
        netWorth: netWorth,
        growthAmount: growthAmount,
        growthPercentage: growthPercentage,
      ));

      prevNetWorth = netWorth;
    }

    return list;
  }

  // 2. Net Worth Growth Summary (Overall progression + totals)
  Future<NetWorthGrowthSummary> getNetWorthGrowth() async {
    final progression = await getMonthlyGrowthMoM();
    if (progression.isEmpty) {
      return NetWorthGrowthSummary(
        initialNetWorth: 0.0,
        currentNetWorth: 0.0,
        totalGrowthAmount: 0.0,
        totalGrowthPercentage: 0.0,
        monthlyProgression: [],
      );
    }

    final initial = progression.first.netWorth;
    final current = progression.last.netWorth;
    final totalGrowth = current - initial;
    final growthPercentage = initial != 0.0 ? (totalGrowth / initial) * 100.0 : 0.0;

    return NetWorthGrowthSummary(
      initialNetWorth: initial,
      currentNetWorth: current,
      totalGrowthAmount: totalGrowth,
      totalGrowthPercentage: growthPercentage,
      monthlyProgression: progression,
    );
  }

  // 3. Income Growth (MoM income growth %)
  Future<List<IncomeGrowthItem>> getIncomeGrowthMoM() async {
    // SQLite aggregation query: group income transactions by month
    final rows = await _db.customSelect(
      "SELECT "
      "  strftime('%Y-%m', datetime("
      "    CASE WHEN transaction_date > 10000000000 THEN transaction_date / 1000 ELSE transaction_date END, "
      "    'unixepoch'"
      "  )) AS month, "
      "  SUM(amount) AS total_income "
      "FROM transactions "
      "WHERE type = 'income' AND voided_transaction_id IS NULL "
      "GROUP BY month "
      "ORDER BY month ASC"
    ).get();

    final List<IncomeGrowthItem> list = [];
    double prevIncome = 0.0;

    for (final row in rows) {
      final month = row.read<String>('month');
      final totalIncome = row.read<double>('total_income');

      double growthAmount = 0.0;
      double growthPercentage = 0.0;

      if (list.isNotEmpty) {
        growthAmount = totalIncome - prevIncome;
        growthPercentage = prevIncome != 0.0 ? (growthAmount / prevIncome) * 100.0 : 0.0;
      }

      list.add(IncomeGrowthItem(
        month: month,
        totalIncome: totalIncome,
        growthAmount: growthAmount,
        growthPercentage: growthPercentage,
      ));

      prevIncome = totalIncome;
    }

    return list;
  }

  // 4. Expense Growth (MoM expense growth %)
  Future<List<ExpenseGrowthItem>> getExpenseGrowthMoM() async {
    // SQLite aggregation query: group expense transactions by month
    final rows = await _db.customSelect(
      "SELECT "
      "  strftime('%Y-%m', datetime("
      "    CASE WHEN transaction_date > 10000000000 THEN transaction_date / 1000 ELSE transaction_date END, "
      "    'unixepoch'"
      "  )) AS month, "
      "  SUM(amount) AS total_expense "
      "FROM transactions "
      "WHERE type = 'expense' AND voided_transaction_id IS NULL "
      "GROUP BY month "
      "ORDER BY month ASC"
    ).get();

    final List<ExpenseGrowthItem> list = [];
    double prevExpense = 0.0;

    for (final row in rows) {
      final month = row.read<String>('month');
      final totalExpense = row.read<double>('total_expense');

      double growthAmount = 0.0;
      double growthPercentage = 0.0;

      if (list.isNotEmpty) {
        growthAmount = totalExpense - prevExpense;
        growthPercentage = prevExpense != 0.0 ? (growthAmount / prevExpense) * 100.0 : 0.0;
      }

      list.add(ExpenseGrowthItem(
        month: month,
        totalExpense: totalExpense,
        growthAmount: growthAmount,
        growthPercentage: growthPercentage,
      ));

      prevExpense = totalExpense;
    }

    return list;
  }

  // 5. Savings Rate (Monthly savings / income %)
  Future<List<SavingsRateItem>> getSavingsRate() async {
    // SQLite aggregation query: group both income and expense transactions by month
    final rows = await _db.customSelect(
      "SELECT "
      "  strftime('%Y-%m', datetime("
      "    CASE WHEN transaction_date > 10000000000 THEN transaction_date / 1000 ELSE transaction_date END, "
      "    'unixepoch'"
      "  )) AS month, "
      "  SUM(CASE WHEN type = 'income' THEN amount ELSE 0.0 END) AS total_income, "
      "  SUM(CASE WHEN type = 'expense' THEN amount ELSE 0.0 END) AS total_expense "
      "FROM transactions "
      "WHERE voided_transaction_id IS NULL "
      "GROUP BY month "
      "ORDER BY month ASC"
    ).get();

    final List<SavingsRateItem> list = [];

    for (final row in rows) {
      final month = row.read<String>('month');
      final income = row.read<double>('total_income');
      final expense = row.read<double>('total_expense');
      final savings = income - expense;
      final savingsRate = income != 0.0 ? (savings / income) * 100.0 : 0.0;

      list.add(SavingsRateItem(
        month: month,
        income: income,
        expense: expense,
        savings: savings,
        savingsRate: savingsRate,
      ));
    }

    return list;
  }

  // 6. Investment Growth (MoM invested capital growth from snapshots)
  Future<List<InvestmentGrowthItem>> getInvestmentGrowthMoM() async {
    // SQLite aggregation query: retrieve invested capital snapshots ordered by date
    final rows = await _db.customSelect(
      "SELECT snapshot_date, invested_capital FROM snapshots "
      "ORDER BY snapshot_date ASC"
    ).get();

    final List<InvestmentGrowthItem> list = [];
    double prevInvested = 0.0;

    for (final row in rows) {
      final int dateSecs = row.read<int>('snapshot_date');
      final double investedCapital = row.read<double>('invested_capital');

      final date = DateTime.fromMillisecondsSinceEpoch(
        dateSecs > 10000000000 ? dateSecs : dateSecs * 1000
      );
      final monthStr = _formatDateToMonth(date);

      double growthAmount = 0.0;
      double growthPercentage = 0.0;

      if (list.isNotEmpty) {
        growthAmount = investedCapital - prevInvested;
        growthPercentage = prevInvested != 0.0 ? (growthAmount / prevInvested) * 100.0 : 0.0;
      }

      list.add(InvestmentGrowthItem(
        month: monthStr,
        investedCapital: investedCapital,
        growthAmount: growthAmount,
        growthPercentage: growthPercentage,
      ));

      prevInvested = investedCapital;
    }

    return list;
  }
}
