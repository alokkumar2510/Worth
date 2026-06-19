import 'package:drift/drift.dart';

class PortfolioHistories extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get action => text()(); // 'Added', 'Edited', 'Deleted', 'Voided', 'Recovered', etc.
  TextColumn get entityType => text()(); // 'Asset', 'Liability', 'Investment', 'MTF Position', 'Receivable', 'Expected Income', 'Goal', 'Transaction', 'SIP Event', 'IPO Activity', 'Settlement', etc.
  TextColumn get entityId => text()();
  TextColumn get entityTitle => text()(); 
  TextColumn get valueChanged => text()(); 
  TextColumn get previousValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get detailsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
