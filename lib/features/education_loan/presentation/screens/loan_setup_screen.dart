import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/education_loan.dart';
import '../../providers/education_loan_provider.dart';

class LoanSetupScreen extends ConsumerStatefulWidget {
  final EducationLoan? existingLoan; // null = create, non-null = edit
  const LoanSetupScreen({super.key, this.existingLoan});

  @override
  ConsumerState<LoanSetupScreen> createState() => _LoanSetupScreenState();
}

class _LoanSetupScreenState extends ConsumerState<LoanSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _lenderCtrl;
  late TextEditingController _courseCtrl;
  late TextEditingController _institutionCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _moratoriumCtrl;
  late TextEditingController _emiCtrl;

  DateTime? _sanctionDate;
  DateTime? _courseStartDate;
  DateTime? _courseEndDate;
  DateTime? _emiStartDate;

  LoanStatus _status = LoanStatus.sanctioned;
  CourseStatus _courseStatus = CourseStatus.ongoing;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final loan = widget.existingLoan;
    _lenderCtrl = TextEditingController(text: loan?.lenderName ?? '');
    _courseCtrl = TextEditingController(text: loan?.courseName ?? '');
    _institutionCtrl = TextEditingController(text: loan?.institutionName ?? '');
    _amountCtrl = TextEditingController(text: loan != null ? loan.sanctionedAmount.toStringAsFixed(0) : '');
    _rateCtrl = TextEditingController(text: loan != null ? loan.interestRate.toStringAsFixed(2) : '');
    _moratoriumCtrl = TextEditingController(text: (loan?.moratoriumMonths ?? 6).toString());
    _emiCtrl = TextEditingController(text: loan?.expectedEmi?.toStringAsFixed(0) ?? '');

    _sanctionDate = loan?.sanctionDate;
    _courseStartDate = loan?.courseStartDate;
    _courseEndDate = loan?.courseEndDate;
    _emiStartDate = loan?.emiStartDate;
    _status = loan?.status ?? LoanStatus.sanctioned;
    _courseStatus = loan?.courseStatus ?? CourseStatus.ongoing;
  }

  @override
  void dispose() {
    _lenderCtrl.dispose();
    _courseCtrl.dispose();
    _institutionCtrl.dispose();
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _moratoriumCtrl.dispose();
    _emiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(String label, DateTime? current, void Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
      helpText: 'Select $label',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0EA5E9),
              onPrimary: Colors.white,
              surface: AppColors.layer2,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sanctionDate == null) {
      _showError('Please set the sanction date');
      return;
    }

    setState(() => _saving = true);

    try {
      final loan = EducationLoan(
        id: widget.existingLoan?.id,
        lenderName: _lenderCtrl.text.trim(),
        courseName: _courseCtrl.text.trim(),
        institutionName: _institutionCtrl.text.trim(),
        sanctionedAmount: double.parse(_amountCtrl.text.trim()),
        interestRate: double.parse(_rateCtrl.text.trim()),
        sanctionDate: _sanctionDate!,
        courseStartDate: _courseStartDate,
        courseEndDate: _courseEndDate,
        moratoriumMonths: int.tryParse(_moratoriumCtrl.text.trim()) ?? 6,
        emiStartDate: _emiStartDate,
        expectedEmi: _emiCtrl.text.trim().isNotEmpty ? double.tryParse(_emiCtrl.text.trim()) : null,
        status: _status,
        courseStatus: _courseStatus,
      );

      if (widget.existingLoan == null) {
        await ref.read(educationLoanProvider.notifier).createLoan(loan);
      } else {
        await ref.read(educationLoanProvider.notifier).updateLoan(loan);
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingLoan == null ? 'Education Loan created' : 'Loan updated'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.darkDanger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingLoan != null;
    final fmt = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEdit ? 'Edit Loan Details' : 'Set Up Education Loan',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFF0EA5E9), strokeWidth: 2))
                : Text(
                    'Save',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF0EA5E9),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(16),
          children: [
            // Isolation notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkSuccess.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkSuccess.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.darkSuccess),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This loan is isolated — it will not affect your Net Worth or Portfolio.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.darkSuccess, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Loan Info
            _sectionTitle('LOAN INFORMATION'),
            const SizedBox(height: 12),

            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _inputTile(
                    label: 'Bank / Lender Name *',
                    icon: Icons.account_balance_outlined,
                    child: TextFormField(
                      controller: _lenderCtrl,
                      style: _inputStyle,
                      decoration: _inputDecoration('e.g. SBI, HDFC, Axis Bank'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  _divider(),
                  _inputTile(
                    label: 'Sanctioned Amount (₹) *',
                    icon: Icons.currency_rupee_rounded,
                    child: TextFormField(
                      controller: _amountCtrl,
                      style: _inputStyle,
                      decoration: _inputDecoration('e.g. 2000000'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid amount';
                        return null;
                      },
                    ),
                  ),
                  _divider(),
                  _inputTile(
                    label: 'Annual Interest Rate (%) *',
                    icon: Icons.percent_rounded,
                    child: TextFormField(
                      controller: _rateCtrl,
                      style: _inputStyle,
                      decoration: _inputDecoration('e.g. 8.50'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid rate';
                        return null;
                      },
                    ),
                  ),
                  _divider(),
                  _dateTile(
                    label: 'Sanction Date *',
                    icon: Icons.event_outlined,
                    value: _sanctionDate != null ? fmt.format(_sanctionDate!) : 'Tap to select',
                    onTap: () => _pickDate('Sanction Date', _sanctionDate, (d) => setState(() => _sanctionDate = d)),
                  ),
                  _divider(),
                  _inputTile(
                    label: 'Loan Status',
                    icon: Icons.info_outline_rounded,
                    child: DropdownButtonFormField<LoanStatus>(
                      value: _status,
                      dropdownColor: AppColors.layer2,
                      style: _inputStyle,
                      decoration: _inputDecoration(null),
                      items: LoanStatus.values
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                          .toList(),
                      onChanged: (v) { if (v != null) setState(() => _status = v); },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Course Info
            _sectionTitle('COURSE DETAILS'),
            const SizedBox(height: 12),

            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _inputTile(
                    label: 'Course Name *',
                    icon: Icons.menu_book_outlined,
                    child: TextFormField(
                      controller: _courseCtrl,
                      style: _inputStyle,
                      decoration: _inputDecoration('e.g. B.Tech Computer Science'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  _divider(),
                  _inputTile(
                    label: 'Institution Name *',
                    icon: Icons.school_outlined,
                    child: TextFormField(
                      controller: _institutionCtrl,
                      style: _inputStyle,
                      decoration: _inputDecoration('e.g. IIT Bombay'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  _divider(),
                  _inputTile(
                    label: 'Course Status',
                    icon: Icons.timeline_outlined,
                    child: DropdownButtonFormField<CourseStatus>(
                      value: _courseStatus,
                      dropdownColor: AppColors.layer2,
                      style: _inputStyle,
                      decoration: _inputDecoration(null),
                      items: CourseStatus.values
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                          .toList(),
                      onChanged: (v) { if (v != null) setState(() => _courseStatus = v); },
                    ),
                  ),
                  _divider(),
                  _dateTile(
                    label: 'Course Start Date',
                    icon: Icons.play_circle_outline_rounded,
                    value: _courseStartDate != null ? fmt.format(_courseStartDate!) : 'Optional',
                    onTap: () => _pickDate('Course Start', _courseStartDate, (d) => setState(() => _courseStartDate = d)),
                  ),
                  _divider(),
                  _dateTile(
                    label: 'Course End Date',
                    icon: Icons.stop_circle_outlined,
                    value: _courseEndDate != null ? fmt.format(_courseEndDate!) : 'Optional',
                    onTap: () => _pickDate('Course End', _courseEndDate, (d) => setState(() => _courseEndDate = d)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Repayment
            _sectionTitle('REPAYMENT SETUP'),
            const SizedBox(height: 12),

            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _inputTile(
                    label: 'Moratorium Period (months)',
                    icon: Icons.hourglass_empty_outlined,
                    child: TextFormField(
                      controller: _moratoriumCtrl,
                      style: _inputStyle,
                      decoration: _inputDecoration('Default: 6 months'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  _divider(),
                  _dateTile(
                    label: 'EMI Start Date (optional override)',
                    icon: Icons.payments_outlined,
                    value: _emiStartDate != null ? fmt.format(_emiStartDate!) : 'Auto-calculated',
                    onTap: () => _pickDate('EMI Start', _emiStartDate, (d) => setState(() => _emiStartDate = d)),
                  ),
                  _divider(),
                  _inputTile(
                    label: 'Expected EMI (₹)',
                    icon: Icons.calculate_outlined,
                    child: TextFormField(
                      controller: _emiCtrl,
                      style: _inputStyle,
                      decoration: _inputDecoration('Optional — for forecast calculations'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Save Button
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0EA5E9).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          isEdit ? 'Update Loan' : 'Create Education Loan',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: AppColors.grey500,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _divider() => const Divider(color: AppColors.glassBorder, height: 1, indent: 16);

  TextStyle get _inputStyle => GoogleFonts.inter(fontSize: 14, color: Colors.white);

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.grey500),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      );

  Widget _inputTile({required String label, required IconData icon, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF0EA5E9)),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF0EA5E9)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(value, style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.grey500),
          ],
        ),
      ),
    );
  }
}
