import '../entities/goal.dart';

abstract class GoalRepository {
  Stream<List<Goal>> watchAllGoals();
  Future<List<Goal>> getAllGoals();
  Future<Goal?> getGoalById(String id);
  Future<void> createGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<List<Goal>> searchGoals(String query);
}
