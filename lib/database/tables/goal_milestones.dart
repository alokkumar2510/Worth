import 'package:drift/drift.dart';

class GoalMilestones extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().customConstraint('NOT NULL REFERENCES goals(id) ON DELETE CASCADE')();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  DateTimeColumn get reachedAt => dateTime().nullable()();
  IntColumn get isArchived => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
