import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart';

class TimelineItem {
  final String month;
  final double netWorth;

  TimelineItem({required this.month, required this.netWorth});
}

class ChangeItem {
  final String label;
  final String name;
  final double amount;

  ChangeItem({required this.label, required this.name, required this.amount});
}

class WealthIntelligenceData {
  final double currentNetWorth;
  final double monthlyChange;
  final double monthlyChangePercent;
  final double quarterlyChange;
  final double quarterlyChangePercent;
  final double yearlyChange;
  final double yearlyChangePercent;

  final double totalAssets;
  final double totalLiabilities;
  final double totalReceivables;
  final double totalInvestedCapital;
  final double totalExpectedIncome;

  final Map<String, double> assetAllocation;
  final Map<String, double> liabilityAllocation;
  final Map<String, double> investmentAllocation;

  // This Month Stats
  final double newAssetsAdded;
  final double liabilitiesReduced;
  final double receivablesRecovered;
  final double investmentsAdded;
  final double expectedIncomeReceived;

  // Timeline & Biggest Changes & Insights
  final List<TimelineItem> timeline;
  final List<ChangeItem> biggestChanges;
  final List<String> insights;

  // Charts
  final List<FlSpot> trendSpots;
  final List<String> trendDates;
  final List<double> growthData;
  final List<String> growthMonths;

  final bool hasData;
 
  // Portfolio metrics additions
  final double averageHoldingPeriod;
  final List<Map<String, dynamic>> holdingDurations;
  final Map<String, dynamic> sipPerformance;
  final Map<String, dynamic> mtfInterestSummary;
  final List<Map<String, dynamic>> mtfInterestHistory;

  WealthIntelligenceData({
    required this.currentNetWorth,
    required this.monthlyChange,
    required this.monthlyChangePercent,
    required this.quarterlyChange,
    required this.quarterlyChangePercent,
    required this.yearlyChange,
    required this.yearlyChangePercent,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalReceivables,
    required this.totalInvestedCapital,
    required this.totalExpectedIncome,
    required this.assetAllocation,
    required this.liabilityAllocation,
    required this.investmentAllocation,
    required this.newAssetsAdded,
    required this.liabilitiesReduced,
    required this.receivablesRecovered,
    required this.investmentsAdded,
    required this.expectedIncomeReceived,
    required this.timeline,
    required this.biggestChanges,
    required this.insights,
    required this.trendSpots,
    required this.trendDates,
    required this.growthData,
    required this.growthMonths,
    required this.hasData,
    required this.averageHoldingPeriod,
    required this.holdingDurations,
    required this.sipPerformance,
    required this.mtfInterestSummary,
    required this.mtfInterestHistory,
  });
}

