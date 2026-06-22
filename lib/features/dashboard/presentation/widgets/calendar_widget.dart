import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../calendar/domain/entities/calendar_event.dart';
import '../../../calendar/domain/services/calendar_engine.dart';

class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({super.key});

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Income':
        return AppColors.darkSuccess;
      case 'Investment':
        return AppColors.darkPrimary;
      case 'Liability':
        return AppColors.darkDanger;
      case 'Receivables':
        return const Color(0xFF3B82F6);
      case 'Goals':
        return AppColors.darkWarning;
      case 'IPO':
        return const Color(0xFFF97316);
      case 'Subscription':
        return const Color(0xFF6366F1);
      case 'Insurance':
        return const Color(0xFF14B8A6);
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    // Compile upcoming events for next 30 days
    final now = DateTime.now();
    final events = CalendarEngine.compileAllEvents(
      dbState: dbState,
      startRange: now,
      endRange: now.add(const Duration(days: 30)),
    );

    // Filter out past events (today or later)
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = events.where((e) => !e.date.isBefore(today) && e.deletedAt == null && e.status != 'Cancelled').toList();

    if (upcoming.isEmpty) {
      return GlassCard(
        onTap: () => context.go('/portfolio/calendar'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: AppColors.glow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'UPCOMING EVENTS',
                  style: GoogleFonts.outfit(
                    color: AppColors.glow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No upcoming financial events scheduled.',
              style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final nextEvent = upcoming.first;
    final diffDays = nextEvent.date.difference(today).inDays;

    String countdownText;
    if (diffDays == 0) {
      countdownText = 'Due Today';
    } else if (diffDays == 1) {
      countdownText = 'Due Tomorrow';
    } else {
      countdownText = 'In $diffDays days';
    }

    final eventColor = _getCategoryColor(nextEvent.category);

    return GlassCard(
      onTap: () => context.go('/portfolio/calendar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.glow, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'UPCOMING OBLIGATION',
                    style: GoogleFonts.outfit(
                      color: AppColors.glow,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: diffDays == 0 
                      ? AppColors.darkDanger.withOpacity(0.15) 
                      : AppColors.layer2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: diffDays == 0 
                        ? AppColors.darkDanger.withOpacity(0.3) 
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  countdownText,
                  style: GoogleFonts.inter(
                    color: diffDays == 0 ? AppColors.darkDanger : AppColors.glow,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: eventColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextEvent.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, d MMMM').format(nextEvent.date),
                      style: GoogleFonts.inter(
                        color: AppColors.grey500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currency${NumberFormat.decimalPattern().format(nextEvent.amount.toInt())}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    nextEvent.category,
                    style: GoogleFonts.inter(
                      color: eventColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
