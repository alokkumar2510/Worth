import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/receivable.dart' as domain;
import '../../domain/repositories/receivable_repository.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class ReceivableRepositoryImpl implements ReceivableRepository {
  final db.AppDatabase _database;
  final Ref _ref;

  ReceivableRepositoryImpl(this._database, this._ref);

  domain.Receivable _toDomain(db.Person p) {
    return domain.Receivable(
      id: p.id,
      personName: p.name,
      amount: 0.0, // Cache balance resolved in service layer or derived in UI
      phone: p.phone,
      whatsApp: p.whatsApp,
      borrowDate: p.borrowDate,
      dueDate: p.dueDate,
      upiId: p.upiId,
      bankName: p.bankName,
      accountHolderName: p.accountHolderName,
      notes: p.notes,
      isArchived: p.isArchived,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
      syncStatus: p.syncStatus,
    );
  }

  db.PeopleCompanion _toCompanion(domain.Receivable rec) {
    return db.PeopleCompanion(
      id: Value(rec.id),
      name: Value(rec.personName),
      phone: Value(rec.phone),
      whatsApp: Value(rec.whatsApp),
      borrowDate: Value(rec.borrowDate),
      dueDate: Value(rec.dueDate),
      upiId: Value(rec.upiId),
      bankName: Value(rec.bankName),
      accountHolderName: Value(rec.accountHolderName),
      notes: Value(rec.notes),
      isArchived: Value(rec.isArchived),
      createdAt: Value(rec.createdAt),
      updatedAt: Value(rec.updatedAt),
      syncStatus: Value(rec.syncStatus),
    );
  }

  @override
  Stream<List<domain.Receivable>> watchAllReceivables() {
    return _database.select(_database.people)
        .watch()
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<domain.Receivable>> getAllReceivables() async {
    final list = await _database.select(_database.people).get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<domain.Receivable?> getReceivableById(String id) async {
    final query = _database.select(_database.people)..where((tbl) => tbl.id.equals(id));
    final p = await query.getSingleOrNull();
    return p != null ? _toDomain(p) : null;
  }

  @override
  Future<void> createReceivable(domain.Receivable receivable) async {
    await _database.into(_database.people).insert(_toCompanion(receivable));
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'person',
      entityId: receivable.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> updateReceivable(domain.Receivable receivable) async {
    final existing = await (_database.select(_database.people)..where((tbl) => tbl.id.equals(receivable.id))).getSingleOrNull();
    await _database.update(_database.people).replace(db.Person(
          id: receivable.id,
          name: receivable.personName,
          phone: receivable.phone,
          whatsApp: receivable.whatsApp,
          borrowDate: receivable.borrowDate,
          dueDate: receivable.dueDate,
          upiId: receivable.upiId,
          bankName: receivable.bankName,
          accountHolderName: receivable.accountHolderName,
          notes: receivable.notes,
          isArchived: receivable.isArchived,
          createdAt: receivable.createdAt,
          updatedAt: receivable.updatedAt,
          syncStatus: receivable.syncStatus,
          lastSyncedAt: existing?.lastSyncedAt,
          deviceId: existing?.deviceId,
          deletedAt: existing?.deletedAt,
          deletedBy: existing?.deletedBy,
          type: existing?.type ?? 'personal_loan',
        ));
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'person',
      entityId: receivable.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> deleteReceivable(String id) async {
    final rec = await getReceivableById(id);
    if (rec != null) {
      final updated = rec.copyWith(
        isArchived: 1,
        updatedAt: DateTime.now().toUtc(),
      );
      await updateReceivable(updated);
      await _ref.read(syncServiceProvider).queueOperation(
        entityType: 'person',
        entityId: id,
        operation: 'delete',
      );
    }
  }

  @override
  Future<List<domain.Receivable>> searchReceivables(String query) async {
    final searchPattern = '%$query%';
    final search = _database.select(_database.people)
      ..where((tbl) => tbl.name.like(searchPattern) | tbl.notes.like(searchPattern));
    final list = await search.get();
    return list.map(_toDomain).toList();
  }
}
