import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../providers/check_in_providers.dart';

class CheckInDashboardWidget extends ConsumerWidget {
  const CheckInDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(checkInActivityProvider);
    final streakAsync = ref.watch(checkInStreakInfoProvider);

    return streakAsync.when(
      data: (streak) {
        // Missed days calculation
        final hasMissedDays = streak.daysSinceLastActivity >= 3;

        Color statusColor;
        IconData statusIcon;
        String completionText;

        if (activity.isCompleted) {
          statusColor = const Color(0xFF00E676); // Emerald Green
          statusIcon = Icons.check_circle_rounded;
          completionText = 'Completed';
        } else if (activity.transactionsTodayCount == 0) {
          statusColor = AppColors.grey500; // Grey
          statusIcon = Icons.radio_button_unchecked_rounded;
          completionText = 'No Activity';
        } else {
          statusColor = const Color(0xFFFF9100); // Amber Orange
          statusIcon = Icons.change_circle_outlined;
          completionText = 'Partially Updated';
        }

        return GlassCard(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.darkPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Check-in',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push('/settings/checkins'),
                    child: const Icon(Icons.settings_outlined, color: AppColors.grey500, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Missed Days Warning Banner
              if (hasMissedDays) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.darkDanger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.darkDanger.withOpacity(0.24),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.darkDanger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "You haven't recorded any activity for ${streak.daysSinceLastActivity} days. Review and update your records.",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Main info row (Today's status + Streak info)
              Row(
                children: [
                  // Status Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TODAY\'S ACTIVITY',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.grey500,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              completionText,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          activity.statusLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Streak Info
                  Container(
                    height: 40,
                    width: 1.2,
                    color: AppColors.glassBorder,
                  ),
                  const SizedBox(width: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF5722), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${streak.currentStreak} Days',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Current Streak',
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Longest: ${streak.longestStreak} Days',
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey400, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),

              // Button to complete check-in
              if (!activity.isCompleted) ...[
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () => ref.read(checkInActivityProvider.notifier).markCompleted(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary.withOpacity(0.12),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.darkPrimary, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, size: 16, color: AppColors.darkPrimary),
                      const SizedBox(width: 6),
                      Text(
                        'Complete Check-in',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const GlassCard(
        child: SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.darkPrimary),
          ),
        ),
      ),
      error: (e, s) => GlassCard(
        child: Text('Error loading streaks: $e', style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
