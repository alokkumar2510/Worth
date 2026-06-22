import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_motion.dart';
import '../providers/app_providers.dart';
import '../services/update_service.dart';
import 'glass_card.dart';
import 'tactile_button.dart';

class UpdatePromptSheet extends ConsumerStatefulWidget {
  final UpdateInfo updateInfo;
  final bool hasPendingSync;

  const UpdatePromptSheet({
    required this.updateInfo,
    required this.hasPendingSync,
    super.key,
  });

  static Future<void> show(BuildContext context, UpdateInfo info, bool hasPendingSync) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => UpdatePromptSheet(
        updateInfo: info,
        hasPendingSync: hasPendingSync,
      ),
    );
  }

  @override
  ConsumerState<UpdatePromptSheet> createState() => _UpdatePromptSheetState();
}

class _WorthSyncWarningDialog extends ConsumerWidget {
  final VoidCallback onProceed;

  const _WorthSyncWarningDialog({required this.onProceed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
      child: AlertDialog(
        backgroundColor: AppColors.layer1.withOpacity(0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.darkWarning, size: 28),
            const SizedBox(width: 12),
            Text(
              'Unsynced Changes',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'You have pending changes that haven\'t synced to the cloud. We recommend performing a cloud sync before updating to prevent potential data conflicts.',
          style: GoogleFonts.inter(
            color: AppColors.grey400,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TactileButton(
                  color: AppColors.layer2,
                  border: const BorderSide(color: AppColors.glassBorder),
                  onTap: () {
                    Navigator.of(context).pop(); // Close dialog
                    onProceed(); // Proceed with update
                  },
                  child: Text(
                    'Skip & Update',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TactileButton(
                  color: AppColors.darkPrimary,
                  onTap: () async {
                    Navigator.of(context).pop(); // Close dialog
                    // Trigger forceSync and wait a bit
                    await ref.read(syncServiceProvider).forceSync();
                    onProceed(); // Proceed
                  },
                  child: Text(
                    'Sync & Update',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpdatePromptSheetState extends ConsumerState<UpdatePromptSheet> {
  bool _isSyncing = false;

  void _handleUpdate() {
    if (widget.hasPendingSync) {
      showDialog<void>(
        context: context,
        builder: (context) => _WorthSyncWarningDialog(
          onProceed: () {
            ref.read(updateServiceProvider.notifier).launchDownloadUrl();
            Navigator.of(context).pop(); // Close sheet
          },
        ),
      );
    } else {
      ref.read(updateServiceProvider.notifier).launchDownloadUrl();
      Navigator.of(context).pop(); // Close sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkBackground.withOpacity(0.85),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: const Border(
            top: BorderSide(color: AppColors.glassBorder, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Center handle
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header Icon / Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.system_update_alt_rounded,
                    color: AppColors.darkPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Update Available',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Worth v${info.version} • Released ${info.releaseDate}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Features Checklist
            Text(
              'WHAT\'S NEW IN THIS VERSION',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.grey500,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.white, Colors.transparent],
                      stops: [0.0, 0.85, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: info.releaseNotes.map((note) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.darkSuccess,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  note,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: AppColors.darkText.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Warning Banner for Sync
            if (widget.hasPendingSync) ...[
              GlassCard(
                padding: const EdgeInsets.all(14),
                borderColor: AppColors.darkWarning.withOpacity(0.3),
                child: Row(
                  children: [
                    const Icon(Icons.sync_problem_rounded, color: AppColors.darkWarning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You have pending local ledger changes. A cloud backup is recommended before installing.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.darkWarning,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TactileButton(
                    color: AppColors.layer2,
                    border: const BorderSide(color: AppColors.glassBorder),
                    onTap: () {
                      ref.read(updateServiceProvider.notifier).dismissUpdate(info.version);
                      Navigator.of(context).pop(); // Dismiss sheet
                    },
                    child: Text(
                      'Remind Me Later',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TactileButton(
                    color: AppColors.darkPrimary,
                    onTap: _handleUpdate,
                    child: Text(
                      'Update Now',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class ForceUpdateWidget extends ConsumerStatefulWidget {
  final UpdateInfo updateInfo;
  final bool hasPendingSync;

  const ForceUpdateWidget({
    required this.updateInfo,
    required this.hasPendingSync,
    super.key,
  });

  @override
  ConsumerState<ForceUpdateWidget> createState() => _ForceUpdateWidgetState();
}

class _ForceUpdateWidgetState extends ConsumerState<ForceUpdateWidget> {
  bool _isSyncing = false;

  void _handleUpdate() {
    if (widget.hasPendingSync) {
      showDialog<void>(
        context: context,
        builder: (context) => _WorthSyncWarningDialog(
          onProceed: () {
            ref.read(updateServiceProvider.notifier).launchDownloadUrl();
          },
        ),
      );
    } else {
      ref.read(updateServiceProvider.notifier).launchDownloadUrl();
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Glowy Warning Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkDanger.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkDanger.withOpacity(0.3), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.security_update_warning_rounded,
                      color: AppColors.darkDanger,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Critical Update Required',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'To protect your private wealth data and ledger operations, an update to Worth v${info.version} is required. You cannot bypass this upgrade.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    color: AppColors.grey400,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'WHAT\'S IN THIS RELEASE',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 180),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: info.releaseNotes.map((note) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2.0),
                                      child: Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: AppColors.darkSuccess,
                                        size: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        note,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.darkText.withOpacity(0.95),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                if (widget.hasPendingSync) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    borderColor: AppColors.darkWarning.withOpacity(0.2),
                    child: Row(
                      children: [
                        const Icon(Icons.sync_problem_rounded, color: AppColors.darkWarning, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Unsynced transactions detected. We recommend performing a backup sync.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.darkWarning,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                TactileButton(
                  color: AppColors.darkDanger,
                  height: 52,
                  onTap: _handleUpdate,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Update Worth Now',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
