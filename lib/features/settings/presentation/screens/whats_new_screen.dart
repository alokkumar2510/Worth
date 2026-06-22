import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_version.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tactile_button.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../database/database.dart';

class WhatsNewScreen extends ConsumerStatefulWidget {
  const WhatsNewScreen({super.key});

  @override
  ConsumerState<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends ConsumerState<WhatsNewScreen> {
  final List<Map<String, String>> features = [
    {
      'title': 'Premium Update Ecosystem',
      'desc': 'Seamlessly check for, download, and review minor, optional, and security updates directly within Worth, styled with luxury dark-mode aesthetics.'
    },
    {
      'title': 'Production Image Rendering Engine',
      'desc': 'Generates and saves professional payment reminders in high-resolution aspect ratios (1080x1350, 1080x1920, 1200x628) using on-device RepaintBoundary rendering.'
    },
    {
      'title': 'Embedded Scan-to-Pay QR Codes',
      'desc': 'Dynamically generates and embeds UPI scan-to-pay QR codes directly in your generated reminder image with "Scan & Pay" details.'
    },
    {
      'title': 'UPI Options & App Chooser Panel',
      'desc': 'Quick options to copy UPI ID/payment links, share QR codes, or instantly launch Google Pay, PhonePe, Paytm, or BHIM directly from the receivable screen.'
    },
    {
      'title': 'Smart Contact Picker Import',
      'desc': 'Search and select contacts using a search sheet to automatically pre-fill names, phone numbers, and WhatsApp IDs for new receivables.'
    },
    {
      'title': 'Debtor Profile Avatars',
      'desc': 'Synchronize contact photos to local storage and display debtor avatars on dashboard cards, ledgers, and transaction timeline sheets.'
    },
  ];

  Future<void> _markAsSeen() async {
    try {
      final db = ref.read(realDatabaseProvider);
      await db.into(db.settings).insertOnConflictUpdate(
        Setting(
          key: 'last_displayed_changelog_version',
          value: AppVersion.version,
          updatedAt: DateTime.now(),
        ),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const goldAccent = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          "What's New",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () async {
            await _markAsSeen();
            if (context.mounted) {
              context.pop();
            }
          },
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
                    // Header card
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: goldAccent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.stars_rounded, color: goldAccent, size: 40),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Worth v${AppVersion.version}',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Seamless Update Systems & Ledger Safeguards',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: goldAccent,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Introducing the premium in-app Update Center, automatic update checking, and warning alerts for backup sync, along with high-res receivable templates and contact picker features.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.grey400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 12),
                      child: Text(
                        'NEW FEATURES & CAPABILITIES',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey500,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    // Feature list
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: features.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final feat = features[index];
                        return GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: goldAccent.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: goldAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feat['title']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      feat['desc']!,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.grey400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

            // Bottom CTA
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onTap: () async {
                        await _markAsSeen();
                        if (context.mounted) {
                          context.pop();
                        }
                      },
                      child: Text(
                        'Dismiss',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TactileButton(
                      color: AppColors.darkPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onTap: () async {
                        await _markAsSeen();
                        if (context.mounted) {
                          context.pop(); // Close WhatsNew
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                        ],
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
