import 'package:drift/drift.dart';

class InvestmentLotConsumptions extends Table {
  TextColumn get id => text()();
  TextColumn get sellTransactionId => text().customConstraint('NOT NULL REFERENCES transactions(id)')();
  TextColumn get lotId => text().customConstraint('NOT NULL REFERENCES investment_lots(id)')();
  RealColumn get unitsConsumed => real()();
  RealColumn get costBasis => real()(); // unitsConsumed * lot.costPerUnit
  RealColumn get proceedsAllocated => real()(); // portion of sale proceeds allocated to this lot
  RealColumn get realizedGainLoss => real()(); // proceedsAllocated - costBasis
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
