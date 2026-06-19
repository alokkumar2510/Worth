import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/expected_income.dart' as domain;
import '../../domain/repositories/expected_income_repository.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class ExpectedIncomeRepositoryImpl implements ExpectedIncomeRepository {
  final db.AppDatabase _database;
  final Ref _ref;

  ExpectedIncomeRepositoryImpl(this._database, this._ref);

  domain.ExpectedIncome _toDomain(db.ExpectedIncome entity) {
    return domain.ExpectedIncome(
      id: entity.id,
      source: entity.source,
      amount: entity.amount,
      status: entity.status,
      expectedDate: entity.expectedDate,
      receivedTransactionId: entity.receivedTransactionId,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  db.ExpectedIncomesCompanion _toCompanion(domain.ExpectedIncome entity) {
    return db.ExpectedIncomesCompanion(
      id: Value(entity.id),
      source: Value(entity.source),
      amount: Value(entity.amount),
      status: Value(entity.status),
      expectedDate: Value(entity.expectedDate),
      receivedTransactionId: Value(entity.receivedTransactionId),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  @override
  Stream<List<domain.ExpectedIncome>> watchPendingIncome() {
    return (_database.select(_database.expectedIncomes)
          ..where((tbl) => tbl.status.equals('pending')))
        .watch()
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<domain.ExpectedIncome>> getPendingIncome() async {
    final list = await (_database.select(_database.expectedIncomes)
          ..where((tbl) => tbl.status.equals('pending')))
        .get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<void> saveExpectedIncome(domain.ExpectedIncome income) async {
    final companion = _toCompanion(income);
    await _database.into(_database.expectedIncomes).insertOnConflictUpdate(companion);
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'expected_income',
      entityId: income.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> markAsReceived(String id, String toAccountId) async {
    await _database.transaction(() async {
      final query = _database.update(_database.expectedIncomes)..where((tbl) => tbl.id.equals(id));
      final updatedAt = DateTime.now().toUtc();
      await query.write(db.ExpectedIncomesCompanion(
        status: const Value('received'),
        updatedAt: Value(updatedAt),
      ));
      await _ref.read(syncServiceProvider).queueOperation(
        entityType: 'expected_income',
        entityId: id,
        operation: 'upsert',
      );
    });
  }

  @override
  Future<void> markAsExpired(String id) async {
    final query = _database.update(_database.expectedIncomes)..where((tbl) => tbl.id.equals(id));
    final updatedAt = DateTime.now().toUtc();
    await query.write(db.ExpectedIncomesCompanion(
      status: const Value('expired'),
      updatedAt: Value(updatedAt),
    ));
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'expected_income',
      entityId: id,
      operation: 'upsert',
    );
  }
}
