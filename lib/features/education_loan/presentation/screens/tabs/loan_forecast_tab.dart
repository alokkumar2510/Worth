import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../providers/education_loan_provider.dart';
import '../../../domain/services/loan_calculator.dart';
import '../../../domain/entities/education_loan.dart';

const _eduBlue = Color(0xFF0EA5E9);

class LoanForecastTab extends ConsumerWidget {
  const LoanForecastTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final points = LoanCalculator.generateForecast(
      loan: loan,
      disbursements: state.disbursements,
      forecastYears: 10,
    );

    if (points.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_outlined, size: 56, color: AppColors.grey700),
              const SizedBox(height: 16),
              Text('No Forecast Available', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Add at least one disbursement to generate a loan forecast.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400, height: 1.4), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    final maxOutstanding = points.fold(0.0, (m, p) => p.outstanding > m ? p.outstanding : m);

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        Text('Loan Forecast', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Projected outstanding balance at key milestones', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
        const SizedBox(height: 20),

        // Visual bar chart (custom, no dependencies)
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bar_chart_rounded, size: 16, color: _eduBlue),
                  const SizedBox(width: 6),
                  Text('Outstanding Balance Projection', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: _buildBarChart(points, maxOutstanding, currency),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Milestone cards
        Text('MILESTONE BREAKDOWN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0)),
        const SizedBox(height: 12),
        ...points.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final isClosed = p.outstanding == 0;
          final color = isClosed ? AppColors.darkSuccess : (i == 0 ? _eduBlue : AppColors.darkWarning);

          return GlassCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(isClosed ? Icons.check_circle_rounded : Icons.timeline_rounded, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.label, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text(DateFormat('MMM yyyy').format(p.date), style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isClosed ? 'DEBT FREE' : currency.format(p.outstanding),
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(
                      '+${currency.format(p.totalInterestAccrued)} interest',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBarChart(List<LoanForecastPoint> points, double maxOutstanding, NumberFormat currency) {
    if (maxOutstanding == 0) return const SizedBox();
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - (points.length - 1) * 8) / points.length;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: points.map((p) {
            final ratio = maxOutstanding > 0 ? (p.outstanding / maxOutstanding).clamp(0.0, 1.0).toDouble() : 0.0;
            final isClosed = p.outstanding == 0;
            final color = isClosed ? AppColors.darkSuccess : (ratio > 0.7 ? AppColors.darkDanger : (ratio > 0.3 ? AppColors.darkWarning : AppColors.darkSuccess));

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isClosed)
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.darkSuccess,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    else
                      Container(
                        height: (140.0 * (ratio > 0 ? ratio : 0.02)).toDouble(),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [color.withOpacity(0.9), color.withOpacity(0.4)],
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      p.label.split(' ').first,
                      style: GoogleFonts.inter(fontSize: 8, color: AppColors.grey500),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
