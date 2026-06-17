import 'package:drift/drift.dart';
import '../database.dart';

class ExpectedIncomeRepository {
  final AppDatabase _db;
  ExpectedIncomeRepository(this._db);

  Stream<List<ExpectedIncome>> watchPendingIncomes() {
    return (_db.select(_db.expectedIncomes)..where((tbl) => tbl.status.equals('pending'))).watch();
  }

  Stream<List<ExpectedIncome>> watchAllIncomes() {
    return _db.select(_db.expectedIncomes).watch();
  }

  Future<List<ExpectedIncome>> getPendingIncomes() {
    return (_db.select(_db.expectedIncomes)..where((tbl) => tbl.status.equals('pending'))).get();
  }

  Future<ExpectedIncome?> getIncomeById(String id) {
    return (_db.select(_db.expectedIncomes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertExpectedIncome(ExpectedIncomesCompanion companion) {
    return _db.into(_db.expectedIncomes).insert(companion);
  }

  Future<void> updateExpectedIncome(ExpectedIncome income) {
    return _db.update(_db.expectedIncomes).replace(income);
  }
}
