import 'package:drift/drift.dart';
import 'investments.dart';


class Sips extends Table {
  TextColumn get id => text()();
  TextColumn get investmentId => text().customConstraint('NOT NULL REFERENCES investments(id)')();
  RealColumn get amount => real()();
  TextColumn get frequency => text()(); // monthly | weekly | quarterly
  IntColumn get sipDate => integer()(); // day of month (1-31) or day of week (1-7)
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get autoCreate => integer().withDefault(const Constant(0))(); // 0 = No, 1 = Yes
  IntColumn get isActive => integer().withDefault(const Constant(1))(); // 0 = Inactive, 1 = Active
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get deviceId => text().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deletedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
