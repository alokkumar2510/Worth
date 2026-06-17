import 'package:drift/drift.dart';

class InvestmentLots extends Table {
  TextColumn get id => text()();
  TextColumn get investmentId => text().customConstraint('NOT NULL REFERENCES investments(id)')();
  TextColumn get buyTransactionId => text().customConstraint('NOT NULL REFERENCES transactions(id)')();
  RealColumn get unitsPurchased => real()();
  RealColumn get unitsRemaining => real()(); // decremented as units are sold via FIFO
  RealColumn get costPerUnit => real()();
  DateTimeColumn get purchaseDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
