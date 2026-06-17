import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/sync_status_provider.dart';

/// A compact, premium Cloud Sync status indicator for the dashboard header.
///
/// Visual states:
///   ✅ Synced  → Green dot, "Synced", "Last: Xm ago"
///   🔄 Pending → Pulsing blue dot, "Pending: X Changes"
///   ⚡ Syncing → Spinning indicator, "Syncing..."
///   📡 Offline → Orange dot, "Offline", "Pending: X Changes"
///   ❌ Error   → Red dot, "Sync Error", "X Failed"
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    final Color dotColor;
    final Color glowColor;
    final IconData icon;
    final bool shouldPulse;

    switch (syncState.status) {
      case SyncStatusType.synced:
        dotColor = AppColors.darkSuccess;
        glowColor = AppColors.darkSuccess.withOpacity(0.3);
        icon = Icons.cloud_done_rounded;
        shouldPulse = false;
        break;
      case SyncStatusType.syncing:
        dotColor = const Color(0xFF60A5FA); // Blue-400
        glowColor = const Color(0xFF60A5FA).withOpacity(0.3);
        icon = Icons.cloud_sync_rounded;
        shouldPulse = true;
        break;
      case SyncStatusType.pending:
        dotColor = const Color(0xFF60A5FA); // Blue-400
        glowColor = const Color(0xFF60A5FA).withOpacity(0.3);
        icon = Icons.cloud_upload_rounded;
        shouldPulse = true;
        break;
      case SyncStatusType.offline:
        dotColor = AppColors.darkWarning;
        glowColor = AppColors.darkWarning.withOpacity(0.3);
        icon = Icons.cloud_off_rounded;
        shouldPulse = false;
        break;
      case SyncStatusType.error:
        dotColor = AppColors.darkDanger;
        glowColor = AppColors.darkDanger.withOpacity(0.3);
        icon = Icons.error_outline_rounded;
        shouldPulse = false;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.layer1.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator with glow
          _StatusDot(
            color: dotColor,
            glowColor: glowColor,
            shouldPulse: shouldPulse,
          ),
          const SizedBox(width: 8),
          // Icon
          Icon(icon, color: dotColor, size: 16),
          const SizedBox(width: 6),
          // Status text column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                syncState.statusText,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: dotColor,
                  height: 1.2,
                ),
              ),
              if (syncState.status == SyncStatusType.synced ||
                  syncState.status == SyncStatusType.offline)
                Text(
                  syncState.status == SyncStatusType.offline && syncState.pendingCount > 0
                      ? 'Pending: ${syncState.pendingCount} changes'
                      : syncState.lastSyncedText,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: AppColors.grey500,
                    height: 1.3,
                  ),
                ),
              if (syncState.status == SyncStatusType.error && syncState.failedCount > 0)
                Text(
                  '${syncState.failedCount} failed',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkDanger.withOpacity(0.7),
                    height: 1.3,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated status dot with optional pulsing glow
class _StatusDot extends StatefulWidget {
  final Color color;
  final Color glowColor;
  final bool shouldPulse;

  const _StatusDot({
    required this.color,
    required this.glowColor,
    required this.shouldPulse,
  });

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.shouldPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPulse && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.shouldPulse && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_animation.value * 0.6),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
