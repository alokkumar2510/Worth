import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/goal.dart' as domain;
import '../../domain/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  final db.AppDatabase _database;

  GoalRepositoryImpl(this._database);

  domain.Goal _toDomain(db.Goal entity) {
    return domain.Goal(
      id: entity.id,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      deadline: entity.deadline,
      notes: entity.notes,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  db.GoalsCompanion _toCompanion(domain.Goal entity) {
    return db.GoalsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      targetAmount: Value(entity.targetAmount),
      currentAmount: Value(entity.currentAmount),
      deadline: Value(entity.deadline),
      notes: Value(entity.notes),
      isArchived: Value(entity.isArchived),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncStatus: Value(entity.syncStatus),
    );
  }

  @override
  Stream<List<domain.Goal>> watchAllGoals() {
    return _database.select(_database.goals)
        .watch()
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<domain.Goal>> getAllGoals() async {
    final list = await _database.select(_database.goals).get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<domain.Goal?> getGoalById(String id) async {
    final query = _database.select(_database.goals)..where((tbl) => tbl.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> createGoal(domain.Goal goal) async {
    await _database.into(_database.goals).insert(_toCompanion(goal));
  }

  @override
  Future<void> updateGoal(domain.Goal goal) async {
    final dbGoal = db.Goal(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      deadline: goal.deadline,
      notes: goal.notes,
      isArchived: goal.isArchived,
      createdAt: goal.createdAt,
      updatedAt: goal.updatedAt,
      syncStatus: goal.syncStatus,
    );
    await _database.update(_database.goals).replace(dbGoal);
  }

  @override
  Future<void> deleteGoal(String id) async {
    final goal = await getGoalById(id);
    if (goal != null) {
      await updateGoal(goal.copyWith(
        isArchived: 1,
        updatedAt: DateTime.now().toUtc(),
      ));
    }
  }

  @override
  Future<List<domain.Goal>> searchGoals(String query) async {
    final searchPattern = '%$query%';
    final search = _database.select(_database.goals)
      ..where((tbl) => tbl.name.like(searchPattern) | tbl.notes.like(searchPattern));
    final list = await search.get();
    return list.map(_toDomain).toList();
  }
}
