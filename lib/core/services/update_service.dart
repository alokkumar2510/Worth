import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_version.dart';
import '../providers/app_providers.dart';
import '../providers/mock_database.dart';
import '../../database/database.dart';

enum UpdateStatus {
  noUpdate,
  checking,
  optionalAvailable,
  forceRequired,
  error,
}

class UpdateInfo {
  final String version;
  final int build;
  final String releaseDate;
  final bool forceUpdate;
  final String downloadUrl;
  final List<String> releaseNotes;

  UpdateInfo({
    required this.version,
    required this.build,
    required this.releaseDate,
    required this.forceUpdate,
    required this.downloadUrl,
    required this.releaseNotes,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] as String? ?? '',
      build: json['build'] as int? ?? 0,
      releaseDate: json['release_date'] as String? ?? '',
      forceUpdate: json['force_update'] as bool? ?? false,
      downloadUrl: json['download_url'] as String? ?? 'https://worth.alokkumarsahu.in/download',
      releaseNotes: List<String>.from(json['release_notes'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'build': build,
    'release_date': releaseDate,
    'force_update': forceUpdate,
    'download_url': downloadUrl,
    'release_notes': releaseNotes,
  };
}

class UpdateState {
  final UpdateStatus status;
  final UpdateInfo? updateInfo;
  final String? errorMessage;
  final bool hasPendingSync;
  final DateTime? lastChecked;

  UpdateState({
    this.status = UpdateStatus.noUpdate,
    this.updateInfo,
    this.errorMessage,
    this.hasPendingSync = false,
    this.lastChecked,
  });

  UpdateState copyWith({
    UpdateStatus? status,
    UpdateInfo? updateInfo,
    String? errorMessage,
    bool? hasPendingSync,
    DateTime? lastChecked,
  }) {
    return UpdateState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      errorMessage: errorMessage ?? this.errorMessage,
      hasPendingSync: hasPendingSync ?? this.hasPendingSync,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class UpdateService extends StateNotifier<UpdateState> {
  final Ref _ref;
  Timer? _checkTimer;
  static const String _versionUrl = 'https://worth.alokkumarsahu.in/version.json';

  UpdateService(this._ref) : super(UpdateState()) {
    _startPeriodicChecks();
  }

  /// Test-only constructor: skips starting the periodic timer.
  UpdateService.test(this._ref) : super(UpdateState());

  void _startPeriodicChecks() {
    _checkTimer?.cancel();
    // Periodic check every 12 hours
    _checkTimer = Timer.periodic(const Duration(hours: 12), (timer) {
      checkForUpdates(isManual: false);
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  /// Compares two semantic version strings.
  /// Returns 1 if v1 > v2, -1 if v1 < v2, and 0 if they are equal.
  int compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map(int.tryParse).map((e) => e ?? 0).toList();
    final parts2 = v2.split('.').map(int.tryParse).map((e) => e ?? 0).toList();

    for (var i = 0; i < 3; i++) {
      final val1 = parts1.length > i ? parts1[i] : 0;
      final val2 = parts2.length > i ? parts2[i] : 0;
      if (val1 > val2) return 1;
      if (val1 < val2) return -1;
    }
    return 0;
  }

  /// Helper to fetch key-value from Settings table.
  Future<String?> _getSetting(String key) async {
    try {
      final db = _ref.read(realDatabaseProvider);
      final row = await (db.select(db.settings)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
      return row?.value;
    } catch (_) {
      return null;
    }
  }

  /// Helper to write key-value to Settings table.
  Future<void> _saveSetting(String key, String value) async {
    try {
      final db = _ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(
          key: key,
          value: value,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (_) {}
  }

  /// Checks if there are pending operations in the sync queue.
  Future<bool> checkPendingSync() async {
    try {
      final db = _ref.read(realDatabaseProvider);
      final pendingItems = await (db.select(db.syncQueues)
            ..where((tbl) => tbl.status.equals('pending') | tbl.status.equals('retrying') | tbl.status.equals('failed')))
          .get();
      return pendingItems.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Check for updates from the remote version JSON.
  Future<UpdateState> checkForUpdates({required bool isManual}) async {
    state = state.copyWith(status: UpdateStatus.checking);

    final hasPending = await checkPendingSync();

    try {
      final response = await http.get(Uri.parse(_versionUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception('Failed to load version info (HTTP ${response.statusCode})');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final info = UpdateInfo.fromJson(json);

      final currentVer = AppVersion.version;
      final currentBld = AppVersion.build;

      final verComparison = compareVersions(info.version, currentVer);
      final isNewerVersion = verComparison > 0;
      final isNewerBuild = verComparison == 0 && info.build > currentBld;

      await _saveSetting('last_update_check_time', DateTime.now().toIso8601String());

      if (isNewerVersion || isNewerBuild) {
        // Update is available!
        if (info.forceUpdate) {
          state = state.copyWith(
            status: UpdateStatus.forceRequired,
            updateInfo: info,
            hasPendingSync: hasPending,
            lastChecked: DateTime.now(),
          );
          return state;
        }

        // It is an optional update.
        // Check 7-day rule for auto checks.
        if (!isManual) {
          final dismissedVer = await _getSetting('dismissed_update_version');
          final dismissedTimeStr = await _getSetting('dismissed_update_time');

          if (dismissedVer == info.version && dismissedTimeStr != null) {
            final dismissedTime = DateTime.tryParse(dismissedTimeStr);
            if (dismissedTime != null) {
              final difference = DateTime.now().difference(dismissedTime).inDays;
              if (difference < 7) {
                // Ignore prompt, return noUpdate state for dashboard overlay purposes
                state = state.copyWith(
                  status: UpdateStatus.noUpdate,
                  updateInfo: info,
                  hasPendingSync: hasPending,
                  lastChecked: DateTime.now(),
                );
                return state;
              }
            }
          }
        }

        // Notify user via local notification once per release.
        final notifiedVer = await _getSetting('notified_update_version');
        if (notifiedVer != info.version) {
          await _saveSetting('notified_update_version', info.version);
          await _ref.read(realNotificationServiceProvider).showNotification(
            title: '🚀 Worth ${info.version} is available',
            body: info.releaseNotes.isNotEmpty 
                ? 'What\'s New: ${info.releaseNotes.first}' 
                : 'Tap to see the latest premium financial features.',
            type: 'general',
          );
        }

        state = state.copyWith(
          status: UpdateStatus.optionalAvailable,
          updateInfo: info,
          hasPendingSync: hasPending,
          lastChecked: DateTime.now(),
        );
      } else {
        // No update available
        state = state.copyWith(
          status: UpdateStatus.noUpdate,
          updateInfo: null,
          hasPendingSync: hasPending,
          lastChecked: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('[UpdateService] Update check failed: $e');
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString(),
        hasPendingSync: hasPending,
        lastChecked: DateTime.now(),
      );
    }
    return state;
  }

  /// Saves version dismissal for 7 days.
  Future<void> dismissUpdate(String version) async {
    await _saveSetting('dismissed_update_version', version);
    await _saveSetting('dismissed_update_time', DateTime.now().toIso8601String());
    // Reset status to noUpdate so sheets/banners vanish
    state = state.copyWith(status: UpdateStatus.noUpdate);
  }

  /// Launch update URL.
  Future<void> launchDownloadUrl() async {
    final url = state.updateInfo?.downloadUrl ?? 'https://worth.alokkumarsahu.in/download';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('[UpdateService] Could not launch download URL: $url');
    }
  }
}

final updateServiceProvider = StateNotifierProvider<UpdateService, UpdateState>((ref) {
  return UpdateService(ref);
});
