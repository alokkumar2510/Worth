import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../providers/education_loan_provider.dart';
import '../../../domain/entities/education_loan.dart';

const _eduBlue = Color(0xFF0EA5E9);

class SemesterExpenseTab extends ConsumerStatefulWidget {
  const SemesterExpenseTab({super.key});

  @override
  ConsumerState<SemesterExpenseTab> createState() => _SemesterExpenseTabState();
}

class _SemesterExpenseTabState extends ConsumerState<SemesterExpenseTab> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final semesters = [...state.semesterExpenses]..sort((a, b) => a.semesterName.compareTo(b.semesterName));

    final totalCost = semesters.fold(0.0, (s, e) => s + e.totalCost);
    final totalLoan = semesters.fold(0.0, (s, e) => s + e.loanAmountUsed);
    final totalSelf = semesters.fold(0.0, (s, e) => s + e.selfFundedAmount);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          // Summary
          GlassCard(
            gradientColors: [AppColors.darkPrimary.withOpacity(0.12), AppColors.darkBackground],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 16, color: AppColors.darkPrimary),
                    const SizedBox(width: 6),
                    Text('TOTAL EDUCATION COST', style: _labelStyle),
                  ],
                ),
                const SizedBox(height: 8),
                Text(currency.format(totalCost), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _miniStat('Loan Funded', currency.format(totalLoan), _eduBlue)),
                    Expanded(child: _miniStat('Self Funded', currency.format(totalSelf), AppColors.darkSuccess)),
                    Expanded(child: _miniStat('Semesters', '${semesters.length}', AppColors.darkPrimary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (semesters.isEmpty)
            _emptyState(context)
          else ...[
            Text('SEMESTER BREAKDOWN', style: _labelStyle),
            const SizedBox(height: 12),
            ...semesters.map((s) => _semesterCard(s, currency, context)),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, null, loan),
        backgroundColor: AppColors.darkPrimary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Semester', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: 56, color: AppColors.darkPrimary.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No Semester Data', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Track expenses for each semester — tuition, hostel, books, and more.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400, height: 1.4), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _semesterCard(SemesterExpense s, NumberFormat currency, BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s.semesterName, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkPrimary)),
              ),
              const Spacer(),
              Text(currency.format(s.totalCost), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),

          // Breakdown rows
          if (s.tuitionFees > 0) _expRow('Tuition', currency.format(s.tuitionFees)),
          if (s.hostelFees > 0) _expRow('Hostel', currency.format(s.hostelFees)),
          if (s.booksCost > 0) _expRow('Books & Materials', currency.format(s.booksCost)),
          if (s.otherCosts > 0) _expRow('Other', currency.format(s.otherCosts)),

          if (s.totalCost > 0) ...[
            const Divider(color: AppColors.glassBorder, height: 16),
            Row(
              children: [
                _fundingBadge('Loan', currency.format(s.loanAmountUsed), _eduBlue),
                const SizedBox(width: 8),
                _fundingBadge('Self', currency.format(s.selfFundedAmount), AppColors.darkSuccess),
              ],
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAddSheet(context, s, ref.read(educationLoanProvider).loan!),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.grey400,
                    side: const BorderSide(color: AppColors.glassBorder),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(educationLoanProvider.notifier).deleteSemesterExpense(s.id),
                  icon: const Icon(Icons.delete_outline_rounded, size: 14),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkDanger,
                    side: BorderSide(color: AppColors.darkDanger.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _expRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _fundingBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text('$label: $value', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  void _showAddSheet(BuildContext context, SemesterExpense? existing, EducationLoan loan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.layer2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _SemesterSheet(existing: existing, loan: loan),
    );
  }
}

class _SemesterSheet extends ConsumerStatefulWidget {
  final SemesterExpense? existing;
  final EducationLoan loan;
  const _SemesterSheet({this.existing, required this.loan});

  @override
  ConsumerState<_SemesterSheet> createState() => _SemesterSheetState();
}

class _SemesterSheetState extends ConsumerState<_SemesterSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _tuitionCtrl;
  late TextEditingController _hostelCtrl;
  late TextEditingController _booksCtrl;
  late TextEditingController _otherCtrl;
  late TextEditingController _loanCtrl;
  late TextEditingController _selfCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.semesterName ?? '');
    _tuitionCtrl = TextEditingController(text: e?.tuitionFees.toStringAsFixed(0) ?? '');
    _hostelCtrl = TextEditingController(text: e?.hostelFees.toStringAsFixed(0) ?? '');
    _booksCtrl = TextEditingController(text: e?.booksCost.toStringAsFixed(0) ?? '');
    _otherCtrl = TextEditingController(text: e?.otherCosts.toStringAsFixed(0) ?? '');
    _loanCtrl = TextEditingController(text: e?.loanAmountUsed.toStringAsFixed(0) ?? '');
    _selfCtrl = TextEditingController(text: e?.selfFundedAmount.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _tuitionCtrl.dispose(); _hostelCtrl.dispose();
    _booksCtrl.dispose(); _otherCtrl.dispose(); _loanCtrl.dispose(); _selfCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final s = SemesterExpense(
        id: widget.existing?.id,
        loanId: widget.loan.id,
        semesterName: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Semester',
        tuitionFees: _parse(_tuitionCtrl),
        hostelFees: _parse(_hostelCtrl),
        booksCost: _parse(_booksCtrl),
        otherCosts: _parse(_otherCtrl),
        loanAmountUsed: _parse(_loanCtrl),
        selfFundedAmount: _parse(_selfCtrl),
        createdAt: widget.existing?.createdAt,
      );
      if (widget.existing == null) {
        await ref.read(educationLoanProvider.notifier).addSemesterExpense(s);
      } else {
        await ref.read(educationLoanProvider.notifier).updateSemesterExpense(s);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.darkDanger));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? 'Add Semester' : 'Edit Semester',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            _tf('Semester Name', _nameCtrl, hint: 'e.g. Semester 3 or Year 2'),
            const SizedBox(height: 10),
            _tf('Tuition Fees (₹)', _tuitionCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _tf('Hostel Fees (₹)', _hostelCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _tf('Books & Materials (₹)', _booksCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _tf('Other Expenses (₹)', _otherCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _tf('Loan Amount Used (₹)', _loanCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _tf('Self Funded Amount (₹)', _selfCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(_saving ? 'Saving...' : (widget.existing == null ? 'Add Semester' : 'Update'),
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(String label, TextEditingController ctrl, {TextInputType? keyboardType, String? hint}) {
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
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500),
            filled: true,
            fillColor: AppColors.glassSurface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.darkPrimary)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

TextStyle get _labelStyle => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0);
