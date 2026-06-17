import 'package:drift/drift.dart';

class Adjustments extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // account | person_receivable | person_liability | investment_capital | investment_market_value | expected_income
  TextColumn get entityId => text()();
  RealColumn get oldAmount => real()();
  RealColumn get newAmount => real()();
  RealColumn get adjustedAmount => real()();
  TextColumn get reason => text()(); // Correction | Bank Reconciliation | Manual Fix | Migration | Other
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
