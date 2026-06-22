import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_version.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tactile_button.dart';
import '../../../../core/widgets/update_prompt_sheet.dart';
import '../../../../core/services/update_service.dart';

class UpdateCenterScreen extends ConsumerStatefulWidget {
  const UpdateCenterScreen({super.key});

  @override
  ConsumerState<UpdateCenterScreen> createState() => _UpdateCenterScreenState();
}

class _UpdateCenterScreenState extends ConsumerState<UpdateCenterScreen> {
  final List<Map<String, dynamic>> _historicalReleases = [
    {
      'version': '1.12.0',
      'build': 13,
      'date': '2026-06-22',
      'notes': [
        'Fixed application crash when saving MTF ETF and Stock positions.',
        'Corrected investment type mapping (ETF vs Stock) in Margin Trading Facility.',
        'Upgraded DB placeholder insertions to prevent Unique constraint collision crashes.'
      ]
    },
    {
      'version': '1.11.0',
      'build': 12,
      'date': '2026-06-22',
      'notes': [
        'Premium Update Ecosystem and In-App Update Center.',
        'Production Image Rendering Engine for Receivables.',
        'Embedded Scan-to-Pay QR Codes (UPI integrated).',
        'Smart Contact Picker Import for receivables.',
        'Sleek App-Wide Motion and decel scroll physics.'
      ]
    },
    {
      'version': '1.10.0',
      'build': 11,
      'date': '2026-06-15',
      'notes': [
        'Beta Update service endpoints setup.',
        'Backup sync warning thresholds.',
        'UI improvements in liability sheets.'
      ]
    },
    {
      'version': '1.9.0',
      'build': 9,
      'date': '2026-05-15',
      'notes': [
        'Moratorium Repayment SIM trackers in Education Loans.',
        'Encrypted JSON backup file vault.',
        'Automatic local DB interest accrual loops.'
      ]
    },
    {
      'version': '1.8.0',
      'build': 8,
      'date': '2026-04-10',
      'notes': [
        'Time Machine Ledger Time Travel Archive.',
        'Receivable settlement timeline logs.',
        'Custom category & transaction label manager.'
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateServiceProvider);
    final notifier = ref.read(updateServiceProvider.notifier);

    // Merge remote info if available in timeline
    final List<Map<String, dynamic>> combinedReleases = [];
    if (updateState.updateInfo != null) {
      final info = updateState.updateInfo!;
      final alreadyExists = _historicalReleases.any((r) => r['version'] == info.version);
      if (!alreadyExists) {
        combinedReleases.add({
          'version': info.version,
          'build': info.build,
          'date': info.releaseDate,
          'notes': info.releaseNotes,
        });
      }
    }
    combinedReleases.addAll(_historicalReleases);

    final isChecking = updateState.status == UpdateStatus.checking;
    final isUpdateAvailable = updateState.status == UpdateStatus.optionalAvailable || 
                              updateState.status == UpdateStatus.forceRequired;

    String statusTitle = 'Your App is Up to Date';
    String statusSubtitle = 'Worth is running the latest ledger safeguards.';
    Color statusColor = AppColors.darkSuccess;
    IconData statusIcon = Icons.check_circle_rounded;

    if (updateState.status == UpdateStatus.checking) {
      statusTitle = 'Checking for updates...';
      statusSubtitle = 'Reaching secure version server.';
      statusColor = AppColors.darkPrimary;
      statusIcon = Icons.hourglass_empty_rounded;
    } else if (updateState.status == UpdateStatus.optionalAvailable) {
      statusTitle = 'New Update Available';
      statusSubtitle = 'Worth v${updateState.updateInfo!.version} is ready for installation.';
      statusColor = AppColors.darkWarning;
      statusIcon = Icons.rocket_launch_rounded;
    } else if (updateState.status == UpdateStatus.forceRequired) {
      statusTitle = 'Critical Update Required';
      statusSubtitle = 'Version v${updateState.updateInfo!.version} contains vital security adjustments.';
      statusColor = AppColors.darkDanger;
      statusIcon = Icons.security_update_warning_rounded;
    } else if (updateState.status == UpdateStatus.error) {
      statusTitle = 'Update Check Failed';
      statusSubtitle = updateState.errorMessage ?? 'Please verify your internet connection.';
      statusColor = AppColors.darkDanger;
      statusIcon = Icons.error_outline_rounded;
    }

    final checkedTimeText = updateState.lastChecked != null
        ? DateFormat('hh:mm a, MMM dd').format(updateState.lastChecked!)
        : 'Never';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          'Update Center',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status glowing indicator card
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      borderColor: statusColor.withOpacity(0.2),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                              border: Border.all(color: statusColor.withOpacity(0.2)),
                            ),
                            child: isChecking 
                                ? SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                                    ),
                                  )
                                : Icon(statusIcon, color: statusColor, size: 32),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            statusTitle,
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            statusSubtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.grey400,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Version properties grid
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Version',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.grey500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  AppVersion.version,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Build Number',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.grey500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${AppVersion.build}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Last Checked',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.grey400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            checkedTimeText,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Historical release notes
                    Text(
                      'RELEASE HISTORY & CHANGELOG',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: combinedReleases.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final rel = combinedReleases[index];
                        final isCurrentlyRunning = rel['version'] == AppVersion.version;

                        return GlassCard(
                          padding: const EdgeInsets.all(18),
                          borderColor: isCurrentlyRunning ? AppColors.darkPrimary.withOpacity(0.15) : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'v${rel['version']}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${rel['date']})',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.grey500,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isCurrentlyRunning)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkPrimary.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        'Running',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.glow,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.white.withOpacity(0.04), height: 1),
                              const SizedBox(height: 12),
                              ...((rel['notes'] as List<dynamic>?) ?? []).map((n) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Icon(Icons.circle, color: AppColors.darkPrimary, size: 6),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          n as String,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: AppColors.grey400,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom action panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.layer1,
                border: Border(
                  top: BorderSide(color: AppColors.glassBorder),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TactileButton(
                      color: AppColors.layer2,
                      border: const BorderSide(color: AppColors.glassBorder),
                      onTap: isChecking ? null : () async {
                        final res = await notifier.checkForUpdates(isManual: true);
                        if (!context.mounted) return;
                        if (res.status == UpdateStatus.optionalAvailable) {
                          await UpdatePromptSheet.show(context, res.updateInfo!, res.hasPendingSync);
                        } else if (res.status == UpdateStatus.noUpdate) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Worth is up to date (v${AppVersion.version}).',
                                style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                              ),
                              backgroundColor: AppColors.layer2,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Check For Updates',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TactileButton(
                      color: isUpdateAvailable ? AppColors.darkPrimary : AppColors.layer2.withOpacity(0.3),
                      border: isUpdateAvailable ? null : const BorderSide(color: AppColors.glassBorder),
                      onTap: isUpdateAvailable ? () {
                        if (updateState.updateInfo != null) {
                          if (updateState.status == UpdateStatus.forceRequired) {
                            ref.read(updateServiceProvider.notifier).launchDownloadUrl();
                          } else {
                            UpdatePromptSheet.show(context, updateState.updateInfo!, updateState.hasPendingSync);
                          }
                        }
                      } : null,
                      child: Text(
                        'Download Update',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isUpdateAvailable ? Colors.white : AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
