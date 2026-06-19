import 'dart:convert';
import 'package:drift/drift.dart';
import '../../database/database.dart' as db;

class ExportService {
  final db.AppDatabase _db;

  ExportService(this._db);

  // --- JSON Export ---

  // Reads all data tables and formats them into a single backup map
  Future<Map<String, dynamic>> exportToMap() async {
    final Map<String, dynamic> backupData = {};

    await _db.transaction(() async {
      final accounts = await _db.select(_db.accounts).get();
      final people = await _db.select(_db.people).get();
      final investments = await _db.select(_db.investments).get();
      final investmentLots = await _db.select(_db.investmentLots).get();
      final lotConsumptions = await _db.select(_db.investmentLotConsumptions).get();
      final transactions = await _db.select(_db.transactions).get();
      final expectedIncomes = await _db.select(_db.expectedIncomes).get();
      final goals = await _db.select(_db.goals).get();
      final settings = await _db.select(_db.settings).get();
      final goalMilestones = await _db.select(_db.goalMilestones).get();
      final definitions = await _db.select(_db.definitions).get();
      final adjustments = await _db.select(_db.adjustments).get();
      final milestones = await _db.select(_db.milestones).get();
      final achievements = await _db.select(_db.achievements).get();
      final achievementProgress = await _db.select(_db.achievementProgress).get();
      final mtfPositions = await _db.select(_db.mtfPositions).get();
      final sips = await _db.select(_db.sips).get();
      final dailyCheckIns = await _db.select(_db.dailyCheckIns).get();
      final portfolioHistories = await _db.select(_db.portfolioHistories).get();
      final portfolioSnapshots = await _db.select(_db.portfolioSnapshots).get();
      final recoveryAllocations = await _db.select(_db.recoveryAllocations).get();
      final recoveryDestinations = await _db.select(_db.recoveryDestinations).get();

      backupData['accounts'] = accounts.map((r) => r.toJson()).toList();
      backupData['people'] = people.map((r) => r.toJson()).toList();
      backupData['investments'] = investments.map((r) => r.toJson()).toList();
      backupData['investment_lots'] = investmentLots.map((r) => r.toJson()).toList();
      backupData['investment_lot_consumptions'] = lotConsumptions.map((r) => r.toJson()).toList();
      backupData['transactions'] = transactions.map((r) => r.toJson()).toList();
      backupData['expected_incomes'] = expectedIncomes.map((r) => r.toJson()).toList();
      backupData['goals'] = goals.map((r) => r.toJson()).toList();
      backupData['settings'] = settings.map((r) => r.toJson()).toList();
      backupData['goal_milestones'] = goalMilestones.map((r) => r.toJson()).toList();
      backupData['definitions'] = definitions.map((r) => r.toJson()).toList();
      backupData['adjustments'] = adjustments.map((r) => r.toJson()).toList();
      backupData['milestones'] = milestones.map((r) => r.toJson()).toList();
      backupData['achievements'] = achievements.map((r) => r.toJson()).toList();
      backupData['achievement_progress'] = achievementProgress.map((r) => r.toJson()).toList();
      backupData['mtf_positions'] = mtfPositions.map((r) => r.toJson()).toList();
      backupData['sips'] = sips.map((r) => r.toJson()).toList();
      backupData['daily_check_ins'] = dailyCheckIns.map((r) => r.toJson()).toList();
      backupData['portfolio_histories'] = portfolioHistories.map((r) => r.toJson()).toList();
      backupData['portfolio_snapshots'] = portfolioSnapshots.map((r) => r.toJson()).toList();
      backupData['recovery_allocations'] = recoveryAllocations.map((r) => r.toJson()).toList();
      backupData['recovery_destinations'] = recoveryDestinations.map((r) => r.toJson()).toList();
    });

    return {
      'version': 3, // Bumped version to represent comprehensive backup payload
      'timestamp': DateTime.now().toIso8601String(),
      'data': backupData,
    };
  }

  // Serializes the backup map to a raw JSON string
  Future<String> exportToJsonString() async {
    final map = await exportToMap();
    return jsonEncode(map);
  }

  // --- CSV Export ---

