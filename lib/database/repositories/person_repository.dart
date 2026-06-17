import 'package:drift/drift.dart';
import '../database.dart';

class PersonRepository {
  final AppDatabase _db;
  PersonRepository(this._db);

  Stream<List<Person>> watchActivePeople() {
    return (_db.select(_db.people)..where((tbl) => tbl.isArchived.equals(0))).watch();
  }

  Stream<List<Person>> watchAllPeople() {
    return _db.select(_db.people).watch();
  }

  Future<List<Person>> getActivePeople() {
    return (_db.select(_db.people)..where((tbl) => tbl.isArchived.equals(0))).get();
  }

  Future<Person?> getPersonById(String id) {
    return (_db.select(_db.people)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertPerson(PeopleCompanion companion) {
    return _db.into(_db.people).insert(companion);
  }

  Future<void> updatePerson(Person person) {
    return _db.update(_db.people).replace(person);
  }
}
