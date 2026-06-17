import 'package:drift/drift.dart';
import '../database.dart';

class GoalMilestoneRepository {
  final AppDatabase _db;
  GoalMilestoneRepository(this._db);

  Stream<List<GoalMilestone>> watchMilestonesForGoal(String goalId) {
    return (_db.select(_db.goalMilestones)
          ..where((tbl) => tbl.goalId.equals(goalId) & tbl.isArchived.equals(0))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.targetAmount, mode: OrderingMode.asc)]))
        .watch();
  }

  Future<List<GoalMilestone>> getMilestonesForGoal(String goalId) {
    return (_db.select(_db.goalMilestones)
          ..where((tbl) => tbl.goalId.equals(goalId) & tbl.isArchived.equals(0))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.targetAmount, mode: OrderingMode.asc)]))
        .get();
  }

  Future<GoalMilestone?> getMilestoneById(String id) {
    return (_db.select(_db.goalMilestones)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertMilestone(GoalMilestonesCompanion companion) {
    return _db.into(_db.goalMilestones).insert(companion);
  }

  Future<void> updateMilestone(GoalMilestone milestone) {
    return _db.update(_db.goalMilestones).replace(milestone);
  }
}
