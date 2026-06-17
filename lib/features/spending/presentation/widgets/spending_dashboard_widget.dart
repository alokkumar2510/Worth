import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../providers/spending_providers.dart';

class SpendingDashboardWidget extends ConsumerWidget {
  const SpendingDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(spendingAnalyticsProvider);
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    // Find top spending category
    final activeEntries = analytics.categoryBreakdown.entries
        .where((e) => e.value > 0.0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final hasSpending = analytics.thisMonthTotal > 0.0;
    final topCategoryName = hasSpending && activeEntries.isNotEmpty ? activeEntries.first.key : 'None';
    final topCategoryPct = hasSpending && activeEntries.isNotEmpty 
        ? ((activeEntries.first.value / analytics.thisMonthTotal) * 100).toStringAsFixed(0)
        : '0';

    return GestureDetector(
      onTap: () => context.push('/spending'),
      child: GlassCard(
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
                    const Icon(Icons.analytics_outlined, color: AppColors.darkPrimary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Spending Intelligence',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.grey500, size: 14),
              ],
            ),
            const SizedBox(height: 14),

            // Main Info Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THIS MONTH SPENT',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey500,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        format.format(analytics.thisMonthTotal),
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 36,
                  width: 1.2,
                  color: AppColors.glassBorder,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOP CATEGORY',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey500,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasSpending ? '$topCategoryName ($topCategoryPct%)' : 'No Activity',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: hasSpending ? AppColors.glow : AppColors.grey400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
