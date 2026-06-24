import 'package:intl/intl.dart';

class SipCalculator {
  /// Calculates the next due date based on the current date, frequency, and target SIP day.
  /// Generates dates cycle-by-cycle (next week, next month, next quarter).
  static DateTime calculateNextDueDate(DateTime fromDate, String frequency, int sipDate) {
    final cleanDate = DateTime(fromDate.year, fromDate.month, fromDate.day);
    if (frequency == 'weekly') {
      final currentWeekday = cleanDate.weekday;
      final daysToAdd = 7 - currentWeekday + sipDate;
      return cleanDate.add(Duration(days: daysToAdd));
    } else if (frequency == 'monthly') {
      final nextMonthDate = DateTime(cleanDate.year, cleanDate.month + 1, 1);
      final daysInMonth = DateTime(nextMonthDate.year, nextMonthDate.month + 1, 0).day;
      final targetDay = sipDate > daysInMonth ? daysInMonth : sipDate;
      return DateTime(nextMonthDate.year, nextMonthDate.month, targetDay);
    } else if (frequency == 'quarterly') {
      final nextQuarterDate = DateTime(cleanDate.year, cleanDate.month + 3, 1);
      final daysInMonth = DateTime(nextQuarterDate.year, nextQuarterDate.month + 1, 0).day;
      final targetDay = sipDate > daysInMonth ? daysInMonth : sipDate;
      return DateTime(nextQuarterDate.year, nextQuarterDate.month, targetDay);
    }
    return cleanDate;
  }

  /// Calculate all scheduled dates of a SIP between [startLimit] and [endLimit].
  static List<DateTime> calculateScheduledDates({
    required DateTime startDate,
    required String frequency,
    required int sipDate,
    required DateTime startLimit,
    required DateTime endLimit,
    DateTime? endDate,
  }) {
    final List<DateTime> dates = [];
    final actualStart = DateTime(startDate.year, startDate.month, startDate.day);
    
    DateTime current = actualStart;
    
    final DateTime actualEndLimit = endDate != null && endDate.isBefore(endLimit)
        ? DateTime(endDate.year, endDate.month, endDate.day)
        : DateTime(endLimit.year, endLimit.month, endLimit.day);

    final startLimitClean = DateTime(startLimit.year, startLimit.month, startLimit.day);

    int loops = 0;
    while ((current.isBefore(actualEndLimit) || current.isAtSameMomentAs(actualEndLimit)) && loops < 1000) {
      loops++;
      if (current.isAfter(startLimitClean) || current.isAtSameMomentAs(startLimitClean)) {
        dates.add(current);
      }
      current = calculateNextDueDate(current, frequency, sipDate);
    }
    return dates;
  }

  /// Calculates the difference in months between two dates.
  static int calculateMonthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + end.month - start.month;
  }

  /// Formats the age in months/years as a human-readable string (e.g. "1 Yr 5 Mo").
  static String formatAge(int totalMonths) {
    if (totalMonths <= 0) {
      return '0 Mo';
    }
    if (totalMonths < 12) {
      return '$totalMonths Mo';
    }
    final yrs = totalMonths ~/ 12;
    final mos = totalMonths % 12;
    if (mos == 0) {
      return '$yrs ${yrs == 1 ? "Yr" : "Yrs"}';
    }
    return '$yrs ${yrs == 1 ? "Yr" : "Yrs"} $mos Mo';
  }
}
