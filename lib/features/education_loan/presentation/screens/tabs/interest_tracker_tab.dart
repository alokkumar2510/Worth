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

class InterestTrackerTab extends ConsumerWidget {
  const InterestTrackerTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final currencyFull = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');

    final totalDisbursed = state.totalDisbursed;
    final accrued = LoanCalculator.accruedInterestToDate(
      disbursements: state.disbursements,
      annualRatePct: loan.interestRate,
    );

    final dailyRate = totalDisbursed * loan.interestRate / 100 / 365;
    final monthlyRate = dailyRate * 30;

    final records = [...state.interestRecords]..sort((a, b) => b.date.compareTo(a.date));
    final totalRecorded = records.fold(0.0, (s, r) => s + r.interestAmount);

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        // Total accrued hero
        GlassCard(
          gradientColors: [AppColors.darkDanger.withOpacity(0.15), AppColors.darkBackground],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.darkDanger),
                  const SizedBox(width: 6),
                  Text('TOTAL INTEREST ACCRUED', style: _labelStyle),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currencyFull.format(accrued),
                style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.darkDanger),
              ),
              const SizedBox(height: 4),
              Text(
                'Calculated on ${currency.format(totalDisbursed)} principal @ ${loan.interestRate}% p.a.',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Rate breakdown
        Row(
          children: [
            Expanded(child: _rateCard('Per Day', currencyFull.format(dailyRate), Icons.today_outlined, AppColors.darkWarning)),
            const SizedBox(width: 10),
            Expanded(child: _rateCard('Per Month', currency.format(monthlyRate), Icons.calendar_month_outlined, _eduBlue)),
            const SizedBox(width: 10),
            Expanded(child: _rateCard('Per Year', currency.format(monthlyRate * 12), Icons.calendar_today_outlined, AppColors.darkSuccess)),
          ],
        ),
        const SizedBox(height: 24),

        // Add interest record button
        GestureDetector(
          onTap: () => _showAddInterestSheet(context, ref, loan),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.darkDanger.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkDanger.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.darkDanger),
                const SizedBox(width: 8),
                Text('Log Interest Record', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkDanger)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (records.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('INTEREST HISTORY', style: _labelStyle),
              Text('Total: ${currencyFull.format(totalRecorded)}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
            ],
          ),
          const SizedBox(height: 12),
          ...records.map((r) => _buildRecordCard(r, currencyFull, ref, context)),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'No interest records logged yet.\nAdd records to track historical accruals.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500, height: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _rateCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 3),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
        ],
      ),
    );
  }

  Widget _buildRecordCard(LoanInterestRecord r, NumberFormat currency, WidgetRef ref, BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.darkDanger.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.darkDanger),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd MMM yyyy').format(r.date), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('${r.daysAccrued} days @ ${r.rateAtDate}% on ₹${NumberFormat.compactCurrency(symbol: '').format(r.principalAtDate)}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currency.format(r.interestAmount), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkDanger)),
              IconButton(
                onPressed: () => ref.read(educationLoanProvider.notifier).deleteInterestRecord(r.id),
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.grey500),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddInterestSheet(BuildContext context, WidgetRef ref, EducationLoan loan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.layer2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _AddInterestSheet(loan: loan),
    );
  }
}

class _AddInterestSheet extends ConsumerStatefulWidget {
  final EducationLoan loan;
  const _AddInterestSheet({required this.loan});

  @override
  ConsumerState<_AddInterestSheet> createState() => _AddInterestSheetState();
}

class _AddInterestSheetState extends ConsumerState<_AddInterestSheet> {
  final _principalCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  double _computed = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rateCtrl.text = widget.loan.interestRate.toStringAsFixed(2);
    final state = ref.read(educationLoanProvider);
    _principalCtrl.text = state.totalDisbursed.toStringAsFixed(0);
    _principalCtrl.addListener(_recompute);
    _daysCtrl.addListener(_recompute);
    _rateCtrl.addListener(_recompute);
  }

  void _recompute() {
    final p = double.tryParse(_principalCtrl.text) ?? 0;
    final d = int.tryParse(_daysCtrl.text) ?? 0;
    final r = double.tryParse(_rateCtrl.text) ?? 0;
    setState(() => _computed = LoanCalculator.dailySimpleInterest(p, r, d));
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _daysCtrl.dispose();
    _rateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final r = LoanInterestRecord(
        loanId: widget.loan.id,
        date: _date,
        principalAtDate: double.tryParse(_principalCtrl.text) ?? 0,
        rateAtDate: double.tryParse(_rateCtrl.text) ?? 0,
        daysAccrued: int.tryParse(_daysCtrl.text) ?? 0,
        interestAmount: _computed,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
      );
      await ref.read(educationLoanProvider.notifier).addInterestRecord(r);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.darkDanger));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Interest Record', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            _tf('Principal (₹)', _principalCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _tf('Days Accrued', _daysCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _tf('Rate (%)', _rateCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 10),
            _tf('Notes', _notesCtrl),
            const SizedBox(height: 16),
            if (_computed > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.darkDanger.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Computed Interest:', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
                    Text(currency.format(_computed), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkDanger)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(_saving ? 'Saving...' : 'Log Record', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(String label, TextEditingController ctrl, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.glassSurface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.darkDanger)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

TextStyle get _labelStyle => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0);
