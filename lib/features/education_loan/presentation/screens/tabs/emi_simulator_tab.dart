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

class EmiSimulatorTab extends ConsumerStatefulWidget {
  const EmiSimulatorTab({super.key});

  @override
  ConsumerState<EmiSimulatorTab> createState() => _EmiSimulatorTabState();
}

class _EmiSimulatorTabState extends ConsumerState<EmiSimulatorTab> {
  double _principal = 0;
  double _rate = 8.5;
  double _emi = 0;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    if (!_initialized) {
      _principal = state.totalDisbursed > 0 ? state.totalDisbursed : loan.sanctionedAmount;
      _rate = loan.interestRate;
      // Default EMI = minimum for 120 months
      _emi = LoanCalculator.calculateEmi(_principal, _rate, 120);
      _initialized = true;
    }

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final currFull = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    final result = LoanCalculator.emiSimulationResult(
      principal: _principal,
      annualRatePct: _rate,
      emiAmount: _emi,
      startDate: loan.computedEmiStartDate,
    );

    final minEmi = LoanCalculator.calculateEmi(_principal, _rate, 180);
    final maxEmi = _principal * 0.1; // 10% of principal

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        Text('EMI Simulator', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text('Adjust sliders to simulate different repayment scenarios', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
        const SizedBox(height: 20),

        // Result hero
        GlassCard(
          gradientColors: [_eduBlue.withOpacity(0.15), AppColors.darkBackground],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _resultBlock('Monthly EMI', currFull.format(_emi), _eduBlue)),
                  Container(width: 1, height: 50, color: AppColors.glassBorder),
                  Expanded(child: _resultBlock('Total Interest', currency.format(result.totalInterest), AppColors.darkDanger)),
                  Container(width: 1, height: 50, color: AppColors.glassBorder),
                  Expanded(child: _resultBlock('Total Paid', currency.format(result.totalRepayment), AppColors.darkWarning)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.glassBorder),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loan Tenure', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                      Text('${result.months} months (${(result.months / 12).toStringAsFixed(1)} yrs)', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Closure Date', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                      Text(DateFormat('MMM yyyy').format(result.closureDate), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkSuccess)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Sliders
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Simulation Parameters', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),

              // Principal
              _sliderSection(
                label: 'Outstanding Principal',
                value: currency.format(_principal),
                child: Slider(
                  value: _principal.clamp(10000, loan.sanctionedAmount * 1.5),
                  min: 10000,
                  max: loan.sanctionedAmount * 1.5,
                  divisions: 100,
                  activeColor: _eduBlue,
                  inactiveColor: _eduBlue.withOpacity(0.15),
                  onChanged: (v) {
                    setState(() {
                      _principal = v;
                      _emi = LoanCalculator.calculateEmi(_principal, _rate, 120);
                    });
                  },
                ),
              ),

              const Divider(color: AppColors.glassBorder),

              // Interest Rate
              _sliderSection(
                label: 'Interest Rate',
                value: '${_rate.toStringAsFixed(2)}% p.a.',
                child: Slider(
                  value: _rate,
                  min: 5.0,
                  max: 18.0,
                  divisions: 130,
                  activeColor: AppColors.darkWarning,
                  inactiveColor: AppColors.darkWarning.withOpacity(0.15),
                  onChanged: (v) {
                    setState(() {
                      _rate = v;
                      _emi = LoanCalculator.calculateEmi(_principal, _rate, 120);
                    });
                  },
                ),
              ),

              const Divider(color: AppColors.glassBorder),

              // EMI
              _sliderSection(
                label: 'Monthly EMI',
                value: currency.format(_emi),
                child: Slider(
                  value: _emi.clamp(minEmi, maxEmi.clamp(minEmi + 1, double.infinity)),
                  min: minEmi,
                  max: maxEmi.clamp(minEmi + 1, double.infinity),
                  divisions: 100,
                  activeColor: AppColors.darkSuccess,
                  inactiveColor: AppColors.darkSuccess.withOpacity(0.15),
                  onChanged: (v) => setState(() => _emi = v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Save simulation button
        GestureDetector(
          onTap: () => _saveSimulation(loan, result),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: _eduBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _eduBlue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bookmark_outline_rounded, size: 18, color: _eduBlue),
                const SizedBox(width: 8),
                Text('Save This Simulation', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: _eduBlue)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Saved simulations
        if (state.emiSimulations.isNotEmpty) ...[
          Text('SAVED SIMULATIONS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          ...state.emiSimulations.map((s) => _savedSimCard(s, currency)),
        ],
      ],
    );
  }

  Widget _resultBlock(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 5),
          Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _sliderSection({required String label, required String value, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
              Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
        child,
      ],
    );
  }

  Widget _savedSimCard(EmiSimulation s, NumberFormat currency) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.label ?? DateFormat('dd MMM yyyy').format(s.savedAt), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('${currency.format(s.emiAmount)}/mo · Closes ${DateFormat('MMM yyyy').format(s.closureDate)}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(s.totalInterest), style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkDanger)),
              Text('interest', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveSimulation(EducationLoan loan,
      ({DateTime closureDate, double totalInterest, double totalRepayment, int months}) result) async {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final sim = EmiSimulation(
      loanId: loan.id,
      outstanding: _principal,
      interestRate: _rate,
      emiAmount: _emi,
      closureDate: result.closureDate,
      totalInterest: result.totalInterest,
      totalRepayment: result.totalRepayment,
      label: '${currency.format(_emi)}/mo · ${_rate.toStringAsFixed(1)}%',
    );
    await ref.read(educationLoanProvider.notifier).saveEmiSimulation(sim);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulation saved'), backgroundColor: AppColors.darkSuccess),
      );
    }
  }
}
