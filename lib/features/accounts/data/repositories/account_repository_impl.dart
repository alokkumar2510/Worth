import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/account.dart' as domain;
import '../../domain/repositories/account_repository.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class AccountRepositoryImpl implements AccountRepository {
  final db.AppDatabase _database;
  final Ref _ref;

  AccountRepositoryImpl(this._database, this._ref);

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
      ownershipType: entity.ownershipType,
      liabilityType: entity.liabilityType,
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
      ownershipType: Value(account.ownershipType),
      liabilityType: Value(account.liabilityType),
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
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'account',
      entityId: account.id,
      operation: 'upsert',
    );
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
      ownershipType: account.ownershipType,
      liabilityType: account.liabilityType,
    );
    await _database.update(_database.accounts).replace(dbAccount);
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'account',
      entityId: account.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> deleteAccount(String id) async {
    final account = await getAccountById(id);
    if (account != null) {
      final updated = account.copyWith(
        isArchived: 1,
        updatedAt: DateTime.now().toUtc(),
      );
      await updateAccount(updated);
      await _ref.read(syncServiceProvider).queueOperation(
        entityType: 'account',
        entityId: id,
        operation: 'delete',
      );
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
