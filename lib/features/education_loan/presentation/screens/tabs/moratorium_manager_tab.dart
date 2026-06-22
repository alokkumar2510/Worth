import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../providers/education_loan_provider.dart';
import '../../../domain/services/loan_calculator.dart';

const _eduBlue = Color(0xFF0EA5E9);

class MoratoriumManagerTab extends ConsumerWidget {
  const MoratoriumManagerTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    final progress = LoanCalculator.moratoriumProgress(loan.courseEndDate, loan.moratoriumMonths);
    final daysRemaining = LoanCalculator.moratoriumDaysRemaining(loan.courseEndDate, loan.moratoriumMonths);
    final morEnd = loan.moratoriumEndDate;
    final emiStart = loan.computedEmiStartDate;
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final fmt = DateFormat('dd MMM yyyy');

    final isInMoratorium = loan.courseEndDate != null &&
        DateTime.now().isAfter(loan.courseEndDate!) &&
        daysRemaining > 0;

    final isMoratoriumOver = morEnd != null && DateTime.now().isAfter(morEnd);
    final isBeforeCourse = loan.courseEndDate == null || DateTime.now().isBefore(loan.courseEndDate!);

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        // Hero status
        _buildHeroCard(isInMoratorium, isMoratoriumOver, isBeforeCourse, daysRemaining, progress, loan.moratoriumMonths),
        const SizedBox(height: 20),

        // Dates overview
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Dates', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              if (loan.courseStartDate != null)
                _dateRow('Course Start', fmt.format(loan.courseStartDate!), Icons.play_circle_outline_rounded, AppColors.darkPrimary),
              if (loan.courseEndDate != null)
                _dateRow('Course End / Moratorium Start', fmt.format(loan.courseEndDate!), Icons.emoji_events_outlined, AppColors.darkSuccess),
              if (morEnd != null)
                _dateRow(
                  'Moratorium End',
                  fmt.format(morEnd),
                  Icons.hourglass_bottom_rounded,
                  isInMoratorium ? AppColors.darkWarning : (isMoratoriumOver ? AppColors.darkSuccess : AppColors.grey500),
                ),
              if (emiStart != null)
                _dateRow('EMI Start Date', fmt.format(emiStart), Icons.payments_outlined, _eduBlue),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // What happens post moratorium
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Post-Moratorium Impact', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              _impactItem(
                'Outstanding at EMI Start',
                currency.format(state.totalDisbursed +
                    LoanCalculator.accruedInterestToDate(
                      disbursements: state.disbursements,
                      annualRatePct: loan.interestRate,
                      asOfDate: emiStart ?? DateTime.now(),
                    )),
                AppColors.darkDanger,
              ),
              _impactItem(
                'Interest Accrued in Moratorium',
                currency.format(LoanCalculator.accruedInterestToDate(
                  disbursements: state.disbursements,
                  annualRatePct: loan.interestRate,
                  asOfDate: morEnd ?? DateTime.now(),
                )),
                AppColors.darkWarning,
              ),
              if (loan.expectedEmi != null)
                _impactItem('Expected Monthly EMI', currency.format(loan.expectedEmi!), _eduBlue),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Tips
        GlassCard(
          borderColor: AppColors.darkPrimary.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.darkPrimary),
                  const SizedBox(width: 8),
                  Text('Smart Tips', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 12),
              _tip('Pay interest during moratorium to reduce your outstanding balance significantly.'),
              _tip('Set up a recurring SIP in Worth to build an EMI fund during moratorium.'),
              _tip('Consider prepaying a lump sum at moratorium end to reduce EMI tenure.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(bool inMoratorium, bool over, bool before, int daysLeft, double progress, int totalMonths) {
    Color statusColor;
    String statusTitle;
    String statusSubtitle;
    IconData statusIcon;

    if (before) {
      statusColor = AppColors.darkPrimary;
      statusTitle = 'In Study Phase';
      statusSubtitle = 'Moratorium will start after course completion';
      statusIcon = Icons.school_outlined;
    } else if (inMoratorium) {
      statusColor = AppColors.darkWarning;
      statusTitle = 'Moratorium Active';
      statusSubtitle = '$daysLeft days remaining before EMI begins';
      statusIcon = Icons.hourglass_empty_rounded;
    } else if (over) {
      statusColor = AppColors.darkSuccess;
      statusTitle = 'Repayment Phase';
      statusSubtitle = 'Moratorium ended · EMI payments active';
      statusIcon = Icons.check_circle_outline_rounded;
    } else {
      statusColor = AppColors.grey500;
      statusTitle = 'Status Unknown';
      statusSubtitle = 'Set course end date to track moratorium';
      statusIcon = Icons.help_outline_rounded;
    }

    return GlassCard(
      gradientColors: [statusColor.withOpacity(0.12), AppColors.darkBackground],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withOpacity(0.15),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Icon(statusIcon, size: 24, color: statusColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusTitle, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(statusSubtitle, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          if (inMoratorium) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moratorium Progress', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.w600)),
                Text('${(progress * 100).toStringAsFixed(0)}%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.08),
                color: statusColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * totalMonths).toStringAsFixed(1)} of $totalMonths months completed',
              style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dateRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400))),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _impactItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
          Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _tip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(color: AppColors.darkPrimary, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400, height: 1.4))),
        ],
      ),
    );
  }
}
