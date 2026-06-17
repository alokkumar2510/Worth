import 'package:drift/drift.dart';
import '../database.dart';

class GoalRepository {
  final AppDatabase _db;
  GoalRepository(this._db);

  Stream<List<Goal>> watchActiveGoals() {
    return (_db.select(_db.goals)..where((tbl) => tbl.isArchived.equals(0))).watch();
  }

  Future<List<Goal>> getActiveGoals() {
    return (_db.select(_db.goals)..where((tbl) => tbl.isArchived.equals(0))).get();
  }

  Future<Goal?> getGoalById(String id) {
    return (_db.select(_db.goals)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertGoal(GoalsCompanion companion) {
    return _db.into(_db.goals).insert(companion);
  }

  Future<void> updateGoal(Goal goal) {
    return _db.update(_db.goals).replace(goal);
  }
}
