import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tactile_button.dart';
import '../../../sync/presentation/providers/sync_status_provider.dart';

class SyncCenterScreen extends ConsumerStatefulWidget {
  const SyncCenterScreen({super.key});

  @override
  ConsumerState<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends ConsumerState<SyncCenterScreen> {
  bool _isManualSyncing = false;

  Future<void> _handleForceSync() async {
    setState(() {
      _isManualSyncing = true;
    });

    try {
      await ref.read(syncStatusProvider.notifier).forceSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Force sync completed successfully.'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isManualSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final syncState = ref.watch(syncStatusProvider);

    final statusColor = _getStatusColor(syncState.status);
    final statusIcon = _getStatusIcon(syncState.status);

    final titleTextColor = isDark ? Colors.white : AppColors.lightText;
    final bodyTextColor = isDark ? AppColors.grey400 : AppColors.lightSecondaryText;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sync Center',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: titleTextColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Status Indicator Header Card
              GlassCard(
                isPrimary: true,
                child: Column(
                  children: [
                    Icon(
                      statusIcon,
                      size: 64,
                      color: statusColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      syncState.statusText,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: titleTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      syncState.isConnected ? 'Device Connected to Cloud' : 'Offline Mode (Local changes will queue)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: bodyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Metrics Card
              Text(
                'SYNC METRICS & DIAGNOSTICS',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.grey500 : AppColors.lightSecondaryText,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  children: [
                    _buildMetricRow(
                      context,
                      'Last Replicated Time',
                      syncState.lastSyncedText,
                      Icons.access_time_rounded,
                      isDark,
                    ),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildMetricRow(
                      context,
                      'Pending Queued Changes',
                      '${syncState.pendingCount} operations',
                      Icons.queue_play_next_rounded,
                      isDark,
                    ),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildMetricRow(
                      context,
                      'Permanently Failed Changes',
                      '${syncState.failedCount} failures',
                      Icons.error_outline_rounded,
                      isDark,
                    ),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildMetricRow(
                      context,
                      'Total Cloud Records',
                      '${syncState.cloudRecords} elements',
                      Icons.cloud_done_rounded,
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 3. Actions Row
              TactileButton(
                onTap: (syncState.status == SyncStatusType.syncing || _isManualSyncing)
                    ? null
                    : _handleForceSync,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.darkPrimary,
                        AppColors.darkPrimary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: (syncState.status == SyncStatusType.syncing || _isManualSyncing)
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Force Sync Now',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Force Sync processes all pending queue mutations and triggers a full pull of remote ledger entries.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppColors.grey500 : AppColors.lightSecondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(SyncStatusType status) {
    switch (status) {
      case SyncStatusType.synced:
        return AppColors.darkSuccess;
      case SyncStatusType.syncing:
        return AppColors.darkPrimary;
      case SyncStatusType.pending:
        return AppColors.darkWarning;
      case SyncStatusType.offline:
        return AppColors.grey500;
      case SyncStatusType.error:
        return AppColors.darkDanger;
    }
  }

  IconData _getStatusIcon(SyncStatusType status) {
    switch (status) {
      case SyncStatusType.synced:
        return Icons.cloud_done_rounded;
      case SyncStatusType.syncing:
        return Icons.sync_rounded;
      case SyncStatusType.pending:
        return Icons.cloud_upload_rounded;
      case SyncStatusType.offline:
        return Icons.cloud_off_rounded;
      case SyncStatusType.error:
        return Icons.cloud_sync_rounded;
    }
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final titleColor = isDark ? Colors.white : AppColors.lightText;
    final subtitleColor = isDark ? AppColors.grey400 : AppColors.lightSecondaryText;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.layer2 : AppColors.lightBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.darkPrimary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
      ],
    );
  }
}
