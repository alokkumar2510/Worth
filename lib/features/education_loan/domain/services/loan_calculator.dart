import 'dart:math' as math;
import '../entities/education_loan.dart';

// ============================================================
// PURE MATH ENGINE — no side effects, no Flutter, no providers
// ============================================================
class LoanCalculator {
  LoanCalculator._();

  // ----------------------------------------------------------
  // SIMPLE INTEREST (daily, moratorium phase)
  // ----------------------------------------------------------
  static double dailySimpleInterest(double principal, double annualRatePct, int days) {
    if (principal <= 0 || annualRatePct <= 0 || days <= 0) return 0;
    return principal * (annualRatePct / 100) * days / 365.0;
  }

  static double interestFromTo(double principal, double annualRatePct, DateTime from, DateTime to) {
    final days = to.difference(from).inDays;
    return dailySimpleInterest(principal, annualRatePct, days);
  }

  // ----------------------------------------------------------
  // INTEREST ACCRUED TO DATE
  // given disbursements and rate, compute total simple interest from first
  // disbursement to today (moratorium-style: no repayments yet)
  // ----------------------------------------------------------
  static double accruedInterestToDate({
    required List<LoanDisbursement> disbursements,
    required double annualRatePct,
    DateTime? asOfDate,
  }) {
    if (disbursements.isEmpty) return 0;
    final today = asOfDate ?? DateTime.now();
    double total = 0;
    for (final d in disbursements) {
      final days = today.difference(d.date).inDays;
      if (days > 0) {
        total += dailySimpleInterest(d.amount, annualRatePct, days);
      }
    }
    return total;
  }

  // ----------------------------------------------------------
  // MONTHLY REDUCING BALANCE EMI
  // P = principal, r = annual rate %, n = tenure in months
  // EMI = P × [r(1+r)^n] / [(1+r)^n - 1]
  // ----------------------------------------------------------
  static double calculateEmi(double principal, double annualRatePct, int tenureMonths) {
    if (principal <= 0 || annualRatePct <= 0 || tenureMonths <= 0) return 0;
    final r = annualRatePct / 100 / 12;
    final factor = math.pow(1 + r, tenureMonths);
    return principal * r * factor / (factor - 1);
  }

  // ----------------------------------------------------------
  // FULL AMORTIZATION TABLE
  // Returns a list of monthly rows: {month, openingBalance, emi, interest, principal, closingBalance}
  // ----------------------------------------------------------
  static List<Map<String, dynamic>> amortizationSchedule({
    required double principal,
    required double annualRatePct,
    required double emiAmount,
    DateTime? startDate,
  }) {
    final schedule = <Map<String, dynamic>>[];
    double balance = principal;
    final r = annualRatePct / 100 / 12;
    DateTime date = startDate ?? DateTime.now();
    int month = 1;

    while (balance > 0.01 && month <= 360) {
      final interestPart = balance * r;
      double principalPart = emiAmount - interestPart;
      if (principalPart > balance) principalPart = balance;
      final emi = interestPart + principalPart;
      final closing = balance - principalPart;

      schedule.add({
        'month': month,
        'date': date,
        'openingBalance': balance,
        'emi': emi,
        'interest': interestPart,
        'principal': principalPart,
        'closingBalance': closing < 0.01 ? 0.0 : closing,
      });

      balance = closing;
      date = DateTime(date.year, date.month + 1, date.day);
      month++;
    }
    return schedule;
  }

  // ----------------------------------------------------------
  // EMI SIMULATION RESULT
  // ----------------------------------------------------------
  static ({DateTime closureDate, double totalInterest, double totalRepayment, int months}) emiSimulationResult({
    required double principal,
    required double annualRatePct,
    required double emiAmount,
    DateTime? startDate,
  }) {
    final schedule = amortizationSchedule(
      principal: principal,
      annualRatePct: annualRatePct,
      emiAmount: emiAmount,
      startDate: startDate,
    );

    if (schedule.isEmpty) {
      return (
        closureDate: startDate ?? DateTime.now(),
        totalInterest: 0,
        totalRepayment: principal,
        months: 0,
      );
    }

    final totalInterest = schedule.fold(0.0, (sum, row) => sum + (row['interest'] as double));
    final totalRepayment = schedule.fold(0.0, (sum, row) => sum + (row['emi'] as double));
    final closureDate = schedule.last['date'] as DateTime;
    return (closureDate: closureDate, totalInterest: totalInterest, totalRepayment: totalRepayment, months: schedule.length);
  }

