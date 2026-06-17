import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../database/database.dart';
import '../providers/dependency_provider.dart';
import '../providers/mock_database.dart';
import '../providers/app_providers.dart';

class GoalService {
  final Ref _ref;
  final _uuid = const Uuid();

  GoalService(this._ref);

  AppDatabase get _db => _ref.read(realDatabaseProvider);
  bool get _isMock => _ref.read(mockModeProvider);

  Future<String> createGoal({
    required String name,
    required double targetAmount,
    DateTime? targetDate,
    String? notes,
  }) async {
    if (_isMock) {
      final notifier = _ref.read(mockDatabaseProvider.notifier);
      final id = _uuid.v4();
      final newGoal = Goal(
        id: id,
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        deadline: targetDate,
        notes: notes,
        isArchived: 0,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: 'pending',
      );
      notifier.state = notifier.state.copyWith(
        goals: [...notifier.state.goals, newGoal],
      );
      return id;
    } else {
      final id = _uuid.v4();
      await _db.into(_db.goals).insert(GoalsCompanion.insert(
        id: id,
        name: name,
        targetAmount: targetAmount,
        currentAmount: const Value(0.0),
        deadline: Value(targetDate),
        notes: Value(notes),
        isArchived: const Value(0),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ));
      return id;
    }
  }

  Future<void> updateProgress(String goalId, double currentAmount) async {
    if (_isMock) {
      final notifier = _ref.read(mockDatabaseProvider.notifier);
      notifier.state = notifier.state.copyWith(
        goals: notifier.state.goals.map((g) => g.id == goalId ? g.copyWith(currentAmount: currentAmount, updatedAt: DateTime.now().toUtc()) : g).toList(),
      );
    } else {
      final query = _db.update(_db.goals)..where((tbl) => tbl.id.equals(goalId));
      await query.write(GoalsCompanion(
        currentAmount: Value(currentAmount),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
    }
  }

  Future<double> calculateCompletionPercentage(String goalId) async {
    if (_isMock) {
      final state = _ref.read(mockDatabaseProvider);
      try {
        final goal = state.goals.firstWhere((g) => g.id == goalId);
        if (goal.targetAmount == 0.0) return 0.0;
        return (goal.currentAmount / goal.targetAmount) * 100.0;
      } catch (_) {
        return 0.0;
      }
    } else {
      final goal = await (_db.select(_db.goals)..where((tbl) => tbl.id.equals(goalId))).getSingleOrNull();
      if (goal == null || goal.targetAmount == 0.0) return 0.0;
      return (goal.currentAmount / goal.targetAmount) * 100.0;
    }
  }

  Future<double> calculateRemainingAmount(String goalId) async {
    if (_isMock) {
      final state = _ref.read(mockDatabaseProvider);
      try {
        final goal = state.goals.firstWhere((g) => g.id == goalId);
        return goal.targetAmount - goal.currentAmount;
      } catch (_) {
        return 0.0;
      }
    } else {
      final goal = await (_db.select(_db.goals)..where((tbl) => tbl.id.equals(goalId))).getSingleOrNull();
      if (goal == null) return 0.0;
      return goal.targetAmount - goal.currentAmount;
    }
  }
}
