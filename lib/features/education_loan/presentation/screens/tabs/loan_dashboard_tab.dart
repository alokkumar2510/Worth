import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/glass_card.dart';
import '../../../providers/education_loan_provider.dart';
import '../../../domain/entities/education_loan.dart';
import '../../../domain/services/loan_calculator.dart';

const _eduBlue = Color(0xFF0EA5E9);

class LoanDashboardTab extends ConsumerWidget {
  const LoanDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(educationLoanProvider);
    final loan = state.loan;
    if (loan == null) return const SizedBox();

    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');
    final totalDisbursed = state.totalDisbursed;
    final remaining = state.remainingEligible;
    final accrued = LoanCalculator.accruedInterestToDate(
      disbursements: state.disbursements,
      annualRatePct: loan.interestRate,
    );

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        // Hero metrics grid
        _buildMetricsGrid(currency, loan.sanctionedAmount, totalDisbursed, remaining, accrued, loan.interestRate),
        const SizedBox(height: 20),

        // Status card
        _buildStatusCard(loan, currency),
        const SizedBox(height: 20),

        // Quick Actions
        _buildQuickActions(context, ref),
        const SizedBox(height: 20),

        // Recent disbursements
        if (state.disbursements.isNotEmpty) ...[
          _buildRecentDisbursements(state.disbursements.take(3).toList(), currency),
        ],
      ],
    );
  }

  Widget _buildMetricsGrid(
    NumberFormat currency,
    double sanctioned,
    double disbursed,
    double remaining,
    double accrued,
    double rate,
  ) {
    return Column(
      children: [
        // Large hero card
        GlassCard(
          gradientColors: [
            _eduBlue.withOpacity(0.18),
            AppColors.darkPrimary.withOpacity(0.08),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_outlined, size: 16, color: _eduBlue),
                  const SizedBox(width: 6),
                  Text('LOAN SANCTIONED', style: _labelStyle),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currency.format(sanctioned),
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Disbursement progress
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: sanctioned > 0 ? (disbursed / sanctioned).clamp(0, 1) : 0,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  color: _eduBlue,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${currency.format(disbursed)} disbursed · ${currency.format(remaining)} remaining',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3-column metrics
        Row(
          children: [
            Expanded(child: _metricCard('Interest Rate', '${rate.toStringAsFixed(2)}%', Icons.percent_rounded, AppColors.darkWarning)),
            const SizedBox(width: 8),
            Expanded(child: _metricCard('Accrued Today', currency.format(accrued), Icons.trending_up_rounded, AppColors.darkDanger)),
            const SizedBox(width: 8),
            Expanded(child: _metricCard('Disbursements', disbursed > 0 ? '${((disbursed / sanctioned) * 100).toStringAsFixed(0)}%' : '0%', Icons.pie_chart_outline_rounded, _eduBlue)),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatusCard(EducationLoan loan, NumberFormat currency) {
    final moratoriumDays = LoanCalculator.moratoriumDaysRemaining(
      loan.courseEndDate,
      loan.moratoriumMonths,
    );
    final emiStart = loan.computedEmiStartDate;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Loan Overview', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(loan.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loan.status.label,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(loan.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _overviewRow('Lender', loan.lenderName),
          _overviewRow('Course', loan.courseName),
          _overviewRow('Institution', loan.institutionName),
          _overviewRow('Course Status', loan.courseStatus.label),
          if (moratoriumDays > 0)
            _overviewRow('Moratorium Left', '$moratoriumDays days', color: AppColors.darkWarning),
          if (emiStart != null && moratoriumDays <= 0)
            _overviewRow('EMI Started', DateFormat('dd MMM yyyy').format(emiStart), color: _eduBlue),
          if (loan.expectedEmi != null)
            _overviewRow('Expected EMI', currency.format(loan.expectedEmi!), color: _eduBlue),
        ],
      ),
    );
  }

  Widget _overviewRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    final actions = [
      (_AddDisbursementAction(), Icons.add_card_outlined, 'Add\nDisbursement', _eduBlue),
      (null, Icons.calculate_outlined, 'EMI\nSimulator', AppColors.darkPrimary),
      (null, Icons.flash_on_outlined, 'Prepayment\nPlanner', AppColors.darkWarning),
      (null, Icons.bar_chart_outlined, 'Loan\nForecast', AppColors.darkSuccess),
    ];

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: List.generate(actions.length, (i) {
                final a = actions[i];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == actions.length - 1 ? 0 : 4),
                    child: GestureDetector(
                      onTap: () {
                        if (a.$1 is _AddDisbursementAction) {
                          _showAddDisbursementSheet(context, ref);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: (a.$4 as Color).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: (a.$4 as Color).withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Icon(a.$2 as IconData, size: 22, color: a.$4 as Color),
                            const SizedBox(height: 6),
                            Text(
                              a.$3 as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70, height: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDisbursements(List<LoanDisbursement> disbursements, NumberFormat currency) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Disbursements', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('See all →', style: GoogleFonts.inter(fontSize: 12, color: _eduBlue)),
              ],
            ),
          ),
          ...disbursements.map((d) => ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _eduBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_card_outlined, size: 16, color: _eduBlue),
                ),
                title: Text(d.semester, style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text(DateFormat('dd MMM yyyy').format(d.date), style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                trailing: Text(
                  currency.format(d.amount),
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: _eduBlue),
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showAddDisbursementSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.layer2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => const _AddDisbursementSheet(),
    );
  }

  Color _statusColor(LoanStatus loanStatus) {
    switch (loanStatus) {
      case LoanStatus.sanctioned: return AppColors.darkWarning;
      case LoanStatus.active: return _eduBlue;
      case LoanStatus.moratorium: return AppColors.darkWarning;
      case LoanStatus.repaying: return AppColors.darkSuccess;
      case LoanStatus.closed: return AppColors.grey500;
      case LoanStatus.defaulted: return AppColors.darkDanger;
    }
  }
}

// Marker class to identify quick action
class _AddDisbursementAction {}

// Add disbursement bottom sheet
class _AddDisbursementSheet extends ConsumerStatefulWidget {
  const _AddDisbursementSheet();

  @override
  ConsumerState<_AddDisbursementSheet> createState() => _AddDisbursementSheetState();
}

class _AddDisbursementSheetState extends ConsumerState<_AddDisbursementSheet> {
  final _amountCtrl = TextEditingController();
  final _semesterCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

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
    if (state.loan == null) return;
    if (_amountCtrl.text.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      final d = LoanDisbursement(
        loanId: state.loan!.id,
        date: _date,
        semester: _semesterCtrl.text.trim().isNotEmpty ? _semesterCtrl.text.trim() : 'Semester',
        amount: double.parse(_amountCtrl.text.trim()),
        purpose: _purposeCtrl.text.trim().isNotEmpty ? _purposeCtrl.text.trim() : 'Tuition & Expenses',
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      );
      await ref.read(educationLoanProvider.notifier).addDisbursement(d);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.darkDanger));
      }
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
            Text('Add Disbursement', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            _field('Amount (₹)', _amountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            _field('Semester / Period', _semesterCtrl, hint: 'e.g. Sem 3, Year 2'),
            const SizedBox(height: 12),
            _field('Purpose', _purposeCtrl, hint: 'e.g. Tuition, Hostel, Lab Fees'),
            const SizedBox(height: 12),
            _field('Notes (optional)', _notesCtrl, hint: 'Any additional info'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _eduBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_saving ? 'Saving...' : 'Add Disbursement', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _eduBlue)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// Label style
TextStyle get _labelStyle => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5);