  // ----------------------------------------------------------
  // PREPAYMENT IMPACT
  // Computes difference in closure date & total interest if extraPayment
  // is made periodically (monthly/quarterly/yearly) or one-time
  // ----------------------------------------------------------
  static ({
    DateTime baseClosureDate,
    DateTime newClosureDate,
    double interestSaved,
    int monthsSaved,
    double baseTotalInterest,
    double newTotalInterest,
  }) prepaymentImpact({
    required double principal,
    required double annualRatePct,
    required double regularEmi,
    required double extraPayment,
    required String frequency, // 'monthly' | 'quarterly' | 'yearly' | 'onetime'
    DateTime? startDate,
  }) {
    final baseResult = emiSimulationResult(
      principal: principal,
      annualRatePct: annualRatePct,
      emiAmount: regularEmi,
      startDate: startDate,
    );

    // Simulate with prepayment
    final r = annualRatePct / 100 / 12;
    double balance = principal;
    DateTime date = startDate ?? DateTime.now();
    int month = 1;
    double newTotalInterest = 0;
    double newTotalRepayment = 0;
    int newMonths = 0;

    while (balance > 0.01 && month <= 360) {
      final interestPart = balance * r;
      double principalPart = regularEmi - interestPart;
      if (principalPart <= 0) principalPart = 0;

      // Add extra payment based on frequency
      double extra = 0;
      if (frequency == 'monthly') {
        extra = extraPayment;
      } else if (frequency == 'quarterly' && month % 3 == 0) {
        extra = extraPayment;
      } else if (frequency == 'yearly' && month % 12 == 0) {
        extra = extraPayment;
      } else if (frequency == 'onetime' && month == 1) {
        extra = extraPayment;
      }

      double totalPrincipal = principalPart + extra;
      if (totalPrincipal > balance) totalPrincipal = balance;

      newTotalInterest += interestPart;
      newTotalRepayment += interestPart + totalPrincipal;
      balance -= totalPrincipal;
      date = DateTime(date.year, date.month + 1, date.day);
      newMonths = month;
      month++;
    }

    final interestSaved = baseResult.totalInterest - newTotalInterest;
    final monthsSaved = baseResult.months - newMonths;

    return (
      baseClosureDate: baseResult.closureDate,
      newClosureDate: date,
      interestSaved: interestSaved.clamp(0, double.infinity),
      monthsSaved: monthsSaved.clamp(0, 999),
      baseTotalInterest: baseResult.totalInterest,
      newTotalInterest: newTotalInterest,
    );
  }

  // ----------------------------------------------------------
  // LOAN FORECAST POINTS
  // Generates projected outstanding balance at key milestones
  // ----------------------------------------------------------
  static List<LoanForecastPoint> generateForecast({
    required EducationLoan loan,
    required List<LoanDisbursement> disbursements,
    int forecastYears = 10,
  }) {
    final points = <LoanForecastPoint>[];
    final now = DateTime.now();
    final totalDisbursed = disbursements.fold(0.0, (s, d) => s + d.amount);

    if (totalDisbursed == 0) return points;

    // Current state
    final accruedNow = accruedInterestToDate(
      disbursements: disbursements,
      annualRatePct: loan.interestRate,
    );
    points.add(LoanForecastPoint(
      label: 'Today',
      date: now,
      outstanding: totalDisbursed,
      totalInterestAccrued: accruedNow,
    ));

    // After moratorium
    final moratoriumEnd = loan.moratoriumEndDate;
    if (moratoriumEnd != null && moratoriumEnd.isAfter(now)) {
      final accruedAtMoratorium = accruedInterestToDate(
        disbursements: disbursements,
        annualRatePct: loan.interestRate,
        asOfDate: moratoriumEnd,
      );
      points.add(LoanForecastPoint(
        label: 'EMI Start',
        date: moratoriumEnd,
        outstanding: totalDisbursed + accruedAtMoratorium,
        totalInterestAccrued: accruedAtMoratorium,
      ));
    }

    // Yearly forecasts during repayment if EMI is set
    if (loan.expectedEmi != null && loan.expectedEmi! > 0) {
      final emiStart = loan.computedEmiStartDate ?? moratoriumEnd ?? now;
      final totalAtEmiStart = totalDisbursed + accruedInterestToDate(
        disbursements: disbursements,
        annualRatePct: loan.interestRate,
        asOfDate: emiStart,
      );

      final r = loan.interestRate / 100 / 12;
      double balance = totalAtEmiStart;
      double accumulatedInterest = 0;

      for (int year = 1; year <= forecastYears; year++) {
        // Simulate 12 months of EMI
        for (int m = 0; m < 12; m++) {
          if (balance <= 0.01) break;
          final interestPart = balance * r;
          accumulatedInterest += interestPart;
          final principalPart = (loan.expectedEmi! - interestPart).clamp(0, balance);
          balance -= principalPart;
        }

        if (balance <= 0.01) {
          points.add(LoanForecastPoint(
            label: 'Loan Closed',
            date: DateTime(emiStart.year + year, emiStart.month, 1),
            outstanding: 0,
            totalInterestAccrued: totalAtEmiStart - totalDisbursed + accumulatedInterest,
          ));
          break;
        }

        points.add(LoanForecastPoint(
          label: 'Year ${year} EMI',
          date: DateTime(emiStart.year + year, emiStart.month, 1),
          outstanding: balance,
          totalInterestAccrued: totalAtEmiStart - totalDisbursed + accumulatedInterest,
        ));
      }
    }

    return points;
  }

  // ----------------------------------------------------------
  // MORATORIUM PROGRESS
  // Returns 0.0-1.0 progress through moratorium period
  // ----------------------------------------------------------
  static double moratoriumProgress(DateTime? courseEndDate, int moratoriumMonths) {
    if (courseEndDate == null || moratoriumMonths == 0) return 1.0;
    final morEnd = DateTime(courseEndDate.year, courseEndDate.month + moratoriumMonths, courseEndDate.day);
    final now = DateTime.now();
    if (now.isBefore(courseEndDate)) return 0.0;
    if (now.isAfter(morEnd)) return 1.0;
    final totalDays = morEnd.difference(courseEndDate).inDays.toDouble();
    final elapsedDays = now.difference(courseEndDate).inDays.toDouble();
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  // ----------------------------------------------------------
  // REMAINING MORATORIUM DAYS
  // ----------------------------------------------------------
  static int moratoriumDaysRemaining(DateTime? courseEndDate, int moratoriumMonths) {
    if (courseEndDate == null) return 0;
    final morEnd = DateTime(courseEndDate.year, courseEndDate.month + moratoriumMonths, courseEndDate.day);
    final now = DateTime.now();
    if (now.isAfter(morEnd)) return 0;
    return morEnd.difference(now).inDays;
  }
}