  // Convert tabular list of lists to CSV string
  String _toCsvString(List<List<dynamic>> rows) {
    final StringBuffer sb = StringBuffer();
    for (final row in rows) {
      final List<String> escapedRow = [];
      for (final cell in row) {
        if (cell == null) {
          escapedRow.add('');
          continue;
        }
        String val = cell.toString();
        // Escape quotes and wrap cell if it contains special characters
        if (val.contains(',') || val.contains('\n') || val.contains('\r') || val.contains('"')) {
          val = '"' + val.replaceAll('"', '""') + '"';
        }
        escapedRow.add(val);
      }
      sb.writeln(escapedRow.join(','));
    }
    return sb.toString();
  }

  Future<String> exportAccountsToCsv() async {
    final list = await _db.select(_db.accounts).get();
    final List<List<dynamic>> rows = [
      ['id', 'name', 'type', 'notes', 'isArchived', 'createdAt', 'updatedAt']
    ];
    for (final a in list) {
      rows.add([
        a.id,
        a.name,
        a.type,
        a.notes,
        a.isArchived,
        a.createdAt.toIso8601String(),
        a.updatedAt.toIso8601String(),
      ]);
    }
    return _toCsvString(rows);
  }

  Future<String> exportTransactionsToCsv() async {
    final list = await _db.select(_db.transactions).get();
    final List<List<dynamic>> rows = [
      [
        'id',
        'type',
        'amount',
        'category',
        'fromAccountId',
        'toAccountId',
        'personId',
        'investmentId',
        'voidedTransactionId',
        'notes',
        'pricePerUnit',
        'units',
        'transactionDate',
        'createdAt',
        'updatedAt'
      ]
    ];
    for (final t in list) {
      rows.add([
        t.id,
        t.type,
        t.amount,
        t.category,
        t.fromAccountId,
        t.toAccountId,
        t.personId,
        t.investmentId,
        t.voidedTransactionId,
        t.notes,
        t.pricePerUnit,
        t.units,
        t.transactionDate.toIso8601String(),
        t.createdAt.toIso8601String(),
        t.updatedAt.toIso8601String(),
      ]);
    }
    return _toCsvString(rows);
  }

  Future<String> exportAssetsToCsv() async {
    // Assets: Accounts (non-credit) + Investments + People (receivable cash balance)
    final List<List<dynamic>> rows = [
      ['id', 'name', 'type', 'balance', 'notes', 'isArchived', 'createdAt', 'updatedAt']
    ];

    // 1. Non-credit Accounts
    final accounts = await (_db.select(_db.accounts)..where((tbl) => tbl.type.equals('credit').not())).get();
    for (final a in accounts) {
      // Fetch balance from cache
      final cache = await (_db.select(_db.accountBalanceCaches)..where((tbl) => tbl.accountId.equals(a.id))).getSingleOrNull();
      final balance = cache?.cashBalance ?? 0.0;
      rows.add([a.id, a.name, a.type, balance, a.notes, a.isArchived, a.createdAt.toIso8601String(), a.updatedAt.toIso8601String()]);
    }

    // 2. Investments
    final investments = await _db.select(_db.investments).get();
    for (final i in investments) {
      final cache = await (_db.select(_db.investmentBalanceCaches)..where((tbl) => tbl.investmentId.equals(i.id))).getSingleOrNull();
      final units = cache?.unitsHeld ?? 0.0;
      final price = i.marketValue ?? 0.0;
      final balance = units * price;
      rows.add([i.id, i.name, i.type, balance, i.notes, i.isArchived, i.createdAt.toIso8601String(), i.updatedAt.toIso8601String()]);
    }

    // 3. People (Receivables)
    final people = await _db.select(_db.people).get();
    for (final p in people) {
      final cache = await (_db.select(_db.personBalanceCaches)..where((tbl) => tbl.personId.equals(p.id))).getSingleOrNull();
      final balance = cache?.receivableBalance ?? 0.0;
      if (balance > 0) {
        rows.add([p.id, p.name, 'receivable', balance, p.notes, p.isArchived, p.createdAt.toIso8601String(), p.updatedAt.toIso8601String()]);
      }
    }

    return _toCsvString(rows);
  }