final wealthIntelligenceProvider = Provider<WealthIntelligenceData>((ref) {
  final dbState = ref.watch(mockDatabaseProvider);
  final now = DateTime.now();

  // If no transactions exist, treat it as empty state
  if (dbState.transactions.isEmpty && dbState.snapshots.isEmpty) {
    return WealthIntelligenceData(
      currentNetWorth: 0.0,
      monthlyChange: 0.0,
      monthlyChangePercent: 0.0,
      quarterlyChange: 0.0,
      quarterlyChangePercent: 0.0,
      yearlyChange: 0.0,
      yearlyChangePercent: 0.0,
      totalAssets: 0.0,
      totalLiabilities: 0.0,
      totalReceivables: 0.0,
      totalInvestedCapital: 0.0,
      totalExpectedIncome: 0.0,
      assetAllocation: const {},
      liabilityAllocation: const {},
      investmentAllocation: const {},
      newAssetsAdded: 0.0,
      liabilitiesReduced: 0.0,
      receivablesRecovered: 0.0,
      investmentsAdded: 0.0,
      expectedIncomeReceived: 0.0,
      timeline: const [],
      biggestChanges: const [],
      insights: const ['Add transactions to generate wealth intelligence.'],
      trendSpots: const [],
      trendDates: const [],
      growthData: const [],
      growthMonths: const [],
      hasData: false,
      averageHoldingPeriod: 0.0,
      holdingDurations: const [],
      sipPerformance: const {
        'investedCapital': 0.0,
        'currentValuation': 0.0,
        'growth': 0.0,
        'consistencyRate': 100.0,
      },
      mtfInterestSummary: const {
        'accrued': 0.0,
        'paid': 0.0,
        'outstanding': 0.0,
      },
      mtfInterestHistory: const [],
    );
  }

  // 1. Snapshot calculations
  final sortedSnaps = List<Snapshot>.from(dbState.snapshots)
    ..sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate));

  final double currentNetWorth = dbState.netWorth;

  // Changes
  final double monthlyChange = sortedSnaps.isNotEmpty
      ? currentNetWorth - sortedSnaps.last.netWorth
      : 0.0;
  final double monthlyChangePercent = (sortedSnaps.isNotEmpty && sortedSnaps.last.netWorth != 0.0)
      ? (monthlyChange / sortedSnaps.last.netWorth) * 100.0
      : 0.0;

  // Quarterly Change (approx 90 days ago)
  Snapshot? qSnap;
  final threeMonthsAgo = now.subtract(const Duration(days: 90));
  for (final snap in sortedSnaps.reversed) {
    if (snap.snapshotDate.isBefore(threeMonthsAgo)) {
      qSnap = snap;
      break;
    }
  }
  if (qSnap == null && sortedSnaps.isNotEmpty) {
    qSnap = sortedSnaps.first;
  }
  final double quarterlyChange = qSnap != null ? currentNetWorth - qSnap.netWorth : 0.0;
  final double quarterlyChangePercent = (qSnap != null && qSnap.netWorth != 0.0)
      ? (quarterlyChange / qSnap.netWorth) * 100.0
      : 0.0;

  // Yearly Change (approx 365 days ago)
  Snapshot? ySnap;
  final oneYearAgo = now.subtract(const Duration(days: 365));
  for (final snap in sortedSnaps.reversed) {
    if (snap.snapshotDate.isBefore(oneYearAgo)) {
      ySnap = snap;
      break;
    }
  }
  if (ySnap == null && sortedSnaps.isNotEmpty) {
    ySnap = sortedSnaps.first;
  }
  final double yearlyChange = ySnap != null ? currentNetWorth - ySnap.netWorth : 0.0;
  final double yearlyChangePercent = (ySnap != null && ySnap.netWorth != 0.0)
      ? (yearlyChange / ySnap.netWorth) * 100.0
      : 0.0;

  // 2. Wealth Breakdown
  final double totalAssets = dbState.totalAssets;
  final double totalLiabilities = dbState.totalLiabilities;
  final double totalReceivables = dbState.people
      .where((p) => p.isArchived == 0)
      .fold(0.0, (sum, p) => sum + dbState.getPersonReceivableBalance(p.id));
  final double totalInvestedCapital = dbState.totalInvestedCapital;
  final double totalExpectedIncome = dbState.totalExpectedIncome;

  // 3. Allocations
  final Map<String, double> assetAllocation = {};
  for (final acc in dbState.accounts) {
    if (acc.isArchived == 0 && acc.type != 'credit') {
      final bal = dbState.getAccountCashBalance(acc.id);
      if (bal > 0) assetAllocation[acc.name] = bal;
    }
  }
  for (final inv in dbState.investments) {
    if (inv.isArchived == 0) {
      final val = dbState.getInvestmentMarketValue(inv.id);
      if (val > 0) assetAllocation[inv.name] = val;
    }
  }
  for (final p in dbState.people) {
    if (p.isArchived == 0) {
      final bal = dbState.getPersonReceivableBalance(p.id);
      if (bal > 0) assetAllocation[p.name] = bal;
    }
  }

  final Map<String, double> liabilityAllocation = {};
  for (final acc in dbState.accounts) {
    if (acc.isArchived == 0 && acc.type == 'credit') {
      final bal = dbState.getAccountLiabilityBalance(acc.id);
      if (bal > 0) liabilityAllocation[acc.name] = bal;
    }
  }
  for (final p in dbState.people) {
    if (p.isArchived == 0) {
      final bal = dbState.getPersonLiabilityBalance(p.id);
      if (bal > 0) liabilityAllocation[p.name] = bal;
    }
  }

  final Map<String, double> investmentAllocation = {};
  for (final inv in dbState.investments) {
    if (inv.isArchived == 0) {
      final val = dbState.getInvestmentMarketValue(inv.id);
      if (val > 0) {
        final String typeLabel = inv.type == 'stock'
            ? 'Direct Equity'
            : (inv.type == 'mutual_fund' ? 'Mutual Funds' : inv.type.toUpperCase());
        investmentAllocation[typeLabel] = (investmentAllocation[typeLabel] ?? 0.0) + val;
      }
    }
  }

  // 4. This Month Stats
  final currentMonthTxs = dbState.transactions.where((tx) =>
      tx.voidedTransactionId == null &&
      tx.type != 'void' &&
      tx.transactionDate.year == now.year &&
      tx.transactionDate.month == now.month).toList();

  double newAssetsAdded = 0.0;
  double liabilitiesReduced = 0.0;
  double receivablesRecovered = 0.0;
  double investmentsAdded = 0.0;
  double expectedIncomeReceived = 0.0;

  for (final tx in currentMonthTxs) {
    if (tx.type == 'income') {
      newAssetsAdded += tx.amount;
    } else if (tx.type == 'repay_money') {
      liabilitiesReduced += tx.amount;
    } else if (tx.type == 'recover_money') {
      receivablesRecovered += tx.amount;
      newAssetsAdded += tx.amount; // recovery counts as asset added
    } else if (tx.type == 'investment_buy') {
      investmentsAdded += tx.amount;
    } else if (tx.type == 'expected_income_received') {
      expectedIncomeReceived += tx.amount;
      newAssetsAdded += tx.amount; // expected income counts as asset added
    }
  }

  // 5. Timeline Feed
  final List<TimelineItem> timeline = [];
  for (final s in sortedSnaps) {
    timeline.add(TimelineItem(
      month: DateFormat('MMMM yyyy').format(s.snapshotDate.toLocal()),
      netWorth: s.netWorth,
    ));
  }
  // Append current day as the final timeline element if it differs from last snapshot month
  final String currentMonthLabel = DateFormat('MMMM yyyy').format(now);
  if (timeline.isEmpty || timeline.last.month != currentMonthLabel) {
    timeline.add(TimelineItem(
      month: currentMonthLabel,
      netWorth: currentNetWorth,
    ));
  }

  // 6. Biggest Changes
  final List<ChangeItem> biggestChanges = [];

  // Largest Asset Growth
  final Map<String, double> assetNetFlows = {};
  for (final tx in currentMonthTxs) {
    if (tx.toAccountId != null) {
      final toAcc = dbState.accounts.firstWhereOrNull((a) => a.id == tx.toAccountId);
      if (toAcc != null && toAcc.type != 'credit') {
        assetNetFlows[toAcc.name] = (assetNetFlows[toAcc.name] ?? 0.0) + tx.amount;
      }
    }
    if (tx.fromAccountId != null) {
      final fromAcc = dbState.accounts.firstWhereOrNull((a) => a.id == tx.fromAccountId);
      if (fromAcc != null && fromAcc.type != 'credit') {
        assetNetFlows[fromAcc.name] = (assetNetFlows[fromAcc.name] ?? 0.0) - tx.amount;
      }
    }
  }
  String largestAssetGrowthName = 'None';
  double largestAssetGrowthValue = 0.0;
  for (final entry in assetNetFlows.entries) {
    if (entry.value > largestAssetGrowthValue) {
      largestAssetGrowthName = entry.key;
      largestAssetGrowthValue = entry.value;
    }
  }
  if (largestAssetGrowthValue > 0) {
    biggestChanges.add(ChangeItem(
      label: 'Largest Asset Growth',
      name: largestAssetGrowthName,
      amount: largestAssetGrowthValue,
    ));
  }

  // Largest Liability Reduction
  final Map<String, double> liabilityReductions = {};
  for (final tx in currentMonthTxs) {
    if (tx.type == 'repay_money') {
      if (tx.toAccountId != null) {
        final toAcc = dbState.accounts.firstWhereOrNull((a) => a.id == tx.toAccountId);
        if (toAcc != null && toAcc.type == 'credit') {
          liabilityReductions[toAcc.name] = (liabilityReductions[toAcc.name] ?? 0.0) + tx.amount;
        }
      }
      if (tx.personId != null) {
        final person = dbState.people.firstWhereOrNull((p) => p.id == tx.personId);
        if (person != null) {
          liabilityReductions[person.name] = (liabilityReductions[person.name] ?? 0.0) + tx.amount;
        }
      }
    }
  }
  String largestLiabilityReductionName = 'None';
  double largestLiabilityReductionValue = 0.0;
  for (final entry in liabilityReductions.entries) {
    if (entry.value > largestLiabilityReductionValue) {
      largestLiabilityReductionName = entry.key;
      largestLiabilityReductionValue = entry.value;
    }
  }
  if (largestLiabilityReductionValue > 0) {
    biggestChanges.add(ChangeItem(
      label: 'Largest Liability Reduction',
      name: largestLiabilityReductionName,
      amount: largestLiabilityReductionValue,
    ));
  }

  // Largest Recovery
  double largestRecoveryValue = 0.0;
  String largestRecoveryPerson = 'None';
  for (final tx in currentMonthTxs) {
    if (tx.type == 'recover_money' && tx.amount > largestRecoveryValue) {
      largestRecoveryValue = tx.amount;
      final person = dbState.people.firstWhereOrNull((p) => p.id == tx.personId);
      largestRecoveryPerson = person?.name ?? 'Unknown';
    }
  }
  if (largestRecoveryValue > 0) {
    biggestChanges.add(ChangeItem(
      label: 'Largest Recovery',
      name: largestRecoveryPerson,
      amount: largestRecoveryValue,
    ));
  }

  // Largest Investment
  double largestInvestmentValue = 0.0;
  String largestInvestmentName = 'None';
  for (final tx in currentMonthTxs) {
    if (tx.type == 'investment_buy' && tx.amount > largestInvestmentValue) {
      largestInvestmentValue = tx.amount;
      final inv = dbState.investments.firstWhereOrNull((i) => i.id == tx.investmentId);
      largestInvestmentName = inv?.name ?? 'Unknown';
    }
  }
  if (largestInvestmentValue > 0) {
    biggestChanges.add(ChangeItem(
      label: 'Largest Investment',
      name: largestInvestmentName,
      amount: largestInvestmentValue,
    ));
  }

  // 7. Auto-generated Insights
  final List<String> insights = [];
  if (monthlyChange != 0.0) {
    final String direction = monthlyChange > 0 ? 'increased' : 'decreased';
    insights.add('Your net worth $direction ${monthlyChangePercent.abs().toStringAsFixed(1)}% this month.');
  }
  if (liabilitiesReduced > 0) {
    insights.add('Liabilities decreased by ${dbState.currency}${NumberFormat.decimalPattern().format(liabilitiesReduced)}.');
  }
  if (investmentsAdded > 0) {
    insights.add('Invested capital increased by ${dbState.currency}${NumberFormat.decimalPattern().format(investmentsAdded)}.');
  }
  if (receivablesRecovered > 0) {
    insights.add('Receivables recovered ${dbState.currency}${NumberFormat.decimalPattern().format(receivablesRecovered)}.');
  }
  if (insights.isEmpty) {
    insights.add('Add more transactions to generate custom wealth insights.');
  }

  // 8. Trend Spots & Dates
  final List<FlSpot> trendSpots = [];
  final List<String> trendDates = [];
  for (int i = 0; i < sortedSnaps.length; i++) {
    trendSpots.add(FlSpot(sortedSnaps[i].snapshotDate.millisecondsSinceEpoch.toDouble(), sortedSnaps[i].netWorth));
    trendDates.add(DateFormat('MMM yy').format(sortedSnaps[i].snapshotDate.toLocal()));
  }
  // Add current net worth as the final curve spot
  trendSpots.add(FlSpot(now.millisecondsSinceEpoch.toDouble(), currentNetWorth));
  trendDates.add(DateFormat('MMM yy').format(now.toLocal()));

  // 9. Growth History
  final List<double> growthData = [];
  final List<String> growthMonths = [];
  for (int i = 1; i < sortedSnaps.length; i++) {
    final prev = sortedSnaps[i - 1].netWorth;
    final curr = sortedSnaps[i].netWorth;
    growthData.add(curr - prev);
    growthMonths.add(DateFormat('MMM').format(sortedSnaps[i].snapshotDate.toLocal()));
  }
  if (sortedSnaps.isNotEmpty) {
    final prev = sortedSnaps.last.netWorth;
    final curr = currentNetWorth;
    growthData.add(curr - prev);
    growthMonths.add(DateFormat('MMM').format(now));
  }

  // --- Portfolio metrics calculations ---
  final activeInvestments = dbState.investments.where((i) => i.isArchived == 0).toList();
  final List<Map<String, dynamic>> holdingDurations = [];
  double totalHoldingDays = 0.0;
  for (final inv in activeInvestments) {
    final purchaseDateTime = inv.purchaseDate ?? inv.createdAt;
    final diff = now.difference(purchaseDateTime).inDays;
    final days = diff >= 0 ? diff : 0;
    final ageDiff = now.difference(inv.createdAt).inDays;
    final ageDays = ageDiff >= 0 ? ageDiff : 0;
    holdingDurations.add({
      'name': inv.name,
      'days': days,
      'purchaseDate': purchaseDateTime,
      'id': inv.id,
      'age': ageDays,
      'createdAt': inv.createdAt,
    });
    totalHoldingDays += days;
  }
  final double averageHoldingPeriod = activeInvestments.isNotEmpty
      ? totalHoldingDays / activeInvestments.length
      : 0.0;

  double sipInvestedCapital = 0.0;
  double sipCurrentValuation = 0.0;
  int totalSipPastOccurrences = 0;
  int completedSipOccurrences = 0;

  for (final sip in dbState.sips) {
    final investment = dbState.investments.firstWhereOrNull((i) => i.id == sip.investmentId);
    if (investment == null) continue;

    final sipTxs = dbState.transactions.where((t) =>
        t.type == 'investment_buy' &&
        t.investmentId == sip.investmentId &&
        t.notes != null &&
        t.notes!.contains('SIP ID: ${sip.id}') &&
        t.voidedTransactionId == null).toList();

    final double investedAmt = sipTxs.fold(0.0, (sum, t) => sum + t.amount);
    final double unitsBought = sipTxs.fold(0.0, (sum, t) => sum + (t.units ?? 0.0));

    sipInvestedCapital += investedAmt;
    sipCurrentValuation += unitsBought * (investment.marketValue ?? 1.0);

    final occurrences = _getSipOccurrences(sip, dbState.transactions, now);
    for (final occ in occurrences) {
      totalSipPastOccurrences++;
      if (occ.isCompleted) {
        completedSipOccurrences++;
      }
    }
  }

  final double sipGrowth = sipCurrentValuation - sipInvestedCapital;
  final double sipConsistencyRate = totalSipPastOccurrences > 0
      ? (completedSipOccurrences / totalSipPastOccurrences) * 100.0
      : 100.0;

  double totalPaidInterest = dbState.transactions
      .where((t) => t.category == 'MTF Interest' && t.voidedTransactionId == null)
      .fold(0.0, (sum, t) => sum + t.amount);

  double totalOutstandingInterest = 0.0;
  final activeMtfPositions = dbState.mtfPositions.where((p) => p.isClosed == 0).toList();
  for (final pos in activeMtfPositions) {
    final openDate = DateTime(pos.openingDate.year, pos.openingDate.month, pos.openingDate.day);
    final daysHeld = now.difference(openDate).inDays;
    final dailyInterest = pos.borrowedCapital * (pos.interestRate / 100) / 365;
    final accrued = dailyInterest * (daysHeld >= 0 ? daysHeld : 0);
    
    final paidForPos = dbState.transactions
        .where((t) => t.investmentId == pos.investmentId && t.category == 'MTF Interest' && t.voidedTransactionId == null)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final outstanding = accrued - paidForPos;
    if (outstanding > 0) {
      totalOutstandingInterest += outstanding;
    }
  }

  double totalAccruedInterest = totalPaidInterest + totalOutstandingInterest;

  final mtfInterestTransactions = dbState.transactions
      .where((t) => t.category == 'MTF Interest' && t.voidedTransactionId == null)
      .toList()
    ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

  final List<Map<String, dynamic>> mtfInterestHistory = mtfInterestTransactions.map((t) {
    final inv = dbState.investments.firstWhereOrNull((i) => i.id == t.investmentId);
    return {
      'date': t.transactionDate,
      'instrument': inv?.name ?? 'Unknown Position',
      'amount': t.amount,
      'notes': t.notes ?? 'MTF Interest Accrued',
    };
  }).toList();

  return WealthIntelligenceData(
    currentNetWorth: currentNetWorth,
    monthlyChange: monthlyChange,
    monthlyChangePercent: monthlyChangePercent,
    quarterlyChange: quarterlyChange,
    quarterlyChangePercent: quarterlyChangePercent,
    yearlyChange: yearlyChange,
    yearlyChangePercent: yearlyChangePercent,
    totalAssets: totalAssets,
    totalLiabilities: totalLiabilities,
    totalReceivables: totalReceivables,
    totalInvestedCapital: totalInvestedCapital,
    totalExpectedIncome: totalExpectedIncome,
    assetAllocation: assetAllocation,
    liabilityAllocation: liabilityAllocation,
    investmentAllocation: investmentAllocation,
    newAssetsAdded: newAssetsAdded,
    liabilitiesReduced: liabilitiesReduced,
    receivablesRecovered: receivablesRecovered,
    investmentsAdded: investmentsAdded,
    expectedIncomeReceived: expectedIncomeReceived,
    timeline: timeline,
    biggestChanges: biggestChanges,
    insights: insights,
    trendSpots: trendSpots,
    trendDates: trendDates,
    growthData: growthData,
    growthMonths: growthMonths,
    hasData: true,
    averageHoldingPeriod: averageHoldingPeriod,
    holdingDurations: holdingDurations,
    sipPerformance: {
      'investedCapital': sipInvestedCapital,
      'currentValuation': sipCurrentValuation,
      'growth': sipGrowth,
      'consistencyRate': sipConsistencyRate,
    },
    mtfInterestSummary: {
      'accrued': totalAccruedInterest,
      'paid': totalPaidInterest,
      'outstanding': totalOutstandingInterest,
    },
    mtfInterestHistory: mtfInterestHistory,
  );
});

