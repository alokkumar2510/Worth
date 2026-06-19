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

class LiabilityDetailScreen extends ConsumerStatefulWidget {
  final String id; // prefixed with 'acc_' or 'person_'

  const LiabilityDetailScreen({required this.id, super.key});

  @override
  ConsumerState<LiabilityDetailScreen> createState() => _LiabilityDetailScreenState();
}

class _LiabilityDetailScreenState extends ConsumerState<LiabilityDetailScreen> {
  final _repayController = TextEditingController();

  @override
  void dispose() {
    _repayController.dispose();
    super.dispose();
  }

  void _showRepayDialog(BuildContext context, String cleanId, bool isAccount, String currency, String name, double outstanding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: Text('Repay to $name', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              controller: _repayController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Repayment Amount',
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
            onPressed: () {
              final amount = double.tryParse(_repayController.text.trim()) ?? 0.0;
              if (amount > 0) {
                final notifier = ref.read(mockDatabaseProvider.notifier);
                if (isAccount) {
                  notifier.addTransaction(
                    type: 'repay_money',
                    amount: amount,
                    fromAccountId: 'acc_primary_bank_uuid',
                    toAccountId: cleanId,
                    notes: 'Credit card bill repayment',
                    date: DateTime.now().toUtc(),
                  );
                } else {
                  notifier.addRepayTransaction(cleanId, 'acc_primary_bank_uuid', amount, 'Repaid loan amount', DateTime.now().toUtc());
                }
                _repayController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Repayment of $currency$amount recorded successfully.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _markClosed(BuildContext context, String cleanId, bool isAccount, String name, double outstanding) {
    if (outstanding <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Liability is already closed.')),
      );
      return;
    }
    final notifier = ref.read(mockDatabaseProvider.notifier);
    if (isAccount) {
      notifier.addTransaction(
        type: 'repay_money',
        amount: outstanding,
        fromAccountId: 'acc_primary_bank_uuid',
        toAccountId: cleanId,
        notes: 'Credit card bill repayment (Closed)',
        date: DateTime.now().toUtc(),
      );
    } else {
      notifier.addRepayTransaction(cleanId, 'acc_primary_bank_uuid', outstanding, 'Repaid loan amount (Closed)', DateTime.now().toUtc());
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Liability "$name" marked as closed by paying outstanding balance.')),
    );
  }

  void _showEditDialog(BuildContext context, bool isAccount, String cleanId) {
    final dbState = ref.read(mockDatabaseProvider);
    if (isAccount) {
      final acc = dbState.accounts.firstWhere((a) => a.id == cleanId);
      final nameController = TextEditingController(text: acc.name);
      final notesController = TextEditingController(text: acc.notes ?? '');
      String type = acc.type;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          
          
          title: const Text('Edit Credit Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Card Name', labelStyle: TextStyle(color: AppColors.grey500)),
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
                final notes = notesController.text.trim();
                if (name.isNotEmpty) {
                  ref.read(mockDatabaseProvider.notifier).updateAccount(
                        acc.id,
                        name,
                        type,
                        notes.isNotEmpty ? notes : null,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Liability details updated.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      final person = dbState.people.firstWhere((p) => p.id == cleanId);
      final nameController = TextEditingController(text: person.name);
      final phoneController = TextEditingController(text: person.phone ?? '');
      final notesController = TextEditingController(text: person.notes ?? '');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          
          
          title: const Text('Edit Liability Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    const SnackBar(content: Text('Liability details updated.')),
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
  }

  void _confirmDeleteLiability(BuildContext context, bool isAccount, dynamic originalItem, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Liability?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this liability? This will hide it from all views and calculations. You can undo this action immediately.',
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
              if (isAccount) {
                await notifier.deleteAccountSoft((originalItem as Account).id);
              } else {
                await notifier.deletePersonSoft((originalItem as Person).id);
              }
              context.pop(); // pop details screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Liability "$name" deleted.'),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: AppColors.darkPrimary,
                    onPressed: () {
                      if (isAccount) {
                        ref.read(mockDatabaseProvider.notifier).restoreAccount(originalItem as Account);
                      } else {
                        ref.read(mockDatabaseProvider.notifier).restorePerson(originalItem as Person);
                      }
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

    final isAccount = widget.id.startsWith('acc_');
    final cleanId = widget.id.substring(widget.id.indexOf('_') + 1);

    String name = '';
    String subType = '';
    String? notes;
    double outstanding = 0.0;
    List<Transaction> txs = [];
    int isArchived = 0;
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    dynamic originalItem;

    if (isAccount) {
      final acc = dbState.accounts.firstWhereOrNull((a) => a.id == cleanId);
      if (acc != null) {
        name = acc.name;
        subType = 'CREDIT ACCOUNT';
        notes = acc.notes;
        outstanding = dbState.getAccountLiabilityBalance(cleanId);
        txs = dbState.transactions.where((t) => (t.fromAccountId == cleanId || t.toAccountId == cleanId) && t.voidedTransactionId == null).toList();
        isArchived = acc.isArchived;
        createdAt = acc.createdAt;
        updatedAt = acc.updatedAt;
        originalItem = acc;
      }
    } else {
      final person = dbState.people.firstWhereOrNull((p) => p.id == cleanId);
      if (person != null) {
        name = person.name;
        subType = 'LOAN FROM INDIVIDUAL';
        notes = person.notes;
        outstanding = dbState.getPersonLiabilityBalance(cleanId);
        txs = dbState.transactions.where((t) => t.personId == cleanId && t.voidedTransactionId == null && (t.type == 'borrow_money' || t.type == 'repay_money')).toList();
        isArchived = person.isArchived;
        createdAt = person.createdAt;
        updatedAt = person.updatedAt;
        originalItem = person;
      }
    }

    if (name.isEmpty || originalItem == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Liability not found.', style: TextStyle(color: Colors.white))),
      );
    }

    final createdStr = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt.toLocal());
    final updatedStr = DateFormat('dd MMM yyyy, hh:mm a').format(updatedAt.toLocal());
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer1,
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context, isAccount, cleanId);
              } else if (value == 'adjust_amount') {
                _showAdjustAmountDialog(context, ref, isAccount, cleanId, name, outstanding);
              } else if (value == 'view_history') {
                showAdjustmentHistorySheet(
                  context,
                  cleanId,
                  isAccount ? 'account' : 'person_liability',
                  name,
                );
              } else if (value == 'duplicate') {
                if (isAccount) {
                  ref.read(mockDatabaseProvider.notifier).duplicateAccount(cleanId);
                } else {
                  ref.read(mockDatabaseProvider.notifier).duplicatePerson(cleanId);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Liability "$name" duplicated.')),
                );
              } else if (value == 'archive') {
                final notifier = ref.read(mockDatabaseProvider.notifier);
                if (isAccount) {
                  notifier.archiveAccount(cleanId);
                } else {
                  notifier.archivePerson(cleanId);
                }
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Liability "$name" archived.')),
                );
              } else if (value == 'restore') {
                final notifier = ref.read(mockDatabaseProvider.notifier);
                if (isAccount) {
                  notifier.unarchiveAccount(cleanId);
                } else {
                  notifier.unarchivePerson(cleanId);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Liability "$name" unarchived successfully.')),
                );
              } else if (value == 'delete') {
                _confirmDeleteLiability(context, isAccount, originalItem, name);
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
                value: isArchived == 1 ? 'restore' : 'archive',
                child: Text(isArchived == 1 ? 'Restore from Archive' : 'Archive', style: const TextStyle(color: Colors.white)),
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
                borderColor: AppColors.darkDanger.withOpacity(0.2),
                child: Column(
                  children: [
                    Text(
                      'OUTSTANDING AMOUNT OWED',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      format.format(outstanding),
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.darkDanger),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      subType,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (outstanding > 0)
                ElevatedButton.icon(
                  onPressed: () => _showRepayDialog(context, cleanId, isAccount, currency, name, outstanding),
                  icon: const Icon(Icons.payment_rounded, color: Colors.white),
                  label: const Text('Record Repayment', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              const SizedBox(height: 24),

              Builder(
                builder: (context) {
                  if (isAccount) {
                    final double openingBalance = txs
                        .where((t) => t.toAccountId == cleanId && t.voidedTransactionId == null && t.type == 'borrow_money')
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final double purchases = txs
                        .where((t) => t.fromAccountId == cleanId && t.voidedTransactionId == null && t.type != 'void')
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final double interest = txs
                        .where((t) => t.toAccountId == cleanId && t.voidedTransactionId == null && t.type == 'interest_accrued')
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final double payments = txs
                        .where((t) => t.toAccountId == cleanId && t.voidedTransactionId == null && t.type != 'borrow_money' && t.type != 'interest_accrued' && t.type != 'void')
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final double adjs = dbState.adjustments
                        .where((a) => a.entityId == cleanId && a.entityType == 'account')
                        .fold(0.0, (sum, a) => sum + a.adjustedAmount);

                    return CalculationAuditPanel(
                      title: 'Verify Liability Calculation',
                      formula: 'Outstanding Balance = Opening Balance + Purchases + Interest - Payments + Adjustments',
                      inputs: {
                        'Opening Balance': format.format(openingBalance),
                        'Purchases / Spending': format.format(purchases),
                        'Interest Accrued': format.format(interest),
                        'Payments / Credits': format.format(payments),
                        'Adjustments': format.format(adjs),
                      },
                      output: format.format(outstanding),
                      steps: [
                        'Start with opening balance (borrowings): ${format.format(openingBalance)}.',
                        'Add purchases / spending on credit card: ${format.format(purchases)}.',
                        'Add interest accrued: ${format.format(interest)}.',
                        'Subtract payments and other credits received: ${format.format(payments)}.',
                        'Add applied balance adjustments: ${format.format(adjs)}.',
                        'Compute outstanding amount: Opening Balance (${format.format(openingBalance)}) + Purchases (${format.format(purchases)}) + Interest (${format.format(interest)}) - Payments (${format.format(payments)}) + Adjustments (${format.format(adjs)}) = ${format.format(outstanding)}.',
                      ],
                    );
                  } else {
                    final double borrowed = txs
                        .where((t) => t.personId == cleanId && t.voidedTransactionId == null && t.type == 'borrow_money')
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final double repayments = txs
                        .where((t) => t.personId == cleanId && t.voidedTransactionId == null && t.type == 'repay_money')
                        .fold(0.0, (sum, t) => sum + t.amount);
                    final double adjs = dbState.adjustments
                        .where((a) => a.entityId == cleanId && a.entityType == 'person_liability')
                        .fold(0.0, (sum, a) => sum + a.adjustedAmount);

                    return CalculationAuditPanel(
                      title: 'Verify Loan Calculation',
                      formula: 'Outstanding Balance = Borrowed - Repayments + Adjustments',
                      inputs: {
                        'Total Borrowed': format.format(borrowed),
                        'Total Repayments': format.format(repayments),
                        'Adjustments': format.format(adjs),
                      },
                      output: format.format(outstanding),
                      steps: [
                        'Sum all funds borrowed from this individual: ${format.format(borrowed)}.',
                        'Sum all repayments made to this individual: ${format.format(repayments)}.',
                        'Sum all adjustments applied to this liability: ${format.format(adjs)}.',
                        'Calculate outstanding balance: Borrowed (${format.format(borrowed)}) - Repayments (${format.format(repayments)}) + Adjustments (${format.format(adjs)}) = ${format.format(outstanding)}.',
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              if (notes != null) ...[
                Text(
                  'Notes',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  child: Text(
                    notes,
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text(
                'Payment Log',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              if (txs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: Text('No transaction logs recorded.', style: TextStyle(color: AppColors.grey500))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isVoided = tx.voidedTransactionId != null || tx.type == 'void';

                    final isRepayment = tx.type == 'repay_money' || (isAccount && tx.toAccountId == cleanId);

                    final color = isRepayment ? AppColors.darkSuccess : AppColors.darkDanger;
                    final prefix = isRepayment ? '-' : '+';

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
            ],
          ),
        ),
      ),
    );
  }

  void _showAdjustAmountDialog(BuildContext context, WidgetRef ref, bool isAccount, String cleanId, String name, double currentOutstanding) {
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
              final type = isAccount ? 'account' : 'person_liability';
              await ref.read(mockDatabaseProvider.notifier).addAdjustment(
                entityType: type,
                entityId: cleanId,
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
