import 'package:drift/drift.dart';
import '../database.dart';

class AccountRepository {
  final AppDatabase _db;
  AccountRepository(this._db);

  Stream<List<Account>> watchActiveAccounts() {
    return (_db.select(_db.accounts)..where((tbl) => tbl.isArchived.equals(0))).watch();
  }

  Stream<List<Account>> watchAllAccounts() {
    return _db.select(_db.accounts).watch();
  }

  Future<List<Account>> getActiveAccounts() {
    return (_db.select(_db.accounts)..where((tbl) => tbl.isArchived.equals(0))).get();
  }

  Future<Account?> getAccountById(String id) {
    return (_db.select(_db.accounts)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertAccount(AccountsCompanion companion) {
    return _db.into(_db.accounts).insert(companion);
  }

  Future<void> updateAccount(Account account) {
    return _db.update(_db.accounts).replace(account);
  }
}
