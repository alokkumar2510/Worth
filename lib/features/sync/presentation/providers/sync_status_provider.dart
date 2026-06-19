import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../database/database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/dependency_provider.dart';
import '../../../../core/services/network_monitor.dart';
import '../../../../features/auth/providers/auth_providers.dart';

enum SyncStatusType { synced, syncing, pending, offline, error }

class SyncStatusState {
  final SyncStatusType status;
  final int pendingCount;
  final int failedCount;
  final DateTime? lastSyncedAt;
  final bool isConnected;
  final int cloudRecords;

  const SyncStatusState({
    this.status = SyncStatusType.synced,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.lastSyncedAt,
    this.isConnected = true,
    this.cloudRecords = 0,
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
  final Ref? _ref;
  final AppDatabase? _db;
  final NetworkMonitor? _networkMonitor;
  Timer? _pollTimer;
  StreamSubscription? _connectivitySub;
  DateTime? _lastCloudCountFetch;

  /// Real-mode constructor: polls SyncQueues and listens to connectivity
  SyncStatusNotifier(Ref ref, AppDatabase db, NetworkMonitor networkMonitor)
      : _ref = ref,
        _db = db,
        _networkMonitor = networkMonitor,
        super(const SyncStatusState()) {
    _startPolling();
    _listenConnectivity();
  }

  /// Mock-mode constructor: always shows synced, no polling
  SyncStatusNotifier.mock()
      : _ref = null,
        _db = null,
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
        cloudRecords: state.cloudRecords,
      );
    });
  }

  Future<void> fetchCloudCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    final collections = [
      'accounts', 'liabilities', 'receivables', 'investments', 'investment_lots',
      'transactions', 'expected_income', 'goals', 'snapshots', 'adjustments',
      'mtf_positions', 'sips', 'settings'
    ];

    int totalCount = 0;
    for (final col in collections) {
      try {
        final countSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection(col)
            .count()
            .get();
        totalCount += countSnap.count ?? 0;
      } catch (_) {}
    }

    _lastCloudCountFetch = DateTime.now();

    state = SyncStatusState(
      status: state.status,
      pendingCount: state.pendingCount,
      failedCount: state.failedCount,
      lastSyncedAt: state.lastSyncedAt,
      isConnected: state.isConnected,
      cloudRecords: totalCount,
    );
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

      // Fetch cloud count periodically (every 2 minutes)
      if (connected &&
          (_lastCloudCountFetch == null ||
              DateTime.now().difference(_lastCloudCountFetch!) > const Duration(minutes: 2))) {
        // Fetch asynchronously so we don't block state refresh
        fetchCloudCount();
      }

      state = SyncStatusState(
        status: _computeStatus(pendingCount, failedCount, connected),
        pendingCount: pendingCount,
        failedCount: failedCount,
        lastSyncedAt: lastSyncedAt,
        isConnected: connected,
        cloudRecords: state.cloudRecords,
      );
    } catch (e) {
      // Silently handle DB errors
    }
  }

  SyncStatusType _computeStatus(int pendingCount, int failedCount, bool connected) {
    if (!connected) return SyncStatusType.offline;
    if (failedCount > 0) return SyncStatusType.error;
    if (pendingCount > 0) return SyncStatusType.pending;
    return SyncStatusType.synced;
  }

  Future<void> forceSync() async {
    if (_ref == null) return;
    state = SyncStatusState(
      status: SyncStatusType.syncing,
      pendingCount: state.pendingCount,
      failedCount: state.failedCount,
      lastSyncedAt: state.lastSyncedAt,
      isConnected: state.isConnected,
      cloudRecords: state.cloudRecords,
    );
    try {
      final syncService = _ref!.read(syncServiceProvider);
      await syncService.forceSync();
      await fetchCloudCount();
      await _refresh();
    } catch (e) {
      state = SyncStatusState(
        status: SyncStatusType.error,
        pendingCount: state.pendingCount,
        failedCount: state.failedCount,
        lastSyncedAt: state.lastSyncedAt,
        isConnected: state.isConnected,
        cloudRecords: state.cloudRecords,
      );
    }
  }

  Future<void> manualBackup() async {
    if (_ref == null) return;
    state = SyncStatusState(
      status: SyncStatusType.syncing,
      pendingCount: state.pendingCount,
      failedCount: state.failedCount,
      lastSyncedAt: state.lastSyncedAt,
      isConnected: state.isConnected,
      cloudRecords: state.cloudRecords,
    );
    try {
      final syncService = _ref!.read(syncServiceProvider);
      await syncService.forceBackupNow();
      await fetchCloudCount();
      await _refresh();
    } catch (e) {
      state = SyncStatusState(
        status: SyncStatusType.error,
        pendingCount: state.pendingCount,
        failedCount: state.failedCount,
        lastSyncedAt: state.lastSyncedAt,
        isConnected: state.isConnected,
        cloudRecords: state.cloudRecords,
      );
    }
  }

  Future<void> manualRestore() async {
    if (_ref == null) return;
    _ref!.read(isRestoringProvider.notifier).state = true;
    state = SyncStatusState(
      status: SyncStatusType.syncing,
      pendingCount: state.pendingCount,
      failedCount: state.failedCount,
      lastSyncedAt: state.lastSyncedAt,
      isConnected: state.isConnected,
      cloudRecords: state.cloudRecords,
    );
    try {
      final syncService = _ref!.read(syncServiceProvider);
      await syncService.manualRestore();
      await fetchCloudCount();
      await _refresh();
    } catch (e) {
      state = SyncStatusState(
        status: SyncStatusType.error,
        pendingCount: state.pendingCount,
        failedCount: state.failedCount,
        lastSyncedAt: state.lastSyncedAt,
        isConnected: state.isConnected,
        cloudRecords: state.cloudRecords,
      );
    } finally {
      _ref!.read(isRestoringProvider.notifier).state = false;
    }
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
  return SyncStatusNotifier(ref, db, networkMonitor);
});
