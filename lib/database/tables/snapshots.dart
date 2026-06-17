import 'package:drift/drift.dart';

class Snapshots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get snapshotDate => dateTime()();
  RealColumn get netWorth => real()();
  RealColumn get assets => real()();
  RealColumn get liabilities => real()();
  RealColumn get receivables => real().withDefault(const Constant(0.0))();
  RealColumn get investedCapital => real()();
  RealColumn get expectedIncome => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
