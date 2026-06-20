import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../database/database.dart';
import '../../database/seeder.dart';
export '../../database/database.dart' hide Transaction, Snapshot, Account, Investment, Goal, ExpectedIncome, Milestone, Achievement, AchievementProgress, Sip;
import 'package:collection/collection.dart';
import 'dart:convert';
import 'app_providers.dart';
import 'dependency_provider.dart';
import '../mock_data/mock_constants.dart';
import '../mock_data/mock_accounts.dart';
import '../mock_data/mock_assets.dart';
import '../mock_data/mock_liabilities.dart';
import '../mock_data/mock_investments.dart';
import '../mock_data/mock_goals.dart';
import '../mock_data/mock_expected_incomes.dart';
import '../mock_data/mock_snapshots.dart';
import '../mock_data/mock_transactions.dart';
import '../../features/ipo_pool/domain/entities/ipo_pool_models.dart';
import '../../features/investments/domain/entities/sip.dart' as domain;
import '../utils/sip_calculator.dart';
import '../calculation/liability_calculation_service.dart';

class MockDatabaseState {
  final List<Account> accounts;
  final List<Person> people;
  final List<Investment> investments;
  final List<InvestmentLot> investmentLots;
  final List<InvestmentLotConsumption> investmentLotConsumptions;
  final List<Transaction> transactions;
  final List<ExpectedIncome> expectedIncomes;
  final List<Goal> goals;
  final List<Snapshot> snapshots;
  final List<Adjustment> adjustments;
  final List<IpoPool> ipoPools;
  final List<MtfPosition> mtfPositions;
  final List<Sip> sips;
  final List<String> categories;
  final List<String> customLabels;
  final List<PortfolioHistory> portfolioHistory;
  final List<PortfolioSnapshot> portfolioSnapshots;
  final List<RecoveryAllocation> recoveryAllocations;
  final List<RecoveryDestination> recoveryDestinations;
  final List<ReceivableActivity> receivableActivities;
  final String userUpiId;
  final String userUpiName;
  final String userUpiBank;
  
  // Settings & Auth State
  final String currency;
  final String themeMode; // 'light' | 'dark' | 'system'
  final bool appLockEnabled;
  final String appLockPin;
  final int appLockTimeout;
  final bool isLoggedIn;
  final bool isOnboarded;
  final bool onboardingCompleted;
  final bool firstAccountCreated;
  final bool checkInEnabled;
  final String checkInTimes;
  final String checkInReminderCount;
  final String checkInCompletedDate;
  final String lastTriggeredCheckIn;
  final bool notificationsEnabled;
  final bool notificationPrefTransactions;
  final bool notificationPrefCheckIns;
  final bool notificationPrefSip;
  final bool notificationPrefGoals;
  final bool notificationsAsked;
  final DateTime? userCreatedAt;

  MockDatabaseState({
    this.accounts = const [],
    this.people = const [],
    this.investments = const [],
    this.investmentLots = const [],
    this.investmentLotConsumptions = const [],
    this.transactions = const [],
    this.expectedIncomes = const [],
    this.goals = const [],
    this.snapshots = const [],
    this.adjustments = const [],
    this.ipoPools = const [],
    this.mtfPositions = const [],
    this.sips = const [],
    this.categories = const [],
    this.customLabels = const [],
    this.portfolioHistory = const [],
    this.portfolioSnapshots = const [],
    this.recoveryAllocations = const [],
    this.recoveryDestinations = const [],
    this.receivableActivities = const [],
    this.userUpiId = '',
    this.userUpiName = '',
    this.userUpiBank = '',
    this.currency = '₹',
    this.themeMode = 'dark',
    this.appLockEnabled = false,
    this.appLockPin = '',
    this.appLockTimeout = 30000,
    this.isLoggedIn = true,
    this.isOnboarded = true,
    this.onboardingCompleted = true,
    this.firstAccountCreated = true,
    this.checkInEnabled = false,
    this.checkInTimes = '',
    this.checkInReminderCount = '0',
    this.checkInCompletedDate = '',
    this.lastTriggeredCheckIn = '',
    this.notificationsEnabled = false,
    this.notificationPrefTransactions = false,
    this.notificationPrefCheckIns = false,
    this.notificationPrefSip = false,
    this.notificationPrefGoals = false,
    this.notificationsAsked = false,
    this.userCreatedAt,
  });

  MockDatabaseState copyWith({
    List<Account>? accounts,
    List<Person>? people,
    List<Investment>? investments,
    List<InvestmentLot>? investmentLots,
    List<InvestmentLotConsumption>? investmentLotConsumptions,
    List<Transaction>? transactions,
    List<ExpectedIncome>? expectedIncomes,
    List<Goal>? goals,
    List<Snapshot>? snapshots,
    List<Adjustment>? adjustments,
    List<IpoPool>? ipoPools,
    List<MtfPosition>? mtfPositions,
    List<Sip>? sips,
    List<String>? categories,
    List<String>? customLabels,
    List<PortfolioHistory>? portfolioHistory,
    List<PortfolioSnapshot>? portfolioSnapshots,
    List<RecoveryAllocation>? recoveryAllocations,
    List<RecoveryDestination>? recoveryDestinations,
    List<ReceivableActivity>? receivableActivities,
    String? userUpiId,
    String? userUpiName,
    String? userUpiBank,
    String? currency,
    String? themeMode,
    bool? appLockEnabled,
    String? appLockPin,
    int? appLockTimeout,
    bool? isLoggedIn,
    bool? isOnboarded,
    bool? onboardingCompleted,
    bool? firstAccountCreated,
    bool? checkInEnabled,
    String? checkInTimes,
    String? checkInReminderCount,
    String? checkInCompletedDate,
    String? lastTriggeredCheckIn,
    bool? notificationsEnabled,
    bool? notificationPrefTransactions,
    bool? notificationPrefCheckIns,
    bool? notificationPrefSip,
    bool? notificationPrefGoals,
    bool? notificationsAsked,
    DateTime? userCreatedAt,
  }) {
    return MockDatabaseState(
      accounts: accounts ?? this.accounts,
      people: people ?? this.people,
      investments: investments ?? this.investments,
      investmentLots: investmentLots ?? this.investmentLots,
      investmentLotConsumptions: investmentLotConsumptions ?? this.investmentLotConsumptions,
      transactions: transactions ?? this.transactions,
      expectedIncomes: expectedIncomes ?? this.expectedIncomes,
      goals: goals ?? this.goals,
      snapshots: snapshots ?? this.snapshots,
      adjustments: adjustments ?? this.adjustments,
      ipoPools: ipoPools ?? this.ipoPools,
      mtfPositions: mtfPositions ?? this.mtfPositions,
      sips: sips ?? this.sips,
      categories: categories ?? this.categories,
      customLabels: customLabels ?? this.customLabels,
      portfolioHistory: portfolioHistory ?? this.portfolioHistory,
      portfolioSnapshots: portfolioSnapshots ?? this.portfolioSnapshots,
      recoveryAllocations: recoveryAllocations ?? this.recoveryAllocations,
      recoveryDestinations: recoveryDestinations ?? this.recoveryDestinations,
      receivableActivities: receivableActivities ?? this.receivableActivities,
      userUpiId: userUpiId ?? this.userUpiId,
      userUpiName: userUpiName ?? this.userUpiName,
      userUpiBank: userUpiBank ?? this.userUpiBank,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      appLockPin: appLockPin ?? this.appLockPin,
      appLockTimeout: appLockTimeout ?? this.appLockTimeout,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      firstAccountCreated: firstAccountCreated ?? this.firstAccountCreated,
      checkInEnabled: checkInEnabled ?? this.checkInEnabled,
      checkInTimes: checkInTimes ?? this.checkInTimes,
      checkInReminderCount: checkInReminderCount ?? this.checkInReminderCount,
      checkInCompletedDate: checkInCompletedDate ?? this.checkInCompletedDate,
      lastTriggeredCheckIn: lastTriggeredCheckIn ?? this.lastTriggeredCheckIn,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationPrefTransactions: notificationPrefTransactions ?? this.notificationPrefTransactions,
      notificationPrefCheckIns: notificationPrefCheckIns ?? this.notificationPrefCheckIns,
      notificationPrefSip: notificationPrefSip ?? this.notificationPrefSip,
      notificationPrefGoals: notificationPrefGoals ?? this.notificationPrefGoals,
      notificationsAsked: notificationsAsked ?? this.notificationsAsked,
      userCreatedAt: userCreatedAt ?? this.userCreatedAt,
    );
  }

  // --- Derived Calculations ---

  double getAccountCashBalance(String accountId) {
    double balance = 0.0;
    for (final tx in transactions) {
      if (tx.voidedTransactionId != null || tx.type == 'void') continue;

      if (tx.toAccountId == accountId) {
        // Income, positive transfer, recover, borrow, etc.
        balance += tx.amount;
      }
      if (tx.fromAccountId == accountId) {
        // Expense, negative transfer, lend, repay, etc.
        balance -= tx.amount;
      }
    }
    for (final adj in adjustments) {
      if (adj.entityId == accountId && adj.entityType == 'account') {
        balance += adj.adjustedAmount;
      }
    }
    return balance;
  }

  double getAccountLiabilityBalance(String accountId) {
    final account = accounts.firstWhere((a) => a.id == accountId);
    if (account.type != 'credit') return 0.0;
    
    double liability = 0.0;
    for (final tx in transactions) {
      if (tx.voidedTransactionId != null || tx.type == 'void') continue;

      if (tx.fromAccountId == accountId) {
        // Spending on credit card increases liability
        liability += tx.amount;
      }
      if (tx.toAccountId == accountId) {
        if (tx.type == 'borrow_money' || tx.type == 'interest_accrued') {
          // Opening balance or borrowing increases liability
          liability += tx.amount;
        } else {
          // Repayments, transfers, refunds/incomes decrease liability
          liability -= tx.amount;
        }
      }
    }
    for (final adj in adjustments) {
      if (adj.entityId == accountId && adj.entityType == 'account') {
        liability += adj.adjustedAmount;
      }
    }
    return liability;
  }

  double getPersonReceivableBalance(String personId) {
    double balance = 0.0;
    for (final tx in transactions) {
      if (tx.voidedTransactionId != null || tx.type == 'void') continue;

      if (tx.personId == personId) {
        if (tx.type == 'lend_money') {
          balance += tx.amount;
        } else if (tx.type == 'recover_money') {
          balance -= tx.amount;
        }
      }
    }
    for (final adj in adjustments) {
      if (adj.entityId == personId && adj.entityType == 'person_receivable') {
        balance += adj.adjustedAmount;
      }
    }
    return balance;
  }

  double getPersonLiabilityBalance(String personId) {
    double balance = 0.0;
    for (final tx in transactions) {
      if (tx.voidedTransactionId != null || tx.type == 'void') continue;

      if (tx.personId == personId) {
        if (tx.type == 'borrow_money' || tx.type == 'interest_accrued') {
          balance += tx.amount;
        } else if (tx.type == 'repay_money') {
          balance -= tx.amount;
        }
      }
    }
    for (final adj in adjustments) {
      if (adj.entityId == personId && adj.entityType == 'person_liability') {
        balance += adj.adjustedAmount;
      }
    }
    return balance;
  }

  double getInvestmentUnitsHeld(String investmentId) {
    double units = 0.0;
    for (final lot in investmentLots) {
      if (lot.investmentId == investmentId) {
        units += lot.unitsRemaining;
      }
    }
    return units;
  }

  double getInvestmentInvestedCapital(String investmentId) {
    double capital = 0.0;
    for (final lot in investmentLots) {
      if (lot.investmentId == investmentId) {
        capital += lot.unitsRemaining * lot.costPerUnit;
      }
    }
    for (final adj in adjustments) {
      if (adj.entityId == investmentId && adj.entityType == 'investment_capital') {
        capital += adj.adjustedAmount;
      }
    }
    return capital;
  }

  double getInvestmentRealizedGain(String investmentId) {
    double realized = 0.0;
    for (final cons in investmentLotConsumptions) {
      final lot = investmentLots.firstWhereOrNull((l) => l.id == cons.lotId);
      if (lot != null && lot.investmentId == investmentId) {
        realized += cons.realizedGainLoss;
      }
    }
    return realized;
  }

  double getInvestmentMarketValue(String investmentId) {
    final inv = investments.firstWhere((i) => i.id == investmentId);
    final units = getInvestmentUnitsHeld(investmentId);
    double value = (inv.marketValue ?? 0.0) * units;
    for (final adj in adjustments) {
      if (adj.entityId == investmentId && adj.entityType == 'investment_market_value') {
        value += adj.adjustedAmount;
      }
    }
    return value;
  }

  double getInvestmentUnrealizedGain(String investmentId) {
    final capital = getInvestmentInvestedCapital(investmentId);
    final value = getInvestmentMarketValue(investmentId);
    final units = getInvestmentUnitsHeld(investmentId);
    if (units == 0.0) return 0.0;
    return value - capital;
  }

  double get totalAssets {
    // 1. Account Cash Balances (non-credit type)
    double cash = 0.0;
    for (final acc in accounts) {
      if (acc.isArchived == 0 && acc.type != 'credit') {
        cash += getAccountCashBalance(acc.id);
      }
    }

    // 2. Receivables from people
    double receivables = 0.0;
    for (final p in people) {
      if (p.isArchived == 0) {
        receivables += getPersonReceivableBalance(p.id);
      }
    }

    // 3. Invested Capital across all investments
    double invested = 0.0;
    for (final inv in investments) {
      if (inv.isArchived == 0) {
        invested += getInvestmentInvestedCapital(inv.id);
      }
    }

    return cash + receivables + invested;
  }

  double get totalLiabilities {
    return LiabilityCalculationService.calculateTotalLiabilities(this);
  }

  double get netWorth {
    return LiabilityCalculationService.calculateNetWorth(this);
  }

  double get debtFundedAssets {
    double total = 0.0;
    
    // 1. Accounts
    for (final acc in accounts) {
      if (acc.isArchived == 0 && acc.type != 'credit') {
        final bal = getAccountCashBalance(acc.id);
        total += _getDebtPortion(acc.fundingSource, acc.fundingDetails, bal);
      }
    }
    
    // 2. Receivables
    for (final p in people) {
      if (p.isArchived == 0) {
        final bal = getPersonReceivableBalance(p.id);
        final tx = transactions.firstWhereOrNull((t) => t.type == 'lend_money' && t.personId == p.id);
        total += _getDebtPortion(tx?.fundingSource, tx?.fundingDetails, bal);
      }
    }
    
    // 3. Investments
    for (final inv in investments) {
      if (inv.isArchived == 0) {
        final bal = getInvestmentInvestedCapital(inv.id);
        total += _getDebtPortion(inv.fundingSource, inv.fundingDetails, bal);
      }
    }
    
    return total;
  }

  double get selfFundedAssets {
    return totalAssets - debtFundedAssets;
  }

  Map<String, double> get fundingSourceBreakdown {
    final Map<String, double> breakdown = {
      'existing_cash': 0.0,
      'salary_income': 0.0,
      'business_income': 0.0,
      'receivable_collected': 0.0,
      'liability_borrowed': 0.0,
      'mixed_sources': 0.0,
    };
    
    // 1. Accounts
    for (final acc in accounts) {
      if (acc.isArchived == 0 && acc.type != 'credit') {
        final bal = getAccountCashBalance(acc.id);
        final source = acc.fundingSource ?? 'existing_cash';
        breakdown[source] = (breakdown[source] ?? 0.0) + bal;
      }
    }
    
    // 2. Receivables
    for (final p in people) {
      if (p.isArchived == 0) {
        final bal = getPersonReceivableBalance(p.id);
        final tx = transactions.firstWhereOrNull((t) => t.type == 'lend_money' && t.personId == p.id);
        final source = tx?.fundingSource ?? 'existing_cash';
        breakdown[source] = (breakdown[source] ?? 0.0) + bal;
      }
    }
    
    // 3. Investments
    for (final inv in investments) {
      if (inv.isArchived == 0) {
        final bal = getInvestmentInvestedCapital(inv.id);
        final source = inv.fundingSource ?? 'existing_cash';
        breakdown[source] = (breakdown[source] ?? 0.0) + bal;
      }
    }
    
    return breakdown;
  }

