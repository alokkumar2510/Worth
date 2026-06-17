import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' as db;
import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/achievement_progress.dart';

final milestonesProvider = StreamProvider<List<Milestone>>((ref) {
  final appDb = ref.watch(realDatabaseProvider);
  return appDb.select(appDb.milestones).watch().map((rows) {
    return rows.map((row) {
      return Milestone(
        id: row.id,
        amount: row.amount,
        dateAchieved: row.dateAchieved,
        daysSincePrevious: row.daysSincePrevious,
        netWorthAtAchievement: row.netWorthAtAchievement,
        isManual: row.isManual,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    }).toList();
  });
});

final achievementsProvider = StreamProvider<List<Achievement>>((ref) {
  final appDb = ref.watch(realDatabaseProvider);
  return appDb.select(appDb.achievements).watch().map((rows) {
    return rows.map((row) {
      return Achievement(
        id: row.id,
        title: row.title,
        description: row.description,
        dateUnlocked: row.dateUnlocked,
        category: row.category,
        unlockedStatus: row.unlockedStatus,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
    }).toList();
  });
});

final achievementProgressProvider = StreamProvider<List<AchievementProgressModel>>((ref) {
  final appDb = ref.watch(realDatabaseProvider);
  return appDb.select(appDb.achievementProgress).watch().map((rows) {
    return rows.map((row) {
      return AchievementProgressModel(
        id: row.id,
        achievementId: row.achievementId,
        currentValue: row.currentValue,
        targetValue: row.targetValue,
        updatedAt: row.updatedAt,
      );
    }).toList();
  });
});
