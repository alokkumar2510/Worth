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

class PrepaymentPlannerTab extends ConsumerStatefulWidget {
  const PrepaymentPlannerTab({super.key});

  @override
  ConsumerState<PrepaymentPlannerTab> createState() => _PrepaymentPlannerTabState();
}

class _PrepaymentPlannerTabState extends ConsumerState<PrepaymentPlannerTab> {
  double _extraPayment = 5000;
  String _frequency = 'monthly';
  bool _initialized = false;
  double _regularEmi = 0;
  double _principal = 0;
  double _rate = 8.5;

  static const _frequencies = [
    ('Monthly', 'monthly'),
    ('Quarterly', 'quarterly'),
    ('Yearly', 'yearly'),
    ('One-Time', 'onetime'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    if (!_initialized) {
      _principal = state.totalDisbursed > 0 ? state.totalDisbursed : loan.sanctionedAmount;
      _rate = loan.interestRate;
      _regularEmi = loan.expectedEmi ?? LoanCalculator.calculateEmi(_principal, _rate, 120);
      _initialized = true;
    }

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

    final result = LoanCalculator.prepaymentImpact(
      principal: _principal,
      annualRatePct: _rate,
      regularEmi: _regularEmi,
      extraPayment: _extraPayment,
      frequency: _frequency,
      startDate: loan.computedEmiStartDate,
    );

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        Text('Prepayment Planner', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('See how extra payments can close your loan faster', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
        const SizedBox(height: 20),

        // Impact result
        GlassCard(
          gradientColors: [AppColors.darkSuccess.withOpacity(0.15), AppColors.darkBackground],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flash_on_rounded, size: 20, color: AppColors.darkSuccess),
                  const SizedBox(width: 8),
                  Text('Prepayment Impact', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _impactBox('Interest Saved', currency.format(result.interestSaved), AppColors.darkSuccess, Icons.savings_outlined),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _impactBox('Months Saved', '${result.monthsSaved} months', _eduBlue, Icons.schedule_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.glassBorder),
              const SizedBox(height: 12),
              _compareRow('Without Prepayment', DateFormat('MMM yyyy').format(result.baseClosureDate), currency.format(result.baseTotalInterest)),
              const SizedBox(height: 8),
              _compareRow('With Prepayment', DateFormat('MMM yyyy').format(result.newClosureDate), currency.format(result.newTotalInterest), isGood: true),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Parameters
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prepayment Setup', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),

              // Extra payment slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Extra Payment', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
                  Text(currency.format(_extraPayment), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              Slider(
                value: _extraPayment,
                min: 1000,
                max: _regularEmi * 3,
                divisions: 100,
                activeColor: AppColors.darkSuccess,
                inactiveColor: AppColors.darkSuccess.withOpacity(0.15),
                onChanged: (v) => setState(() => _extraPayment = v),
              ),

              const Divider(color: AppColors.glassBorder),

              // Regular EMI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Regular EMI', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
                  Text(currency.format(_regularEmi), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              Slider(
                value: _regularEmi,
                min: LoanCalculator.calculateEmi(_principal, _rate, 180),
                max: _principal * 0.1,
                divisions: 100,
                activeColor: _eduBlue,
                inactiveColor: _eduBlue.withOpacity(0.15),
                onChanged: (v) => setState(() => _regularEmi = v),
              ),

              const Divider(color: AppColors.glassBorder),
              const SizedBox(height: 8),

              // Frequency
              Text('Payment Frequency', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: _frequencies.map((f) {
                  final isSelected = f.$2 == _frequency;
                  return ChoiceChip(
                    label: Text(f.$1),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _frequency = f.$2),
                    selectedColor: AppColors.darkSuccess.withOpacity(0.2),
                    backgroundColor: AppColors.glassSurface,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.darkSuccess : AppColors.grey400,
                    ),
                    side: BorderSide(color: isSelected ? AppColors.darkSuccess.withOpacity(0.4) : AppColors.glassBorder),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Save button
        GestureDetector(
          onTap: () => _saveSimulation(loan, result),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.darkSuccess.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkSuccess.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_outline_rounded, size: 18, color: AppColors.darkSuccess),
                const SizedBox(width: 8),
                Text('Save This Plan', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkSuccess)),
              ],
            ),
          ),
        ),

        // Saved sims
        if (state.prepaymentSimulations.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('SAVED PLANS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          ...state.prepaymentSimulations.map((s) => _savedPlanCard(s, currency)),
        ],
      ],
    );
  }

  Widget _impactBox(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
        ],
      ),
    );
  }

  Widget _compareRow(String label, String date, String interest, {bool isGood = false}) {
    return Row(
      children: [
        Icon(
          isGood ? Icons.trending_down_rounded : Icons.trending_flat_rounded,
          size: 16,
          color: isGood ? AppColors.darkSuccess : AppColors.grey500,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: isGood ? Colors.white : AppColors.grey400, fontWeight: isGood ? FontWeight.w600 : FontWeight.normal))),
        Text('$date · $interest', style: GoogleFonts.inter(fontSize: 12, color: isGood ? AppColors.darkSuccess : AppColors.grey500, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _savedPlanCard(PrepaymentSimulation s, NumberFormat currency) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${currency.format(s.extraPayment)} extra · ${s.frequency}', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('Saved ${s.monthsSaved} months', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400)),
              ],
            ),
          ),
          Text(currency.format(s.interestSaved), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkSuccess)),
        ],
      ),
    );
  }

  Future<void> _saveSimulation(EducationLoan loan,
    ({
      DateTime baseClosureDate,
      DateTime newClosureDate,
      double interestSaved,
      int monthsSaved,
      double baseTotalInterest,
      double newTotalInterest,
    }) result) async {
    final sim = PrepaymentSimulation(
      loanId: loan.id,
      outstanding: _principal,
      interestRate: _rate,
      regularEmi: _regularEmi,
      extraPayment: _extraPayment,
      frequency: _frequency,
      baseClosureDate: result.baseClosureDate,
      newClosureDate: result.newClosureDate,
      interestSaved: result.interestSaved,
      monthsSaved: result.monthsSaved,
    );
    await ref.read(educationLoanProvider.notifier).savePrepaymentSimulation(sim);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prepayment plan saved'), backgroundColor: AppColors.darkSuccess),
      );
    }
  }
}
