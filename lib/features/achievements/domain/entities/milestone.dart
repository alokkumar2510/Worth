class Milestone {
  final String id;
  final double amount;
  final DateTime? dateAchieved;
  final int? daysSincePrevious;
  final double? netWorthAtAchievement;
  final int isManual; // 0 = auto, 1 = manual
  final DateTime createdAt;
  final DateTime updatedAt;

  Milestone({
    required this.id,
    required this.amount,
    this.dateAchieved,
    this.daysSincePrevious,
    this.netWorthAtAchievement,
    required this.isManual,
    required this.createdAt,
    required this.updatedAt,
  });

  Milestone copyWith({
    String? id,
    double? amount,
    DateTime? dateAchieved,
    int? daysSincePrevious,
    double? netWorthAtAchievement,
    int? isManual,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      dateAchieved: dateAchieved ?? this.dateAchieved,
      daysSincePrevious: daysSincePrevious ?? this.daysSincePrevious,
      netWorthAtAchievement: netWorthAtAchievement ?? this.netWorthAtAchievement,
      isManual: isManual ?? this.isManual,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
