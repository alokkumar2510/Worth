class AchievementProgressModel {
  final String id;
  final String achievementId;
  final double currentValue;
  final double targetValue;
  final DateTime updatedAt;

  AchievementProgressModel({
    required this.id,
    required this.achievementId,
    required this.currentValue,
    required this.targetValue,
    required this.updatedAt,
  });

  AchievementProgressModel copyWith({
    String? id,
    String? achievementId,
    double? currentValue,
    double? targetValue,
    DateTime? updatedAt,
  }) {
    return AchievementProgressModel(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
