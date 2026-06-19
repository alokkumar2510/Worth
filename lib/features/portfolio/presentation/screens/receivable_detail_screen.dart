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
import '../../../../features/recovery/presentation/widgets/recovery_allocation_dialog.dart';
import '../../../../features/recovery/presentation/widgets/recovery_flow_report_widget.dart';

class ReceivableDetailScreen extends ConsumerStatefulWidget {
  final String personId;

  const ReceivableDetailScreen({required this.personId, super.key});

  @override
  ConsumerState<ReceivableDetailScreen> createState() => _ReceivableDetailScreenState();
}

class _ReceivableDetailScreenState extends ConsumerState<ReceivableDetailScreen> {
  final _recoverController = TextEditingController();

  @override
  void dispose() {
    _recoverController.dispose();
    super.dispose();
  }

  void _showRecoverDialog(BuildContext context, String currency, String name, double outstanding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recover from $name', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Outstanding: $currency${NumberFormat.decimalPattern().format(outstanding)}',
              style: const TextStyle(color: AppColors.grey500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _recoverController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Recovery Amount',
                labelStyle: const TextStyle(color: AppColors.grey500),
                prefixText: '$currency ',
                prefixStyle: const TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkPrimary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_recoverController.text.trim()) ?? 0.0;
              if (amount > 0) {
                Navigator.pop(context);
                final txId = await ref.read(mockDatabaseProvider.notifier).addRecoverTransaction(
                  widget.personId,
                  'acc_primary_bank_uuid',
                  amount,
                  'Recovered debt amount',
                  DateTime.now().toUtc(),
                );
                _recoverController.clear();
                if (context.mounted) {
                  await _showAllocationDialog(context, currency, name, amount, txId);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAllocationDialog(
    BuildContext context,
    String currency,
    String personName,
    double amount,
    String txId,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RecoveryAllocationDialog(
        personId: widget.personId,
        personName: personName,
        totalAmount: amount,
        sourceTransactionId: txId,
        currency: currency,
      ),
    );
  }

  Future<void> _handleSettle(BuildContext context, String currency, String name, double outstanding) async {
    if (outstanding > 0) {
      final txId = await ref.read(mockDatabaseProvider.notifier).addRecoverTransaction(
        widget.personId,
        'acc_primary_bank_uuid',
        outstanding,
        'Full debt settlement',
        DateTime.now().toUtc(),
      );
      if (context.mounted) {
        await _showAllocationDialog(context, currency, name, outstanding, txId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receivable fully settled.')),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, Person person) {
    final nameController = TextEditingController(text: person.name);
    final phoneController = TextEditingController(text: person.phone ?? '');
    final notesController = TextEditingController(text: person.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Edit Receivable Person', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: AppColors.grey500)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Phone', labelStyle: TextStyle(color: AppColors.grey500)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: AppColors.grey500)),
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
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              final notes = notesController.text.trim();
              if (name.isNotEmpty) {
                ref.read(mockDatabaseProvider.notifier).updatePerson(
                      person.id,
                      name,
                      phone.isNotEmpty ? phone : null,
                      notes.isNotEmpty ? notes : null,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Receivable details updated.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteReceivable(BuildContext context, Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Receivable?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this receivable? This will hide it from all views and calculations. You can undo this action immediately.',
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
              await notifier.deletePersonSoft(person.id);
              context.pop(); // pop details screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Receivable "${person.name}" deleted.'),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: AppColors.darkPrimary,
                    onPressed: () {
                      notifier.restorePerson(person);
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

    final person = dbState.people.firstWhereOrNull((p) => p.id == widget.personId);

    if (person == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Receivable person not found.', style: TextStyle(color: Colors.white))),
      );
    }

    final outstanding = dbState.getPersonReceivableBalance(person.id);
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);
    
    final txs = dbState.transactions.where((t) => t.personId == person.id && t.voidedTransactionId == null && (t.type == 'lend_money' || t.type == 'recover_money')).toList();
    final createdStr = DateFormat('dd MMM yyyy, hh:mm a').format(person.createdAt.toLocal());
    final updatedStr = DateFormat('dd MMM yyyy, hh:mm a').format(person.updatedAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(person.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer1,
            onSelected: (value) async {
              if (value == 'edit') {
                _showEditDialog(context, person);
              } else if (value == 'adjust_amount') {
                _showAdjustAmountDialog(context, ref, person, outstanding);
              } else if (value == 'view_history') {
                showAdjustmentHistorySheet(context, person.id, 'person_receivable', person.name);
              } else if (value == 'duplicate') {
                await ref.read(mockDatabaseProvider.notifier).duplicatePerson(person.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Receivable "${person.name}" duplicated.')),
                  );
                }
              } else if (value == 'archive') {
                await ref.read(mockDatabaseProvider.notifier).archivePerson(person.id);
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Receivable "${person.name}" archived.')),
                  );
                }
              } else if (value == 'restore') {
                await ref.read(mockDatabaseProvider.notifier).unarchivePerson(person.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Receivable "${person.name}" unarchived successfully.')),
                  );
                }
              } else if (value == 'delete') {
                _confirmDeleteReceivable(context, person);
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
              PopupMenuItem(
                value: person.isArchived == 1 ? 'restore' : 'archive',
                child: Text(person.isArchived == 1 ? 'Restore from Archive' : 'Archive', style: const TextStyle(color: Colors.white)),
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
                borderColor: AppColors.darkSuccess.withOpacity(0.2),
                child: Column(
                  children: [
                    Text(
                      'OUTSTANDING AMOUNT OWED TO YOU',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      format.format(outstanding),
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.darkSuccess),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (outstanding > 0) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRecoverDialog(context, currency, person.name, outstanding),
                        icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white),
                        label: const Text('Recover Partial', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleSettle(context, currency, person.name, outstanding),
                        icon: const Icon(Icons.check, color: AppColors.darkSuccess),
                        label: const Text('Mark Settled', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.glassBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              Builder(
                builder: (context) {
                  final double lent = txs
                      .where((t) => t.personId == person.id && t.voidedTransactionId == null && t.type == 'lend_money')
                      .fold(0.0, (sum, t) => sum + t.amount);
                  final double recoveries = txs
                      .where((t) => t.personId == person.id && t.voidedTransactionId == null && t.type == 'recover_money')
                      .fold(0.0, (sum, t) => sum + t.amount);
                  final double adjs = dbState.adjustments
                      .where((a) => a.entityId == person.id && a.entityType == 'person_receivable')
                      .fold(0.0, (sum, a) => sum + a.adjustedAmount);

                  return CalculationAuditPanel(
                    title: 'Verify Receivable Calculation',
                    formula: 'Outstanding Balance = Lent - Recoveries + Adjustments',
                    inputs: {
                      'Total Lent': format.format(lent),
                      'Total Recovered': format.format(recoveries),
                      'Adjustments': format.format(adjs),
                    },
                    output: format.format(outstanding),
                    steps: [
                      'Sum all funds lent to this individual: ${format.format(lent)}.',
                      'Sum all recoveries received from this individual: ${format.format(recoveries)}.',
                      'Sum all adjustments applied to this receivable: ${format.format(adjs)}.',
                      'Calculate outstanding balance: Lent (${format.format(lent)}) - Recoveries (${format.format(recoveries)}) + Adjustments (${format.format(adjs)}) = ${format.format(outstanding)}.',
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              if (person.notes != null) ...[
                Text(
                  'Notes',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  child: Text(
                    person.notes!,
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text(
                'Recovery Log',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              if (txs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: Text('No recovery history found.', style: TextStyle(color: AppColors.grey500))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isVoided = tx.voidedTransactionId != null || tx.type == 'void';

                    final isRecovery = tx.type == 'recover_money';
                    final color = isRecovery ? AppColors.darkSuccess : AppColors.darkDanger;
                    final prefix = isRecovery ? '-' : '+';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.notes ?? tx.type.replaceAll('_', ' ').toUpperCase(),
                                    style: TextStyle(
                                      color: isVoided ? AppColors.grey500 : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(DateFormat('dd MMM yyyy').format(tx.transactionDate), style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                                ],
                              ),
                            ),
                            Text(
                              '$prefix$currency${NumberFormat.decimalPattern().format(tx.amount)}',
                              style: TextStyle(
                                color: isVoided ? AppColors.grey500 : color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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

              // ─── Recovery Flow Report ────────────────────────────────────
              RecoveryFlowReportWidget(
                personId: widget.personId,
                dbState: dbState,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdjustAmountDialog(BuildContext context, WidgetRef ref, Person person, double currentOutstanding) {
    final controller = TextEditingController(text: currentOutstanding.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Outstanding Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Outstanding Amount',
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
              final continueAdj = await showAdjustmentWarningDialog(context);
              if (!continueAdj) return;

              // 2. Ask Reason
              final reason = await showAdjustmentReasonSheet(context);
              if (reason == null) return;

              // 3. Save
              await ref.read(mockDatabaseProvider.notifier).addAdjustment(
                entityType: 'person_receivable',
                entityId: person.id,
                oldAmount: currentOutstanding,
                newAmount: newAmt,
                reason: reason,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Outstanding amount adjusted successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
