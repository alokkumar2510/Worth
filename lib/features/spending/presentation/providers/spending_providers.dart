import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../transactions/domain/entities/transaction.dart';

class MonthlyTrendItem {
  final String label;
  final double amount;

  MonthlyTrendItem({required this.label, required this.amount});
}

class SpendingAnalyticsData {
  final double thisMonthTotal;
  final double lastMonthTotal;
  final double momChange;
  final double momChangePercent;
  final double dailyAverage;

  final Map<String, double> categoryBreakdown;
  final Map<String, double> categoryPercentages;

  final List<MonthlyTrendItem> monthlyTrend;
  final Map<DateTime, double> heatmapData;

  final List<String> insights;
  final List<Transaction> recentExpenses;

  SpendingAnalyticsData({
    required this.thisMonthTotal,
    required this.lastMonthTotal,
    required this.momChange,
    required this.momChangePercent,
    required this.dailyAverage,
    required this.categoryBreakdown,
    required this.categoryPercentages,
    required this.monthlyTrend,
    required this.heatmapData,
    required this.insights,
    required this.recentExpenses,
  });
}

// 1. Provider that exposes only expense transactions (non-voided)
final spendingTransactionsProvider = Provider<List<Transaction>>((ref) {
  final dbState = ref.watch(mockDatabaseProvider);
  return dbState.transactions.where((tx) =>
    tx.voidedTransactionId == null &&
    tx.type == 'expense'
  ).map((tx) => Transaction(
    id: tx.id,
    type: tx.type,
    amount: tx.amount,
    category: tx.category,
    fromAccountId: tx.fromAccountId,
    toAccountId: tx.toAccountId,
    personId: tx.personId,
    investmentId: tx.investmentId,
    voidedTransactionId: tx.voidedTransactionId,
    notes: tx.notes,
    pricePerUnit: tx.pricePerUnit,
    units: tx.units,
    transactionDate: tx.transactionDate,
    createdAt: tx.createdAt,
    updatedAt: tx.updatedAt,
    syncStatus: tx.syncStatus,
  )).toList();
});

