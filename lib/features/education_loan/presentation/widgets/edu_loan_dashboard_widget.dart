import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../providers/education_loan_provider.dart';
import '../../domain/services/loan_calculator.dart';
import '../../domain/entities/education_loan.dart';

const _eduBlue = Color(0xFF0EA5E9);

/// Compact dashboard card for the main dashboard screen.
/// Shown only when a loan exists.
class EduLoanDashboardWidget extends ConsumerWidget {
  const EduLoanDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox.shrink();

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final totalDisbursed = state.totalDisbursed;
    final accrued = LoanCalculator.accruedInterestToDate(
      disbursements: state.disbursements,
      annualRatePct: loan.interestRate,
    );
    final daysLeft = LoanCalculator.moratoriumDaysRemaining(loan.courseEndDate, loan.moratoriumMonths);

    return GestureDetector(
      onTap: () => context.push('/settings/education_loan'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _eduBlue.withOpacity(0.15),
              AppColors.darkPrimary.withOpacity(0.08),
              AppColors.layer1,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _eduBlue.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _eduBlue.withOpacity(0.15),
                    ),
                    child: const Icon(Icons.school_rounded, size: 16, color: _eduBlue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Education Loan',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          loan.lenderName,
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _eduBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(loan.status.label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: _eduBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _miniStat('Sanctioned', currency.format(loan.sanctionedAmount), _eduBlue)),
                  Expanded(child: _miniStat('Disbursed', currency.format(totalDisbursed), Colors.white)),
                  Expanded(child: _miniStat('Accrued', currency.format(accrued), AppColors.darkDanger)),
                ],
              ),
              if (daysLeft > 0) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkWarning.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_empty_rounded, size: 12, color: AppColors.darkWarning),
                      const SizedBox(width: 6),
                      Text(
                        'Moratorium: $daysLeft days remaining before EMI starts',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.darkWarning, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500), textAlign: TextAlign.center),
      ],
    );
  }
}
