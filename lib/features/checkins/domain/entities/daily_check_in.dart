class DailyCheckIn {
  final String id;
  final DateTime date;
  final int transactionCount;
  final DateTime? lastTransactionTime;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyCheckIn({
    required this.id,
    required this.date,
    required this.transactionCount,
    this.lastTransactionTime,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  DailyCheckIn copyWith({
    String? id,
    DateTime? date,
    int? transactionCount,
    DateTime? lastTransactionTime,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyCheckIn(
      id: id ?? this.id,
      date: date ?? this.date,
      transactionCount: transactionCount ?? this.transactionCount,
      lastTransactionTime: lastTransactionTime ?? this.lastTransactionTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