  double _getDebtPortion(String? fundingSource, String? fundingDetails, double assetValue) {
    if (fundingSource == 'liability_borrowed') {
      return assetValue;
    }
    if (fundingSource == 'mixed_sources') {
      if (fundingDetails != null && fundingDetails.isNotEmpty) {
        try {
          final decoded = jsonDecode(fundingDetails);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('debt_pct')) {
              final pct = (decoded['debt_pct'] as num).toDouble();
              return assetValue * (pct / 100.0);
            }
            if (decoded.containsKey('debt_ratio')) {
              final ratio = (decoded['debt_ratio'] as num).toDouble();
              return assetValue * ratio;
            }
            if (decoded.containsKey('debt_amount')) {
              final debtAmt = (decoded['debt_amount'] as num).toDouble();
              if (decoded.containsKey('total_amount')) {
                final totalAmt = (decoded['total_amount'] as num).toDouble();
                if (totalAmt > 0) {
                  return assetValue * (debtAmt / totalAmt);
                }
              }
              return debtAmt.clamp(0.0, assetValue);
            }
          }
        } catch (e) {
          // ignore
        }
        
        final lowercase = fundingDetails.toLowerCase();
        final regexPct = RegExp(r'(\d+)\s*%\s*debt');
        final matchPct = regexPct.firstMatch(lowercase);
        if (matchPct != null) {
          final pct = double.tryParse(matchPct.group(1) ?? '0') ?? 0.0;
          return assetValue * (pct / 100.0);
        }
        final regexAmt = RegExp(r'debt\s*[:=]\s*(\d+)');
        final matchAmt = regexAmt.firstMatch(lowercase);
        if (matchAmt != null) {
          final amt = double.tryParse(matchAmt.group(1) ?? '0') ?? 0.0;
          return amt.clamp(0.0, assetValue);
        }
      }
      return assetValue * 0.5;
    }
    return 0.0;
  }

  double get totalInvestedCapital {
    double total = 0.0;
    for (final inv in investments) {
      if (inv.isArchived == 0) {
        total += getInvestmentInvestedCapital(inv.id);
      }
    }
    return total;
  }

  double getExpectedIncomeAmount(String incomeId) {
    final inc = expectedIncomes.firstWhere((i) => i.id == incomeId);
    double amount = inc.amount;
    for (final adj in adjustments) {
      if (adj.entityId == incomeId && adj.entityType == 'expected_income') {
        amount += adj.adjustedAmount;
      }
    }
    return amount;
  }

  double get totalExpectedIncome {
    double total = 0.0;
    for (final inc in expectedIncomes) {
      if (inc.status == 'pending') {
        total += getExpectedIncomeAmount(inc.id);
      }
    }
    return total;
  }

  MockDatabaseState reconstructPortfolioOnDate(DateTime targetDate) {
    // 1. Filter transactions on or before targetDate
    final filteredTxs = transactions.where((tx) => !tx.transactionDate.isAfter(targetDate)).toList();
    final filteredTxIds = filteredTxs.map((t) => t.id).toSet();
    
    // 2. Filter adjustments on or before targetDate
    final filteredAdjustments = adjustments.where((adj) => !adj.createdAt.isAfter(targetDate)).toList();

    // 3. Reconstruct investment lots as of targetDate
    final reconstructedLots = investmentLots.where((lot) => !lot.purchaseDate.isAfter(targetDate)).map((lot) {
      double consumedBeforeTarget = 0.0;
      for (final cons in investmentLotConsumptions) {
        if (cons.lotId == lot.id && filteredTxIds.contains(cons.sellTransactionId)) {
          consumedBeforeTarget += cons.unitsConsumed;
        }
      }
      return lot.copyWith(
        unitsRemaining: lot.unitsPurchased - consumedBeforeTarget,
      );
    }).toList();

    // 4. Reconstruct expected incomes as of targetDate
    final reconstructedExpectedIncomes = expectedIncomes.where((i) => !i.createdAt.isAfter(targetDate)).map((i) {
      final isReceivedAfterTarget = i.status == 'received' && 
          i.receivedTransactionId != null && 
          !filteredTxIds.contains(i.receivedTransactionId);
      if (isReceivedAfterTarget) {
        return i.copyWith(status: 'pending');
      }
      return i;
    }).toList();

    // 5. Reconstruct MTF positions as of targetDate
    final reconstructedMtf = mtfPositions.where((p) => !p.openingDate.isAfter(targetDate)).map((p) {
      final closedDateVal = p.closedDate;
      final isClosedAfterTarget = p.isClosed == 1 && 
          closedDateVal != null && 
          closedDateVal.isAfter(targetDate);
      if (isClosedAfterTarget) {
        return p.copyWith(isClosed: 0, closedDate: const Value(null));
      }
      return p;
    }).toList();

    // 6. Return a reconstructed MockDatabaseState
    return MockDatabaseState(
      accounts: accounts.where((a) => !a.createdAt.isAfter(targetDate)).toList(),
      people: people.where((p) => !p.createdAt.isAfter(targetDate)).toList(),
      investments: investments.where((i) => !i.createdAt.isAfter(targetDate)).toList(),
      investmentLots: reconstructedLots,
      investmentLotConsumptions: investmentLotConsumptions.where((c) => filteredTxIds.contains(c.sellTransactionId)).toList(),
      transactions: filteredTxs,
      expectedIncomes: reconstructedExpectedIncomes,
      goals: goals.where((g) => !g.createdAt.isAfter(targetDate)).toList(),
      snapshots: snapshots.where((s) => !s.snapshotDate.isAfter(targetDate)).toList(),
      adjustments: filteredAdjustments,
      ipoPools: ipoPools.where((p) => !p.createdAt.isAfter(targetDate)).toList(),
      mtfPositions: reconstructedMtf,
      sips: sips.where((s) => !s.startDate.isAfter(targetDate)).toList(),
      categories: categories,
      customLabels: customLabels,
      portfolioHistory: portfolioHistory.where((h) => !h.createdAt.isAfter(targetDate)).toList(),
      portfolioSnapshots: portfolioSnapshots.where((s) => !s.snapshotDate.isAfter(targetDate)).toList(),
      recoveryAllocations: recoveryAllocations.where((a) => !a.createdAt.isAfter(targetDate)).toList(),
      recoveryDestinations: recoveryDestinations.where((d) => !d.createdAt.isAfter(targetDate)).toList(),
      receivableActivities: receivableActivities.where((a) => !a.createdAt.isAfter(targetDate)).toList(),
      userUpiId: userUpiId,
      userUpiName: userUpiName,
      userUpiBank: userUpiBank,
      currency: currency,
      themeMode: themeMode,
      appLockEnabled: appLockEnabled,
      appLockPin: appLockPin,
      appLockTimeout: appLockTimeout,
      isLoggedIn: isLoggedIn,
      isOnboarded: isOnboarded,
      onboardingCompleted: onboardingCompleted,
      firstAccountCreated: firstAccountCreated,
      checkInEnabled: checkInEnabled,
      checkInTimes: checkInTimes,
      checkInReminderCount: checkInReminderCount,
      checkInCompletedDate: checkInCompletedDate,
      lastTriggeredCheckIn: lastTriggeredCheckIn,
      notificationsEnabled: notificationsEnabled,
      notificationPrefTransactions: notificationPrefTransactions,
      notificationPrefCheckIns: notificationPrefCheckIns,
      notificationPrefSip: notificationPrefSip,
      notificationPrefGoals: notificationPrefGoals,
      notificationsAsked: notificationsAsked,
      userCreatedAt: userCreatedAt,
    );
  }
}

class MockDatabaseNotifier extends StateNotifier<MockDatabaseState> {
  final Ref _ref;

