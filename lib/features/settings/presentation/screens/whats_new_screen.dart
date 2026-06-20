import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tactile_button.dart';

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const goldAccent = Color(0xFFD4AF37);

    final List<Map<String, String>> features = [
      {
        'title': 'Interactive Debt Aging Chart',
        'desc': 'Beautiful, dynamic bar charts visualizing outstanding receivables across aging buckets (0-30, 31-60, 61-90, 90+ days).'
      },
      {
        'title': 'Automated Recovery Calculator',
        'desc': 'Computes borrower-specific risk levels (Low to Critical), recovery probabilities, and days pending in real-time.'
      },
      {
        'title': 'Smart Follow-Up Engine',
        'desc': 'Categorizes collection status into 5 progressive stages—from Gentle Reminder to Legal Escalation.'
      },
      {
        'title': 'Custom Reminder Card Generator',
        'desc': 'Generates and exports premium, customizable payment cards with themes like Luxury Gold, Corporate Blue, and Minimalist.'
      },
      {
        'title': 'Dynamic UPI QR Generation',
        'desc': 'Creates scan-to-pay QR codes instantly on-device using the debtor’s name and outstanding balance.'
      },
      {
        'title': 'Smart Share Integrations',
        'desc': 'Formats and launches personalized reminder copy directly into WhatsApp, Telegram, SMS, or system clipboard.'
      },
      {
        'title': 'Comprehensive Collection Timeline',
        'desc': 'Keeps a visual log of all collection activities, including reminders sent, custom manual notes, and partial payments.'
      },
      {
        'title': 'Offline-First Architecture',
        'desc': 'Manage configurations, track debtors, and log updates offline with robust local SQLite/Drift caching.'
      },
      {
        'title': 'Seamless Firebase Cloud Sync',
        'desc': 'Automatically pushes and pulls offline updates, backup points, and collection logs to Firestore when back online.'
      },
      {
        'title': 'Local Notifications Scheduler',
        'desc': 'Schedules precise device reminders for critical aging thresholds to ensure you never forget to follow up.'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(
          "What's New in v1.9.0",
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
                            child: Icon(Icons.stars_rounded, color: goldAccent, size: 40),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Worth v1.9.0',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Smart Debt Recovery & UPI Collection',
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
                            'A major core upgrade introduces full-cycle receivables tracking, professional reminders sharing, and UPI payment integration.',
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
                        '10 NEW FEATURES & CAPABILITIES',
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
                      onTap: () => context.pop(),
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
                      onTap: () {
                        context.pop(); // Close WhatsNew
                        context.push('/recovery/dashboard'); // Go to Recovery Dashboard
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Open Dashboard',
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
