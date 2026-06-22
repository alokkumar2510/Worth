import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../providers/education_loan_provider.dart';
import '../../../domain/entities/education_loan.dart';

const _eduBlue = Color(0xFF0EA5E9);

class LoanTimelineTab extends ConsumerWidget {
  const LoanTimelineTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    final milestones = _buildMilestones(loan, state);
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final now = DateTime.now();

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        Text(
          'Loan Timeline',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          '${loan.courseName} · ${loan.lenderName}',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400),
        ),
        const SizedBox(height: 24),
        ...milestones.asMap().entries.map((entry) {
          final idx = entry.key;
          final m = entry.value;
          final isLast = idx == milestones.length - 1;
          final isPast = now.isAfter(m.date);
          final isCurrent = !isPast && (idx == 0 || now.isAfter(milestones[idx - 1].date));

          return _buildTimelineItem(
            milestone: m,
            isLast: isLast,
            isPast: isPast,
            isCurrent: isCurrent,
            currency: currency,
          );
        }),
      ],
    );
  }

  List<_Milestone> _buildMilestones(EducationLoan loan, EducationLoanState state) {
    final fmt = DateFormat('dd MMM yyyy');
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final milestones = <_Milestone>[];

    // 1. Sanction Date
    milestones.add(_Milestone(
      date: loan.sanctionDate,
      title: 'Loan Sanctioned',
      subtitle: 'Amount: ${currency.format(loan.sanctionedAmount)} @ ${loan.interestRate}% p.a.',
      icon: Icons.check_circle_outline_rounded,
      color: _eduBlue,
      type: _MilestoneType.sanction,
    ));

    // 2. Course Start
    if (loan.courseStartDate != null) {
      milestones.add(_Milestone(
        date: loan.courseStartDate!,
        title: 'Course Started',
        subtitle: loan.courseName,
        icon: Icons.school_outlined,
        color: AppColors.darkPrimary,
        type: _MilestoneType.courseStart,
      ));
    }

    // 3. Disbursements
    for (final d in state.disbursements..sort((a, b) => a.date.compareTo(b.date))) {
      milestones.add(_Milestone(
        date: d.date,
        title: 'Disbursement — ${d.semester}',
        subtitle: '${currency.format(d.amount)} · ${d.purpose}',
        icon: Icons.account_balance_outlined,
        color: _eduBlue,
        type: _MilestoneType.disbursement,
      ));
    }

    // 4. Course End
    if (loan.courseEndDate != null) {
      milestones.add(_Milestone(
        date: loan.courseEndDate!,
        title: 'Course Completed',
        subtitle: 'Moratorium period begins (${loan.moratoriumMonths} months)',
        icon: Icons.emoji_events_outlined,
        color: AppColors.darkSuccess,
        type: _MilestoneType.courseEnd,
      ));
    }

    // 5. Moratorium End / EMI Start
    final morEnd = loan.moratoriumEndDate;
    if (morEnd != null) {
      milestones.add(_Milestone(
        date: morEnd,
        title: 'Moratorium Ends',
        subtitle: 'EMI repayment begins',
        icon: Icons.payments_outlined,
        color: AppColors.darkWarning,
        type: _MilestoneType.moratoriumEnd,
      ));
    }

    // 6. Interest records
    for (final r in state.interestRecords..sort((a, b) => a.date.compareTo(b.date))) {
      milestones.add(_Milestone(
        date: r.date,
        title: 'Interest Logged',
        subtitle: '${currency.format(r.interestAmount)} for ${r.daysAccrued} days @ ${r.rateAtDate}%',
        icon: Icons.trending_up_outlined,
        color: AppColors.darkDanger,
        type: _MilestoneType.interest,
      ));
    }

    // Sort by date
    milestones.sort((a, b) => a.date.compareTo(b.date));
    return milestones;
  }

  Widget _buildTimelineItem({
    required _Milestone milestone,
    required bool isLast,
    required bool isPast,
    required bool isCurrent,
    required NumberFormat currency,
  }) {
    final nodeColor = isPast
        ? milestone.color
        : isCurrent
            ? milestone.color.withOpacity(0.7)
            : AppColors.grey700;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nodeColor.withOpacity(0.15),
                    border: Border.all(
                      color: isCurrent ? milestone.color : nodeColor,
                      width: isCurrent ? 2 : 1,
                    ),
                    boxShadow: isCurrent
                        ? [BoxShadow(color: milestone.color.withOpacity(0.4), blurRadius: 12)]
                        : null,
                  ),
                  child: Icon(
                    milestone.icon,
                    size: 14,
                    color: isCurrent ? milestone.color : nodeColor,
                  ),
                ),
                // Connector
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isPast ? AppColors.grey700 : AppColors.grey700.withOpacity(0.4),
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          milestone.title,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isPast || isCurrent ? Colors.white : AppColors.grey500,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: milestone.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'NOW',
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: milestone.color),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    milestone.subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(milestone.date),
                    style: GoogleFonts.inter(fontSize: 11, color: isPast ? milestone.color.withOpacity(0.7) : AppColors.grey700, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MilestoneType { sanction, courseStart, courseEnd, disbursement, interest, moratoriumEnd }

class _Milestone {
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final _MilestoneType type;

  const _Milestone({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.type,
  });
}
