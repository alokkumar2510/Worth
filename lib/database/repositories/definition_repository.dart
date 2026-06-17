import 'package:drift/drift.dart';
import '../database.dart';

class DefinitionRepository {
  final AppDatabase _db;
  DefinitionRepository(this._db);

  Stream<List<Definition>> watchActiveDefinitions() {
    return (_db.select(_db.definitions)..where((tbl) => tbl.isArchived.equals(0))).watch();
  }

  Future<List<Definition>> getActiveDefinitions() {
    return (_db.select(_db.definitions)..where((tbl) => tbl.isArchived.equals(0))).get();
  }

  Future<Definition?> getDefinitionById(String id) {
    return (_db.select(_db.definitions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertDefinition(DefinitionsCompanion companion) {
    return _db.into(_db.definitions).insert(companion);
  }

  Future<void> updateDefinition(Definition definition) {
    return _db.update(_db.definitions).replace(definition);
  }
}
