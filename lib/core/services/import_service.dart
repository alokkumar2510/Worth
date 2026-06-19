import 'dart:convert';
import 'package:drift/drift.dart';
import '../../database/database.dart' as db;
import '../calculation/balance_cache_service.dart';
import 'search_index_service.dart';

class ImportService {
  final db.AppDatabase _db;
  final BalanceCacheService _cacheService;
  final SearchIndexService _searchIndexService;

  ImportService(this._db, this._cacheService, this._searchIndexService);

  // --- JSON Import ---

  // Clears all existing user table data and restores records from the backup payload map
  Future<void> importFromMap(Map<String, dynamic> payload) async {
    final version = payload['version'] as int? ?? 1;
    final data = payload['data'] as Map<String, dynamic>;

    await _db.transaction(() async {
      // 1. Wipe all current tables to support full recovery
      await _db.delete(_db.investmentLotConsumptions).go();
      await _db.delete(_db.investmentLots).go();
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.expectedIncomes).go();
      await _db.delete(_db.goalMilestones).go();
      await _db.delete(_db.goals).go();
      await _db.delete(_db.accounts).go();
      await _db.delete(_db.people).go();
      await _db.delete(_db.investments).go();
      await _db.delete(_db.settings).go();
      await _db.delete(_db.definitions).go();
      await _db.delete(_db.adjustments).go();
      await _db.delete(_db.milestones).go();
      await _db.delete(_db.achievementProgress).go();
      await _db.delete(_db.achievements).go();
      await _db.delete(_db.mtfPositions).go();
      await _db.delete(_db.sips).go();
      await _db.delete(_db.dailyCheckIns).go();
      await _db.delete(_db.portfolioHistories).go();
      await _db.delete(_db.portfolioSnapshots).go();
      await _db.delete(_db.recoveryAllocations).go();
      await _db.delete(_db.recoveryDestinations).go();

      // 2. Insert records sequentially to satisfy foreign key constraints

      // Accounts
      if (data['accounts'] != null) {
        for (final item in data['accounts'] as List) {
          await _db.into(_db.accounts).insert(db.Account.fromJson(item as Map<String, dynamic>));
        }
      }

      // People
      if (data['people'] != null) {
        for (final item in data['people'] as List) {
          await _db.into(_db.people).insert(db.Person.fromJson(item as Map<String, dynamic>));
        }
      }

      // Investments
      if (data['investments'] != null) {
        for (final item in data['investments'] as List) {
          await _db.into(_db.investments).insert(db.Investment.fromJson(item as Map<String, dynamic>));
        }
      }

      // Transactions
      if (data['transactions'] != null) {
        for (final item in data['transactions'] as List) {
          await _db.into(_db.transactions).insert(db.Transaction.fromJson(item as Map<String, dynamic>));
        }
      }

      // Investment Lots
      if (data['investment_lots'] != null) {
        for (final item in data['investment_lots'] as List) {
          await _db.into(_db.investmentLots).insert(db.InvestmentLot.fromJson(item as Map<String, dynamic>));
        }
      }

      // Lot Consumptions
      if (data['investment_lot_consumptions'] != null) {
        for (final item in data['investment_lot_consumptions'] as List) {
          await _db.into(_db.investmentLotConsumptions).insert(db.InvestmentLotConsumption.fromJson(item as Map<String, dynamic>));
        }
      }

      // Expected Incomes
      if (data['expected_incomes'] != null) {
        for (final item in data['expected_incomes'] as List) {
          await _db.into(_db.expectedIncomes).insert(db.ExpectedIncome.fromJson(item as Map<String, dynamic>));
        }
      }

      // Goals
      if (data['goals'] != null) {
        for (final item in data['goals'] as List) {
          await _db.into(_db.goals).insert(db.Goal.fromJson(item as Map<String, dynamic>));
        }
      }

      // Goal Milestones
      if (data['goal_milestones'] != null) {
        for (final item in data['goal_milestones'] as List) {
          await _db.into(_db.goalMilestones).insert(db.GoalMilestone.fromJson(item as Map<String, dynamic>));
        }
      }

      // Settings
      if (data['settings'] != null) {
        for (final item in data['settings'] as List) {
          await _db.into(_db.settings).insert(db.Setting.fromJson(item as Map<String, dynamic>));
        }
      }

      // Definitions
      if (data['definitions'] != null) {
        for (final item in data['definitions'] as List) {
          await _db.into(_db.definitions).insert(db.Definition.fromJson(item as Map<String, dynamic>));
        }
      }

      // Adjustments
      if (data['adjustments'] != null) {
        for (final item in data['adjustments'] as List) {
          await _db.into(_db.adjustments).insert(db.Adjustment.fromJson(item as Map<String, dynamic>));
        }
      }

      // Milestones
      if (data['milestones'] != null) {
        for (final item in data['milestones'] as List) {
          await _db.into(_db.milestones).insert(db.Milestone.fromJson(item as Map<String, dynamic>));
        }
      }

      // Achievements
      if (data['achievements'] != null) {
        for (final item in data['achievements'] as List) {
          await _db.into(_db.achievements).insert(db.Achievement.fromJson(item as Map<String, dynamic>));
        }
      }

      // Achievement Progress
      if (data['achievement_progress'] != null) {
        for (final item in data['achievement_progress'] as List) {
          await _db.into(_db.achievementProgress).insert(db.AchievementProgressData.fromJson(item as Map<String, dynamic>));
        }
      }

      // MTF Positions
      if (data['mtf_positions'] != null) {
        for (final item in data['mtf_positions'] as List) {
          await _db.into(_db.mtfPositions).insert(db.MtfPosition.fromJson(item as Map<String, dynamic>));
        }
      }

      // Sips
      if (data['sips'] != null) {
        for (final item in data['sips'] as List) {
          await _db.into(_db.sips).insert(db.Sip.fromJson(item as Map<String, dynamic>));
        }
      }

      // Daily Check Ins
      if (data['daily_check_ins'] != null) {
        for (final item in data['daily_check_ins'] as List) {
          await _db.into(_db.dailyCheckIns).insert(db.DailyCheckIn.fromJson(item as Map<String, dynamic>));
        }
      }

      // Portfolio Histories
      if (data['portfolio_histories'] != null) {
        for (final item in data['portfolio_histories'] as List) {
          await _db.into(_db.portfolioHistories).insert(db.PortfolioHistory.fromJson(item as Map<String, dynamic>));
        }
      }

      // Portfolio Snapshots
      if (data['portfolio_snapshots'] != null) {
        for (final item in data['portfolio_snapshots'] as List) {
          await _db.into(_db.portfolioSnapshots).insert(db.PortfolioSnapshot.fromJson(item as Map<String, dynamic>));
        }
      }

      // Recovery Allocations
      if (data['recovery_allocations'] != null) {
        for (final item in data['recovery_allocations'] as List) {
          await _db.into(_db.recoveryAllocations).insert(db.RecoveryAllocation.fromJson(item as Map<String, dynamic>));
        }
      }

      // Recovery Destinations
      if (data['recovery_destinations'] != null) {
        for (final item in data['recovery_destinations'] as List) {
          await _db.into(_db.recoveryDestinations).insert(db.RecoveryDestination.fromJson(item as Map<String, dynamic>));
        }
      }
    });

