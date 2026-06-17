import 'package:drift/drift.dart';
import '../database.dart';

class SipRepository {
  final AppDatabase _db;
  SipRepository(this._db);

  Stream<List<Sip>> watchAllSips() {
    return _db.select(_db.sips).watch();
  }

  Future<List<Sip>> getAllSips() {
    return _db.select(_db.sips).get();
  }

  Future<List<Sip>> getActiveSips() {
    return (_db.select(_db.sips)..where((tbl) => tbl.isActive.equals(1))).get();
  }

  Future<Sip?> getSipById(String id) {
    return (_db.select(_db.sips)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertSip(SipsCompanion companion) {
    return _db.into(_db.sips).insert(companion);
  }

  Future<void> updateSip(Sip sip) {
    return _db.update(_db.sips).replace(sip);
  }

  Future<void> deleteSip(String id) {
    return (_db.delete(_db.sips)..where((tbl) => tbl.id.equals(id))).go();
  }
}
