import 'package:drift/drift.dart';

class ExpectedIncomes extends Table {
  TextColumn get id => text()();
  TextColumn get source => text()();
  RealColumn get amount => real()();
  TextColumn get status => text()(); // pending | received | expired
  DateTimeColumn get expectedDate => dateTime().nullable()();
  TextColumn get receivedTransactionId => text().nullable().customConstraint('REFERENCES transactions(id)')();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