// 2. Core Spending Intelligence Calculation Provider
final spendingAnalyticsProvider = Provider<SpendingAnalyticsData>((ref) {
  final expenses = ref.watch(spendingTransactionsProvider);
  final dbState = ref.watch(mockDatabaseProvider);
  final now = DateTime.now();

  // Categories helper
  final List<String> expenseCategories = [
    'Food', 'Travel', 'Shopping', 'Education', 'Bills',
    'Subscriptions', 'Health', 'Entertainment', 'Fees', 'Miscellaneous'
  ];

  // Helper to normalize any existing categories in the database to our 10 standards
  String normalizeCategory(String? cat) {
    if (cat == null) return 'Miscellaneous';
    final normalized = cat.trim().toLowerCase();
    if (normalized == 'food & drinks' || normalized == 'food') return 'Food';
    if (normalized == 'travel') return 'Travel';
    if (normalized == 'shopping') return 'Shopping';
    if (normalized == 'education') return 'Education';
    if (normalized == 'bills & utilities' || normalized == 'bills') return 'Bills';
    if (normalized == 'subscriptions') return 'Subscriptions';
    if (normalized == 'medical' || normalized == 'health') return 'Health';
    if (normalized == 'entertainment') return 'Entertainment';
    if (normalized == 'fees') return 'Fees';
    return 'Miscellaneous';
  }

  // 1. Calculate Monthly Totals
  final thisMonthStart = DateTime(now.year, now.month, 1);
  final thisMonthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  final lastMonthStart = DateTime(now.year, now.month - 1, 1);
  final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);

  final thisMonthExpenses = expenses.where((tx) =>
    tx.transactionDate.isAfter(thisMonthStart.subtract(const Duration(seconds: 1))) &&
    tx.transactionDate.isBefore(thisMonthEnd.add(const Duration(seconds: 1)))
  ).toList();

  final lastMonthExpenses = expenses.where((tx) =>
    tx.transactionDate.isAfter(lastMonthStart.subtract(const Duration(seconds: 1))) &&
    tx.transactionDate.isBefore(lastMonthEnd.add(const Duration(seconds: 1)))
  ).toList();

  final double thisMonthTotal = thisMonthExpenses.fold(0.0, (sum, tx) => sum + tx.amount);
  final double lastMonthTotal = lastMonthExpenses.fold(0.0, (sum, tx) => sum + tx.amount);

  final double momChange = thisMonthTotal - lastMonthTotal;
  final double momChangePercent = lastMonthTotal > 0.0
      ? (momChange / lastMonthTotal) * 100.0
      : 0.0;

  final daysPassed = now.day;
  final double dailyAverage = thisMonthTotal / daysPassed;

  // 2. Calculate Category Breakdown
  final Map<String, double> breakdown = {
    for (final cat in expenseCategories) cat: 0.0
  };

  for (final tx in thisMonthExpenses) {
    final normalized = normalizeCategory(tx.category);
    breakdown[normalized] = (breakdown[normalized] ?? 0.0) + tx.amount;
  }

  final Map<String, double> percentages = {};
  breakdown.forEach((cat, amt) {
    percentages[cat] = thisMonthTotal > 0.0 ? (amt / thisMonthTotal) * 100.0 : 0.0;
  });

  // 3. Group Monthly Trend (Last 6 Months)
  final List<MonthlyTrendItem> trend = [];
  for (int i = 5; i >= 0; i--) {
    final date = DateTime(now.year, now.month - i, 1);
    final mStart = DateTime(date.year, date.month, 1);
    final mEnd = DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    final mLabel = DateFormat('MMM').format(date);

    final double monthTotal = expenses.where((tx) =>
      tx.transactionDate.isAfter(mStart.subtract(const Duration(seconds: 1))) &&
      tx.transactionDate.isBefore(mEnd.add(const Duration(seconds: 1)))
    ).fold(0.0, (sum, tx) => sum + tx.amount);

    trend.add(MonthlyTrendItem(label: mLabel, amount: monthTotal));
  }

  // 4. Group Daily Heatmap (Last 90 Days)
  final Map<DateTime, double> heatmap = {};
  for (int i = 89; i >= 0; i--) {
    final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    heatmap[DateTime(d.year, d.month, d.day)] = 0.0;
  }

  for (final tx in expenses) {
    final localDate = tx.transactionDate.toLocal();
    final dayKey = DateTime(localDate.year, localDate.month, localDate.day);
    if (heatmap.containsKey(dayKey)) {
      heatmap[dayKey] = heatmap[dayKey]! + tx.amount;
    }
  }

  // 5. Generate Spending Insights
  final List<String> insights = [];

  if (thisMonthTotal == 0.0) {
    insights.add('No spending recorded this month. Your wealth is preserved!');
  } else {
    if (lastMonthTotal > 0.0) {
      final diffPercent = momChangePercent.abs().toStringAsFixed(1);
      if (momChange > 0.0) {
        insights.add('Monthly spending is up by $diffPercent% compared to last month. Track outflows by category to locate savings.');
      } else {
        insights.add('Incredible control! You have reduced your overall spending by $diffPercent% compared to last month.');
      }
    } else {
      insights.add('Establishing baseline spending. Consistently logging expenses will unlock historical wealth calculations.');
    }

    final sortedBreakdown = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = sortedBreakdown.first;
    if (topCategory.value > 0.0) {
      final topCategoryPct = ((topCategory.value / thisMonthTotal) * 100).toStringAsFixed(1);
      insights.add('${topCategory.key} accounts for your largest outflow this month ($topCategoryPct% of total spending).');
    }

    final subscriptionsTotal = breakdown['Subscriptions'] ?? 0.0;
    if (subscriptionsTotal > 0.0) {
      final subPct = ((subscriptionsTotal / thisMonthTotal) * 100).toStringAsFixed(1);
      insights.add('Recurring Subscriptions account for $subPct% (${dbState.currency}${NumberFormat.decimalPattern().format(subscriptionsTotal.toInt())}) of your outflows. Review regularly.');
    }

    final activeSpendingDays = heatmap.entries
      .where((e) => e.key.month == now.month && e.key.year == now.year && e.value > 0.0)
      .length;
    if (activeSpendingDays > 0) {
      insights.add('You made expense transactions on $activeSpendingDays days this month. Decreasing frequency reduces micro-spending leakage.');
    }
  }

  // Sort recent expenses by date newest first
  final sortedRecentExpenses = thisMonthExpenses
    ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

  return SpendingAnalyticsData(
    thisMonthTotal: thisMonthTotal,
    lastMonthTotal: lastMonthTotal,
    momChange: momChange,
    momChangePercent: momChangePercent,
    dailyAverage: dailyAverage,
    categoryBreakdown: breakdown,
    categoryPercentages: percentages,
    monthlyTrend: trend,
    heatmapData: heatmap,
    insights: insights,
    recentExpenses: sortedRecentExpenses,
  );
});
