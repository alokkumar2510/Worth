import 'package:drift/drift.dart';

class Milestones extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  DateTimeColumn get dateAchieved => dateTime().nullable()();
  IntColumn get daysSincePrevious => integer().nullable()();
  RealColumn get netWorthAtAchievement => real().nullable()();
  IntColumn get isManual => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
