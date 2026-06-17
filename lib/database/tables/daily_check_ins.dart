import 'package:drift/drift.dart';

class DailyCheckIns extends Table {
  TextColumn get id => text()(); // UUID
  DateTimeColumn get date => dateTime()(); // Midnight local date
  IntColumn get transactionCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastTransactionTime => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