  Future<String> exportLiabilitiesToCsv() async {
    // Liabilities: Credit Accounts + People (liability balances)
    final List<List<dynamic>> rows = [
      ['id', 'name', 'type', 'outstandingAmount', 'notes', 'isArchived', 'createdAt', 'updatedAt']
    ];

    // 1. Credit Cards
    final creditAccounts = await (_db.select(_db.accounts)..where((tbl) => tbl.type.equals('credit'))).get();
    for (final a in creditAccounts) {
      final cache = await (_db.select(_db.accountBalanceCaches)..where((tbl) => tbl.accountId.equals(a.id))).getSingleOrNull();
      final balance = cache?.liabilityBalance ?? 0.0;
      rows.add([a.id, a.name, 'credit_card', balance, a.notes, a.isArchived, a.createdAt.toIso8601String(), a.updatedAt.toIso8601String()]);
    }

    // 2. People (Liability debts)
    final people = await _db.select(_db.people).get();
    for (final p in people) {
      final cache = await (_db.select(_db.personBalanceCaches)..where((tbl) => tbl.personId.equals(p.id))).getSingleOrNull();
      final balance = cache?.liabilityBalance ?? 0.0;
      if (balance > 0) {
        rows.add([p.id, p.name, 'personal_debt', balance, p.notes, p.isArchived, p.createdAt.toIso8601String(), p.updatedAt.toIso8601String()]);
      }
    }

    return _toCsvString(rows);
  }

  Future<String> exportInvestmentsToCsv() async {
    final list = await _db.select(_db.investments).get();
    final List<List<dynamic>> rows = [
      ['id', 'name', 'type', 'symbol', 'marketValue', 'notes', 'isArchived', 'createdAt', 'updatedAt']
    ];
    for (final i in list) {
      rows.add([
        i.id,
        i.name,
        i.type,
        i.symbol,
        i.marketValue,
        i.notes,
        i.isArchived,
        i.createdAt.toIso8601String(),
        i.updatedAt.toIso8601String(),
      ]);
    }
    return _toCsvString(rows);
  }

  Future<String> exportReceivablesToCsv() async {
    // People having receivableBalance > 0
    final List<List<dynamic>> rows = [
      ['id', 'personName', 'amount', 'notes', 'isArchived', 'createdAt', 'updatedAt']
    ];
    final list = await _db.select(_db.people).get();
    for (final p in list) {
      final cache = await (_db.select(_db.personBalanceCaches)..where((tbl) => tbl.personId.equals(p.id))).getSingleOrNull();
      final outstanding = cache?.receivableBalance ?? 0.0;
      if (outstanding > 0) {
        rows.add([
          p.id,
          p.name,
          outstanding,
          p.notes,
          p.isArchived,
          p.createdAt.toIso8601String(),
          p.updatedAt.toIso8601String(),
        ]);
      }
    }
    return _toCsvString(rows);
  }

  Future<String> exportGoalsToCsv() async {
    final list = await _db.select(_db.goals).get();
    final List<List<dynamic>> rows = [
      ['id', 'name', 'targetAmount', 'currentAmount', 'deadline', 'notes', 'isArchived', 'createdAt', 'updatedAt']
    ];
    for (final g in list) {
      rows.add([
        g.id,
        g.name,
        g.targetAmount,
        g.currentAmount,
        g.deadline?.toIso8601String(),
        g.notes,
        g.isArchived,
        g.createdAt.toIso8601String(),
        g.updatedAt.toIso8601String(),
      ]);
    }
    return _toCsvString(rows);
  }

  Future<Map<String, String>> exportAllToCsv() async {
    return {
      'accounts.csv': await exportAccountsToCsv(),
      'transactions.csv': await exportTransactionsToCsv(),
      'assets.csv': await exportAssetsToCsv(),
      'liabilities.csv': await exportLiabilitiesToCsv(),
      'investments.csv': await exportInvestmentsToCsv(),
      'receivables.csv': await exportReceivablesToCsv(),
      'goals.csv': await exportGoalsToCsv(),
    };
  }
}
