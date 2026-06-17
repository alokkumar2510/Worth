import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/account.dart' as domain;
import '../../domain/repositories/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final db.AppDatabase _database;

  AccountRepositoryImpl(this._database);

  domain.Account _toDomain(db.Account entity) {
    return domain.Account(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      notes: entity.notes,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  db.AccountsCompanion _toCompanion(domain.Account account) {
    return db.AccountsCompanion(
      id: Value(account.id),
      name: Value(account.name),
      type: Value(account.type),
      notes: Value(account.notes),
      isArchived: Value(account.isArchived),
      createdAt: Value(account.createdAt),
      updatedAt: Value(account.updatedAt),
      syncStatus: Value(account.syncStatus),
    );
  }

  @override
  Stream<List<domain.Account>> watchAllAccounts() {
    return _database.select(_database.accounts)
        .watch()
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<domain.Account>> getAllAccounts() async {
    final list = await _database.select(_database.accounts).get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<domain.Account?> getAccountById(String id) async {
    final query = _database.select(_database.accounts)..where((tbl) => tbl.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> createAccount(domain.Account account) async {
    await _database.into(_database.accounts).insert(_toCompanion(account));
  }

  @override
  Future<void> updateAccount(domain.Account account) async {
    final dbAccount = db.Account(
      id: account.id,
      name: account.name,
      type: account.type,
      notes: account.notes,
      isArchived: account.isArchived,
      createdAt: account.createdAt,
      updatedAt: account.updatedAt,
      syncStatus: account.syncStatus,
    );
    await _database.update(_database.accounts).replace(dbAccount);
  }

  @override
  Future<void> deleteAccount(String id) async {
    // Clean Architecture Soft Delete Requirement
    final account = await getAccountById(id);
    if (account != null) {
      await updateAccount(account.copyWith(
        isArchived: 1,
        updatedAt: DateTime.now().toUtc(),
      ));
    }
  }

  @override
  Future<List<domain.Account>> searchAccounts(String query) async {
    final searchPattern = '%$query%';
    final search = _database.select(_database.accounts)
      ..where((tbl) => tbl.name.like(searchPattern) | tbl.notes.like(searchPattern));
    final list = await search.get();
    return list.map(_toDomain).toList();
  }
}
