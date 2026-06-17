import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/receivable.dart' as domain;
import '../../domain/repositories/receivable_repository.dart';

class ReceivableRepositoryImpl implements ReceivableRepository {
  final db.AppDatabase _database;

  ReceivableRepositoryImpl(this._database);

  domain.Receivable _toDomain(db.Person p) {
    return domain.Receivable(
      id: p.id,
      personName: p.name,
      amount: 0.0, // Cache balance resolved in service layer or derived in UI
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
  }

  @override
  Future<void> updateReceivable(domain.Receivable receivable) async {
    await _database.update(_database.people).replace(db.Person(
          id: receivable.id,
          name: receivable.personName,
          notes: receivable.notes,
          isArchived: receivable.isArchived,
          createdAt: receivable.createdAt,
          updatedAt: receivable.updatedAt,
          syncStatus: receivable.syncStatus,
        ));
  }

  @override
  Future<void> deleteReceivable(String id) async {
    final rec = await getReceivableById(id);
    if (rec != null) {
      await updateReceivable(rec.copyWith(
        isArchived: 1,
        updatedAt: DateTime.now().toUtc(),
      ));
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
