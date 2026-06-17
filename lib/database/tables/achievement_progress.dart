import 'package:drift/drift.dart';

class AchievementProgress extends Table {
  TextColumn get id => text()();
  TextColumn get achievementId => text()();
  RealColumn get currentValue => real()();
  RealColumn get targetValue => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
