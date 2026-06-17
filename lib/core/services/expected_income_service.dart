import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../providers/dependency_provider.dart';
import '../providers/mock_database.dart';
import '../providers/app_providers.dart';

class ExpectedIncomeService {
  final Ref _ref;
  final _uuid = const Uuid();

  ExpectedIncomeService(this._ref);

  AppDatabase get _db => _ref.read(realDatabaseProvider);
  bool get _isMock => _ref.read(mockModeProvider);

  Future<String> addExpectedIncome({
    required String source,
    required double amount,
    DateTime? expectedDate,
    String? notes,
  }) async {
    final id = _uuid.v4();
    if (_isMock) {
      _ref.read(mockDatabaseProvider.notifier).addExpectedIncome(
        source,
        amount,
        expectedDate,
        notes,
      );
    } else {
      await _db.into(_db.expectedIncomes).insert(ExpectedIncomesCompanion.insert(
        id: id,
        source: source,
        amount: amount,
        status: 'pending',
        expectedDate: Value(expectedDate),
        notes: Value(notes),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ));
      _ref.read(syncServiceProvider).queueOperation(
        entityType: 'expected_income',
        entityId: id,
        operation: 'upsert',
      );
    }
    return id;
  }

  Future<void> markReceived(String incomeId, String destinationAccountId) async {
    if (_isMock) {
      _ref.read(mockDatabaseProvider.notifier).markExpectedIncomeReceived(
        incomeId,
        destinationAccountId,
      );
    } else {
      final inc = await (_db.select(_db.expectedIncomes)..where((tbl) => tbl.id.equals(incomeId))).getSingleOrNull();
      if (inc == null) return;

      double amount = inc.amount;
      final adjs = await (_db.select(_db.adjustments)
            ..where((tbl) => tbl.entityId.equals(incomeId) & tbl.entityType.equals('expected_income')))
          .get();
      for (final adj in adjs) {
        amount += adj.adjustedAmount;
      }

      final txId = _uuid.v4();
      final companion = TransactionsCompanion.insert(
        id: txId,
        type: 'expected_income_received',
        amount: amount,
        toAccountId: Value(destinationAccountId),
        notes: Value('Received expected income: ${inc.source}'),
        transactionDate: DateTime.now(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
      _ref.read(syncServiceProvider).queueOperation(
        entityType: 'transaction',
        entityId: txId,
        operation: 'upsert',
      );

      final query = _db.update(_db.expectedIncomes)..where((tbl) => tbl.id.equals(incomeId));
      await query.write(ExpectedIncomesCompanion(
        status: const Value('received'),
        receivedTransactionId: Value(txId),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
      _ref.read(syncServiceProvider).queueOperation(
        entityType: 'expected_income',
        entityId: incomeId,
        operation: 'upsert',
      );
    }
  }

  Future<void> markExpired(String incomeId) async {
    if (_isMock) {
      _ref.read(mockDatabaseProvider.notifier).markExpectedIncomeExpired(incomeId);
    } else {
      final query = _db.update(_db.expectedIncomes)..where((tbl) => tbl.id.equals(incomeId));
      await query.write(ExpectedIncomesCompanion(
        status: const Value('expired'),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
      _ref.read(syncServiceProvider).queueOperation(
        entityType: 'expected_income',
        entityId: incomeId,
        operation: 'upsert',
      );
    }
  }
}
