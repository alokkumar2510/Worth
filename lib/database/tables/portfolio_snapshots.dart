import 'package:drift/drift.dart';

class PortfolioSnapshots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get snapshotDate => dateTime()();
  TextColumn get snapshotType => text()(); // 'daily', 'weekly', 'monthly'
  RealColumn get netWorth => real()();
  RealColumn get assets => real()();
  RealColumn get liabilities => real()();
  RealColumn get investments => real()();
  RealColumn get receivables => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
