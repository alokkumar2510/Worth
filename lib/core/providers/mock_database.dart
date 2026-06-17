import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../../database/seeder.dart';
export '../../database/database.dart' hide Transaction, Snapshot, Account, Investment, Goal, ExpectedIncome, Milestone, Achievement, AchievementProgress;
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

  MockDatabaseState({
    required this.accounts,
    required this.people,
    required this.investments,
    required this.investmentLots,
    required this.investmentLotConsumptions,
    required this.transactions,
    required this.expectedIncomes,
    required this.goals,
    required this.snapshots,
    required this.adjustments,
    required this.ipoPools,
    required this.currency,
    required this.themeMode,
    required this.appLockEnabled,
    required this.appLockPin,
    required this.appLockTimeout,
    required this.isLoggedIn,
    required this.isOnboarded,
    required this.onboardingCompleted,
    required this.firstAccountCreated,
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
    String? currency,
    String? themeMode,
    bool? appLockEnabled,
    String? appLockPin,
    int? appLockTimeout,
    bool? isLoggedIn,
    bool? isOnboarded,
    bool? onboardingCompleted,
    bool? firstAccountCreated,
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
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      appLockPin: appLockPin ?? this.appLockPin,
      appLockTimeout: appLockTimeout ?? this.appLockTimeout,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      firstAccountCreated: firstAccountCreated ?? this.firstAccountCreated,
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
      if (tx.toAccountId == accountId && tx.type == 'repay_money') {
        // Repaying credit card reduces liability
        liability -= tx.amount;
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
        if (tx.type == 'borrow_money') {
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
    // 1. Person liabilities (borrowed money)
    double borrowed = 0.0;
    for (final p in people) {
      if (p.isArchived == 0) {
        borrowed += getPersonLiabilityBalance(p.id);
      }
    }

    // 2. Credit Card outstanding dues
    double credit = 0.0;
    for (final acc in accounts) {
      if (acc.isArchived == 0 && acc.type == 'credit') {
        credit += getAccountLiabilityBalance(acc.id);
      }
    }

    return borrowed + credit;
  }

  double get netWorth {
    return totalAssets - totalLiabilities;
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

  Future<void> loadStateFromDatabase() async {
    try {
      final db = _ref.read(realDatabaseProvider);
      final accounts = await db.select(db.accounts).get();
      final people = await db.select(db.people).get();
      final investments = await db.select(db.investments).get();
      final transactions = await db.select(db.transactions).get();
      final expectedIncomes = await db.select(db.expectedIncomes).get();
      final goals = await db.select(db.goals).get();
      final snapshots = await db.select(db.snapshots).get();
      final investmentLots = await db.select(db.investmentLots).get();
      final consumptions = await db.select(db.investmentLotConsumptions).get();
      final adjustments = await db.select(db.adjustments).get();
      final settingsList = await db.select(db.settings).get();

      final settingsMap = {for (var s in settingsList) s.key: s.value};

      final currency = settingsMap['currency'] ?? '₹';
      final themeMode = settingsMap['themeMode'] ?? 'dark';
      final appLockEnabled = settingsMap['appLockEnabled'] == 'true';
      final appLockPin = settingsMap['appLockPin'] ?? '1234';
      final appLockTimeout = int.tryParse(settingsMap['appLockTimeout'] ?? '0') ?? 0;
      final isLoggedIn = settingsMap['isLoggedIn'] == 'true';
      final isOnboarded = settingsMap['isOnboarded'] == 'true';
      final onboardingCompleted = settingsMap['onboardingCompleted'] == 'true' || isOnboarded;
      final firstAccountCreated = settingsMap['firstAccountCreated'] == 'true' || accounts.isNotEmpty;

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
        currency: currency,
        themeMode: themeMode,
        appLockEnabled: appLockEnabled,
        appLockPin: appLockPin,
        appLockTimeout: appLockTimeout,
        isLoggedIn: isLoggedIn,
        isOnboarded: isOnboarded,
        onboardingCompleted: onboardingCompleted,
        firstAccountCreated: firstAccountCreated,
      );

      // Trigger gamification engine evaluation
      Future.microtask(() async {
        try {
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
    }
  }

  void logout() {
    state = state.copyWith(isLoggedIn: false);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'isLoggedIn', value: 'false'));
    }
  }

  Future<void> setOnboardingCompleted() async {
    state = state.copyWith(onboardingCompleted: true);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'onboardingCompleted', value: 'true'));
    }
  }

  Future<void> setFirstAccountCreated() async {
    state = state.copyWith(firstAccountCreated: true);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'firstAccountCreated', value: 'true'));
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(
      isOnboarded: true,
      isLoggedIn: true,
      onboardingCompleted: true,
      firstAccountCreated: true,
    );
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'isOnboarded', value: 'true'));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'isLoggedIn', value: 'true'));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'onboardingCompleted', value: 'true'));
      await db.into(db.settings).insertOnConflictUpdate(Setting(key: 'firstAccountCreated', value: 'true'));
    }
  }

  // --- Settings Mutations ---

  void updateCurrency(String newCurrency) {
    state = state.copyWith(currency: newCurrency);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'currency', value: newCurrency));
    }
  }

  void updateTheme(String theme) {
    state = state.copyWith(themeMode: theme);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'themeMode', value: theme));
    }
  }

  void updateAppLock(bool enabled, String pin) {
    state = state.copyWith(appLockEnabled: enabled, appLockPin: pin);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'appLockEnabled', value: enabled ? 'true' : 'false'));
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'appLockPin', value: pin));
    }
  }

  void updateAppLockTimeout(int seconds) {
    state = state.copyWith(appLockTimeout: seconds);
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.settings).insertOnConflictUpdate(Setting(key: 'appLockTimeout', value: seconds.toString()));
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

  Future<Account> addAccount(String name, String type, String? notes, double openingBalance, {String? id}) async {
    final actualId = id ?? _uuid.v4();
    final now = DateTime.now().toUtc();
    final newAccount = Account(
      id: actualId,
      name: name,
      type: type,
      notes: notes,
      isArchived: 0,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.accounts).insert(newAccount);
      if (openingBalance > 0) {
        if (type == 'credit') {
          await addBorrowTransaction(actualId, actualId, openingBalance, 'Opening Balance Owed', now);
        } else {
          await addTransaction(
            type: 'income',
            amount: openingBalance,
            toAccountId: actualId,
            category: 'Opening Balance',
            notes: 'Initial deposit',
            date: now,
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
            notes: 'Opening Balance Owed',
            date: now,
          );
        } else {
          _createTransactionInternal(
            type: 'income',
            amount: openingBalance,
            toAccountId: actualId,
            category: 'Opening Balance',
            notes: 'Initial deposit',
            date: now,
          );
        }
      }
    }

    return newAccount;
  }

  void archiveAccount(String accountId) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.update(db.accounts)
        ..where((tbl) => tbl.id.equals(accountId))
        ..write(AccountsCompanion(isArchived: const Value(1), updatedAt: Value(DateTime.now().toUtc())));
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
  }

  Future<bool> deleteAccountEmpty(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final countQuery = db.select(db.transactions)..where((tbl) => tbl.fromAccountId.equals(id) | tbl.toAccountId.equals(id));
      final count = (await countQuery.get()).length;
      if (count > 0) return false;
      await (db.delete(db.accounts)..where((tbl) => tbl.id.equals(id))).go();
      return true;
    } else {
      final count = state.transactions.where((t) => t.fromAccountId == id || t.toAccountId == id).length;
      if (count > 0) return false;
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

  Person addPerson(String name, String? phone, String? notes) {
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
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.people).insert(newPerson);
    } else {
      state = state.copyWith(people: [...state.people, newPerson]);
    }
    return newPerson;
  }

  Future<void> updatePerson(String id, String name, String? phone, String? notes) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.people)..where((tbl) => tbl.id.equals(id)))
        .write(PeopleCompanion(
          name: Value(name),
          phone: Value(phone),
          notes: Value(notes),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
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
              updatedAt: DateTime.now().toUtc(),
              syncStatus: p.syncStatus,
            );
          }
          return p;
        }).toList(),
      );
    }
  }

  Future<bool> deletePerson(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final countQuery = db.select(db.transactions)..where((tbl) => tbl.personId.equals(id));
      final count = (await countQuery.get()).length;
      if (count > 0) return false;
      await (db.delete(db.people)..where((tbl) => tbl.id.equals(id))).go();
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
            );
          }
          return p;
        }).toList(),
      );
    }
  }

  Future<void> addLendTransaction(String personId, String fromAccountId, double amount, String? notes, DateTime date) async {
    await addTransaction(
      type: 'lend_money',
      amount: amount,
      fromAccountId: fromAccountId,
      personId: personId,
      notes: notes,
      date: date,
    );
  }

  Future<void> addBorrowTransaction(String personId, String toAccountId, double amount, String? notes, DateTime date) async {
    await addTransaction(
      type: 'borrow_money',
      amount: amount,
      toAccountId: toAccountId,
      personId: personId,
      notes: notes,
      date: date,
    );
  }

  Future<void> addRepayTransaction(String personId, String fromAccountId, double amount, String? notes, DateTime date) async {
    await addTransaction(
      type: 'repay_money',
      amount: amount,
      fromAccountId: fromAccountId,
      personId: personId,
      notes: notes,
      date: date,
    );
  }

  Future<void> addRecoverTransaction(String personId, String toAccountId, double amount, String? notes, DateTime date) async {
    await addTransaction(
      type: 'recover_money',
      amount: amount,
      toAccountId: toAccountId,
      personId: personId,
      notes: notes,
      date: date,
    );
  }

  Investment addInvestment(String name, String type, String? symbol, String? notes, double marketValue) {
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
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );

    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      db.into(db.investments).insert(newInvestment);
    } else {
      state = state.copyWith(investments: [...state.investments, newInvestment]);
    }
    return newInvestment;
  }

  void updateInvestmentMarketValue(String investmentId, double newValue) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realInvestmentServiceProvider).updateMarketValue(investmentId, newValue);
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
  }

  Future<void> updateInvestment(String id, String name, String type, String? symbol, String? notes) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.update(db.investments)..where((tbl) => tbl.id.equals(id)))
        .write(InvestmentsCompanion(
          name: Value(name),
          type: Value(type),
          symbol: Value(symbol),
          notes: Value(notes),
          updatedAt: Value(DateTime.now().toUtc()),
        ));
    } else {
      state = state.copyWith(
        investments: state.investments.map((i) {
          if (i.id == id) {
            return i.copyWith(
              name: name,
              type: type,
              symbol: Value(symbol),
              notes: Value(notes),
              updatedAt: DateTime.now().toUtc(),
            );
          }
          return i;
        }).toList(),
      );
    }
  }

  Future<bool> deleteInvestment(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      final countQuery = db.select(db.investmentLots)..where((tbl) => tbl.investmentId.equals(id));
      final count = (await countQuery.get()).length;
      if (count > 0) return false;
      await (db.delete(db.investments)..where((tbl) => tbl.id.equals(id))).go();
      return true;
    } else {
      final count = state.investmentLots.where((l) => l.investmentId == id).length;
      if (count > 0) return false;
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
  }

  void buyInvestment(String investmentId, String fromAccountId, double units, double pricePerUnit, String? notes, DateTime date) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realInvestmentServiceProvider).buyInvestment(
        investmentId: investmentId,
        fromAccountId: fromAccountId,
        units: units,
        pricePerUnit: pricePerUnit,
        notes: notes,
        date: date,
      );
    } else {
      final amount = units * pricePerUnit;
      final tx = _createTransactionInternal(
        type: 'investment_buy',
        amount: amount,
        fromAccountId: fromAccountId,
        investmentId: investmentId,
        notes: notes ?? 'Bought $units units @ ${state.currency} $pricePerUnit',
        date: date,
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
      );

      state = state.copyWith(investmentLots: [...state.investmentLots, newLot]);
    }
  }

  void sellInvestment(String investmentId, String toAccountId, double unitsToSell, double salePricePerUnit, String? notes, DateTime date) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realInvestmentServiceProvider).sellInvestment(
        investmentId: investmentId,
        toAccountId: toAccountId,
        unitsToSell: unitsToSell,
        salePricePerUnit: salePricePerUnit,
        notes: notes,
        date: date,
      );
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
  }

  void addExpectedIncome(String source, double amount, DateTime? expectedDate, String? notes) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realExpectedIncomeServiceProvider).addExpectedIncome(
        source: source,
        amount: amount,
        expectedDate: expectedDate,
        notes: notes,
      );
    } else {
      final newInc = ExpectedIncome(
        id: _uuid.v4(),
        source: source,
        amount: amount,
        status: 'pending',
        expectedDate: expectedDate,
        notes: notes,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
      );

      state = state.copyWith(expectedIncomes: [...state.expectedIncomes, newInc]);
    }
  }

  void markExpectedIncomeReceived(String incomeId, String destinationAccountId) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realExpectedIncomeServiceProvider).markReceived(incomeId, destinationAccountId);
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
  }

  void markExpectedIncomeExpired(String incomeId) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realExpectedIncomeServiceProvider).markExpired(incomeId);
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
    } else {
      state = state.copyWith(
        expectedIncomes: state.expectedIncomes.where((i) => i.id != id).toList(),
      );
    }
  }

  void addGoal(String name, double targetAmount, DateTime? deadline, String? notes) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realGoalServiceProvider).createGoal(
        name: name,
        targetAmount: targetAmount,
        targetDate: deadline,
        notes: notes,
      );
    } else {
      final newGoal = Goal(
        id: _uuid.v4(),
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
    } else {
      state = state.copyWith(
        goals: state.goals.map((g) => g.id == goal.id ? goal : g).toList(),
      );
    }
  }

  Future<void> deleteGoal(String id) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final db = _ref.read(realDatabaseProvider);
      await (db.delete(db.goals)..where((tbl) => tbl.id.equals(id))).go();
    } else {
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
    
    addAccount(mockBankName1, 'bank', 'Main checking account', 250000.0, id: 'acc_primary_bank_uuid');
    addAccount('Cash Wallet', 'cash', 'Physical cash', 5000.0, id: 'acc_cash_wallet_uuid');
    addAccount(mockCreditCardName1, 'credit', 'Primary credit card', 15000.0, id: 'acc_cc_a_uuid');
    
    final p1 = addPerson(mockPersonName1, '+91 98765 43210', 'Friend from college');
    final p2 = addPerson(mockPersonName2, '+91 99999 88888', 'Landlord');
    
    addLendTransaction(p1.id, 'acc_primary_bank_uuid', 10000.0, 'Lent for emergency', now.subtract(const Duration(days: 5)));
    addBorrowTransaction(p2.id, 'acc_primary_bank_uuid', 5000.0, 'Borrowed for deposit', now.subtract(const Duration(days: 3)));
    
    final inv1 = addInvestment(mockInvestmentName1, 'stock', 'INFY', 'Infosys shares', 1800.0);
    final inv2 = addInvestment(mockInvestmentName2, 'mutual_fund', 'NIFTY50', 'Index Mutual Fund', 700.0);
    
    buyInvestment(inv1.id, 'acc_primary_bank_uuid', 30, 1800.0, 'Bought 30 units', now.subtract(const Duration(days: 10)));
    buyInvestment(inv2.id, 'acc_primary_bank_uuid', 100, 700.0, 'Bought 100 units', now.subtract(const Duration(days: 15)));
    
    addExpectedIncome('Freelance Design', 25000.0, now.add(const Duration(days: 7)), 'Logo design project');
    addExpectedIncome('Dividends', 1500.0, now.add(const Duration(days: 12)), 'INFY stock dividends');
    
    addGoal(mockGoalName1, 150000.0, now.add(const Duration(days: 180)), '6 months emergency fund');
    addGoal(mockGoalName2, 300000.0, now.add(const Duration(days: 365)), 'Downpayment for car');
    
    if (!isMock) {
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
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
  }) async {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      final tx = Transaction(
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
      );
      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
      return tx;
    } else {
      return _createTransactionInternal(
        type: type,
        amount: amount,
        category: category,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        personId: personId,
        investmentId: investmentId,
        notes: notes,
        date: date,
      );
    }
  }

  void voidTransaction(String transactionId) {
    final isMock = _ref.read(mockModeProvider);
    if (!isMock) {
      _ref.read(realTransactionServiceProvider).voidTransaction(transactionId);
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
  }

  Future<void> updateIpoPool(IpoPool pool) async {
    final updatedList = state.ipoPools.map((p) => p.id == pool.id ? pool : p).toList();
    state = state.copyWith(ipoPools: updatedList);
    await _saveIpoPoolsToDb();
  }

  Future<void> deleteIpoPool(String id) async {
    final updatedList = state.ipoPools.where((p) => p.id != id).toList();
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
      currency: mockCurrency,
      themeMode: 'dark', // Premium Dark Theme by default
      appLockEnabled: false,
      appLockPin: '1234',
      appLockTimeout: 0,
      isLoggedIn: false, // Start on Login Screen for presentation!
      isOnboarded: false, // Start on Onboarding Screen for presentation!
      onboardingCompleted: false,
      firstAccountCreated: false,
    );
  }
}

// Global Provider
final mockDatabaseProvider = StateNotifierProvider<MockDatabaseNotifier, MockDatabaseState>((ref) {
  ref.watch(mockModeProvider);
  return MockDatabaseNotifier(ref);
});
