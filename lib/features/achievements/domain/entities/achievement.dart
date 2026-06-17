class Achievement {
  final String id;
  final String title;
  final String description;
  final DateTime? dateUnlocked;
  final String category;
  final int unlockedStatus; // 0 = locked, 1 = unlocked
  final DateTime createdAt;
  final DateTime updatedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.dateUnlocked,
    required this.category,
    required this.unlockedStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateUnlocked,
    String? category,
    int? unlockedStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateUnlocked: dateUnlocked ?? this.dateUnlocked,
      category: category ?? this.category,
      unlockedStatus: unlockedStatus ?? this.unlockedStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
