import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/mock_database.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data Model for a single allocation row
// ─────────────────────────────────────────────────────────────────────────────
class AllocationEntry {
  String type; // Cash | BankAccount | Investment | MTFPosition | EmergencyFund | Goal | Asset | Custom
  String? destinationId;
  String destinationLabel;
  double amount;

  AllocationEntry({
    this.type = 'Cash',
    this.destinationId,
    this.destinationLabel = 'Cash',
    this.amount = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'destinationId': destinationId,
        'destinationLabel': destinationLabel,
        'amount': amount,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Destination type metadata
// ─────────────────────────────────────────────────────────────────────────────
class _DestinationType {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _DestinationType(this.key, this.label, this.icon, this.color);
}

const List<_DestinationType> _destTypes = [
  _DestinationType('Cash', 'Cash', Icons.money_rounded, Color(0xFF22C55E)),
  _DestinationType('BankAccount', 'Bank Account', Icons.account_balance_rounded, Color(0xFF3B82F6)),
  _DestinationType('Investment', 'Investment', Icons.trending_up_rounded, Color(0xFFA855F7)),
  _DestinationType('MTFPosition', 'MTF Position', Icons.bolt_rounded, Color(0xFFF59E0B)),
  _DestinationType('EmergencyFund', 'Emergency Fund', Icons.emergency_rounded, Color(0xFFEF4444)),
  _DestinationType('Goal', 'Goal', Icons.flag_rounded, Color(0xFF06B6D4)),
  _DestinationType('Asset', 'Asset', Icons.home_rounded, Color(0xFF84CC16)),
  _DestinationType('Custom', 'Custom', Icons.edit_rounded, Color(0xFF94A3B8)),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main Dialog
// ─────────────────────────────────────────────────────────────────────────────
class RecoveryAllocationDialog extends ConsumerStatefulWidget {
  final String personId;
  final String personName;
  final double totalAmount;
  final String sourceTransactionId;
  final String currency;

  const RecoveryAllocationDialog({
    super.key,
    required this.personId,
    required this.personName,
    required this.totalAmount,
    required this.sourceTransactionId,
    required this.currency,
  });

  @override
  ConsumerState<RecoveryAllocationDialog> createState() => _RecoveryAllocationDialogState();
}

class _RecoveryAllocationDialogState extends ConsumerState<RecoveryAllocationDialog> with TickerProviderStateMixin {
  final List<AllocationEntry> _entries = [];
  bool _isSaving = false;

  late AnimationController _progressCtrl;
  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _addEntry();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  double get _allocated => _entries.fold(0.0, (sum, e) => sum + e.amount);
  double get _remaining => (widget.totalAmount - _allocated).clamp(0.0, double.infinity);
  double get _progress => (_allocated / widget.totalAmount).clamp(0.0, 1.0);
  bool get _isValid => _entries.isNotEmpty && _allocated > 0 && _allocated <= widget.totalAmount;

  void _addEntry() {
    setState(() {
      _entries.add(AllocationEntry(
        type: 'Cash',
        destinationLabel: 'Cash',
        amount: _remaining > 0 ? _remaining : 0.0,
      ));
    });
    _entryCtrl.forward(from: 0.0);
    _progressCtrl.animateTo(_progress);
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
    _progressCtrl.animateTo(_progress);
  }

  void _updateAmount(int index, double amount) {
    setState(() => _entries[index].amount = amount);
    _progressCtrl.animateTo(_progress);
  }

  void _updateEntry(int index, AllocationEntry entry) {
    setState(() => _entries[index] = entry);
    _progressCtrl.animateTo(_progress);
  }

  Future<void> _confirm() async {
    if (!_isValid) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(mockDatabaseProvider.notifier).addRecoveryAllocation(
        personId: widget.personId,
        sourceTransactionId: widget.sourceTransactionId,
        totalAmount: widget.totalAmount,
        destinations: _entries.map((e) => e.toMap()).toList(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving allocation: $e'), backgroundColor: AppColors.darkDanger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final fmt = NumberFormat.currency(symbol: widget.currency, decimalDigits: 0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.90),
        decoration: BoxDecoration(
          color: AppColors.layer1,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkPrimary.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: -8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(fmt),
            _buildProgressBar(),
            Flexible(child: _buildScrollBody(dbState, fmt)),
            _buildFooter(fmt),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkPrimary.withOpacity(0.15), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.darkPrimary, AppColors.darkPrimary.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_tree_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recovery Allocation',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        )),
                    Text('Where did the money go?',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close_rounded, color: AppColors.grey500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  label: 'From',
                  value: widget.personName,
                  icon: Icons.person_rounded,
                  color: AppColors.darkSuccess,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  label: 'Amount',
                  value: fmt.format(widget.totalAmount),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.darkWarning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Allocated', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400)),
              AnimatedBuilder(
                animation: _progressCtrl,
                builder: (_, __) => Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _progress >= 1.0 ? AppColors.darkSuccess : AppColors.darkWarning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: AnimatedBuilder(
              animation: _progressCtrl,
              builder: (_, __) => LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: AppColors.glassSurface,
                valueColor: AlwaysStoppedAnimation(
                  _progress >= 1.0 ? AppColors.darkSuccess : AppColors.darkPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Allocated: ${NumberFormat.currency(symbol: widget.currency, decimalDigits: 0).format(_allocated)}',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400),
              ),
              Text(
                'Remaining: ${NumberFormat.currency(symbol: widget.currency, decimalDigits: 0).format(_remaining)}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: _remaining > 0 ? AppColors.darkWarning : AppColors.darkSuccess,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollBody(MockDatabaseState dbState, NumberFormat fmt) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...List.generate(_entries.length, (i) => _AllocationEntryRow(
            key: ValueKey('entry_$i'),
            entry: _entries[i],
            index: i,
            currency: widget.currency,
            totalAmount: widget.totalAmount,
            dbState: dbState,
            onChanged: (e) => _updateEntry(i, e),
            onAmountChanged: (v) => _updateAmount(i, v),
            onRemove: _entries.length > 1 ? () => _removeEntry(i) : null,
          )),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _addEntry,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _remaining > 0 ? AppColors.darkPrimary.withOpacity(0.5) : AppColors.grey700,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
                color: _remaining > 0 ? AppColors.accentGlow : Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_rounded,
                      size: 18,
                      color: _remaining > 0 ? AppColors.darkPrimary : AppColors.grey500),
                  const SizedBox(width: 8),
                  Text(
                    'Add Destination',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _remaining > 0 ? AppColors.darkPrimary : AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFooter(NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Column(
        children: [
          if (_remaining > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkWarning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkWarning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.darkWarning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${fmt.format(_remaining)} remains unallocated — it stays in the recovery account.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.darkWarning),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.glassBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.grey400)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ElevatedButton(
                    onPressed: (_isValid && !_isSaving) ? _confirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValid ? AppColors.darkPrimary : AppColors.grey700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: _isValid ? 4 : 0,
                      shadowColor: AppColors.darkPrimary.withOpacity(0.4),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Confirm Allocation',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single Allocation Entry Row
// ─────────────────────────────────────────────────────────────────────────────
class _AllocationEntryRow extends StatefulWidget {
  final AllocationEntry entry;
  final int index;
  final String currency;
  final double totalAmount;
  final MockDatabaseState dbState;
  final ValueChanged<AllocationEntry> onChanged;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback? onRemove;

  const _AllocationEntryRow({
    super.key,
    required this.entry,
    required this.index,
    required this.currency,
    required this.totalAmount,
    required this.dbState,
    required this.onChanged,
    required this.onAmountChanged,
    this.onRemove,
  });

  @override
  State<_AllocationEntryRow> createState() => _AllocationEntryRowState();
}

class _AllocationEntryRowState extends State<_AllocationEntryRow> with SingleTickerProviderStateMixin {
  late TextEditingController _amountCtrl;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.entry.amount > 0 ? widget.entry.amount.toStringAsFixed(0) : '',
    );
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  _DestinationType get _currentType =>
      _destTypes.firstWhere((t) => t.key == widget.entry.type, orElse: () => _destTypes.first);

  void _showTypePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.layer1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _TypePickerSheet(
        current: widget.entry.type,
        onSelected: (type) {
          Navigator.pop(ctx);
          _onTypeSelected(type);
        },
      ),
    );
  }

  void _onTypeSelected(String type) {
    // For types that need a destination, show entity picker
    if (['BankAccount', 'Asset', 'EmergencyFund'].contains(type)) {
      _showAccountPicker(type);
    } else if (type == 'Investment') {
      _showInvestmentPicker();
    } else if (type == 'MTFPosition') {
      _showMtfPicker();
    } else if (type == 'Goal') {
      _showGoalPicker();
    } else if (type == 'Custom') {
      _showCustomLabel();
    } else {
      // Cash — no entity needed
      final updated = AllocationEntry(
        type: type,
        destinationLabel: 'Cash',
        amount: widget.entry.amount,
      );
      widget.onChanged(updated);
    }
  }

  void _showAccountPicker(String type) {
    final accounts = widget.dbState.accounts
        .where((a) => a.isArchived == 0 && a.deletedAt == null)
        .toList();
    _showEntityPicker(
      title: type == 'Investment' ? 'Select Account' : 'Select Account',
      items: accounts.map((a) => _EntityItem(a.id, a.name, Icons.account_balance_wallet_rounded)).toList(),
      onSelected: (id, label) {
        widget.onChanged(AllocationEntry(
          type: type,
          destinationId: id,
          destinationLabel: label,
          amount: widget.entry.amount,
        ));
      },
    );
  }

  void _showInvestmentPicker() {
    final invs = widget.dbState.investments
        .where((i) => i.isArchived == 0 && i.deletedAt == null)
        .toList();
    _showEntityPicker(
      title: 'Select Investment',
      items: invs.map((i) => _EntityItem(i.id, i.name, Icons.trending_up_rounded)).toList(),
      onSelected: (id, label) {
        widget.onChanged(AllocationEntry(
          type: 'Investment',
          destinationId: id,
          destinationLabel: label,
          amount: widget.entry.amount,
        ));
      },
    );
  }

  void _showMtfPicker() {
    final mtfs = widget.dbState.mtfPositions
        .where((m) => m.deletedAt == null && m.isClosed == 0)
        .toList();
    _showEntityPicker(
      title: 'Select MTF Position',
      items: mtfs.map((m) => _EntityItem(m.id, m.instrument, Icons.bolt_rounded)).toList(),
      onSelected: (id, label) {
        widget.onChanged(AllocationEntry(
          type: 'MTFPosition',
          destinationId: id,
          destinationLabel: label,
          amount: widget.entry.amount,
        ));
      },
    );
  }

  void _showGoalPicker() {
    final goals = widget.dbState.goals
        .where((g) => g.isArchived == 0 && g.deletedAt == null)
        .toList();
    _showEntityPicker(
      title: 'Select Goal',
      items: goals.map((g) => _EntityItem(g.id, g.name, Icons.flag_rounded)).toList(),
      onSelected: (id, label) {
        widget.onChanged(AllocationEntry(
          type: 'Goal',
          destinationId: id,
          destinationLabel: label,
          amount: widget.entry.amount,
        ));
      },
    );
  }

  void _showCustomLabel() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.layer1,
        title: const Text('Custom Destination', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Wallet, Family, Savings...',
            hintStyle: TextStyle(color: AppColors.grey500),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.grey500))),
          ElevatedButton(
            onPressed: () {
              final label = ctrl.text.trim();
              if (label.isNotEmpty) {
                Navigator.pop(ctx);
                widget.onChanged(AllocationEntry(
                  type: 'Custom',
                  destinationLabel: label,
                  amount: widget.entry.amount,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEntityPicker({
    required String title,
    required List<_EntityItem> items,
    required void Function(String id, String label) onSelected,
  }) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No $title available.'), backgroundColor: AppColors.darkWarning),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.layer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _EntityPickerSheet(title: title, items: items, onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dt = _currentType;
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.layer2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: dt.color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            // Destination Type Selector
            InkWell(
              onTap: _showTypePicker,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: dt.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(dt.icon, color: dt.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dt.label,
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400, letterSpacing: 0.5)),
                          Text(
                            widget.entry.destinationLabel,
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: dt.color, size: 20),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: dt.color.withOpacity(0.1)),
            // Amount Input
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  Text(widget.currency, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700, color: dt.color)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.grey700,
                        ),
                      ),
                      onChanged: (v) {
                        final parsed = double.tryParse(v) ?? 0.0;
                        widget.onAmountChanged(parsed);
                      },
                    ),
                  ),
                  if (widget.onRemove != null)
                    IconButton(
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.darkDanger, size: 22),
                      tooltip: 'Remove',
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper sheets
// ─────────────────────────────────────────────────────────────────────────────
class _TypePickerSheet extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelected;
  const _TypePickerSheet({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where did this money go?',
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text('Select a destination type', style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400)),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: _destTypes.length,
              itemBuilder: (ctx, i) {
                final dt = _destTypes[i];
                final isSelected = dt.key == current;
                return GestureDetector(
                  onTap: () => onSelected(dt.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? dt.color.withOpacity(0.2) : AppColors.layer2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? dt.color : AppColors.glassBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(dt.icon, color: dt.color, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(dt.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? dt.color : Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _EntityItem {
  final String id;
  final String label;
  final IconData icon;
  const _EntityItem(this.id, this.label, this.icon);
}

class _EntityPickerSheet extends StatelessWidget {
  final String title;
  final List<_EntityItem> items;
  final void Function(String id, String label) onSelected;
  const _EntityPickerSheet({required this.title, required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(title,
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          const Divider(height: 1, color: AppColors.glassBorder),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                return ListTile(
                  leading: Icon(item.icon, color: AppColors.darkPrimary, size: 20),
                  title: Text(item.label, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onSelected(item.id, item.label);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widget
// ─────────────────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _InfoChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey400, letterSpacing: 0.5)),
                Text(value,
                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