class _SipOccurrence {
  final DateTime date;
  final bool isCompleted;
  _SipOccurrence({required this.date, required this.isCompleted});
}

List<_SipOccurrence> _getSipOccurrences(Sip sip, List<Transaction> transactions, DateTime today) {
  final List<_SipOccurrence> list = [];
  DateTime current = DateTime(sip.startDate.year, sip.startDate.month, sip.startDate.day);
  final end = sip.endDate != null && sip.endDate!.isBefore(today)
      ? DateTime(sip.endDate!.year, sip.endDate!.month, sip.endDate!.day)
      : today;

  if (current.isAfter(end)) return list;

  int loops = 0;
  while ((current.isBefore(end) || current.isAtSameMomentAs(end)) && loops < 500) {
    loops++;
    bool matches = false;
    if (sip.frequency == 'weekly') {
      if (current.weekday == sip.sipDate) matches = true;
    } else if (sip.frequency == 'monthly') {
      final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
      final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
      if (current.day == targetDay) matches = true;
    } else if (sip.frequency == 'quarterly') {
      final monthDiff = current.month - sip.startDate.month;
      if (monthDiff % 3 == 0) {
        final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
        final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
        if (current.day == targetDay) matches = true;
      }
    }

    if (matches) {
      final isCompleted = transactions.any((t) =>
          t.type == 'investment_buy' &&
          t.investmentId == sip.investmentId &&
          t.notes != null &&
          t.notes!.contains('SIP ID: ${sip.id}') &&
          t.transactionDate.year == current.year &&
          t.transactionDate.month == current.month &&
          t.transactionDate.day == current.day &&
          t.voidedTransactionId == null);

      list.add(_SipOccurrence(
        date: current,
        isCompleted: isCompleted,
      ));
    }
    current = current.add(const Duration(days: 1));
  }
  return list;
}