    // 3. Replay transactions to rebuild balance cache
    await _cacheService.rebuildCache();

    // 4. Rebuild full text search index
    await _searchIndexService.rebuildIndex();
  }

  // Parses a JSON string and executes complete data restore
  Future<void> importFromJsonString(String jsonString) async {
    final Map<String, dynamic> payload = jsonDecode(jsonString) as Map<String, dynamic>;
    await importFromMap(payload);
  }

  // --- CSV Parser Helper ---

  List<List<String>> _parseCsv(String csvContent) {
    final List<List<String>> result = [];
    List<String> currentRow = [];
    final StringBuffer currentCell = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < csvContent.length; i++) {
      final char = csvContent[i];

      if (inQuotes) {
        if (char == '"') {
          // Check for escaped double quote
          if (i + 1 < csvContent.length && csvContent[i + 1] == '"') {
            currentCell.write('"');
            i++; // skip next quote
          } else {
            inQuotes = false;
          }
        } else {
          currentCell.write(char);
        }
      } else {
        if (char == '"') {
          inQuotes = true;
        } else if (char == ',') {
          currentRow.add(currentCell.toString());
          currentCell.clear();
        } else if (char == '\n' || char == '\r') {
          currentRow.add(currentCell.toString());
          currentCell.clear();
          if (currentRow.isNotEmpty) {
            result.add(currentRow);
            currentRow = [];
          }
          // Handle CRLF (\r\n)
          if (char == '\r' && i + 1 < csvContent.length && csvContent[i + 1] == '\n') {
            i++;
          }
        } else {
          currentCell.write(char);
        }
      }
    }
    // Add final cell & row if remaining
    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString());
      result.add(currentRow);
    }
    return result;
  }

  // --- CSV Import ---

  Future<void> importAccountsFromCsv(String csv) async {
    final parsed = _parseCsv(csv);
    if (parsed.length <= 1) return; // Only header or empty

    final headers = parsed.first;
    await _db.transaction(() async {
      for (int i = 1; i < parsed.length; i++) {
        final row = parsed[i];
        if (row.length < headers.length) continue;

        final map = Map<String, String>.fromIterables(headers, row);
        final account = db.Account(
          id: map['id']!,
          name: map['name']!,
          type: map['type']!,
          notes: map['notes']?.isEmpty ?? true ? null : map['notes'],
          isArchived: int.parse(map['isArchived']!),
          createdAt: DateTime.parse(map['createdAt']!),
          updatedAt: DateTime.parse(map['updatedAt']!),
          syncStatus: map['syncStatus'] ?? 'pending',
        );

        await _db.into(_db.accounts).insertOnConflictUpdate(account);
      }
    });
    await _cacheService.rebuildCache();
  }

  Future<void> importTransactionsFromCsv(String csv) async {
    final parsed = _parseCsv(csv);
    if (parsed.length <= 1) return;

    final headers = parsed.first;
    await _db.transaction(() async {
      for (int i = 1; i < parsed.length; i++) {
        final row = parsed[i];
        if (row.length < headers.length) continue;

        final map = Map<String, String>.fromIterables(headers, row);
        final tx = db.Transaction(
          id: map['id']!,
          type: map['type']!,
          amount: double.parse(map['amount']!),
          category: map['category']?.isEmpty ?? true ? null : map['category'],
          fromAccountId: map['fromAccountId']?.isEmpty ?? true ? null : map['fromAccountId'],
          toAccountId: map['toAccountId']?.isEmpty ?? true ? null : map['toAccountId'],
          personId: map['personId']?.isEmpty ?? true ? null : map['personId'],
          investmentId: map['investmentId']?.isEmpty ?? true ? null : map['investmentId'],
          voidedTransactionId: map['voidedTransactionId']?.isEmpty ?? true ? null : map['voidedTransactionId'],
          notes: map['notes']?.isEmpty ?? true ? null : map['notes'],
          pricePerUnit: map['pricePerUnit']?.isEmpty ?? true ? null : double.tryParse(map['pricePerUnit']!),
          units: map['units']?.isEmpty ?? true ? null : double.tryParse(map['units']!),
          transactionDate: DateTime.parse(map['transactionDate']!),
          createdAt: DateTime.parse(map['createdAt']!),
          updatedAt: DateTime.parse(map['updatedAt']!),
          syncStatus: map['syncStatus'] ?? 'pending',
        );

        await _db.into(_db.transactions).insertOnConflictUpdate(tx);
      }
    });
    await _cacheService.rebuildCache();
    await _searchIndexService.rebuildIndex();
  }

  Future<void> importAssetsFromCsv(String csv) async {
    final parsed = _parseCsv(csv);
    if (parsed.length <= 1) return;

    final headers = parsed.first;
    await _db.transaction(() async {
      for (int i = 1; i < parsed.length; i++) {
        final row = parsed[i];
        if (row.length < headers.length) continue;

        final map = Map<String, String>.fromIterables(headers, row);
        final String id = map['id']!;
        final String name = map['name']!;
        final String type = map['type']!;
        final double balance = double.parse(map['balance']!);
        final String? notes = map['notes']?.isEmpty ?? true ? null : map['notes'];
        final int isArchived = int.parse(map['isArchived']!);
        final DateTime createdAt = DateTime.parse(map['createdAt']!);
        final DateTime updatedAt = DateTime.parse(map['updatedAt']!);

        if (type == 'receivable') {
          final person = db.Person(
            id: id,
            name: name,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: map['syncStatus'] ?? 'pending',
          );
          await _db.into(_db.people).insertOnConflictUpdate(person);
        } else if (['stock', 'mutual_fund', 'etf', 'gold', 'crypto', 'bond', 'fd'].contains(type)) {
          final inv = db.Investment(
            id: id,
            name: name,
            type: type,
            marketValue: balance,
            isArchived: isArchived,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: map['syncStatus'] ?? 'pending',
          );
          await _db.into(_db.investments).insertOnConflictUpdate(inv);
        } else {
          final account = db.Account(
            id: id,
            name: name,
            type: type,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: map['syncStatus'] ?? 'pending',
          );
          await _db.into(_db.accounts).insertOnConflictUpdate(account);
        }
      }
    });
    await _cacheService.rebuildCache();
  }

  Future<void> importLiabilitiesFromCsv(String csv) async {
    final parsed = _parseCsv(csv);
    if (parsed.length <= 1) return;

    final headers = parsed.first;
    await _db.transaction(() async {
      for (int i = 1; i < parsed.length; i++) {
        final row = parsed[i];
        if (row.length < headers.length) continue;

        final map = Map<String, String>.fromIterables(headers, row);
        final String id = map['id']!;
        final String name = map['name']!;
        final String type = map['type']!;
        final String? notes = map['notes']?.isEmpty ?? true ? null : map['notes'];
        final int isArchived = int.parse(map['isArchived']!);
        final DateTime createdAt = DateTime.parse(map['createdAt']!);
        final DateTime updatedAt = DateTime.parse(map['updatedAt']!);

        if (type == 'personal_debt') {
          final person = db.Person(
            id: id,
            name: name,
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: map['syncStatus'] ?? 'pending',
          );
          await _db.into(_db.people).insertOnConflictUpdate(person);
        } else {
          final account = db.Account(
            id: id,
            name: name,
            type: 'credit',
            notes: notes,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: map['syncStatus'] ?? 'pending',
          );
          await _db.into(_db.accounts).insertOnConflictUpdate(account);
        }
      }
    });
    await _cacheService.rebuildCache();
  }

  Future<void> importInvestmentsFromCsv(String csv) async {
    final parsed = _parseCsv(csv);
    if (parsed.length <= 1) return;

    final headers = parsed.first;
    await _db.transaction(() async {
      for (int i = 1; i < parsed.length; i++) {
        final row = parsed[i];
        if (row.length < headers.length) continue;

        final map = Map<String, String>.fromIterables(headers, row);
        final inv = db.Investment(
          id: map['id']!,
          name: map['name']!,
          type: map['type']!,
          symbol: map['symbol']?.isEmpty ?? true ? null : map['symbol'],
          marketValue: map['marketValue']?.isEmpty ?? true ? null : double.tryParse(map['marketValue']!),
          isArchived: int.parse(map['isArchived']!),
          notes: map['notes']?.isEmpty ?? true ? null : map['notes'],
          createdAt: DateTime.parse(map['createdAt']!),
          updatedAt: DateTime.parse(map['updatedAt']!),
          syncStatus: map['syncStatus'] ?? 'pending',
        );

        await _db.into(_db.investments).insertOnConflictUpdate(inv);
      }
    });
    await _cacheService.rebuildCache();
  }

  Future<void> importReceivablesFromCsv(String csv) async {
    final parsed = _parseCsv(csv);
    if (parsed.length <= 1) return;

    final headers = parsed.first;
    await _db.transaction(() async {
      for (int i = 1; i < parsed.length; i++) {
        final row = parsed[i];
        if (row.length < headers.length) continue;

        final map = Map<String, String>.fromIterables(headers, row);
        final person = db.Person(
          id: map['id']!,
          name: map['personName']!,
          notes: map['notes']?.isEmpty ?? true ? null : map['notes'],
          isArchived: int.parse(map['isArchived']!),
          createdAt: DateTime.parse(map['createdAt']!),
          updatedAt: DateTime.parse(map['updatedAt']!),
          syncStatus: map['syncStatus'] ?? 'pending',
        );

        await _db.into(_db.people).insertOnConflictUpdate(person);
      }
    });
    await _cacheService.rebuildCache();
  }

  Future<void> importGoalsFromCsv(String csv) async {
    final parsed = _parseCsv(csv);
    if (parsed.length <= 1) return;

    final headers = parsed.first;
    await _db.transaction(() async {
      for (int i = 1; i < parsed.length; i++) {
        final row = parsed[i];
        if (row.length < headers.length) continue;

        final map = Map<String, String>.fromIterables(headers, row);
        final goal = db.Goal(
          id: map['id']!,
          name: map['name']!,
          targetAmount: double.parse(map['targetAmount']!),
          currentAmount: double.parse(map['currentAmount']!),
          deadline: map['deadline']?.isEmpty ?? true ? null : DateTime.parse(map['deadline']!),
          notes: map['notes']?.isEmpty ?? true ? null : map['notes'],
          isArchived: int.parse(map['isArchived']!),
          createdAt: DateTime.parse(map['createdAt']!),
          updatedAt: DateTime.parse(map['updatedAt']!),
          syncStatus: map['syncStatus'] ?? 'pending',
        );

        await _db.into(_db.goals).insertOnConflictUpdate(goal);
      }
    });
  }
}
