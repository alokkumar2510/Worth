import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../calendar/domain/services/calendar_engine.dart';

class CalendarReportView extends ConsumerWidget {
  const CalendarReportView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    // Generate monthly forecast for the next 6 months
    final now = DateTime.now();
    final startRange = DateTime(now.year, now.month, 1);
    final endRange = DateTime(now.year, now.month + 6, 0, 23, 59, 59);

    final events = CalendarEngine.compileAllEvents(
      dbState: dbState,
      startRange: startRange,
      endRange: endRange,
    );

    // Group events by month
    final Map<String, List<CalendarEvent>> monthlyGroups = {};
    final monthFormat = DateFormat('MMMM yyyy');

    for (int i = 0; i < 6; i++) {
      final monthDate = DateTime(now.year, now.month + i, 1);
      final key = monthFormat.format(monthDate);
      monthlyGroups[key] = [];
    }

    for (final e in events) {
      if (e.deletedAt != null || e.status == 'Cancelled') continue;
      final key = monthFormat.format(e.date);
      if (monthlyGroups.containsKey(key)) {
        monthlyGroups[key]!.add(e);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            '6-Month Cash Flow Forecast',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...monthlyGroups.entries.map((entry) {
          final monthStr = entry.key;
          final monthEvents = entry.value;

          final insights = CalendarEngine.calculateInsights(monthEvents);
          final netIsPositive = insights.netCashFlow >= 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Title Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        monthStr.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: AppColors.glow,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: netIsPositive
                              ? AppColors.darkSuccess.withOpacity(0.12)
                              : AppColors.darkDanger.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: netIsPositive
                                ? AppColors.darkSuccess.withOpacity(0.2)
                                : AppColors.darkDanger.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          '${netIsPositive ? "+" : ""}$currency${NumberFormat.decimalPattern().format(insights.netCashFlow.toInt())}',
                          style: GoogleFonts.outfit(
                            color: netIsPositive ? AppColors.darkSuccess : AppColors.darkDanger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppColors.grey700.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  // Breakdown rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRowItem('Expected Incomes', '$currency${NumberFormat.decimalPattern().format(insights.expectedIncome.toInt())}', AppColors.darkSuccess),
                      _buildRowItem('Obligations / Outflows', '$currency${NumberFormat.decimalPattern().format(insights.expectedOutflow.toInt())}', AppColors.darkDanger),
                    ],
                  ),
                  if (monthEvents.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'KEY OBLIGATIONS',
                      style: GoogleFonts.inter(
                        color: AppColors.grey500,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...monthEvents.take(3).map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  e.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                                ),
                              ),
                              Text(
                                '$currency${NumberFormat.decimalPattern().format(e.amount.toInt())}',
                                style: GoogleFonts.inter(
                                  color: e.category == 'Income' ? AppColors.darkSuccess : Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (monthEvents.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '+ ${monthEvents.length - 3} more events scheduled',
                          style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'No events scheduled for this month.',
                        style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRowItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
