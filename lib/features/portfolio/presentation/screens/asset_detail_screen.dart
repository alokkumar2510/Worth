import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart';
import '../widgets/adjustment_widgets.dart';

class AssetDetailScreen extends ConsumerWidget {
  final String accountId;

  const AssetDetailScreen({required this.accountId, super.key});

  void _showEditAccountDialog(BuildContext context, WidgetRef ref, Account acc) {
    final nameController = TextEditingController(text: acc.name);
    final notesController = TextEditingController(text: acc.notes ?? '');
    String type = acc.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          
          
          title: const Text('Edit Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Account Name', labelStyle: TextStyle(color: AppColors.grey500)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                dropdownColor: AppColors.layer1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Type', labelStyle: TextStyle(color: AppColors.grey500)),
                items: const [
                  DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash Wallet')),
                  DropdownMenuItem(value: 'wallet', child: Text('Digital Wallet')),
                  DropdownMenuItem(value: 'credit', child: Text('Credit Card Dues')),
                ],
                onChanged: (val) => setState(() => type = val!),
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

  void _confirmClearTransactions(BuildContext context, WidgetRef ref, Account acc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Clear Transactions?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently delete all transactions associated with this account. This action cannot be undone.',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(mockDatabaseProvider.notifier).clearAccountTransactions(acc.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account transactions cleared.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger, foregroundColor: Colors.white),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref, Account acc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Delete Account?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(mockDatabaseProvider.notifier).deleteAccountEmpty(acc.id);
              Navigator.pop(context);
              if (success) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Account "${acc.name}" deleted.')),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    
                    title: const Text('Cannot Delete Account', style: TextStyle(color: Colors.white)),
                    content: const Text('This account is not empty. Please clear its transactions or merge it first.', style: TextStyle(color: AppColors.grey400)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: AppColors.darkPrimary))),
                    ],
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    
    final account = dbState.accounts.firstWhereOrNull((a) => a.id == accountId);

    if (account == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Account not found.', style: TextStyle(color: Colors.white))),
      );
    }

    final currency = dbState.currency;
    final balance = dbState.getAccountCashBalance(accountId);
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    final txs = dbState.transactions.where((t) => t.fromAccountId == accountId || t.toAccountId == accountId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer1,
            onSelected: (value) {
              if (value == 'edit') {
                _showEditAccountDialog(context, ref, account);
              } else if (value == 'adjust_amount') {
                _showAdjustBalanceDialog(context, ref, account, balance);
              } else if (value == 'view_history') {
                showAdjustmentHistorySheet(context, account.id, 'account', account.name);
              } else if (value == 'archive') {
                ref.read(mockDatabaseProvider.notifier).archiveAccount(accountId);
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${account.name} archived successfully.')),
                );
              } else if (value == 'delete') {
                _confirmDeleteAccount(context, ref, account);
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
                value: 'archive',
                child: Text('Archive', style: TextStyle(color: Colors.white)),
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
                borderColor: AppColors.darkPrimary.withOpacity(0.2),
                child: Column(
                  children: [
                    Text(
                      'CURRENT CASH BALANCE',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      format.format(balance),
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (account.notes != null) ...[
                Text(
                  'Notes',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                GlassCard(
                  child: Text(
                    account.notes!,
                    style: const TextStyle(color: Colors.white, height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text(
                'Transaction History',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              if (txs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: Text('No transactions for this account.', style: TextStyle(color: AppColors.grey500))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isVoided = tx.voidedTransactionId != null || tx.type == 'void';
                    
                    bool isOutgoing = tx.fromAccountId == accountId;
                    
                    String symbol = isOutgoing ? '-' : '+';
                    Color valColor = isOutgoing ? AppColors.darkDanger : AppColors.darkSuccess;
                    
                    if (tx.type == 'void') {
                      symbol = '';
                      valColor = Colors.white;
                    }

                    final formattedDate = DateFormat('dd MMM yyyy').format(tx.transactionDate);

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
                                      decoration: isVoided ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$formattedDate · ${tx.type.toUpperCase()}', style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                                ],
                              ),
                            ),
                            Text(
                              '$symbol$currency${NumberFormat.decimalPattern().format(tx.amount)}',
                              style: TextStyle(
                                color: isVoided ? AppColors.grey500 : valColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: isVoided ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdjustBalanceDialog(BuildContext context, WidgetRef ref, Account account, double currentBalance) {
    final controller = TextEditingController(text: currentBalance.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Balance',
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
              final newBal = double.tryParse(controller.text.trim());
              if (newBal == null) return;
              
              Navigator.pop(context); // close input dialog

              // 1. Show Warning
              final continueAdj = await showAdjustmentWarningDialog(context);
              if (!continueAdj) return;

              // 2. Ask Reason
              final reason = await showAdjustmentReasonSheet(context);
              if (reason == null) return;

              // 3. Save
              await ref.read(mockDatabaseProvider.notifier).addAdjustment(
                entityType: 'account',
                entityId: account.id,
                oldAmount: currentBalance,
                newAmount: newBal,
                reason: reason,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Balance adjusted successfully.')),
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
