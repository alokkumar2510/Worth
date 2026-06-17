import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' hide DailyCheckIn;
import '../../../../core/providers/mock_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/dependency_provider.dart';
import '../../domain/services/reminder_engine.dart';
import '../../domain/services/streak_engine.dart';

class CheckInActivityState {
  final int transactionsTodayCount;
  final DateTime? lastTransactionTime;
  final bool isCompleted;
  final String statusLabel;
  final String completionStatus; // 'No Activity' | 'Partially Updated' | 'Completed'

  CheckInActivityState({
    required this.transactionsTodayCount,
    this.lastTransactionTime,
    required this.isCompleted,
    required this.statusLabel,
    required this.completionStatus,
  });
}

final checkInStreakEngineProvider = Provider<StreakEngine>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    return StreakEngine(null, ref);
  } else {
    final database = ref.watch(realDatabaseProvider);
    return StreakEngine(database, ref);
  }
});

final checkInReminderEngineProvider = Provider<ReminderEngine>((ref) {
  final database = ref.watch(realDatabaseProvider);
  final notificationService = ref.watch(realNotificationServiceProvider);
  return ReminderEngine(database, notificationService);
});

final checkInStreakInfoProvider = FutureProvider<StreakInfo>((ref) async {
  final engine = ref.watch(checkInStreakEngineProvider);
  // Re-run whenever transactions list changes
  ref.watch(allTransactionsProvider);
  return engine.getStreakInfo();
});

final checkInActivityProvider = StateNotifierProvider<CheckInActivityNotifier, CheckInActivityState>((ref) {
  return CheckInActivityNotifier(ref);
});

class CheckInActivityNotifier extends StateNotifier<CheckInActivityState> {
  final Ref _ref;

  CheckInActivityNotifier(this._ref) : super(
    CheckInActivityState(
      transactionsTodayCount: 0,
      isCompleted: false,
      statusLabel: 'No Transactions Recorded Today',
      completionStatus: 'No Activity',
    )
  ) {
    _ref.listen(allTransactionsProvider, (_, __) => _eval());
    _ref.listen(mockDatabaseProvider, (_, __) => _eval());
    _eval();
  }

  void _eval() {
    final txsAsync = _ref.read(allTransactionsProvider);
    final dbState = _ref.read(mockDatabaseProvider);

    txsAsync.when(
      data: (transactions) {
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = todayStart.add(const Duration(days: 1));

        final todayTxs = transactions.where((t) {
          final localDate = t.transactionDate.toLocal();
          return localDate.isAfter(todayStart) && localDate.isBefore(todayEnd);
        }).toList();

        final count = todayTxs.length;
        DateTime? lastTxTime;
        if (todayTxs.isNotEmpty) {
          todayTxs.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
          lastTxTime = todayTxs.first.transactionDate.toLocal();
        } else {
          // If no transactions today, look for last transaction ever
          if (transactions.isNotEmpty) {
            final sorted = List.of(transactions)..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
            lastTxTime = sorted.first.transactionDate.toLocal();
          }
        }

        final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final isCompleted = dbState.checkInCompletedDate == todayStr;

        String statusLabel = 'No Transactions Recorded Today';
        String completionStatus = 'No Activity';

        if (isCompleted) {
          completionStatus = 'Completed';
          statusLabel = 'Daily Check-in Completed';
        } else if (count == 0) {
          completionStatus = 'No Activity';
          statusLabel = 'No Transactions Recorded Today';
        } else {
          completionStatus = 'Partially Updated';
          if (lastTxTime != null && now.difference(lastTxTime).inHours < 24 && lastTxTime.day == now.day) {
            final diff = now.difference(lastTxTime);
            if (diff.inMinutes < 1) {
              statusLabel = 'Last Updated Just Now';
            } else if (diff.inMinutes < 60) {
              statusLabel = 'Last Updated ${diff.inMinutes} Minutes Ago';
            } else {
              statusLabel = 'Last Updated ${diff.inHours} Hours Ago';
            }
          } else {
            statusLabel = '$count Transactions Recorded Today';
          }
        }

        state = CheckInActivityState(
          transactionsTodayCount: count,
          lastTransactionTime: lastTxTime,
          isCompleted: isCompleted,
          statusLabel: statusLabel,
          completionStatus: completionStatus,
        );
      },
      loading: () {},
      error: (_, __) {},
    );
  }

  Future<void> markCompleted() async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await _ref.read(mockDatabaseProvider.notifier).updateCheckInSettings(completedDate: dateStr);
    _eval();
  }
}
