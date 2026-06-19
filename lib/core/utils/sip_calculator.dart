import 'package:intl/intl.dart';

class SipCalculator {
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
    DateTime current = DateTime(startLimit.year, startLimit.month, startLimit.day);
    if (current.isBefore(actualStart)) {
      current = actualStart;
    }

    final DateTime actualEndLimit = endDate != null && endDate.isBefore(endLimit)
        ? DateTime(endDate.year, endDate.month, endDate.day)
        : DateTime(endLimit.year, endLimit.month, endLimit.day);

    int loops = 0;
    while ((current.isBefore(actualEndLimit) || current.isAtSameMomentAs(actualEndLimit)) && loops < 2000) {
      loops++;
      bool matches = false;

      if (frequency == 'weekly') {
        if (current.weekday == sipDate) {
          matches = true;
        }
      } else if (frequency == 'monthly') {
        final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
        final targetDay = sipDate > daysInMonth ? daysInMonth : sipDate;
        if (current.day == targetDay) {
          matches = true;
        }
      } else if (frequency == 'quarterly') {
        final monthDiff = (current.year - actualStart.year) * 12 + (current.month - actualStart.month);
        if (monthDiff % 3 == 0) {
          final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
          final targetDay = sipDate > daysInMonth ? daysInMonth : sipDate;
          if (current.day == targetDay) {
            matches = true;
          }
        }
      }

      if (matches) {
        dates.add(current);
      }
      current = current.add(const Duration(days: 1));
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
