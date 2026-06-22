import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../providers/education_loan_provider.dart';
import '../../../domain/entities/education_loan.dart';

const _eduBlue = Color(0xFF0EA5E9);

class DisbursementTrackerTab extends ConsumerStatefulWidget {
  const DisbursementTrackerTab({super.key});

  @override
  ConsumerState<DisbursementTrackerTab> createState() => _DisbursementTrackerTabState();
}

class _DisbursementTrackerTabState extends ConsumerState<DisbursementTrackerTab> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final disbursements = [...state.disbursements]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        children: [
          // Summary card
          GlassCard(
            gradientColors: [_eduBlue.withOpacity(0.15), AppColors.darkBackground],
            child: Row(
              children: [
                Expanded(
                  child: _summaryTile('Total Disbursed', currency.format(state.totalDisbursed), _eduBlue),
                ),
                Container(width: 1, height: 40, color: AppColors.glassBorder),
                Expanded(
                  child: _summaryTile('Remaining', currency.format(state.remainingEligible), AppColors.darkSuccess),
                ),
                Container(width: 1, height: 40, color: AppColors.glassBorder),
                Expanded(
                  child: _summaryTile('Count', '${disbursements.length}', AppColors.darkPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (disbursements.isEmpty)
            _buildEmptyState(context)
          else ...[
            Text(
              'DISBURSEMENT HISTORY',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
            ),
            const SizedBox(height: 12),
            ...disbursements.map((d) => _buildDisbursementCard(d, currency, loan)),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        backgroundColor: _eduBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Disbursement', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _summaryTile(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.account_balance_outlined, size: 56, color: _eduBlue.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No Disbursements Yet', style: GoogleFonts.outfit(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Add disbursements each time funds are released for a semester.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddSheet(context),
            icon: const Icon(Icons.add, size: 18),
            label: Text('Add First Disbursement', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _eduBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisbursementCard(LoanDisbursement d, NumberFormat currency, EducationLoan loan) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _eduBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.payments_outlined, size: 20, color: _eduBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.semester, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(d.purpose, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currency.format(d.amount), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: _eduBlue)),
                  Text(DateFormat('dd MMM yyyy').format(d.date), style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                ],
              ),
            ],
          ),
          if (d.notes != null && d.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.glassBorder, height: 1),
            const SizedBox(height: 8),
            Text(d.notes!, style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditSheet(context, d),
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
                  onPressed: () => _confirmDelete(context, d),
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

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.layer2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => const _DisbursementSheet(),
    );
  }

  void _showEditSheet(BuildContext context, LoanDisbursement d) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.layer2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _DisbursementSheet(existing: d),
    );
  }

  void _confirmDelete(BuildContext context, LoanDisbursement d) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.layer2,
        title: Text('Delete Disbursement?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('This will remove the ${DateFormat('dd MMM yyyy').format(d.date)} disbursement of ₹${d.amount.toStringAsFixed(0)}.', style: GoogleFonts.inter(color: AppColors.grey400)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.grey500))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(educationLoanProvider.notifier).deleteDisbursement(d.id);
            },
            child: Text('Delete', style: GoogleFonts.inter(color: AppColors.darkDanger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Reusable disbursement form sheet
class _DisbursementSheet extends ConsumerStatefulWidget {
  final LoanDisbursement? existing;
  const _DisbursementSheet({this.existing});

  @override
  ConsumerState<_DisbursementSheet> createState() => _DisbursementSheetState();
}

class _DisbursementSheetState extends ConsumerState<_DisbursementSheet> {
  late TextEditingController _amountCtrl;
  late TextEditingController _semesterCtrl;
  late TextEditingController _purposeCtrl;
  late TextEditingController _notesCtrl;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(text: widget.existing?.amount.toStringAsFixed(0) ?? '');
    _semesterCtrl = TextEditingController(text: widget.existing?.semester ?? '');
    _purposeCtrl = TextEditingController(text: widget.existing?.purpose ?? '');
    _notesCtrl = TextEditingController(text: widget.existing?.notes ?? '');
    _date = widget.existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _semesterCtrl.dispose();
    _purposeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final state = ref.read(educationLoanProvider);
    if (state.loan == null || _amountCtrl.text.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      final d = LoanDisbursement(
        id: widget.existing?.id,
        loanId: state.loan!.id,
        date: _date,
        semester: _semesterCtrl.text.trim().isNotEmpty ? _semesterCtrl.text.trim() : 'Semester',
        amount: double.parse(_amountCtrl.text.trim()),
        purpose: _purposeCtrl.text.trim().isNotEmpty ? _purposeCtrl.text.trim() : 'General',
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        createdAt: widget.existing?.createdAt,
      );

      if (widget.existing == null) {
        await ref.read(educationLoanProvider.notifier).addDisbursement(d);
      } else {
        await ref.read(educationLoanProvider.notifier).updateDisbursement(d);
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
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing == null ? 'Add Disbursement' : 'Edit Disbursement',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            _field('Amount (₹) *', _amountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            _field('Semester / Period', _semesterCtrl, hint: 'e.g. Sem 3'),
            const SizedBox(height: 12),
            _field('Purpose', _purposeCtrl, hint: 'e.g. Tuition, Hostel'),
            const SizedBox(height: 12),
            _field('Notes (optional)', _notesCtrl),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _eduBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_saving ? 'Saving...' : (widget.existing == null ? 'Add Disbursement' : 'Update'),
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType? keyboardType, String? hint}) {
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _eduBlue)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}
