import 'package:drift/drift.dart';

class Definitions extends Table {
  TextColumn get id => text()();
  TextColumn get term => text()();
  TextColumn get definition => text()();
  TextColumn get formula => text()();
  TextColumn get example => text()();
  TextColumn get includedItems => text()(); // Semicolon-separated or JSON list
  TextColumn get excludedItems => text()();
  IntColumn get isArchived => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