  MockDatabaseNotifier(this._ref) : super(initialState()) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      loadStateFromDatabase();
      final db = _ref.read(realDatabaseProvider);
      db.tableUpdates().listen((_) {
        loadStateFromDatabase();
      });
    }
  }

  Future<void> _logHistory({
    required String action,
    required String entityType,
    required String entityId,
    required String entityName,
    required String valueChanged,
    String? previousValue,
    String? newValue,
    String? detailsJson,
  }) async {
    final isMock = _ref.read(mockModeProvider);
    final now = DateTime.now().toUtc();
    final historyId = _uuid.v4();
    
    final historyEntry = PortfolioHistory(
      id: historyId,
      createdAt: now,
      action: action,
      entityType: entityType,
      entityId: entityId,
      entityTitle: entityName,
      valueChanged: valueChanged,
      previousValue: previousValue,
      newValue: newValue,
      detailsJson: detailsJson,
    );
    
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.portfolioHistories).insert(historyEntry);
    } else {
      state = state.copyWith(
        portfolioHistory: [historyEntry, ...state.portfolioHistory],
      );
    }
  }

  MockDatabaseState _calculatePortfolioSnapshots(MockDatabaseState value) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    
    final dailyDate = todayMidnight;
    final weeklyDate = todayMidnight.subtract(Duration(days: todayMidnight.weekday - 1));
    final monthlyDate = DateTime(todayMidnight.year, todayMidnight.month, 1);
    
    final netWorthVal = value.netWorth;
    final assetsVal = value.totalAssets;
    final liabilitiesVal = value.totalLiabilities;
    final investmentsVal = value.totalInvestedCapital;
    
    double receivablesVal = 0.0;
    for (final p in value.people) {
      if (p.isArchived == 0) {
        receivablesVal += value.getPersonReceivableBalance(p.id);
      }
    }
    
    final List<PortfolioSnapshot> currentSnaps = List.from(value.portfolioSnapshots);
    bool changed = false;
    
    void processType(String type, DateTime date) {
      final idx = currentSnaps.indexWhere((s) => s.snapshotType == type && s.snapshotDate.year == date.year && s.snapshotDate.month == date.month && s.snapshotDate.day == date.day);
      if (idx == -1) {
        final newSnap = PortfolioSnapshot(
          id: _uuid.v4(),
          snapshotDate: date,
          snapshotType: type,
          netWorth: netWorthVal,
          assets: assetsVal,
          liabilities: liabilitiesVal,
          investments: investmentsVal,
          receivables: receivablesVal,
          createdAt: now.toUtc(),
        );
        currentSnaps.add(newSnap);
        changed = true;
        
        final isMock = _ref.read(mockModeProvider);
        if (!isMock) {
          final db = _ref.read(realDatabaseProvider);
          db.into(db.portfolioSnapshots).insert(newSnap).catchError((_) => 0);
        }
      } else {
        final existing = currentSnaps[idx];
        if (existing.netWorth != netWorthVal ||
            existing.assets != assetsVal ||
            existing.liabilities != liabilitiesVal ||
            existing.investments != investmentsVal ||
            existing.receivables != receivablesVal) {
          final updated = PortfolioSnapshot(
            id: existing.id,
            snapshotDate: existing.snapshotDate,
            snapshotType: existing.snapshotType,
            netWorth: netWorthVal,
            assets: assetsVal,
            liabilities: liabilitiesVal,
            investments: investmentsVal,
            receivables: receivablesVal,
            createdAt: existing.createdAt,
          );
          currentSnaps[idx] = updated;
          changed = true;
          
          final isMock = _ref.read(mockModeProvider);
          if (!isMock) {
            final db = _ref.read(realDatabaseProvider);
            db.into(db.portfolioSnapshots).insertOnConflictUpdate(updated).catchError((_) => 0);
          }
        }
      }
    }
    
    processType('daily', dailyDate);
    processType('weekly', weeklyDate);
    processType('monthly', monthlyDate);
    
    if (changed) {
      currentSnaps.sort((a, b) => b.snapshotDate.compareTo(a.snapshotDate));
      return value.copyWith(portfolioSnapshots: currentSnaps);
    }
    return value;
  }

  @override
  set state(MockDatabaseState value) {
    // 1. Set the new state first
    super.state = value;

    // 2. Compute today's values
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final assetsVal = value.totalAssets;
    final liabilitiesVal = value.totalLiabilities;
    final netWorthVal = value.netWorth;
    final investedCapitalVal = value.totalInvestedCapital;
    final expectedIncomeVal = value.totalExpectedIncome;

    double receivablesVal = 0.0;
    for (final p in value.people) {
      if (p.isArchived == 0) {
        receivablesVal += value.getPersonReceivableBalance(p.id);
      }
    }

    final existingIndex = value.snapshots.indexWhere((s) {
      final sDate = s.snapshotDate;
      return sDate.year == todayMidnight.year && sDate.month == todayMidnight.month && sDate.day == todayMidnight.day;
    });

    bool needsUpdate = false;
    if (existingIndex == -1) {
      needsUpdate = true;
    } else {
      final existing = value.snapshots[existingIndex];
      if (existing.netWorth != netWorthVal ||
          existing.assets != assetsVal ||
          existing.liabilities != liabilitiesVal ||
          existing.receivables != receivablesVal ||
          existing.investedCapital != investedCapitalVal ||
          existing.expectedIncome != expectedIncomeVal) {
        needsUpdate = true;
      }
    }

    List<Snapshot> updatedSnapshots = value.snapshots;
    if (needsUpdate) {
      final List<Snapshot> newList = List.from(value.snapshots);
      if (existingIndex != -1) {
        newList[existingIndex] = newList[existingIndex].copyWith(
          netWorth: netWorthVal,
          assets: assetsVal,
          liabilities: liabilitiesVal,
          receivables: receivablesVal,
          investedCapital: investedCapitalVal,
          expectedIncome: expectedIncomeVal,
          updatedAt: now,
        );
      } else {
        newList.add(Snapshot(
          id: _uuid.v4(),
          snapshotDate: todayMidnight,
          netWorth: netWorthVal,
          assets: assetsVal,
          liabilities: liabilitiesVal,
          receivables: receivablesVal,
          investedCapital: investedCapitalVal,
          expectedIncome: expectedIncomeVal,
          createdAt: now,
          updatedAt: now,
          syncStatus: 'pending',
        ));
      }
      updatedSnapshots = newList;
    }

    final valueWithSnaps = value.copyWith(snapshots: updatedSnapshots);
    final valueWithPortfolioSnaps = _calculatePortfolioSnapshots(valueWithSnaps);
    
    super.state = valueWithPortfolioSnaps;
  }

  void _queueSync(String entityType, String entityId, String operation) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(syncServiceProvider).queueOperation(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
      );
    }
  }

  void _syncSetting(String key) {
    _queueSync('setting', key, 'upsert');
  }

  Future<void> loadStateFromDatabase() async {
    try {
      final db = _ref.read(realDatabaseProvider);
      final rawAccounts = await db.select(db.accounts).get();
      final rawPeople = await db.select(db.people).get();
      final rawInvestments = await db.select(db.investments).get();
      final rawTransactions = await db.select(db.transactions).get();
      final rawExpectedIncomes = await db.select(db.expectedIncomes).get();
      final rawGoals = await db.select(db.goals).get();
      final snapshots = await db.select(db.snapshots).get();
      final investmentLots = await db.select(db.investmentLots).get();
      final consumptions = await db.select(db.investmentLotConsumptions).get();
      final adjustments = await db.select(db.adjustments).get();
      final settingsList = await db.select(db.settings).get();
      final rawMtfPositions = await db.select(db.mtfPositions).get();
      final rawSips = await db.select(db.sips).get();
      final rawPortfolioHistory = await db.select(db.portfolioHistories).get();
      final rawPortfolioSnapshots = await db.select(db.portfolioSnapshots).get();
      final rawRecoveryAllocations = await db.select(db.recoveryAllocations).get();
      final rawRecoveryDestinations = await db.select(db.recoveryDestinations).get();
      final rawReceivableActivities = await db.select(db.receivableActivities).get();

      final accounts = rawAccounts.where((x) => x.deletedAt == null).toList();
      final people = rawPeople.where((x) => x.deletedAt == null).toList();
      final investments = rawInvestments.where((x) => x.deletedAt == null).toList();
      final transactions = rawTransactions.where((x) => x.deletedAt == null).toList();
      final expectedIncomes = rawExpectedIncomes.where((x) => x.deletedAt == null).toList();
      final goals = rawGoals.where((x) => x.deletedAt == null).toList();
      final mtfPositions = rawMtfPositions.where((x) => x.deletedAt == null).toList();
      final sips = rawSips.where((x) => x.deletedAt == null).toList();
      final portfolioHistory = rawPortfolioHistory.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final portfolioSnapshots = rawPortfolioSnapshots.toList()..sort((a, b) => b.snapshotDate.compareTo(a.snapshotDate));
      final receivableActivities = rawReceivableActivities.toList()..sort((ReceivableActivity a, ReceivableActivity b) => b.createdAt.compareTo(a.createdAt));

      final settingsMap = {for (var s in settingsList) s.key: s.value};

      final userUpiId = settingsMap['user_upi_id'] ?? '';
      final userUpiName = settingsMap['user_upi_name'] ?? '';
      final userUpiBank = settingsMap['user_upi_bank'] ?? '';

      final currency = settingsMap['currency'] ?? '₹';
      final themeMode = settingsMap['themeMode'] ?? 'dark';
      final appLockEnabled = settingsMap['appLockEnabled'] == 'true';
      final appLockPin = settingsMap['appLockPin'] ?? '1234';
      final appLockTimeout = int.tryParse(settingsMap['appLockTimeout'] ?? '0') ?? 0;
      final isLoggedIn = settingsMap['isLoggedIn'] == 'true';
      final isOnboarded = settingsMap['isOnboarded'] == 'true';
      final onboardingCompleted = settingsMap['onboardingCompleted'] == 'true' || isOnboarded;
      final firstAccountCreated = settingsMap['firstAccountCreated'] == 'true' || accounts.isNotEmpty;
      final checkInEnabled = settingsMap['checkInEnabled'] != 'false';
      final checkInTimes = settingsMap['checkInTimes'] ?? '10:00,14:00,19:00,22:00';
      final checkInReminderCount = settingsMap['checkInReminderCount'] ?? '4';
      final checkInCompletedDate = settingsMap['checkInCompletedDate'] ?? '';
      final lastTriggeredCheckIn = settingsMap['lastTriggeredCheckIn'] ?? '';
      final notificationsEnabled = settingsMap['notificationsEnabled'] == 'true';
      final notificationPrefTransactions = settingsMap['notificationPrefTransactions'] != 'false';
      final notificationPrefCheckIns = settingsMap['notificationPrefCheckIns'] != 'false';
      final notificationPrefSip = settingsMap['notificationPrefSip'] != 'false';
      final notificationPrefGoals = settingsMap['notificationPrefGoals'] != 'false';
      final notificationsAsked = settingsMap['notificationsAsked'] == 'true';

      List<String> categories = const [
        'Food', 'Travel', 'Shopping', 'Education', 'Bills', 'Subscriptions',
        'Health', 'Entertainment', 'Fees', 'General', 'Salary',
        'Investment Return', 'Miscellaneous'
      ];
      final categoriesData = settingsMap['categories'];
      if (categoriesData != null) {
        try {
          categories = List<String>.from(jsonDecode(categoriesData) as List);
        } catch (e) {
          // ignore
        }
      }

      List<String> customLabels = const ['Urgent', 'Personal', 'Tax Deductible', 'Business'];
      final labelsData = settingsMap['customLabels'];
      if (labelsData != null) {
        try {
          customLabels = List<String>.from(jsonDecode(labelsData) as List);
        } catch (e) {
          // ignore
        }
      }

      final userCreatedAtStr = settingsMap['user_created_at'];
      DateTime? userCreatedAt;
      if (userCreatedAtStr != null) {
        userCreatedAt = DateTime.tryParse(userCreatedAtStr);
      }

      if (userCreatedAt == null) {
        // Fallback checks
        // 1. Firebase Auth user metadata
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.metadata.creationTime != null) {
            userCreatedAt = currentUser.metadata.creationTime;
          }
        } catch (e) {
          // ignore
        }

        // 2. Oldest record in database
        if (userCreatedAt == null) {
          DateTime oldest = DateTime.now().toUtc();
          for (final a in accounts) {
            if (a.createdAt.isBefore(oldest)) oldest = a.createdAt;
          }
          for (final t in transactions) {
            if (t.createdAt.isBefore(oldest)) oldest = t.createdAt;
          }
          for (final g in goals) {
            if (g.createdAt.isBefore(oldest)) oldest = g.createdAt;
          }
          userCreatedAt = oldest;
        }

        // Save permanently to SQLite settings
        final resolvedString = userCreatedAt!.toUtc().toIso8601String();
        final isMock = _ref.read(mockModeProvider);
        if (!isMock) {
          final db = _ref.read(realDatabaseProvider);
          await db.into(db.settings).insertOnConflictUpdate(
            Setting(key: 'user_created_at', value: resolvedString),
          );
        }
      }

      List<IpoPool> ipoPools = [];
      final ipoPoolsData = settingsMap['ipo_pools_data'];
      if (ipoPoolsData != null) {
        try {
          final decoded = jsonDecode(ipoPoolsData) as List<dynamic>;
          ipoPools = decoded.map((item) => IpoPool.fromJson(item as Map<String, dynamic>)).toList();
        } catch (e) {
          // ignore parsing issues
        }
      }

      state = MockDatabaseState(
        accounts: accounts,
        people: people,
        investments: investments,
        investmentLots: investmentLots,
        investmentLotConsumptions: consumptions,
        transactions: transactions,
        expectedIncomes: expectedIncomes,
        goals: goals,
        snapshots: snapshots,
        adjustments: adjustments,
        ipoPools: ipoPools,
        mtfPositions: mtfPositions,
        sips: sips,
        categories: categories,
        customLabels: customLabels,
        portfolioHistory: portfolioHistory,
        portfolioSnapshots: portfolioSnapshots,
        recoveryAllocations: rawRecoveryAllocations.toList(),
        recoveryDestinations: rawRecoveryDestinations.toList(),
        receivableActivities: receivableActivities,
        userUpiId: userUpiId,
        userUpiName: userUpiName,
        userUpiBank: userUpiBank,
        currency: currency,
        themeMode: themeMode,
        appLockEnabled: appLockEnabled,
        appLockPin: appLockPin,
        appLockTimeout: appLockTimeout,
        isLoggedIn: isLoggedIn,
        isOnboarded: isOnboarded,
        onboardingCompleted: onboardingCompleted,
        firstAccountCreated: firstAccountCreated,
        checkInEnabled: checkInEnabled,
        checkInTimes: checkInTimes,
        checkInReminderCount: checkInReminderCount,
        checkInCompletedDate: checkInCompletedDate,
        lastTriggeredCheckIn: lastTriggeredCheckIn,
        notificationsEnabled: notificationsEnabled,
        notificationPrefTransactions: notificationPrefTransactions,
        notificationPrefCheckIns: notificationPrefCheckIns,
        notificationPrefSip: notificationPrefSip,
        notificationPrefGoals: notificationPrefGoals,
        notificationsAsked: notificationsAsked,
        userCreatedAt: userCreatedAt,
      );

      // Trigger background operations & gamification engine evaluation
      Future.microtask(() async {
        try {
          await runAutoInterestAccrual();
          await runAutoSipProcessing();
          await _ref.read(gamificationEngineProvider).evaluateAll();
        } catch (e) {
          // ignore
        }
      });
    } catch (e) {
      // Fallback silently if db is closed or locked
    }
  }

  static const _uuid = Uuid();

  // --- Auth / Onboarding Mutations ---

  void login() {
    state = state.copyWith(isLoggedIn: true);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'isLoggedIn', value: 'true'));
      _syncSetting('isLoggedIn');
    }
  }

  void logout() {
    state = state.copyWith(isLoggedIn: false);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'isLoggedIn', value: 'false'));
      _syncSetting('isLoggedIn');
    }
  }

  Future<void> setOnboardingCompleted() async {
    state = state.copyWith(onboardingCompleted: true);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'onboardingCompleted', value: 'true'));
      _syncSetting('onboardingCompleted');
    }
  }

  Future<void> setFirstAccountCreated() async {
    state = state.copyWith(firstAccountCreated: true);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'firstAccountCreated', value: 'true'));
      _syncSetting('firstAccountCreated');
    }
  }

  Future<void> completeOnboarding() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'isOnboarded', value: 'true'));
        await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'onboardingCompleted', value: 'true'));
        await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'firstAccountCreated', value: 'true'));
      });
      _syncSetting('isOnboarded');
      _syncSetting('onboardingCompleted');
      _syncSetting('firstAccountCreated');
    }
    state = state.copyWith(
      isOnboarded: true,
      onboardingCompleted: true,
      firstAccountCreated: true,
    );
  }

  void updateNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'notificationsEnabled', value: enabled ? 'true' : 'false'));
      _syncSetting('notificationsEnabled');
    }
  }

  void updateNotificationPref(String preferenceKey, bool value) {
    final isMock = _ref.read(mockModeProvider);
    if (preferenceKey == 'transactions') {
      state = state.copyWith(notificationPrefTransactions: value);
      if (!isMock) {
        final db = _ref.read(realDatabaseProvider);
        db.into(db.settings).insertOnConflictUpdate(Setting(key: 'notificationPrefTransactions', value: value ? 'true' : 'false'));
        _syncSetting('notificationPrefTransactions');
      }
    } else if (preferenceKey == 'checkins') {
      state = state.copyWith(notificationPrefCheckIns: value);
      if (!isMock) {
        final db = _ref.read(realDatabaseProvider);
        db.into(db.settings).insertOnConflictUpdate(Setting(key: 'notificationPrefCheckIns', value: value ? 'true' : 'false'));
        _syncSetting('notificationPrefCheckIns');
      }
    } else if (preferenceKey == 'sip') {
      state = state.copyWith(notificationPrefSip: value);
      if (!isMock) {
        final db = _ref.read(realDatabaseProvider);
        db.into(db.settings).insertOnConflictUpdate(Setting(key: 'notificationPrefSip', value: value ? 'true' : 'false'));
        _syncSetting('notificationPrefSip');
      }
    } else if (preferenceKey == 'goals') {
      state = state.copyWith(notificationPrefGoals: value);
      if (!isMock) {
        final db = _ref.read(realDatabaseProvider);
        db.into(db.settings).insertOnConflictUpdate(Setting(key: 'notificationPrefGoals', value: value ? 'true' : 'false'));
        _syncSetting('notificationPrefGoals');
      }
    }
  }

  void setNotificationsAsked(bool asked) {
    state = state.copyWith(notificationsAsked: asked);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'notificationsAsked', value: asked ? 'true' : 'false'));
      _syncSetting('notificationsAsked');
    }
  }

  // --- Settings Mutations ---

  void updateCurrency(String newCurrency) {
    state = state.copyWith(currency: newCurrency);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'currency', value: newCurrency));
      _syncSetting('currency');
    }
  }

  void updateTheme(String theme) {
    state = state.copyWith(themeMode: theme);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'themeMode', value: theme));
      _syncSetting('themeMode');
    }
  }

  void updateAppLock(bool enabled, String pin) {
    state = state.copyWith(appLockEnabled: enabled, appLockPin: pin);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'appLockEnabled', value: enabled ? 'true' : 'false'));
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'appLockPin', value: pin));
      _syncSetting('appLockEnabled');
      _syncSetting('appLockPin');
    }
  }

  void updateAppLockTimeout(int seconds) {
    state = state.copyWith(appLockTimeout: seconds);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'appLockTimeout', value: seconds.toString()));
      _syncSetting('appLockTimeout');
    }
  }

  Future<void> addManualMilestone(double amount) async {
    final isMock = _ref.read(mockModeProvider);
    final now = DateTime.now().toUtc();
    final milestoneId = 'milestone_manual_${amount.toInt()}_${DateTime.now().millisecondsSinceEpoch}';
    
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.milestones).insert(
        MilestonesCompanion.insert(
          id: milestoneId,
          amount: amount,
          isManual: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
      );
      // Immediately evaluate to check if it's achieved
      await _ref.read(gamificationEngineProvider).evaluateAll();
    }
  }

  // --- Database Mutations ---

  Future<Account> addAccount(
    String name,
    String type,
    String? notes,
    double openingBalance, {
    String? id,
    DateTime? openingDate,
    String? fundingSource,
    String? fundingLiabilityId,
    String? fundingDetails,
  }) async {
    final actualId = id ?? _uuid.v4();
    final now = DateTime.now().toUtc();
    final creationDate = openingDate ?? now;
    final newAccount = Account(
      id: actualId,
      name: name,
      type: type,
      notes: notes,
      isArchived: 0,
      createdAt: creationDate,
      updatedAt: now,
      syncStatus: 'pending',
      fundingSource: fundingSource,
      fundingLiabilityId: fundingLiabilityId,
      fundingDetails: fundingDetails,
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.accounts).insert(newAccount);
      _queueSync('account', actualId, 'upsert');
      if (openingBalance > 0) {
        if (type == 'credit') {
          await addBorrowTransaction(actualId, actualId, openingBalance, notes ?? 'Opening Balance Owed', creationDate);
        } else {
          await addTransaction(
            type: 'income',
            amount: openingBalance,
            toAccountId: actualId,
            category: 'Opening Balance',
            notes: notes ?? 'Initial deposit',
            date: creationDate,
            fundingSource: fundingSource,
            fundingLiabilityId: fundingLiabilityId,
            fundingDetails: fundingDetails,
          );
        }
      }
    } else {
      state = state.copyWith(
        accounts: [...state.accounts, newAccount],
        firstAccountCreated: true,
      );

      if (openingBalance > 0) {
        if (type == 'credit') {
          _createTransactionInternal(
            type: 'borrow_money',
            amount: openingBalance,
            toAccountId: actualId,
            notes: notes ?? 'Opening Balance Owed',
            date: creationDate,
          );
        } else {
          _createTransactionInternal(
            type: 'income',
            amount: openingBalance,
            toAccountId: actualId,
            category: 'Opening Balance',
            notes: notes ?? 'Initial deposit',
            date: creationDate,
            fundingSource: fundingSource,
            fundingLiabilityId: fundingLiabilityId,
            fundingDetails: fundingDetails,
          );
        }
      }
    }

    _logHistory(
      action: type == 'credit' ? 'Added Liability' : 'Added Asset',
      entityType: type == 'credit' ? 'Liability' : 'Asset',
      entityId: actualId,
      entityName: name,
      valueChanged: 'Opening Balance: ${state.currency}${openingBalance.toStringAsFixed(0)}',
      newValue: '${state.currency}${openingBalance.toStringAsFixed(0)}',
    );

    return newAccount;
  }

  Future<void> archiveAccount(String accountId) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.accounts)
        ..where((tbl) => tbl.id.equals(accountId))
        ..write(AccountsCompanion(isArchived: const Value(1), updatedAt: Value(DateTime.now().toUtc()))));
      _queueSync('account', accountId, 'upsert');
    } else {
      state = state.copyWith(
        accounts: state.accounts.map((a) {
          if (a.id == accountId) {
            return Account(
              id: a.id,
              name: a.name,
              type: a.type,
              notes: a.notes,
              isArchived: 1,
              createdAt: a.createdAt,
              updatedAt: DateTime.now().toUtc(),
              syncStatus: a.syncStatus,
            );
          }
          return a;
        }).toList(),
      );
    }
    final account = state.accounts.firstWhere((a) => a.id == accountId);
    _logHistory(
      action: account.type == 'credit' ? 'Deleted Liability' : 'Deleted Asset',
      entityType: account.type == 'credit' ? 'Liability' : 'Asset',
      entityId: accountId,
      entityName: account.name,
      valueChanged: 'Archived',
    );
  }

  Future<void> updateAccount(String id, String name, String type, String? notes) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.accounts)..where((tbl) => tbl.id.equals(id)))
        .write(AccountsCompanion(
          name: Value(name),
          type: Value(type),
          notes: Value(notes),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      _queueSync('account', id, 'upsert');
    } else {
      state = state.copyWith(
        accounts: state.accounts.map((a) {
          if (a.id == id) {
            return Account(
              id: a.id,
              name: name,
              type: type,
              notes: notes,
              isArchived: a.isArchived,
              createdAt: a.createdAt,
              updatedAt: DateTime.now().toUtc(),
              syncStatus: a.syncStatus,
            );
          }
          return a;
        }).toList(),
      );
    }
    final account = state.accounts.firstWhere((a) => a.id == id);
    _logHistory(
      action: account.type == 'credit' ? 'Edited Liability' : 'Edited Asset',
      entityType: account.type == 'credit' ? 'Liability' : 'Asset',
      entityId: id,
      entityName: name,
      valueChanged: 'Details updated',
      previousValue: account.name,
      newValue: name,
    );
  }

  Future<bool> deleteAccountEmpty(String id) async {
    final account = state.accounts.firstWhereOrNull((a) => a.id == id);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final countQuery = db.select(db.transactions)..where((tbl) => tbl.fromAccountId.equals(id) | tbl.toAccountId.equals(id));
      final count = (await countQuery.get()).length;
      if (count > 0) return false;
      if (account != null) {
        _logHistory(
          action: account.type == 'credit' ? 'Deleted Liability' : 'Deleted Asset',
          entityType: account.type == 'credit' ? 'Liability' : 'Asset',
          entityId: id,
          entityName: account.name,
          valueChanged: 'Permanently Deleted',
        );
      }
      await (db.delete(db.accounts)..where((tbl) => tbl.id.equals(id))).go();
      _queueSync('account', id, 'delete');
      return true;
    } else {
      final count = state.transactions.where((t) => t.fromAccountId == id || t.toAccountId == id).length;
      if (count > 0) return false;
      if (account != null) {
        _logHistory(
          action: account.type == 'credit' ? 'Deleted Liability' : 'Deleted Asset',
          entityType: account.type == 'credit' ? 'Liability' : 'Asset',
          entityId: id,
          entityName: account.name,
          valueChanged: 'Permanently Deleted',
        );
      }
      state = state.copyWith(accounts: state.accounts.where((a) => a.id != id).toList());
      return true;
    }
  }

  Future<void> clearAccountTransactions(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.delete(db.transactions)..where((tbl) => tbl.fromAccountId.equals(id) | tbl.toAccountId.equals(id))).go();
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    } else {
      state = state.copyWith(
        transactions: state.transactions.where((t) => t.fromAccountId != id && t.toAccountId != id).toList(),
      );
    }
  }

  Future<void> mergeAccounts(String fromId, String toId) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await (db.update(db.transactions)
          ..where((tbl) => tbl.fromAccountId.equals(fromId)))
          .write(TransactionsCompanion(fromAccountId: Value(toId)));
        await (db.update(db.transactions)
          ..where((tbl) => tbl.toAccountId.equals(fromId)))
          .write(TransactionsCompanion(toAccountId: Value(toId)));
        await (db.delete(db.accounts)..where((tbl) => tbl.id.equals(fromId))).go();
      });
      _queueSync('account', fromId, 'delete');
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    } else {
      state = state.copyWith(
        transactions: state.transactions.map((t) {
          String? from = t.fromAccountId;
          String? to = t.toAccountId;
          if (from == fromId) from = toId;
          if (to == fromId) to = toId;
          return t.copyWith(fromAccountId: Value(from), toAccountId: Value(to));
        }).toList(),
        accounts: state.accounts.where((a) => a.id != fromId).toList(),
      );
    }
  }

  Future<Person> addPerson(
    String name,
    String? phone,
    String? notes, [
    String type = 'personal_loan',
    String? whatsApp,
    DateTime? borrowDate,
    DateTime? dueDate,
    String? upiId,
    String? bankName,
    String? accountHolderName,
    String? photoPath,
  ]) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final newPerson = Person(
      id: id,
      name: name,
      phone: phone,
      notes: notes,
      isArchived: 0,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
      type: type,
      whatsApp: whatsApp,
      borrowDate: borrowDate,
      dueDate: dueDate,
      upiId: upiId,
      bankName: bankName,
      accountHolderName: accountHolderName,
      photoPath: photoPath,
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.people).insert(newPerson);
      _queueSync('person', id, 'upsert');
    } else {
      state = state.copyWith(people: [...state.people, newPerson]);
    }
    return newPerson;
  }

  Future<void> updatePerson(
    String id,
    String name,
    String? phone,
    String? notes, {
    String? whatsApp,
    DateTime? borrowDate,
    DateTime? dueDate,
    String? upiId,
    String? bankName,
    String? accountHolderName,
    String? photoPath,
  }) async {
    final isMock = _ref.read(mockModeProvider);
    final now = DateTime.now().toUtc();
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.people)..where((tbl) => tbl.id.equals(id)))
        .write(PeopleCompanion(
          name: Value(name),
          phone: Value(phone),
          notes: Value(notes),
          whatsApp: Value(whatsApp),
          borrowDate: Value(borrowDate),
          dueDate: Value(dueDate),
          upiId: Value(upiId),
          bankName: Value(bankName),
          accountHolderName: Value(accountHolderName),
          photoPath: Value(photoPath),
          updatedAt: Value(now),
        ));
      _queueSync('person', id, 'upsert');
    } else {
      state = state.copyWith(
        people: state.people.map((p) {
          if (p.id == id) {
            return Person(
              id: p.id,
              name: name,
              phone: phone,
              notes: notes,
              isArchived: p.isArchived,
              createdAt: p.createdAt,
              updatedAt: now,
              syncStatus: p.syncStatus,
              type: p.type,
              whatsApp: whatsApp ?? p.whatsApp,
              borrowDate: borrowDate ?? p.borrowDate,
              dueDate: dueDate ?? p.dueDate,
              upiId: upiId ?? p.upiId,
              bankName: bankName ?? p.bankName,
              accountHolderName: accountHolderName ?? p.accountHolderName,
              photoPath: photoPath ?? p.photoPath,
            );
          }
          return p;
        }).toList(),
      );
    }
  }

  Future<void> addReceivableActivity({
    required String personId,
    required String activityType,
    double? amount,
    String? channel,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final activity = ReceivableActivity(
      id: id,
      personId: personId,
      activityType: activityType,
      amount: amount,
      channel: channel,
      notes: notes,
      createdAt: now,
      syncStatus: 'pending',
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.receivableActivities).insert(activity);
      _queueSync('receivable_activity', id, 'upsert');
    } else {
      state = state.copyWith(
        receivableActivities: [activity, ...state.receivableActivities],
      );
    }
  }

  Future<void> updateUpiDetails(String upiId, String name, String bankName) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'user_upi_id', value: upiId));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'user_upi_name', value: name));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'user_upi_bank', value: bankName));
      _syncSetting('user_upi_id');
      _syncSetting('user_upi_name');
      _syncSetting('user_upi_bank');
    }
    state = state.copyWith(
      userUpiId: upiId,
      userUpiName: name,
      userUpiBank: bankName,
    );
  }

  Future<bool> deletePerson(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final countQuery = db.select(db.transactions)..where((tbl) => tbl.personId.equals(id));
      final count = (await countQuery.get()).length;
      if (count > 0) return false;
      await (db.delete(db.people)..where((tbl) => tbl.id.equals(id))).go();
      _queueSync('person', id, 'delete');
      return true;
    } else {
      final count = state.transactions.where((t) => t.personId == id).length;
      if (count > 0) return false;
      state = state.copyWith(
        people: state.people.where((p) => p.id != id).toList(),
      );
      return true;
    }
  }

  Future<void> archivePerson(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.people)..where((tbl) => tbl.id.equals(id)))
        .write(PeopleCompanion(
          isArchived: const Value(1),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      _queueSync('person', id, 'upsert');
    } else {
      state = state.copyWith(
        people: state.people.map((p) {
          if (p.id == id) {
            return Person(
              id: p.id,
              name: p.name,
              phone: p.phone,
              notes: p.notes,
              isArchived: 1,
              createdAt: p.createdAt,
              updatedAt: DateTime.now().toUtc(),
              syncStatus: p.syncStatus,
              type: p.type,
            );
          }
          return p;
        }).toList(),
      );
    }
  }

  Future<void> addLendTransaction(String personId, String? fromAccountId, double amount, String? notes, DateTime date) async {
    await addTransaction(
      type: 'lend_money',
      amount: amount,
      fromAccountId: fromAccountId,
      personId: personId,
      notes: notes,
      date: date,
    );
  }

  Future<void> addBorrowTransaction(String personId, String? toAccountId, double amount, String? notes, DateTime date) async {
    await addTransaction(
      type: 'borrow_money',
      amount: amount,
      toAccountId: toAccountId,
      personId: personId,
      notes: notes,
      date: date,
    );
  }

  Future<void> addRepayTransaction(String personId, String? fromAccountId, double amount, String? notes, DateTime date) async {
    await addTransaction(
      type: 'repay_money',
      amount: amount,
      fromAccountId: fromAccountId,
      personId: personId,
      notes: notes,
      date: date,
    );
  }

  Future<String> addRecoverTransaction(String personId, String? toAccountId, double amount, String? notes, DateTime date) async {
    final tx = await addTransaction(
      type: 'recover_money',
      amount: amount,
      toAccountId: toAccountId,
      personId: personId,
      notes: notes,
      date: date,
    );

    // Fetch outstanding balance to check if it's fully settled
    final outstanding = state.getPersonReceivableBalance(personId);
    final isSettle = (outstanding - amount).abs() < 0.01 || (outstanding - amount) <= 0;

    await addReceivableActivity(
      personId: personId,
      activityType: isSettle ? 'settled' : 'payment_received',
      amount: amount,
      notes: notes ?? (isSettle ? 'Full settlement completed' : 'Payment recovered'),
    );

    return tx.id;
  }

  /// Represents a single allocation destination for a recovery event.
  /// destinationType: Cash | BankAccount | Investment | MTFPosition | EmergencyFund | Goal | Asset | Custom
  Future<void> addRecoveryAllocation({
    required String personId,
    required String sourceTransactionId,
    required double totalAmount,
    required List<Map<String, dynamic>> destinations,
    // Each destination: {type, destinationId?, destinationLabel, amount}
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final allocationId = _uuid.v4();
    final double allocatedAmount = destinations.fold(0.0, (sum, d) => sum + (d['amount'] as double));
    final double unallocatedAmount = (totalAmount - allocatedAmount).clamp(0.0, double.infinity);

    final allocationRecord = RecoveryAllocation(
      id: allocationId,
      personId: personId,
      sourceTransactionId: sourceTransactionId,
      totalAmount: totalAmount,
      allocatedAmount: allocatedAmount,
      unallocatedAmount: unallocatedAmount,
      notes: notes,
      createdAt: now,
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.recoveryAllocations).insert(allocationRecord);
    }

    final List<RecoveryDestination> destRecords = [];
    for (final dest in destinations) {
      final destId = _uuid.v4();
      final destType = dest['type'] as String;
      final destLabel = dest['destinationLabel'] as String;
      final destAmount = dest['amount'] as double;
      final destEntityId = dest['destinationId'] as String?;

      String? linkedTxId;

      // Create the actual linked transaction for this destination
      switch (destType) {
        case 'BankAccount':
        case 'Asset':
        case 'EmergencyFund':
          // Transfer money into the destination account
          if (destEntityId != null) {
            final linkedTx = await addTransaction(
              type: 'transfer',
              amount: destAmount,
              toAccountId: destEntityId,
              notes: 'Recovery allocation → $destLabel',
              date: now,
            );
            linkedTxId = linkedTx.id;
          }
          break;
        case 'Investment':
          if (destEntityId != null) {
            final linkedTx = await addTransaction(
              type: 'investment_buy',
              amount: destAmount,
              investmentId: destEntityId,
              notes: 'Recovery allocation → $destLabel',
              date: now,
            );
            linkedTxId = linkedTx.id;
          }
          break;
        case 'Goal':
          if (destEntityId != null) {
            // Add contribution to goal currentAmount
            final goal = state.goals.firstWhereOrNull((g) => g.id == destEntityId);
            if (goal != null) {
              final newAmount = goal.currentAmount + destAmount;
              final db2 = isMock ? null : _ref.read(realDatabaseProvider);
              if (!isMock && db2 != null) {
                await (db2.update(db2.goals)
                  ..where((tbl) => tbl.id.equals(destEntityId)))
                  .write(GoalsCompanion(currentAmount: Value(newAmount), updatedAt: Value(now)));
              } else {
                final updated = goal.copyWith(currentAmount: newAmount, updatedAt: now);
                state = state.copyWith(
                  goals: state.goals.map((g) => g.id == destEntityId ? updated : g).toList(),
                );
              }
            }
          }
          break;
        case 'Cash':
        case 'Custom':
        default:
          // No linked transaction needed — just record the allocation destination
          break;
      }

      final destRecord = RecoveryDestination(
        id: destId,
        allocationId: allocationId,
        destinationType: destType,
        destinationId: destEntityId,
        destinationLabel: destLabel,
        amount: destAmount,
        linkedTransactionId: linkedTxId,
        createdAt: now,
      );
      destRecords.add(destRecord);

      if (!isMock) {
        final db = _ref.read(realDatabaseProvider);
        await db.into(db.recoveryDestinations).insert(destRecord);
      }
    }

    // Update in-memory state
    state = state.copyWith(
      recoveryAllocations: [allocationRecord, ...state.recoveryAllocations],
      recoveryDestinations: [...destRecords, ...state.recoveryDestinations],
    );

    // Log to portfolio history
    final person = state.people.firstWhereOrNull((p) => p.id == personId);
    final personName = person?.name ?? 'Unknown';
    final destSummary = destinations.map((d) => '${d["destinationLabel"]}: ${state.currency}${(d["amount"] as double).toStringAsFixed(0)}').join(', ');
    _logHistory(
      action: 'Recovery Allocated',
      entityType: 'Receivable',
      entityId: personId,
      entityName: personName,
      valueChanged: 'Recovered ${state.currency}${totalAmount.toStringAsFixed(0)} → $destSummary',
      newValue: '${state.currency}${allocatedAmount.toStringAsFixed(0)} allocated',
    );
  }

  Future<Investment> addInvestment(
    String name,
    String type,
    String? symbol,
    String? notes,
    double marketValue, {
    DateTime? purchaseDate,
    String? purchaseTime,
    String? fundingSource,
    String? fundingLiabilityId,
    String? fundingDetails,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final newInvestment = Investment(
      id: id,
      name: name,
      type: type,
      symbol: symbol,
      marketValue: marketValue,
      marketValueUpdatedAt: now,
      isArchived: 0,
      notes: notes,
      purchaseDate: purchaseDate,
      purchaseTime: purchaseTime,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
      fundingSource: fundingSource,
      fundingLiabilityId: fundingLiabilityId,
      fundingDetails: fundingDetails,
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.investments).insert(newInvestment);
      _queueSync('investment', id, 'upsert');
      await loadStateFromDatabase();
    } else {
      state = state.copyWith(investments: [...state.investments, newInvestment]);
    }
    await _logHistory(
      action: 'Added Investment',
      entityType: 'Investment',
      entityId: id,
      entityName: name,
      valueChanged: 'Initial market value: ${state.currency}${marketValue.toStringAsFixed(0)}',
      newValue: '${state.currency}${marketValue.toStringAsFixed(0)}',
    );
    return newInvestment;
  }

  void updateInvestmentMarketValue(String investmentId, double newValue) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realInvestmentServiceProvider).updateMarketValue(investmentId, newValue);
      _queueSync('investment', investmentId, 'upsert');
    } else {
      state = state.copyWith(
        investments: state.investments.map((i) {
          if (i.id == investmentId) {
            return Investment(
              id: i.id,
              name: i.name,
              type: i.type,
              symbol: i.symbol,
              marketValue: newValue,
              marketValueUpdatedAt: DateTime.now().toUtc(),
              isArchived: i.isArchived,
              notes: i.notes,
              createdAt: i.createdAt,
              updatedAt: DateTime.now().toUtc(),
              syncStatus: i.syncStatus,
            );
          }
          return i;
        }).toList(),
      );
    }
    final investment = state.investments.firstWhere((i) => i.id == investmentId);
    _logHistory(
      action: 'Edited Investment',
      entityType: 'Investment',
      entityId: investmentId,
      entityName: investment.name,
      valueChanged: 'Market Value: ${state.currency}${newValue.toStringAsFixed(0)}',
      previousValue: '${state.currency}${(investment.marketValue ?? 0.0).toStringAsFixed(0)}',
      newValue: '${state.currency}${newValue.toStringAsFixed(0)}',
    );
  }

  Future<void> updateInvestment(
    String id,
    String name,
    String type,
    String? symbol,
    String? notes, {
    DateTime? purchaseDate,
    String? purchaseTime,
  }) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.investments)..where((tbl) => tbl.id.equals(id)))
        .write(InvestmentsCompanion(
          name: Value(name),
          type: Value(type),
          symbol: Value(symbol),
          notes: Value(notes),
          purchaseDate: Value(purchaseDate),
          purchaseTime: Value(purchaseTime),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      _queueSync('investment', id, 'upsert');
    } else {
      state = state.copyWith(
        investments: state.investments.map((i) {
          if (i.id == id) {
            return i.copyWith(
              name: name,
              type: type,
              symbol: Value(symbol),
              notes: Value(notes),
              purchaseDate: Value(purchaseDate),
              purchaseTime: Value(purchaseTime),
              updatedAt: DateTime.now().toUtc(),
            );
          }
          return i;
        }).toList(),
      );
    }
    final investment = state.investments.firstWhere((i) => i.id == id);
    _logHistory(
      action: 'Edited Investment',
      entityType: 'Investment',
      entityId: id,
      entityName: name,
      valueChanged: 'Details updated',
      previousValue: investment.name,
      newValue: name,
    );
  }

  Future<void> updateInvestmentUnits(String investmentId, double newUnits) async {
    final isMock = _ref.read(mockModeProvider);
    final lotIndex = state.investmentLots.indexWhere((l) => l.investmentId == investmentId);
    if (lotIndex == -1) return;
    
    final lot = state.investmentLots[lotIndex];
    final costPerUnit = lot.costPerUnit;
    final newAmount = newUnits * costPerUnit;
    
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.investmentLots)..where((tbl) => tbl.id.equals(lot.id)))
        .write(InvestmentLotsCompanion(
          unitsPurchased: Value(newUnits),
          unitsRemaining: Value(newUnits),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      
      await (db.update(db.transactions)..where((tbl) => tbl.id.equals(lot.buyTransactionId)))
        .write(TransactionsCompanion(
          units: Value(newUnits),
          amount: Value(newAmount),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      
      _queueSync('investment_lot', lot.id, 'upsert');
      _queueSync('transaction', lot.buyTransactionId, 'upsert');
    }
    
    state = state.copyWith(
      investmentLots: state.investmentLots.map((l) {
        if (l.id == lot.id) {
          return l.copyWith(
            unitsPurchased: newUnits,
            unitsRemaining: newUnits,
            updatedAt: DateTime.now().toUtc(),
          );
        }
        return l;
      }).toList(),
      transactions: state.transactions.map((t) {
        if (t.id == lot.buyTransactionId) {
          return t.copyWith(
            units: Value(newUnits),
            amount: newAmount,
            updatedAt: DateTime.now().toUtc(),
          );
        }
        return t;
      }).toList(),
    );
  }

  Future<bool> deleteInvestment(String id) async {
    final investment = state.investments.firstWhereOrNull((i) => i.id == id);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final countQuery = db.select(db.investmentLots)..where((tbl) => tbl.investmentId.equals(id));
      final count = (await countQuery.get()).length;
      if (count > 0) return false;
      if (investment != null) {
        _logHistory(
          action: 'Deleted Investment',
          entityType: 'Investment',
          entityId: id,
          entityName: investment.name,
          valueChanged: 'Permanently Deleted',
        );
      }
      await (db.delete(db.investments)..where((tbl) => tbl.id.equals(id))).go();
      _queueSync('investment', id, 'delete');
      return true;
    } else {
      final count = state.investmentLots.where((l) => l.investmentId == id).length;
      if (count > 0) return false;
      if (investment != null) {
        _logHistory(
          action: 'Deleted Investment',
          entityType: 'Investment',
          entityId: id,
          entityName: investment.name,
          valueChanged: 'Permanently Deleted',
        );
      }
      state = state.copyWith(
        investments: state.investments.where((i) => i.id != id).toList(),
      );
      return true;
    }
  }

  Future<void> archiveInvestment(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.investments)..where((tbl) => tbl.id.equals(id)))
        .write(InvestmentsCompanion(
          isArchived: const Value(1),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      _queueSync('investment', id, 'upsert');
    } else {
      state = state.copyWith(
        investments: state.investments.map((i) {
          if (i.id == id) {
            return i.copyWith(isArchived: 1, updatedAt: DateTime.now().toUtc());
          }
          return i;
        }).toList(),
      );
    }
    final investment = state.investments.firstWhere((i) => i.id == id);
    await _logHistory(
      action: 'Deleted Investment',
      entityType: 'Investment',
      entityId: id,
      entityName: investment.name,
      valueChanged: 'Archived',
    );
  }

  Future<void> buyInvestment(
    String investmentId,
    String? fromAccountId,
    double units,
    double pricePerUnit,
    String? notes,
    DateTime date, {
    String? fundingSource,
    String? fundingLiabilityId,
    String? fundingDetails,
  }) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      await _ref.read(realInvestmentServiceProvider).buyInvestment(
        investmentId: investmentId,
        fromAccountId: fromAccountId,
        units: units,
        pricePerUnit: pricePerUnit,
        notes: notes,
        date: date,
        fundingSource: fundingSource,
        fundingLiabilityId: fundingLiabilityId,
        fundingDetails: fundingDetails,
      );
      await loadStateFromDatabase();
    } else {
      final amount = units * pricePerUnit;
      final tx = _createTransactionInternal(
        type: 'investment_buy',
        amount: amount,
        fromAccountId: fromAccountId,
        investmentId: investmentId,
        notes: notes ?? 'Bought $units units @ ${state.currency} $pricePerUnit',
        date: date,
        fundingSource: fundingSource,
        fundingLiabilityId: fundingLiabilityId,
        fundingDetails: fundingDetails,
      );

      final lotId = _uuid.v4();
      final newLot = InvestmentLot(
        id: lotId,
        investmentId: investmentId,
        buyTransactionId: tx.id,
        unitsPurchased: units,
        unitsRemaining: units,
        costPerUnit: pricePerUnit,
        purchaseDate: date,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
        fundingSource: fundingSource,
        fundingLiabilityId: fundingLiabilityId,
        fundingDetails: fundingDetails,
      );

      state = state.copyWith(investmentLots: [...state.investmentLots, newLot]);
    }
    final investment = state.investments.firstWhere((i) => i.id == investmentId);
    await _logHistory(
      action: 'Edited Investment',
      entityType: 'Investment',
      entityId: investmentId,
      entityName: investment.name,
      valueChanged: 'Bought: $units units @ ${state.currency}${pricePerUnit.toStringAsFixed(0)} (Total: ${state.currency}${(units * pricePerUnit).toStringAsFixed(0)})',
    );
  }

  Future<void> sellInvestment(String investmentId, String toAccountId, double unitsToSell, double salePricePerUnit, String? notes, DateTime date) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      await _ref.read(realInvestmentServiceProvider).sellInvestment(
        investmentId: investmentId,
        toAccountId: toAccountId,
        unitsToSell: unitsToSell,
        salePricePerUnit: salePricePerUnit,
        notes: notes,
        date: date,
      );
      await loadStateFromDatabase();
    } else {
      final totalProceeds = unitsToSell * salePricePerUnit;
      final sellTx = _createTransactionInternal(
        type: 'investment_sell',
        amount: totalProceeds,
        toAccountId: toAccountId,
        investmentId: investmentId,
        notes: notes ?? 'Sold $unitsToSell units @ ${state.currency} $salePricePerUnit',
        date: date,
      );

      double unitsRemainingToAllocate = unitsToSell;
      final activeLots = state.investmentLots
          .where((l) => l.investmentId == investmentId && l.unitsRemaining > 0)
          .toList()
        ..sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));

      final List<InvestmentLot> updatedLots = List.from(state.investmentLots);
      final List<InvestmentLotConsumption> consumptions = [];

      for (final lot in activeLots) {
        if (unitsRemainingToAllocate <= 0) break;

        final double unitsConsumed = (lot.unitsRemaining >= unitsRemainingToAllocate)
            ? unitsRemainingToAllocate
            : lot.unitsRemaining;

        unitsRemainingToAllocate -= unitsConsumed;

        final lotIndex = updatedLots.indexWhere((l) => l.id == lot.id);
        updatedLots[lotIndex] = InvestmentLot(
          id: lot.id,
          investmentId: lot.investmentId,
          buyTransactionId: lot.buyTransactionId,
          unitsPurchased: lot.unitsPurchased,
          unitsRemaining: lot.unitsRemaining - unitsConsumed,
          costPerUnit: lot.costPerUnit,
          purchaseDate: lot.purchaseDate,
          createdAt: lot.createdAt,
          updatedAt: DateTime.now().toUtc(),
          syncStatus: lot.syncStatus,
        );

        final costBasis = unitsConsumed * lot.costPerUnit;
        final proceedsAllocated = unitsConsumed * salePricePerUnit;
        final realizedGainLoss = proceedsAllocated - costBasis;

        consumptions.add(
          InvestmentLotConsumption(
            id: _uuid.v4(),
            sellTransactionId: sellTx.id,
            lotId: lot.id,
            unitsConsumed: unitsConsumed,
            costBasis: costBasis,
            proceedsAllocated: proceedsAllocated,
            realizedGainLoss: realizedGainLoss,
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }

      state = state.copyWith(
        investmentLots: updatedLots,
        investmentLotConsumptions: [...state.investmentLotConsumptions, ...consumptions],
      );
    }
    final investment = state.investments.firstWhere((i) => i.id == investmentId);
    await _logHistory(
      action: 'Edited Investment',
      entityType: 'Investment',
      entityId: investmentId,
      entityName: investment.name,
      valueChanged: 'Sold: $unitsToSell units @ ${state.currency}${salePricePerUnit.toStringAsFixed(0)} (Total: ${state.currency}${(unitsToSell * salePricePerUnit).toStringAsFixed(0)})',
    );
  }

  Future<void> addExpectedIncome(String source, double amount, DateTime? expectedDate, String? notes, {DateTime? createdAt}) async {
    final isMock = _ref.read(mockModeProvider);
    final creationDate = createdAt ?? DateTime.now().toUtc();
    final id = _uuid.v4();
    if (!isMock) {
      await _ref.read(realExpectedIncomeServiceProvider).addExpectedIncome(
        source: source,
        amount: amount,
        expectedDate: expectedDate,
        notes: notes,
      );
    } else {
      final newInc = ExpectedIncome(
        id: id,
        source: source,
        amount: amount,
        status: 'pending',
        expectedDate: expectedDate,
        notes: notes,
        createdAt: creationDate,
        updatedAt: creationDate,
        syncStatus: 'pending',
      );

      state = state.copyWith(expectedIncomes: [...state.expectedIncomes, newInc]);
    }
    await _logHistory(
      action: 'Added Expected Income',
      entityType: 'Expected Income',
      entityId: id,
      entityName: source,
      valueChanged: 'Expected: ${state.currency}${amount.toStringAsFixed(0)}',
      newValue: '${state.currency}${amount.toStringAsFixed(0)}',
    );
  }

  Future<void> markExpectedIncomeReceived(String incomeId, String destinationAccountId) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      await _ref.read(realExpectedIncomeServiceProvider).markReceived(incomeId, destinationAccountId);
    } else {
      final inc = state.expectedIncomes.firstWhere((i) => i.id == incomeId);
      final tx = _createTransactionInternal(
        type: 'expected_income_received',
        amount: state.getExpectedIncomeAmount(incomeId),
        toAccountId: destinationAccountId,
        notes: 'Received expected income: ${inc.source}',
        date: DateTime.now().toUtc(),
      );

      state = state.copyWith(
        expectedIncomes: state.expectedIncomes.map((i) {
          if (i.id == incomeId) {
            return ExpectedIncome(
              id: i.id,
              source: i.source,
              amount: i.amount,
              status: 'received',
              expectedDate: i.expectedDate,
              receivedTransactionId: tx.id,
              notes: i.notes,
              createdAt: i.createdAt,
              updatedAt: DateTime.now().toUtc(),
              syncStatus: i.syncStatus,
            );
          }
          return i;
        }).toList(),
      );
    }
    final inc = state.expectedIncomes.firstWhere((i) => i.id == incomeId);
    await _logHistory(
      action: 'Received Expected Income',
      entityType: 'Expected Income',
      entityId: incomeId,
      entityName: inc.source,
      valueChanged: 'Received: ${state.currency}${inc.amount.toStringAsFixed(0)}',
      newValue: 'Received',
    );
  }

  Future<void> markExpectedIncomeExpired(String incomeId) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      await _ref.read(realExpectedIncomeServiceProvider).markExpired(incomeId);
    } else {
      state = state.copyWith(
        expectedIncomes: state.expectedIncomes.map((i) {
          if (i.id == incomeId) {
            return ExpectedIncome(
              id: i.id,
              source: i.source,
              amount: i.amount,
              status: 'expired',
              expectedDate: i.expectedDate,
              receivedTransactionId: i.receivedTransactionId,
              notes: i.notes,
              createdAt: i.createdAt,
              updatedAt: DateTime.now().toUtc(),
              syncStatus: i.syncStatus,
            );
          }
          return i;
        }).toList(),
      );
    }
  }

  Future<void> updateExpectedIncome(ExpectedIncome item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final dbInc = ExpectedIncome(
        id: item.id,
        source: item.source,
        amount: item.amount,
        status: item.status,
        expectedDate: item.expectedDate,
        receivedTransactionId: item.receivedTransactionId,
        notes: item.notes,
        createdAt: item.createdAt,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
      );
      await db.update(db.expectedIncomes).replace(dbInc);
      _queueSync('expected_income', item.id, 'upsert');
    } else {
      state = state.copyWith(
        expectedIncomes: state.expectedIncomes.map((i) => i.id == item.id ? item : i).toList(),
      );
    }
  }

  Future<void> deleteExpectedIncome(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.delete(db.expectedIncomes)..where((tbl) => tbl.id.equals(id))).go();
      _queueSync('expected_income', id, 'delete');
    } else {
      state = state.copyWith(
        expectedIncomes: state.expectedIncomes.where((i) => i.id != id).toList(),
      );
    }
  }

  Future<void> addGoal(String name, double targetAmount, DateTime? deadline, String? notes) async {
    final isMock = _ref.read(mockModeProvider);
    final id = _uuid.v4();
    if (!isMock) {
      await _ref.read(realGoalServiceProvider).createGoal(
        name: name,
        targetAmount: targetAmount,
        targetDate: deadline,
        notes: notes,
      );
    } else {
      final newGoal = Goal(
        id: id,
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        deadline: deadline,
        notes: notes,
        isArchived: 0,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
      );

      state = state.copyWith(goals: [...state.goals, newGoal]);
    }
    await _logHistory(
      action: 'Added Goal',
      entityType: 'Goal',
      entityId: id,
      entityName: name,
      valueChanged: 'Target: ${state.currency}${targetAmount.toStringAsFixed(0)}',
      newValue: '${state.currency}${targetAmount.toStringAsFixed(0)}',
    );
  }

  Future<void> updateGoal(Goal goal) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final dbGoal = Goal(
        id: goal.id,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        deadline: goal.deadline,
        notes: goal.notes,
        isArchived: goal.isArchived,
        createdAt: goal.createdAt,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
      );
      await db.update(db.goals).replace(dbGoal);
      _queueSync('goal', goal.id, 'upsert');
    } else {
      state = state.copyWith(
        goals: state.goals.map((g) => g.id == goal.id ? goal : g).toList(),
      );
    }
    _logHistory(
      action: 'Edited Goal',
      entityType: 'Goal',
      entityId: goal.id,
      entityName: goal.name,
      valueChanged: 'Target: ${state.currency}${goal.targetAmount.toStringAsFixed(0)}',
      newValue: '${state.currency}${goal.targetAmount.toStringAsFixed(0)}',
    );
  }

  Future<void> deleteGoal(String id) async {
    final goal = state.goals.firstWhereOrNull((g) => g.id == id);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      if (goal != null) {
        _logHistory(
          action: 'Deleted Goal',
          entityType: 'Goal',
          entityId: id,
          entityName: goal.name,
          valueChanged: 'Permanently Deleted',
        );
      }
      await (db.delete(db.goals)..where((tbl) => tbl.id.equals(id))).go();
      _queueSync('goal', id, 'delete');
    } else {
      if (goal != null) {
        _logHistory(
          action: 'Deleted Goal',
          entityType: 'Goal',
          entityId: id,
          entityName: goal.name,
          valueChanged: 'Permanently Deleted',
        );
      }
      state = state.copyWith(
        goals: state.goals.where((g) => g.id != id).toList(),
      );
    }
  }

  Future<void> archiveGoal(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.goals)..where((tbl) => tbl.id.equals(id)))
        .write(GoalsCompanion(
          isArchived: const Value(1),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
      _queueSync('goal', id, 'upsert');
    } else {
      state = state.copyWith(
        goals: state.goals.map((g) {
          if (g.id == id) {
            return g.copyWith(isArchived: 1, updatedAt: DateTime.now().toUtc());
          }
          return g;
        }).toList(),
      );
    }
    final goal = state.goals.firstWhereOrNull((g) => g.id == id);
    if (goal != null) {
      _logHistory(
        action: 'Deleted Goal',
        entityType: 'Goal',
        entityId: id,
        entityName: goal.name,
        valueChanged: 'Archived',
      );
    }
  }

  void recalculateBalances() {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realBalanceCacheServiceProvider).rebuildCache();
      _ref.read(realSearchIndexServiceProvider).rebuildIndex();
    } else {
      state = state.copyWith(
        accounts: List.from(state.accounts),
        people: List.from(state.people),
        investments: List.from(state.investments),
      );
    }
  }

  Future<void> clearCache() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await db.delete(db.accountBalanceCaches).go();
        await db.delete(db.personBalanceCaches).go();
        await db.delete(db.investmentBalanceCaches).go();
      });
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    }
  }

  Future<void> clearAllTransactions() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await db.delete(db.investmentLotConsumptions).go();
        await db.delete(db.investmentLots).go();
        await db.delete(db.transactions).go();
      });
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    } else {
      state = state.copyWith(
        transactions: [],
        investmentLots: [],
        investmentLotConsumptions: [],
      );
    }
  }

  Future<void> clearAllInvestments() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await db.delete(db.investmentLotConsumptions).go();
        await db.delete(db.investmentLots).go();
        await (db.delete(db.transactions)..where((tbl) => tbl.investmentId.isNotNull())).go();
        await db.delete(db.investments).go();
      });
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    } else {
      state = state.copyWith(
        investments: [],
        transactions: state.transactions.where((t) => t.investmentId == null).toList(),
        investmentLots: [],
        investmentLotConsumptions: [],
      );
    }
  }

  Future<void> clearAllReceivables() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await (db.delete(db.transactions)..where((tbl) => tbl.type.equals('lend_money') | tbl.type.equals('recover_money'))).go();
      });
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    } else {
      state = state.copyWith(
        transactions: state.transactions.where((t) => t.type != 'lend_money' && t.type != 'recover_money').toList(),
      );
    }
  }

  Future<void> clearAllLiabilities() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await (db.delete(db.transactions)..where((tbl) => tbl.type.equals('borrow_money') | tbl.type.equals('repay_money'))).go();
      });
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    } else {
      state = state.copyWith(
        transactions: state.transactions.where((t) => t.type != 'borrow_money' && t.type != 'repay_money').toList(),
      );
    }
  }

  Future<void> clearAllGoals() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.delete(db.goals).go();
    } else {
      state = state.copyWith(goals: []);
    }
  }

  Future<void> factoryReset() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await db.delete(db.transactions).go();
        await db.delete(db.investmentLotConsumptions).go();
        await db.delete(db.investmentLots).go();
        await db.delete(db.investments).go();
        await db.delete(db.accounts).go();
        await db.delete(db.people).go();
        await db.delete(db.expectedIncomes).go();
        await db.delete(db.goals).go();
        await db.delete(db.goalMilestones).go();
        await db.delete(db.snapshots).go();
        await db.delete(db.settings).go();
        await db.delete(db.auditLogs).go();
        await db.delete(db.adjustments).go();
        await db.delete(db.accountBalanceCaches).go();
        await db.delete(db.personBalanceCaches).go();
        await db.delete(db.investmentBalanceCaches).go();
      });
      await seedDatabaseIfEmpty(db);
    }
    state = MockDatabaseNotifier.initialState();
  }

  Future<void> resetDemoData() async {
    await factoryReset();
    
    final isMock = _ref.read(mockModeProvider);
    final now = DateTime.now();
    
    state = state.copyWith(isOnboarded: true, isLoggedIn: true);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'isOnboarded', value: 'true'));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'isLoggedIn', value: 'true'));
    }
    
    await addAccount(mockBankName1, 'bank', 'Main checking account', 250000.0, id: 'acc_primary_bank_uuid');
    await addAccount('Cash Wallet', 'cash', 'Physical cash', 5000.0, id: 'acc_cash_wallet_uuid');
    await addAccount(mockCreditCardName1, 'credit', 'Primary credit card', 15000.0, id: 'acc_cc_a_uuid');
    
    final p1 = await addPerson(mockPersonName1, '+91 98765 43210', 'Friend from college');
    final p2 = await addPerson(mockPersonName2, '+91 99999 88888', 'Landlord');
    
    await addLendTransaction(p1.id, 'acc_primary_bank_uuid', 10000.0, 'Lent for emergency', now.subtract(const Duration(days: 5)));
    await addBorrowTransaction(p2.id, 'acc_primary_bank_uuid', 5000.0, 'Borrowed for deposit', now.subtract(const Duration(days: 3)));
    
    final inv1 = await addInvestment(mockInvestmentName1, 'stock', 'INFY', 'Infosys shares', 1800.0);
    final inv2 = await addInvestment(mockInvestmentName2, 'mutual_fund', 'NIFTY50', 'Index Mutual Fund', 700.0);
    
    await buyInvestment(inv1.id, 'acc_primary_bank_uuid', 30, 1800.0, 'Bought 30 units', now.subtract(const Duration(days: 10)));
    await buyInvestment(inv2.id, 'acc_primary_bank_uuid', 100, 700.0, 'Bought 100 units', now.subtract(const Duration(days: 15)));
    
    await addExpectedIncome('Freelance Design', 25000.0, now.add(const Duration(days: 7)), 'Logo design project');
    await addExpectedIncome('Dividends', 1500.0, now.add(const Duration(days: 12)), 'INFY stock dividends');
    
    await addGoal(mockGoalName1, 150000.0, now.add(const Duration(days: 180)), '6 months emergency fund');
    await addGoal(mockGoalName2, 300000.0, now.add(const Duration(days: 365)), 'Downpayment for car');
    
    if (!isMock) {
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    }
  }

  Future<void> updateCheckInSettings({
    bool? enabled,
    String? times,
    String? reminderCount,
    String? completedDate,
  }) async {
    final isMock = _ref.read(mockModeProvider);
    
    final newEnabled = enabled ?? state.checkInEnabled;
    final newTimes = times ?? state.checkInTimes;
    final newReminderCount = reminderCount ?? state.checkInReminderCount;
    final newCompletedDate = completedDate ?? state.checkInCompletedDate;

    state = state.copyWith(
      checkInEnabled: newEnabled,
      checkInTimes: newTimes,
      checkInReminderCount: newReminderCount,
      checkInCompletedDate: newCompletedDate,
    );

    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'checkInEnabled', value: newEnabled.toString()));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'checkInTimes', value: newTimes));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'checkInReminderCount', value: newReminderCount));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'checkInCompletedDate', value: newCompletedDate));
    }
  }

  Future<Transaction> addTransaction({
    required String type,
    required double amount,
    String? category,
    String? fromAccountId,
    String? toAccountId,
    String? personId,
    String? investmentId,
    String? notes,
    required DateTime date,
    String? fundingSource,
    String? fundingLiabilityId,
    String? fundingDetails,
  }) async {
    final isMock = _ref.read(mockModeProvider);
    final Transaction tx;
    if (!isMock) {
      tx = Transaction(
        id: _uuid.v4(),
        type: type,
        amount: amount,
        category: category,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        personId: personId,
        investmentId: investmentId,
        notes: notes,
        transactionDate: date,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
        fundingSource: fundingSource,
        fundingLiabilityId: fundingLiabilityId,
        fundingDetails: fundingDetails,
      );
      final companion = TransactionsCompanion.insert(
        id: tx.id,
        type: tx.type,
        amount: tx.amount,
        category: Value(tx.category),
        fromAccountId: Value(tx.fromAccountId),
        toAccountId: Value(tx.toAccountId),
        personId: Value(tx.personId),
        investmentId: Value(tx.investmentId),
        notes: Value(tx.notes),
        transactionDate: tx.transactionDate,
        createdAt: tx.createdAt,
        updatedAt: tx.updatedAt,
        fundingSource: Value(tx.fundingSource),
        fundingLiabilityId: Value(tx.fundingLiabilityId),
        fundingDetails: Value(tx.fundingDetails),
      );
      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
      _queueSync('transaction', tx.id, 'upsert');
      await loadStateFromDatabase();
    } else {
      tx = _createTransactionInternal(
        type: type,
        amount: amount,
        category: category,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        personId: personId,
        investmentId: investmentId,
        notes: notes,
        date: date,
        fundingSource: fundingSource,
        fundingLiabilityId: fundingLiabilityId,
        fundingDetails: fundingDetails,
      );
    }

    final isBuyOrSellOrIncomeReceived = ['investment_buy', 'investment_sell', 'expected_income_received'].contains(type);
    final isOpeningBalance = notes != null && (notes.contains('Initial deposit') || notes.contains('Opening Balance Owed') || notes.contains('Opening Balance') || notes.contains('Initial funding'));
    
    if (!isBuyOrSellOrIncomeReceived && !isOpeningBalance) {
      String action = 'Transaction';
      String entityType = 'Transaction';
      String entityName = category ?? type;
      String valChanged = '${state.currency}${amount.toStringAsFixed(0)}';

      if (type == 'lend_money') {
        action = 'Lend Money';
        entityType = 'Receivable';
        final person = state.people.firstWhereOrNull((p) => p.id == personId);
        entityName = person?.name ?? 'Someone';
        valChanged = 'Lent: ${state.currency}${amount.toStringAsFixed(0)}';
      } else if (type == 'borrow_money') {
        action = 'Borrow Money';
        entityType = 'Liability';
        final person = state.people.firstWhereOrNull((p) => p.id == personId);
        entityName = person?.name ?? 'Someone';
        valChanged = 'Borrowed: ${state.currency}${amount.toStringAsFixed(0)}';
      } else if (type == 'repay_money') {
        action = 'Repay Loan';
        entityType = 'Settlement';
        final person = state.people.firstWhereOrNull((p) => p.id == personId);
        entityName = person?.name ?? 'Someone';
        valChanged = 'Repaid: ${state.currency}${amount.toStringAsFixed(0)}';
      } else if (type == 'recover_money') {
        action = 'Recover Debt';
        entityType = 'Recoveries';
        final person = state.people.firstWhereOrNull((p) => p.id == personId);
        entityName = person?.name ?? 'Someone';
        valChanged = 'Recovered: ${state.currency}${amount.toStringAsFixed(0)}';
      } else if (type == 'income') {
        action = 'Added Income';
        entityType = 'Transaction';
        entityName = category ?? 'Income';
        valChanged = 'Received: ${state.currency}${amount.toStringAsFixed(0)}';
      } else if (type == 'expense') {
        action = 'Added Expense';
        entityType = 'Transaction';
        entityName = category ?? 'Expense';
        valChanged = 'Paid: ${state.currency}${amount.toStringAsFixed(0)}';
      } else if (type == 'transfer') {
        action = 'Transfer Funds';
        entityType = 'Transaction';
        entityName = 'Transfer';
        valChanged = 'Transferred: ${state.currency}${amount.toStringAsFixed(0)}';
      }

      _logHistory(
        action: action,
        entityType: entityType,
        entityId: tx.id,
        entityName: entityName,
        valueChanged: valChanged,
        newValue: notes,
      );
    }

    return tx;
  }

  Future<void> voidTransaction(String transactionId) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      await _ref.read(realTransactionServiceProvider).voidTransaction(transactionId);
      _queueSync('transaction', transactionId, 'upsert');
    } else {
      final orig = state.transactions.firstWhere((t) => t.id == transactionId);
      final voidTxId = _uuid.v4();

      final voidTx = Transaction(
        id: voidTxId,
        type: 'void',
        amount: orig.amount,
        category: orig.category,
        fromAccountId: orig.toAccountId,
        toAccountId: orig.fromAccountId,
        personId: orig.personId,
        investmentId: orig.investmentId,
        voidedTransactionId: orig.id,
        notes: 'Void of transaction: ${orig.notes ?? orig.type}',
        transactionDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
      );

      if (orig.type == 'investment_sell') {
        final relevantConsumptions = state.investmentLotConsumptions
            .where((c) => c.sellTransactionId == orig.id)
            .toList();

        final List<InvestmentLot> restoredLots = List.from(state.investmentLots);
        for (final cons in relevantConsumptions) {
          final lotIndex = restoredLots.indexWhere((l) => l.id == cons.lotId);
          if (lotIndex != -1) {
            final lot = restoredLots[lotIndex];
            restoredLots[lotIndex] = InvestmentLot(
              id: lot.id,
              investmentId: lot.investmentId,
              buyTransactionId: lot.buyTransactionId,
              unitsPurchased: lot.unitsPurchased,
              unitsRemaining: lot.unitsRemaining + cons.unitsConsumed,
              costPerUnit: lot.costPerUnit,
              purchaseDate: lot.purchaseDate,
              createdAt: lot.createdAt,
              updatedAt: DateTime.now().toUtc(),
              syncStatus: lot.syncStatus,
            );
          }
        }

        state = state.copyWith(
          investmentLots: restoredLots,
          investmentLotConsumptions: state.investmentLotConsumptions
              .where((c) => c.sellTransactionId != orig.id)
              .toList(),
        );
      } else if (orig.type == 'investment_buy') {
        state = state.copyWith(
          investmentLots: state.investmentLots.map((l) {
            if (l.buyTransactionId == orig.id) {
              return InvestmentLot(
                id: l.id,
                investmentId: l.investmentId,
                buyTransactionId: l.buyTransactionId,
                unitsPurchased: l.unitsPurchased,
                unitsRemaining: 0.0,
                costPerUnit: l.costPerUnit,
                purchaseDate: l.purchaseDate,
                createdAt: l.createdAt,
                updatedAt: DateTime.now().toUtc(),
                syncStatus: l.syncStatus,
              );
            }
            return l;
          }).toList(),
        );
      }

      final updatedTxs = state.transactions.map((t) {
        if (t.id == transactionId) {
          return Transaction(
            id: t.id,
            type: t.type,
            amount: t.amount,
            category: t.category,
            fromAccountId: t.fromAccountId,
            toAccountId: t.toAccountId,
            personId: t.personId,
            investmentId: t.investmentId,
            voidedTransactionId: voidTxId,
            notes: t.notes,
            transactionDate: t.transactionDate,
            createdAt: t.createdAt,
            updatedAt: DateTime.now().toUtc(),
            syncStatus: t.syncStatus,
          );
        }
        return t;
      }).toList();

      state = state.copyWith(transactions: [voidTx, ...updatedTxs]);
    }

    final orig = state.transactions.firstWhereOrNull((t) => t.id == transactionId);
    if (orig != null) {
      await _logHistory(
        action: 'Voided Transaction',
        entityType: 'Transaction',
        entityId: transactionId,
        entityName: orig.category ?? orig.type,
        valueChanged: 'Voided: ${state.currency}${orig.amount.toStringAsFixed(0)}',
      );
    }
  }

  Future<void> editTransaction(Transaction transaction) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final dbTx = Transaction(
        id: transaction.id,
        type: transaction.type,
        amount: transaction.amount,
        category: transaction.category,
        fromAccountId: transaction.fromAccountId,
        toAccountId: transaction.toAccountId,
        personId: transaction.personId,
        investmentId: transaction.investmentId,
        voidedTransactionId: transaction.voidedTransactionId,
        notes: transaction.notes,
        pricePerUnit: transaction.pricePerUnit,
        units: transaction.units,
        transactionDate: transaction.transactionDate,
        createdAt: transaction.createdAt,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
      );
      await db.update(db.transactions).replace(dbTx);
      _queueSync('transaction', transaction.id, 'upsert');
      
      if (transaction.type == 'investment_buy') {
        final double units = transaction.units ?? 0.0;
        final double price = transaction.pricePerUnit ?? 0.0;
        await (db.update(db.investmentLots)
          ..where((tbl) => tbl.buyTransactionId.equals(transaction.id)))
          .write(InvestmentLotsCompanion(
            unitsPurchased: Value(units),
            unitsRemaining: Value(units),
            costPerUnit: Value(price),
            purchaseDate: Value(transaction.transactionDate),
            updatedAt: Value(DateTime.now().toUtc()),
          ));
      }
      
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
      await _ref.read(realSearchIndexServiceProvider).rebuildIndex();
    } else {
      state = state.copyWith(
        transactions: state.transactions.map((t) => t.id == transaction.id ? transaction : t).toList(),
      );
      
      if (transaction.type == 'investment_buy') {
        state = state.copyWith(
          investmentLots: state.investmentLots.map((l) {
            if (l.buyTransactionId == transaction.id) {
              return l.copyWith(
                unitsPurchased: transaction.units ?? 0.0,
                unitsRemaining: transaction.units ?? 0.0,
                costPerUnit: transaction.pricePerUnit ?? 0.0,
                purchaseDate: transaction.transactionDate,
                updatedAt: DateTime.now().toUtc(),
              );
            }
            return l;
          }).toList(),
        );
      }
    }
  }

  Future<void> deleteTransaction(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.transaction(() async {
        await (db.delete(db.investmentLots)..where((tbl) => tbl.buyTransactionId.equals(id))).go();
        await (db.delete(db.investmentLotConsumptions)..where((tbl) => tbl.sellTransactionId.equals(id))).go();
        await (db.delete(db.transactions)..where((tbl) => tbl.id.equals(id))).go();
      });
      _queueSync('transaction', id, 'delete');
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    } else {
      state = state.copyWith(
        transactions: state.transactions.where((t) => t.id != id).toList(),
        investmentLots: state.investmentLots.where((l) => l.buyTransactionId != id).toList(),
        investmentLotConsumptions: state.investmentLotConsumptions.where((c) => c.sellTransactionId != id).toList(),
      );
    }
  }

  Future<void> duplicateTransaction(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final orig = await (db.select(db.transactions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (orig != null) {
        final newId = const Uuid().v4();
        final companion = TransactionsCompanion(
          id: Value(newId),
          type: Value(orig.type),
          amount: Value(orig.amount),
          category: Value(orig.category),
          fromAccountId: Value(orig.fromAccountId),
          toAccountId: Value(orig.toAccountId),
          personId: Value(orig.personId),
          investmentId: Value(orig.investmentId),
          notes: Value(orig.notes != null ? '${orig.notes} (Copy)' : '(Copy)'),
          pricePerUnit: Value(orig.pricePerUnit),
          units: Value(orig.units),
          transactionDate: Value(DateTime.now().toUtc()),
          createdAt: Value(DateTime.now().toUtc()),
          updatedAt: Value(DateTime.now().toUtc()),
        );
        await _ref.read(realTransactionServiceProvider).createTransaction(companion);
        _queueSync('transaction', newId, 'upsert');
      }
    } else {
      final orig = state.transactions.firstWhereOrNull((t) => t.id == id);
      if (orig != null) {
        final newId = const Uuid().v4();
        final newTx = Transaction(
          id: newId,
          type: orig.type,
          amount: orig.amount,
          category: orig.category,
          fromAccountId: orig.fromAccountId,
          toAccountId: orig.toAccountId,
          personId: orig.personId,
          investmentId: orig.investmentId,
          notes: orig.notes != null ? '${orig.notes} (Copy)' : '(Copy)',
          pricePerUnit: orig.pricePerUnit,
          units: orig.units,
          transactionDate: DateTime.now().toUtc(),
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          syncStatus: 'pending',
        );
        state = state.copyWith(transactions: [newTx, ...state.transactions]);
      }
    }
  }

  Transaction _createTransactionInternal({
    required String type,
    required double amount,
    String? category,
    String? fromAccountId,
    String? toAccountId,
    String? personId,
    String? investmentId,
    String? voidedTransactionId,
    String? notes,
    required DateTime date,
    String? fundingSource,
    String? fundingLiabilityId,
    String? fundingDetails,
  }) {
    final newTx = Transaction(
      id: _uuid.v4(),
      type: type,
      amount: amount,
      category: category,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      personId: personId,
      investmentId: investmentId,
      voidedTransactionId: voidedTransactionId,
      notes: notes,
      transactionDate: date,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      syncStatus: 'pending',
      fundingSource: fundingSource,
      fundingLiabilityId: fundingLiabilityId,
      fundingDetails: fundingDetails,
    );

    state = state.copyWith(transactions: [newTx, ...state.transactions]);
    return newTx;
  }

  Future<void> addAdjustment({
    required String entityType,
    required String entityId,
    required double oldAmount,
    required double newAmount,
    required String reason,
  }) async {
    final isMock = _ref.read(mockModeProvider);
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final adjustedAmount = newAmount - oldAmount;

    final newAdj = Adjustment(
      id: id,
      entityType: entityType,
      entityId: entityId,
      oldAmount: oldAmount,
      newAmount: newAmount,
      adjustedAmount: adjustedAmount,
      reason: reason,
      createdAt: now,
      syncStatus: 'pending',
    );

    final escapedReason = reason.replaceAll('"', '\\"');
    final newAudit = AuditLog(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      action: 'adjusted',
      detailsJson: '{"oldAmount":$oldAmount,"newAmount":$newAmount,"adjustedAmount":$adjustedAmount,"reason":"$escapedReason"}',
      createdAt: now,
    );

    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.adjustments).insert(newAdj);
      await db.into(db.auditLogs).insert(newAudit);
      _queueSync('adjustment', id, 'upsert');
    } else {
      state = state.copyWith(
        adjustments: [...state.adjustments, newAdj],
      );
    }
  }

  // --- IPO Pool Mutations ---

  Future<void> addIpoPool(IpoPool pool) async {
    final updatedList = [...state.ipoPools, pool];
    state = state.copyWith(ipoPools: updatedList);
    await _saveIpoPoolsToDb();
    _logHistory(
      action: 'IPO Activities',
      entityType: 'IPO Activity',
      entityId: pool.id,
      entityName: pool.name,
      valueChanged: 'Created IPO Pool',
    );
  }

  Future<void> updateIpoPool(IpoPool pool) async {
    final updatedList = state.ipoPools.map((p) => p.id == pool.id ? pool : p).toList();
    state = state.copyWith(ipoPools: updatedList);
    await _saveIpoPoolsToDb();
    _logHistory(
      action: 'IPO Activities',
      entityType: 'IPO Activity',
      entityId: pool.id,
      entityName: pool.name,
      valueChanged: 'Updated IPO Pool status/details',
    );
  }

  Future<void> deleteIpoPool(String id) async {
    final pool = state.ipoPools.firstWhereOrNull((p) => p.id == id);
    final updatedList = state.ipoPools.map((p) {
      if (p.id == id) {
        return p.copyWith(deletedAt: () => DateTime.now());
      }
      return p;
    }).toList();
    state = state.copyWith(ipoPools: updatedList);
    await _saveIpoPoolsToDb();
    if (pool != null) {
      _logHistory(
        action: 'IPO Activities',
        entityType: 'IPO Activity',
        entityId: id,
        entityName: pool.name,
        valueChanged: 'Deleted IPO Pool',
      );
    }
  }

  Future<void> restoreIpoPool(IpoPool pool) async {
    final updatedList = state.ipoPools.map((p) {
      if (p.id == pool.id) {
        return pool.copyWith(deletedAt: () => null);
      }
      return p;
    }).toList();
    state = state.copyWith(ipoPools: updatedList);
    await _saveIpoPoolsToDb();
  }

  Future<void> duplicateIpoPool(String id) async {
    final orig = state.ipoPools.firstWhere((p) => p.id == id);
    final newId = const Uuid().v4();
    final now = DateTime.now();
    final copy = orig.copyWith(
      id: newId,
      name: '${orig.name} (Copy)',
      createdAt: now,
      deletedAt: () => null,
      activities: [
        PoolActivity(
          id: const Uuid().v4(),
          type: 'Created',
          description: 'Duplicated from pool: ${orig.name}',
          timestamp: now,
          userId: 'Me',
        ),
      ],
    );
    final updatedList = [...state.ipoPools, copy];
    state = state.copyWith(ipoPools: updatedList);
    await _saveIpoPoolsToDb();
  }

  Future<void> _saveIpoPoolsToDb() async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final jsonStr = jsonEncode(state.ipoPools.map((p) => p.toJson()).toList());
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(key: 'ipo_pools_data', value: jsonStr),
      );
    }
  }

  // --- MTF Position Mutations ---

  Future<void> addMtfPosition({
    required String broker,
    required String instrument,
    required double units,
    required double averagePrice,
    required double ownCapital,
    required double borrowedCapital,
    required double interestRate,
    required DateTime openingDate,
    required DateTime interestStartDate,
    DateTime? purchaseDate,
    String? purchaseTime,
    String? investmentId,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();

    // 1. Get or Add Investment
    final String actualInvestmentId;
    if (investmentId != null) {
      actualInvestmentId = investmentId;
    } else {
      final inv = await addInvestment(instrument, 'stock', null, notes ?? 'MTF Position: $broker', averagePrice);
      actualInvestmentId = inv.id;
    }

    // 2. Add MtfPosition
    final newPos = MtfPosition(
      id: id,
      investmentId: actualInvestmentId,
      broker: broker,
      instrument: instrument,
      units: units,
      averagePrice: averagePrice,
      ownCapital: ownCapital,
      borrowedCapital: borrowedCapital,
      interestRate: interestRate,
      openingDate: openingDate,
      interestStartDate: interestStartDate,
      purchaseDate: purchaseDate,
      purchaseTime: purchaseTime,
      isClosed: 0,
      createdAt: now,
      updatedAt: now,
      lastAccrualDate: interestStartDate,
      syncStatus: 'pending',
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.mtfPositions).insert(MtfPosition(
        id: id,
        investmentId: actualInvestmentId,
        broker: broker,
        instrument: instrument,
        units: units,
        averagePrice: averagePrice,
        ownCapital: ownCapital,
        borrowedCapital: borrowedCapital,
        interestRate: interestRate,
        openingDate: openingDate,
        interestStartDate: interestStartDate,
        purchaseDate: purchaseDate,
        purchaseTime: purchaseTime,
        isClosed: 0,
        createdAt: now,
        updatedAt: now,
        lastAccrualDate: interestStartDate,
        syncStatus: 'pending',
      ));
      _queueSync('mtf_position', id, 'upsert');
    }

    state = state.copyWith(mtfPositions: [...state.mtfPositions, newPos]);

    // 3. Add Buy Transaction (decreases cash by units * averagePrice)
    await buyInvestment(actualInvestmentId, 'acc_primary_bank_uuid', units, averagePrice, notes ?? 'MTF Buy: $instrument', purchaseDate ?? openingDate);

    // 4. Add Borrow Transaction (deposits borrowedCapital back to offset cash)
    await addBorrowTransaction('person_broker_uuid_placeholder', 'acc_primary_bank_uuid', borrowedCapital, 'MTF Borrowed Funding for $instrument', openingDate);

    await _logHistory(
      action: 'MTF Positions',
      entityType: 'MTF Position',
      entityId: id,
      entityName: instrument,
      valueChanged: 'Created MTF Position: ${state.currency}${borrowedCapital.toStringAsFixed(0)} borrowed',
      newValue: 'Broker: $broker, Rate: $interestRate%',
    );

    // Run auto accrual for any days since opening date
    await runAutoInterestAccrual();
  }

  Future<void> editMtfPosition(MtfPosition pos) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.mtfPositions)..where((tbl) => tbl.id.equals(pos.id))).write(
        MtfPositionsCompanion(
          broker: Value(pos.broker),
          interestRate: Value(pos.interestRate),
          openingDate: Value(pos.openingDate),
          interestStartDate: Value(pos.interestStartDate),
          purchaseDate: Value(pos.purchaseDate),
          purchaseTime: Value(pos.purchaseTime),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      _queueSync('mtf_position', pos.id, 'upsert');
    }

    // Update linked buy transaction if one exists
    final buyTx = state.transactions.firstWhereOrNull((t) => t.investmentId == pos.investmentId && t.type == 'investment_buy');
    if (buyTx != null) {
      final updatedTxDate = pos.purchaseDate ?? pos.openingDate;
      if (buyTx.transactionDate != updatedTxDate) {
        if (!isMock) {
          final db = _ref.read(realDatabaseProvider);
          await (db.update(db.transactions)..where((tbl) => tbl.id.equals(buyTx.id))).write(
            TransactionsCompanion(
              transactionDate: Value(updatedTxDate),
              updatedAt: Value(DateTime.now().toUtc()),
            ),
          );
          _queueSync('transaction', buyTx.id, 'upsert');
        }
        state = state.copyWith(
          transactions: state.transactions.map((t) => t.id == buyTx.id ? t.copyWith(transactionDate: updatedTxDate, updatedAt: DateTime.now().toUtc()) : t).toList(),
        );
      }
    }

    state = state.copyWith(
      mtfPositions: state.mtfPositions.map((p) => p.id == pos.id ? pos : p).toList(),
    );

    _logHistory(
      action: 'MTF Positions',
      entityType: 'MTF Position',
      entityId: pos.id,
      entityName: pos.instrument,
      valueChanged: 'Updated MTF Position',
      newValue: 'Broker: ${pos.broker}, Rate: ${pos.interestRate}%',
    );
  }

  Future<void> closeMtfPosition(String id, double salePrice, DateTime date) async {
    final now = DateTime.now().toUtc();
    final pos = state.mtfPositions.firstWhere((p) => p.id == id);
    
    // 1. Accrue final interest before closing
    await runAutoInterestAccrual();

    final closedPos = pos.copyWith(
      isClosed: 1,
      closedDate: Value(date),
      updatedAt: now,
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.mtfPositions)..where((tbl) => tbl.id.equals(id))).write(
        MtfPositionsCompanion(
          isClosed: const Value(1),
          closedDate: Value(date),
          updatedAt: Value(now),
        ),
      );
      _queueSync('mtf_position', id, 'upsert');
    }

    state = state.copyWith(
      mtfPositions: state.mtfPositions.map((p) => p.id == id ? closedPos : p).toList(),
    );

    // 2. Sell Investment (increases cash by units * salePrice)
    sellInvestment(pos.investmentId, 'acc_primary_bank_uuid', pos.units, salePrice, 'MTF Position Closed: ${pos.instrument}', date);

    // 3. Repay Borrowed Capital (decreases cash by borrowedCapital)
    await addRepayTransaction('person_broker_uuid_placeholder', 'acc_primary_bank_uuid', pos.borrowedCapital, 'MTF Loan Repayment for ${pos.instrument}', date);

    _logHistory(
      action: 'MTF Positions',
      entityType: 'MTF Position',
      entityId: id,
      entityName: pos.instrument,
      valueChanged: 'Closed MTF Position',
      newValue: 'Sale price: ${state.currency}${salePrice.toStringAsFixed(0)}',
    );
  }

  Future<void> deleteMtfPosition(String id) async {
    final pos = state.mtfPositions.firstWhereOrNull((p) => p.id == id);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.delete(db.mtfPositions)..where((tbl) => tbl.id.equals(id))).go();
      _queueSync('mtf_position', id, 'delete');
    }
    state = state.copyWith(
      mtfPositions: state.mtfPositions.where((p) => p.id != id).toList(),
    );

    if (pos != null) {
      _logHistory(
        action: 'MTF Positions',
        entityType: 'MTF Position',
        entityId: id,
        entityName: pos.instrument,
        valueChanged: 'Permanently Deleted',
      );
      // Also delete/archive associated investment and transactions
      await deleteInvestment(pos.investmentId);
    }
  }

  // --- SOFT DELETE, RESTORE & DUPLICATE FUNCTIONS ---

  Future<void> deleteAccountSoft(String id) async {
    final now = DateTime.now().toUtc();
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.accounts)..where((tbl) => tbl.id.equals(id))).write(
        AccountsCompanion(deletedAt: Value(now)),
      );
      _queueSync('account', id, 'upsert');
    }
    state = state.copyWith(
      accounts: state.accounts.where((a) => a.id != id).toList(),
    );
  }

  Future<void> restoreAccount(Account item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.accounts)..where((tbl) => tbl.id.equals(item.id))).write(
        const AccountsCompanion(deletedAt: Value(null)),
      );
      _queueSync('account', item.id, 'upsert');
    }
    state = state.copyWith(
      accounts: [...state.accounts, item.copyWith(deletedAt: const Value(null))],
    );
  }

  Future<Account> duplicateAccount(String id) async {
    final item = state.accounts.firstWhere((x) => x.id == id);
    final newId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final copy = item.copyWith(
      id: newId,
      name: '${item.name} (Copy)',
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.accounts).insert(copy);
      _queueSync('account', newId, 'upsert');
    }
    state = state.copyWith(
      accounts: [...state.accounts, copy],
    );
    return copy;
  }

  Future<void> unarchiveAccount(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.accounts)..where((tbl) => tbl.id.equals(id)))
        .write(AccountsCompanion(isArchived: const Value(0), updatedAt: Value(DateTime.now().toUtc())));
      _queueSync('account', id, 'upsert');
    }
    state = state.copyWith(
      accounts: state.accounts.map((a) => a.id == id ? a.copyWith(isArchived: 0, updatedAt: DateTime.now().toUtc()) : a).toList(),
    );
  }

  Future<void> unarchivePerson(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.people)..where((tbl) => tbl.id.equals(id)))
        .write(PeopleCompanion(isArchived: const Value(0), updatedAt: Value(DateTime.now().toUtc())));
      _queueSync('person', id, 'upsert');
    }
    state = state.copyWith(
      people: state.people.map((p) => p.id == id ? p.copyWith(isArchived: 0, updatedAt: DateTime.now().toUtc()) : p).toList(),
    );
  }

  Future<void> unarchiveInvestment(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.investments)..where((tbl) => tbl.id.equals(id)))
        .write(InvestmentsCompanion(isArchived: const Value(0), updatedAt: Value(DateTime.now().toUtc())));
      _queueSync('investment', id, 'upsert');
    }
    state = state.copyWith(
      investments: state.investments.map((i) => i.id == id ? i.copyWith(isArchived: 0, updatedAt: DateTime.now().toUtc()) : i).toList(),
    );
  }

  Future<void> unarchiveGoal(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.goals)..where((tbl) => tbl.id.equals(id)))
        .write(GoalsCompanion(isArchived: const Value(0), updatedAt: Value(DateTime.now().toUtc())));
      _queueSync('goal', id, 'upsert');
    }
    state = state.copyWith(
      goals: state.goals.map((g) => g.id == id ? g.copyWith(isArchived: 0, updatedAt: DateTime.now().toUtc()) : g).toList(),
    );
  }

  Future<void> deletePersonSoft(String id) async {
    final now = DateTime.now().toUtc();
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.people)..where((tbl) => tbl.id.equals(id))).write(
        PeopleCompanion(deletedAt: Value(now)),
      );
      _queueSync('person', id, 'upsert');
    }
    state = state.copyWith(
      people: state.people.where((p) => p.id != id).toList(),
    );
  }

  Future<void> restorePerson(Person item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.people)..where((tbl) => tbl.id.equals(item.id))).write(
        const PeopleCompanion(deletedAt: Value(null)),
      );
      _queueSync('person', item.id, 'upsert');
    }
    state = state.copyWith(
      people: [...state.people, item.copyWith(deletedAt: const Value(null))],
    );
  }

  Future<Person> duplicatePerson(String id) async {
    final item = state.people.firstWhere((x) => x.id == id);
    final newId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final copy = item.copyWith(
      id: newId,
      name: '${item.name} (Copy)',
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.people).insert(copy);
      _queueSync('person', newId, 'upsert');
    }
    state = state.copyWith(
      people: [...state.people, copy],
    );
    return copy;
  }

  Future<void> deleteInvestmentSoft(String id) async {
    final now = DateTime.now().toUtc();
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.investments)..where((tbl) => tbl.id.equals(id))).write(
        InvestmentsCompanion(deletedAt: Value(now)),
      );
      _queueSync('investment', id, 'upsert');
    }
    state = state.copyWith(
      investments: state.investments.where((i) => i.id != id).toList(),
    );
  }

  Future<void> restoreInvestment(Investment item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.investments)..where((tbl) => tbl.id.equals(item.id))).write(
        const InvestmentsCompanion(deletedAt: Value(null)),
      );
      _queueSync('investment', item.id, 'upsert');
    }
    state = state.copyWith(
      investments: [...state.investments, item.copyWith(deletedAt: const Value(null))],
    );
  }

  Future<Investment> duplicateInvestment(String id) async {
    final item = state.investments.firstWhere((x) => x.id == id);
    final newId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final copy = item.copyWith(
      id: newId,
      name: '${item.name} (Copy)',
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.investments).insert(copy);
      _queueSync('investment', newId, 'upsert');
    }
    state = state.copyWith(
      investments: [...state.investments, copy],
    );
    return copy;
  }

  Future<void> deleteMtfPositionSoft(String id) async {
    final now = DateTime.now().toUtc();
    final pos = state.mtfPositions.firstWhereOrNull((p) => p.id == id);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.mtfPositions)..where((tbl) => tbl.id.equals(id))).write(
        MtfPositionsCompanion(deletedAt: Value(now)),
      );
      _queueSync('mtf_position', id, 'upsert');
    }
    state = state.copyWith(
      mtfPositions: state.mtfPositions.where((p) => p.id != id).toList(),
    );
    if (pos != null) {
      _logHistory(
        action: 'MTF Positions',
        entityType: 'MTF Position',
        entityId: id,
        entityName: pos.instrument,
        valueChanged: 'Deleted MTF Position',
      );
    }
  }

  Future<void> restoreMtfPosition(MtfPosition item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.mtfPositions)..where((tbl) => tbl.id.equals(item.id))).write(
        const MtfPositionsCompanion(deletedAt: Value(null)),
      );
      _queueSync('mtf_position', item.id, 'upsert');
    }
    state = state.copyWith(
      mtfPositions: [...state.mtfPositions, item.copyWith(deletedAt: const Value(null))],
    );
  }

  Future<MtfPosition> duplicateMtfPosition(String id) async {
    final item = state.mtfPositions.firstWhere((x) => x.id == id);
    final newId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final copy = item.copyWith(
      id: newId,
      broker: '${item.broker} (Copy)',
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.mtfPositions).insert(copy);
      _queueSync('mtf_position', newId, 'upsert');
    }
    state = state.copyWith(
      mtfPositions: [...state.mtfPositions, copy],
    );
    return copy;
  }

  Future<void> deleteExpectedIncomeSoft(String id) async {
    final now = DateTime.now().toUtc();
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.expectedIncomes)..where((tbl) => tbl.id.equals(id))).write(
        ExpectedIncomesCompanion(deletedAt: Value(now)),
      );
      _queueSync('expected_income', id, 'upsert');
    }
    state = state.copyWith(
      expectedIncomes: state.expectedIncomes.where((i) => i.id != id).toList(),
    );
  }

  Future<void> restoreExpectedIncome(ExpectedIncome item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.expectedIncomes)..where((tbl) => tbl.id.equals(item.id))).write(
        const ExpectedIncomesCompanion(deletedAt: Value(null)),
      );
      _queueSync('expected_income', item.id, 'upsert');
    }
    state = state.copyWith(
      expectedIncomes: [...state.expectedIncomes, item.copyWith(deletedAt: const Value(null))],
    );
  }

  Future<ExpectedIncome> duplicateExpectedIncome(String id) async {
    final item = state.expectedIncomes.firstWhere((x) => x.id == id);
    final newId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final copy = item.copyWith(
      id: newId,
      source: '${item.source} (Copy)',
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.expectedIncomes).insert(copy);
      _queueSync('expected_income', newId, 'upsert');
    }
    state = state.copyWith(
      expectedIncomes: [...state.expectedIncomes, copy],
    );
    return copy;
  }

  Future<void> deleteGoalSoft(String id) async {
    final now = DateTime.now().toUtc();
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.goals)..where((tbl) => tbl.id.equals(id))).write(
        GoalsCompanion(deletedAt: Value(now)),
      );
      _queueSync('goal', id, 'upsert');
    }
    state = state.copyWith(
      goals: state.goals.where((g) => g.id != id).toList(),
    );
  }

  Future<void> restoreGoal(Goal item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.goals)..where((tbl) => tbl.id.equals(item.id))).write(
        const GoalsCompanion(deletedAt: Value(null)),
      );
      _queueSync('goal', item.id, 'upsert');
    }
    state = state.copyWith(
      goals: [...state.goals, item.copyWith(deletedAt: const Value(null))],
    );
  }

  Future<Goal> duplicateGoal(String id) async {
    final item = state.goals.firstWhere((x) => x.id == id);
    final newId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final copy = item.copyWith(
      id: newId,
      name: '${item.name} (Copy)',
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.goals).insert(copy);
      _queueSync('goal', newId, 'upsert');
    }
    state = state.copyWith(
      goals: [...state.goals, copy],
    );
    return copy;
  }

  Future<void> deleteTransactionSoft(String id) async {
    final now = DateTime.now().toUtc();
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.transactions)..where((tbl) => tbl.id.equals(id))).write(
        TransactionsCompanion(deletedAt: Value(now)),
      );
      _queueSync('transaction', id, 'upsert');
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    }
    state = state.copyWith(
      transactions: state.transactions.where((t) => t.id != id).toList(),
    );
  }

  Future<void> restoreTransaction(Transaction item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.transactions)..where((tbl) => tbl.id.equals(item.id))).write(
        const TransactionsCompanion(deletedAt: Value(null)),
      );
      _queueSync('transaction', item.id, 'upsert');
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    }
    state = state.copyWith(
      transactions: [...state.transactions, item.copyWith(deletedAt: const Value(null))],
    );
  }



  Future<void> deleteSipSoft(String id) async {
    final now = DateTime.now().toUtc();
    final sip = state.sips.firstWhereOrNull((s) => s.id == id);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.sips)..where((tbl) => tbl.id.equals(id))).write(
        SipsCompanion(deletedAt: Value(now)),
      );
      _queueSync('sip', id, 'upsert');
    }
    state = state.copyWith(
      sips: state.sips.where((s) => s.id != id).toList(),
    );
    if (sip != null) {
      final investment = state.investments.firstWhereOrNull((i) => i.id == sip.investmentId);
      _logHistory(
        action: 'SIP Events',
        entityType: 'SIP Event',
        entityId: id,
        entityName: investment?.name ?? 'SIP',
        valueChanged: 'Deleted SIP',
      );
    }
  }

  Future<void> restoreSip(Sip item) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.sips)..where((tbl) => tbl.id.equals(item.id))).write(
        const SipsCompanion(deletedAt: Value(null)),
      );
      _queueSync('sip', item.id, 'upsert');
    }
    state = state.copyWith(
      sips: [...state.sips, item.copyWith(deletedAt: const Value(null))],
    );
  }

  Future<Sip> duplicateSip(String id) async {
    final item = state.sips.firstWhere((x) => x.id == id);
    final newId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final copy = item.copyWith(
      id: newId,
      createdAt: now,
      updatedAt: now,
      deletedAt: const Value(null),
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.sips).insert(copy);
      _queueSync('sip', newId, 'upsert');
    }
    state = state.copyWith(
      sips: [...state.sips, copy],
    );
    return copy;
  }

  // --- Category / Label CRUD ---

  Future<void> addCategory(String category) async {
    final newCategories = [...state.categories, category].toSet().toList();
    state = state.copyWith(categories: newCategories);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(key: 'categories', value: jsonEncode(newCategories)),
      );
      _syncSetting('categories');
    }
  }

  Future<void> editCategory(String oldCategory, String newCategory) async {
    final newCategories = state.categories.map((c) => c == oldCategory ? newCategory : c).toSet().toList();
    state = state.copyWith(categories: newCategories);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(key: 'categories', value: jsonEncode(newCategories)),
      );
      _syncSetting('categories');
      
      // Update any transactions using the old category
      await (db.update(db.transactions)..where((tbl) => tbl.category.equals(oldCategory)))
          .write(TransactionsCompanion(category: Value(newCategory)));
    }
  }

  Future<void> deleteCategory(String category) async {
    final newCategories = state.categories.where((c) => c != category).toList();
    state = state.copyWith(categories: newCategories);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(key: 'categories', value: jsonEncode(newCategories)),
      );
      _syncSetting('categories');
    }
  }

  Future<void> addCustomLabel(String label) async {
    final newLabels = [...state.customLabels, label].toSet().toList();
    state = state.copyWith(customLabels: newLabels);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(key: 'customLabels', value: jsonEncode(newLabels)),
      );
      _syncSetting('customLabels');
    }
  }

  Future<void> editCustomLabel(String oldLabel, String newLabel) async {
    final newLabels = state.customLabels.map((l) => l == oldLabel ? newLabel : l).toSet().toList();
    state = state.copyWith(customLabels: newLabels);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(key: 'customLabels', value: jsonEncode(newLabels)),
      );
      _syncSetting('customLabels');
    }
  }

  Future<void> deleteCustomLabel(String label) async {
    final newLabels = state.customLabels.where((l) => l != label).toList();
    state = state.copyWith(customLabels: newLabels);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(key: 'customLabels', value: jsonEncode(newLabels)),
      );
      _syncSetting('customLabels');
    }
  }

  Future<void> updateMtfPositionAccrual(String id, DateTime date) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.mtfPositions)..where((tbl) => tbl.id.equals(id))).write(
        MtfPositionsCompanion(
          lastAccrualDate: Value(date),
        ),
      );
    }
    state = state.copyWith(
      mtfPositions: state.mtfPositions.map((p) => p.id == id ? p.copyWith(lastAccrualDate: Value(date)) : p).toList(),
    );
  }

  Future<void> runAutoInterestAccrual() async {
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day);
    
    final activePositions = state.mtfPositions.where((pos) => pos.isClosed == 0).toList();

    for (final pos in activePositions) {
      final lastAccrual = pos.lastAccrualDate ?? pos.interestStartDate;
      final lastAccrualDay = DateTime(lastAccrual.year, lastAccrual.month, lastAccrual.day);
      final days = today.difference(lastAccrualDay).inDays;

      if (days > 0) {
        final dailyInterest = pos.borrowedCapital * (pos.interestRate / 100) / 365;
        if (dailyInterest <= 0) continue;

        for (int i = 1; i <= days; i++) {
          final accrualDate = lastAccrualDay.add(Duration(days: i));
          final txNotes = 'MTF Interest Accrued for ${DateFormat("yyyy-MM-dd").format(accrualDate)}';
          
          await addTransaction(
            type: 'expense',
            amount: dailyInterest,
            category: 'MTF Interest',
            fromAccountId: 'acc_primary_bank_uuid',
            investmentId: pos.investmentId,
            notes: txNotes,
            date: accrualDate,
          );
        }

        await updateMtfPositionAccrual(pos.id, today);
      }
    }
  }

  // --- SIP Mutations ---

  Future<void> addSip({
    required String investmentId,
    required double amount,
    required String frequency,
    required int sipDate,
    required DateTime startDate,
    DateTime? endDate,
    required int autoCreate,
    String importMode = 'paid',
    int completedInstallmentsOverride = 0,
    DateTime? worthCreationDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final worthCreation = worthCreationDate ?? now;

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final repo = _ref.read(realSipRepositoryProvider);
      final domainSip = domain.Sip(
        id: id,
        investmentId: investmentId,
        amount: amount,
        frequency: frequency,
        sipDate: sipDate,
        startDate: startDate,
        endDate: endDate,
        autoCreate: autoCreate,
        isActive: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
        importMode: importMode,
        completedInstallmentsOverride: completedInstallmentsOverride,
        worthCreationDate: worthCreation,
      );
      await repo.createSip(domainSip);
      _queueSync('sip', id, 'upsert');
    } else {
      final newSip = Sip(
        id: id,
        investmentId: investmentId,
        amount: amount,
        frequency: frequency,
        sipDate: sipDate,
        startDate: startDate,
        endDate: endDate,
        autoCreate: autoCreate,
        isActive: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: 'pending',
        importMode: importMode,
        completedInstallmentsOverride: completedInstallmentsOverride,
        worthCreationDate: worthCreation,
      );
      state = state.copyWith(sips: [...state.sips, newSip]);
    }

    final investment = state.investments.firstWhereOrNull((i) => i.id == investmentId);
    _logHistory(
      action: 'SIP Events',
      entityType: 'SIP Event',
      entityId: id,
      entityName: investment?.name ?? 'SIP',
      valueChanged: 'Created SIP: ${state.currency}${amount.toStringAsFixed(0)}',
      newValue: 'Frequency: $frequency, Day: $sipDate',
    );

    // Pre-populate historical transactions based on import mode
    final todayMidnight = DateTime(now.year, now.month, now.day);
    if (startDate.isBefore(todayMidnight)) {
      final scheduledDates = SipCalculator.calculateScheduledDates(
        startDate: startDate,
        frequency: frequency,
        sipDate: sipDate,
        startLimit: startDate,
        endLimit: todayMidnight,
        endDate: endDate,
      );

      List<DateTime> datesToGenerate = [];
      if (importMode == 'paid') {
        datesToGenerate = scheduledDates;
      } else if (importMode == 'manual' && completedInstallmentsOverride > 0) {
        final N = completedInstallmentsOverride;
        datesToGenerate = scheduledDates.length > N
            ? scheduledDates.sublist(scheduledDates.length - N)
            : scheduledDates;
      }

      if (datesToGenerate.isNotEmpty) {
        final fromAcc = state.accounts.firstWhereOrNull((a) => a.id == 'acc_primary_bank_uuid') ?? state.accounts.firstOrNull;
        final marketPrice = investment?.marketValue ?? 1.0;
        final price = marketPrice > 0 ? marketPrice : 1.0;
        final units = amount / price;
        final invName = investment?.name ?? 'Investment';

        for (final date in datesToGenerate) {
          await buyInvestment(
            investmentId,
            fromAcc?.id,
            units,
            price,
            'SIP Auto-Invest: $invName (SIP ID: $id)',
            date,
          );
        }

        // Auto-update earliest purchase date of the investment if not already set or if earlier than current purchaseDate
        if (investment != null) {
          final earliestDate = datesToGenerate.first;
          if (investment.purchaseDate == null || investment.purchaseDate!.isAfter(earliestDate)) {
            await updateInvestment(
              investmentId,
              investment.name,
              investment.type,
              investment.symbol,
              investment.notes,
              purchaseDate: earliestDate,
              purchaseTime: investment.purchaseTime,
            );
          }
        }
      }
    }

    // Check if we should process it immediately
    await runAutoSipProcessing();
  }

  Future<void> editSip(Sip sip) async {
    final updatedSip = sip.copyWith(updatedAt: DateTime.now().toUtc());
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final repo = _ref.read(realSipRepositoryProvider);
      final domainSip = domain.Sip(
        id: sip.id,
        investmentId: sip.investmentId,
        amount: sip.amount,
        frequency: sip.frequency,
        sipDate: sip.sipDate,
        startDate: sip.startDate,
        endDate: sip.endDate,
        autoCreate: sip.autoCreate,
        isActive: sip.isActive,
        createdAt: sip.createdAt,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: sip.syncStatus,
      );
      await repo.updateSip(domainSip);
      _queueSync('sip', sip.id, 'upsert');
    } else {
      state = state.copyWith(
        sips: state.sips.map((s) => s.id == sip.id ? updatedSip : s).toList(),
      );
    }
    final investment = state.investments.firstWhereOrNull((i) => i.id == sip.investmentId);
    _logHistory(
      action: 'SIP Events',
      entityType: 'SIP Event',
      entityId: sip.id,
      entityName: investment?.name ?? 'SIP',
      valueChanged: 'Updated SIP: ${state.currency}${sip.amount.toStringAsFixed(0)}',
      newValue: 'Frequency: ${sip.frequency}, Day: ${sip.sipDate}',
    );
  }

  Future<void> deleteSip(String id) async {
    final sip = state.sips.firstWhereOrNull((s) => s.id == id);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final repo = _ref.read(realSipRepositoryProvider);
      await repo.deleteSip(id);
      _queueSync('sip', id, 'delete');
    } else {
      state = state.copyWith(
        sips: state.sips.where((s) => s.id != id).toList(),
      );
    }
    if (sip != null) {
      final investment = state.investments.firstWhereOrNull((i) => i.id == sip.investmentId);
      _logHistory(
        action: 'SIP Events',
        entityType: 'SIP Event',
        entityId: id,
        entityName: investment?.name ?? 'SIP',
        valueChanged: 'Deleted SIP',
      );
    }
  }

  Future<void> toggleSipActive(String id) async {
    final sip = state.sips.firstWhere((s) => s.id == id);
    final updatedSip = sip.copyWith(
      isActive: sip.isActive == 1 ? 0 : 1,
      updatedAt: DateTime.now().toUtc(),
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final repo = _ref.read(realSipRepositoryProvider);
      final domainSip = domain.Sip(
        id: updatedSip.id,
        investmentId: updatedSip.investmentId,
        amount: updatedSip.amount,
        frequency: updatedSip.frequency,
        sipDate: updatedSip.sipDate,
        startDate: updatedSip.startDate,
        endDate: updatedSip.endDate,
        autoCreate: updatedSip.autoCreate,
        isActive: updatedSip.isActive,
        createdAt: updatedSip.createdAt,
        updatedAt: updatedSip.updatedAt,
        syncStatus: updatedSip.syncStatus,
      );
      await repo.updateSip(domainSip);
      _queueSync('sip', updatedSip.id, 'upsert');
    } else {
      state = state.copyWith(
        sips: state.sips.map((s) => s.id == id ? updatedSip : s).toList(),
      );
    }
  }

  Future<void> runAutoSipProcessing() async {
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day);
    
    final activeSips = state.sips.where((s) => s.isActive == 1).toList();
    for (final sip in activeSips) {
      if (sip.startDate.isAfter(today)) continue;
      if (sip.endDate != null && sip.endDate!.isBefore(today)) continue;

      bool matches = false;
      if (sip.frequency == 'weekly') {
        if (today.weekday == sip.sipDate) {
          matches = true;
        }
      } else if (sip.frequency == 'monthly') {
        final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
        final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
        if (today.day == targetDay) {
          matches = true;
        }
      } else if (sip.frequency == 'quarterly') {
        final monthDiff = today.month - sip.startDate.month;
        if (monthDiff % 3 == 0) {
          final daysInMonth = DateTime(today.year, today.month + 1, 0).day;
          final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
          if (today.day == targetDay) {
            matches = true;
          }
        }
      }

      if (matches) {
        final alreadyProcessed = state.transactions.any((t) =>
            t.type == 'investment_buy' &&
            t.investmentId == sip.investmentId &&
            t.notes != null &&
            t.notes!.contains('SIP ID: ${sip.id}') &&
            t.transactionDate.year == today.year &&
            t.transactionDate.month == today.month &&
            t.transactionDate.day == today.day);

        if (!alreadyProcessed) {
          final investment = state.investments.firstWhereOrNull((i) => i.id == sip.investmentId);
          final invName = investment?.name ?? 'Investment';
          
          if (sip.autoCreate == 1) {
            final fromAcc = state.accounts.firstWhereOrNull((a) => a.id == 'acc_primary_bank_uuid') ?? state.accounts.firstOrNull;
            if (fromAcc != null) {
              final marketPrice = investment?.marketValue ?? 1.0;
              final price = marketPrice > 0 ? marketPrice : 1.0;
              final units = sip.amount / price;
              
              buyInvestment(
                sip.investmentId,
                fromAcc.id,
                units,
                price,
                'SIP Auto-Invest: $invName (SIP ID: ${sip.id})',
                today,
              );
            }
          } else {
            final notificationService = _ref.read(realNotificationServiceProvider);
            notificationService.showNotification(
              title: 'SIP Payment Reminder',
              body: 'Your SIP of ${state.currency}${sip.amount} for "$invName" is due today.',
              type: 'sip',
            );
          }
        }
      }
    }
  }

  // --- Initial seed data ---

  static MockDatabaseState initialState() {
    return MockDatabaseState(
      accounts: const [],
      people: const [],
      investments: const [],
      investmentLots: const [],
      investmentLotConsumptions: const [],
      transactions: const [],
      expectedIncomes: const [],
      goals: const [],
      snapshots: getMockSnapshots(DateTime.now()),
      adjustments: const [],
      ipoPools: const [],
      mtfPositions: const [],
      sips: const [],
      categories: const [
        'Food', 'Travel', 'Shopping', 'Education', 'Bills', 'Subscriptions',
        'Health', 'Entertainment', 'Fees', 'General', 'Salary',
        'Investment Return', 'Miscellaneous'
      ],
      customLabels: const ['Urgent', 'Personal', 'Tax Deductible', 'Business'],
      portfolioHistory: const [],
      portfolioSnapshots: const [],
      recoveryAllocations: const [],
      recoveryDestinations: const [],
      receivableActivities: const [],
      userUpiId: '',
      userUpiName: '',
      userUpiBank: '',
      currency: mockCurrency,
      themeMode: 'dark', // Premium Dark Theme by default
      appLockEnabled: false,
      appLockPin: '1234',
      appLockTimeout: 0,
      isLoggedIn: false, // Start on Login Screen for presentation!
      isOnboarded: false, // Start on Onboarding Screen for presentation!
      onboardingCompleted: false,
      firstAccountCreated: false,
      checkInEnabled: true,
      checkInTimes: '10:00,14:00,19:00,22:00',
      checkInReminderCount: '4',
      checkInCompletedDate: '',
      lastTriggeredCheckIn: '',
      notificationsEnabled: false,
      notificationPrefTransactions: true,
      notificationPrefCheckIns: true,
      notificationPrefSip: true,
      notificationPrefGoals: true,
      notificationsAsked: false,
    );
  }
}

// Global Provider
final mockDatabaseProvider = StateNotifierProvider<MockDatabaseNotifier, MockDatabaseState>((ref) {
  ref.watch(mockModeProvider);
  return MockDatabaseNotifier(ref);
});
