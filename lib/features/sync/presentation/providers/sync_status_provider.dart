import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../../database/database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/dependency_provider.dart';
import '../../../../core/services/network_monitor.dart';

enum SyncStatusType { synced, syncing, pending, offline, error }

class SyncStatusState {
  final SyncStatusType status;
  final int pendingCount;
  final int failedCount;
  final DateTime? lastSyncedAt;
  final bool isConnected;

  const SyncStatusState({
    this.status = SyncStatusType.synced,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastSyncedAt,
    this.isConnected = true,
  });

  String get statusText {
    switch (status) {
      case SyncStatusType.synced:
        return 'Synced';
      case SyncStatusType.syncing:
        return 'Syncing...';
      case SyncStatusType.pending:
        return 'Pending: $pendingCount changes';
      case SyncStatusType.offline:
        return 'Offline';
      case SyncStatusType.error:
        return 'Sync Error';
    }
  }

  String get lastSyncedText {
    if (lastSyncedAt == null) return 'Never synced';
    final diff = DateTime.now().toUtc().difference(lastSyncedAt!);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class SyncStatusNotifier extends StateNotifier<SyncStatusState> {
  final AppDatabase? _db;
  final NetworkMonitor? _networkMonitor;
  Timer? _pollTimer;
  StreamSubscription? _connectivitySub;

  /// Real-mode constructor: polls SyncQueues and listens to connectivity
  SyncStatusNotifier(AppDatabase db, NetworkMonitor networkMonitor)
      : _db = db,
        _networkMonitor = networkMonitor,
        super(const SyncStatusState()) {
    _startPolling();
    _listenConnectivity();
  }

  /// Mock-mode constructor: always shows synced, no polling
  SyncStatusNotifier.mock()
      : _db = null,
        _networkMonitor = null,
        super(const SyncStatusState());

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
    _refresh();
  }

  void _listenConnectivity() {
    _connectivitySub = _networkMonitor?.isConnectedStream.listen((connected) {
      state = SyncStatusState(
        status: _computeStatus(state.pendingCount, state.failedCount, connected),
        pendingCount: state.pendingCount,
        failedCount: state.failedCount,
        lastSyncedAt: state.lastSyncedAt,
        isConnected: connected,
      );
    });
  }

  Future<void> _refresh() async {
    final db = _db;
    if (db == null) return;

    try {
      // Count pending/retrying/syncing items
      final pendingItems = await (db.select(db.syncQueues)
            ..where((tbl) => tbl.status.isIn(['pending', 'retrying', 'syncing'])))
          .get();
      final pendingCount = pendingItems.length;

      // Count permanently failed items
      final failedItems = await (db.select(db.syncQueues)
            ..where((tbl) => tbl.status.equals('failed')))
          .get();
      final failedCount = failedItems.length;

      // Get last successful sync timestamp
      final syncedItems = await (db.select(db.syncQueues)
            ..where((tbl) => tbl.status.equals('synced'))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])
            ..limit(1))
          .get();
      final lastSyncedAt = syncedItems.isNotEmpty ? syncedItems.first.updatedAt : state.lastSyncedAt;

      final connected = await _networkMonitor?.isConnected ?? true;

      state = SyncStatusState(
        status: _computeStatus(pendingCount, failedCount, connected),
        pendingCount: pendingCount,
        failedCount: failedCount,
        lastSyncedAt: lastSyncedAt,
        isConnected: connected,
      );
    } catch (e) {
      // Silently handle DB errors (e.g., db closed during disposal)
    }
  }

  SyncStatusType _computeStatus(int pendingCount, int failedCount, bool connected) {
    if (!connected) return SyncStatusType.offline;
    if (failedCount > 0) return SyncStatusType.error;
    if (pendingCount > 0) return SyncStatusType.pending;
    return SyncStatusType.synced;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatusState>((ref) {
  final isMock = ref.watch(mockModeProvider);
  if (isMock) {
    return SyncStatusNotifier.mock();
  }
  final db = ref.watch(realDatabaseProvider);
  final networkMonitor = ref.watch(networkMonitorProvider);
  return SyncStatusNotifier(db, networkMonitor);
});
