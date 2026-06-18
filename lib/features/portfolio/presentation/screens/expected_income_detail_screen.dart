import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import '../../../../core/widgets/calculation_audit_panel.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart';
import '../widgets/adjustment_widgets.dart';

class ExpectedIncomeDetailScreen extends ConsumerStatefulWidget {
  final String incomeId;

  const ExpectedIncomeDetailScreen({required this.incomeId, super.key});

  @override
  ConsumerState<ExpectedIncomeDetailScreen> createState() => _ExpectedIncomeDetailScreenState();
}

class _ExpectedIncomeDetailScreenState extends ConsumerState<ExpectedIncomeDetailScreen> {
  String? _selectedAccountId;

  void _showMarkReceivedDialog(BuildContext context, ExpectedIncome inc, List<Account> accounts) {
    if (accounts.isEmpty) return;
    _selectedAccountId = accounts.first.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              
              
              title: const Text('Receive Income', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Select destination account:', style: TextStyle(color: AppColors.grey500, fontSize: 13)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedAccountId,
                    dropdownColor: AppColors.layer1,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder)),
                    ),
                    items: accounts.map((acc) => DropdownMenuItem(
                      value: acc.id,
                      child: Text(acc.name),
                    )).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        _selectedAccountId = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedAccountId != null) {
                      final adjAmount = ref.read(mockDatabaseProvider).getExpectedIncomeAmount(inc.id);
                      ref.read(mockDatabaseProvider.notifier).markExpectedIncomeReceived(
                        inc.id,
                        _selectedAccountId!,
                      );
                      Navigator.pop(context);
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Income of ${dbStateCurrency(ref)}$adjAmount received into account.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
                  child: const Text('Receive', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String dbStateCurrency(WidgetRef ref) => ref.read(mockDatabaseProvider).currency;

  void _handleExpire(ExpectedIncome inc) {
    ref.read(mockDatabaseProvider.notifier).markExpectedIncomeExpired(inc.id);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expected income marked as expired.')),
    );
  }

  void _showEditDialog(BuildContext context, ExpectedIncome item) {
    final sourceController = TextEditingController(text: item.source);
    final notesController = TextEditingController(text: item.notes ?? '');
    String status = item.status;
    DateTime? selectedDate = item.expectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          
          
          title: const Text('Edit Expected Income', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sourceController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Source Name', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: AppColors.layer1,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: AppColors.grey500)),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'received', child: Text('Received')),
                    DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  ],
                  onChanged: (val) => setState(() => status = val!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? 'Select Expected Date'
                        : 'Expected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
            ElevatedButton(
              onPressed: () {
                final source = sourceController.text.trim();
                final notes = notesController.text.trim();
                if (source.isNotEmpty) {
                  ref.read(mockDatabaseProvider.notifier).updateExpectedIncome(
                        ExpectedIncome(
                          id: item.id,
                          source: source,
                          amount: item.amount,
                          status: status,
                          expectedDate: selectedDate,
                          receivedTransactionId: item.receivedTransactionId,
                          notes: notes.isNotEmpty ? notes : null,
                          createdAt: item.createdAt,
                          updatedAt: DateTime.now().toUtc(),
                          syncStatus: 'pending',
                        ),
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expected income details updated.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustAmountDialog(BuildContext context, ExpectedIncome inc, double currentAmount) {
    final controller = TextEditingController(text: currentAmount.toStringAsFixed(0));
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Expected Income', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Amount',
            labelStyle: TextStyle(color: AppColors.grey500),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAmt = double.tryParse(controller.text.trim());
              if (newAmt == null) return;
              
              Navigator.pop(context); // close input dialog

              // 1. Show Warning
              if (!context.mounted) return;
              final continueAdj = await showAdjustmentWarningDialog(context);
              if (!continueAdj) return;

              // 2. Ask Reason
              if (!context.mounted) return;
              final reason = await showAdjustmentReasonSheet(context);
              if (reason == null) return;

              // 3. Save
              await ref.read(mockDatabaseProvider.notifier).addAdjustment(
                entityType: 'expected_income',
                entityId: inc.id,
                oldAmount: currentAmount,
                newAmount: newAmt,
                reason: reason,
              );

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Amount adjusted successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteExpectedIncome(BuildContext context, ExpectedIncome item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expected Income?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this expected income? This will hide it from all views and calculations. You can undo this action immediately.',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog
              final notifier = ref.read(mockDatabaseProvider.notifier);
              await notifier.deleteExpectedIncomeSoft(item.id);
              context.pop(); // pop details screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Expected income "${item.source}" deleted.'),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: AppColors.darkPrimary,
                    onPressed: () {
                      notifier.restoreExpectedIncome(item);
                    },
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    final inc = dbState.expectedIncomes.firstWhereOrNull((i) => i.id == widget.incomeId);

    if (inc == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Expected income not found.', style: TextStyle(color: Colors.white))),
      );
    }

    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);
    final activeCashAccounts = dbState.accounts.where((a) => a.isArchived == 0 && a.type != 'credit').toList();

    Color statusColor = AppColors.darkWarning;
    if (inc.status == 'received') statusColor = AppColors.darkSuccess;
    if (inc.status == 'expired') statusColor = AppColors.grey500;

    final createdStr = DateFormat('dd MMM yyyy, hh:mm a').format(inc.createdAt.toLocal());
    final updatedStr = DateFormat('dd MMM yyyy, hh:mm a').format(inc.updatedAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(inc.source, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer1,
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context, inc);
              } else if (value == 'adjust_amount') {
                _showAdjustAmountDialog(context, inc, dbState.getExpectedIncomeAmount(inc.id));
              } else if (value == 'view_history') {
                showAdjustmentHistorySheet(context, inc.id, 'expected_income', inc.source);
              } else if (value == 'duplicate') {
                ref.read(mockDatabaseProvider.notifier).duplicateExpectedIncome(inc.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Expected income "${inc.source}" duplicated.')),
                );
              } else if (value == 'delete') {
                _confirmDeleteExpectedIncome(context, inc);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Details', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'adjust_amount',
                child: Text('Adjust Amount', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'view_history',
                child: Text('View History', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Text('Duplicate', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.darkDanger)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassCard(
                borderColor: statusColor.withOpacity(0.2),
                child: Column(
                  children: [
                    Text(
                      'EXPECTED INCOME VALUE',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      format.format(dbState.getExpectedIncomeAmount(inc.id)),
                      style: GoogleFonts.inter(
                        fontSize: 32, 
                        fontWeight: FontWeight.w800, 
                        color: inc.status == 'expired' ? AppColors.grey500 : Colors.white,
                        decoration: inc.status == 'expired' ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        inc.status.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              GlassCard(
                child: Column(
                  children: [
                    _buildDetailRow('Source', inc.source),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildDetailRow(
                      'Expected Date', 
                      inc.expectedDate != null 
                          ? DateFormat('dd MMM yyyy').format(inc.expectedDate!) 
                          : 'Not Specified',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Builder(
                builder: (context) {
                  final double original = inc.amount;
                  final double adjs = dbState.adjustments
                      .where((a) => a.entityId == inc.id && a.entityType == 'expected_income')
                      .fold(0.0, (sum, a) => sum + a.adjustedAmount);
                  final double expectedTotal = dbState.getExpectedIncomeAmount(inc.id);

                  return CalculationAuditPanel(
                    title: 'Verify Expected Income Calculation',
                    formula: 'Expected Value = Original Expected Amount + Adjustments',
                    inputs: {
                      'Original Amount': format.format(original),
                      'Adjustments': format.format(adjs),
                    },
                    output: format.format(expectedTotal),
                    steps: [
                      'Retrieve the original expected income amount: ${format.format(original)}.',
                      'Sum all adjustments applied to this expected income: ${format.format(adjs)}.',
                      'Calculate final expected value: Original (${format.format(original)}) + Adjustments (${format.format(adjs)}) = ${format.format(expectedTotal)}.',
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              if (inc.notes != null) ...[
                Text(
                  'Notes',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  child: Text(
                    inc.notes!,
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (inc.status == 'pending') ...[
                ElevatedButton.icon(
                  onPressed: () => _showMarkReceivedDialog(context, inc, activeCashAccounts),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('Mark Received', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _handleExpire(inc),
                  icon: const Icon(Icons.close, color: AppColors.darkDanger),
                  label: const Text('Mark Expired', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.glassBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUDIT LOG INFORMATION',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Created At', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                          Text(createdStr, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Last Edited', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                          Text(updatedStr, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
