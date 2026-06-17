import 'package:drift/drift.dart';
import 'investments.dart';

class MtfPositions extends Table {
  TextColumn get id => text()();
  TextColumn get investmentId => text().customConstraint('NOT NULL REFERENCES investments(id)')();
  TextColumn get broker => text()();
  TextColumn get instrument => text()();
  RealColumn get units => real()();
  RealColumn get averagePrice => real()();
  RealColumn get ownCapital => real()();
  RealColumn get borrowedCapital => real()();
  RealColumn get interestRate => real()();
  DateTimeColumn get openingDate => dateTime()();
  DateTimeColumn get closedDate => dateTime().nullable()();
  IntColumn get isClosed => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastAccrualDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
