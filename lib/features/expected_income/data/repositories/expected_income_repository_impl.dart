import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/expected_income.dart' as domain;
import '../../domain/repositories/expected_income_repository.dart';

class ExpectedIncomeRepositoryImpl implements ExpectedIncomeRepository {
  final db.AppDatabase _database;

  ExpectedIncomeRepositoryImpl(this._database);

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
  }

  @override
  Future<void> markAsReceived(String id, String toAccountId) async {
    await _database.transaction(() async {
      final query = _database.update(_database.expectedIncomes)..where((tbl) => tbl.id.equals(id));
      await query.write(db.ExpectedIncomesCompanion(
        status: const Value('received'),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
    });
  }

  @override
  Future<void> markAsExpired(String id) async {
    final query = _database.update(_database.expectedIncomes)..where((tbl) => tbl.id.equals(id));
    await query.write(db.ExpectedIncomesCompanion(
      status: const Value('expired'),
      updatedAt: Value(DateTime.now().toUtc()),
    ));
  }
}
