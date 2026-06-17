import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/providers/mock_database.dart';
import '../../core/providers/dependency_provider.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/constants/asset_constants.dart';
import '../../database/database.dart';
import '../../core/widgets/empty_state_widget.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  // --- Reusable Dismissible Wrapper ---
  Widget _buildDismissibleItem<T>({
    required String id,
    required Widget child,
    required String itemType,
    required T item,
    required VoidCallback onEdit,
    required Future<bool> Function() onDelete,
  }) {
    return Dismissible(
      key: Key('${itemType}_$id'),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkPrimary.withOpacity(0.25), AppColors.darkPrimary.withOpacity(0.02)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.15), width: 1.0),
        ),
        child: const Icon(Icons.edit, color: AppColors.glow),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkDanger.withOpacity(0.02), AppColors.darkDanger.withOpacity(0.25)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.darkDanger.withOpacity(0.15), width: 1.0),
        ),
        child: const Icon(Icons.delete, color: AppColors.darkDanger),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe Right -> Edit (snap back, do not dismiss)
          onEdit();
          return false;
        } else {
          // Swipe Left -> Delete
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Delete ${itemType.toUpperCase()}?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: const Text(
                'This action cannot be undone.',
                style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger, foregroundColor: Colors.white),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            return await onDelete();
          }
          return false;
        }
      },
      child: child,
    );
  }

  // --- Add Dialogs ---

  void _showAddAccountDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    String type = 'bank';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        title: const Text('Add Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              onChanged: (val) => type = val!,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Opening Balance', labelStyle: TextStyle(color: AppColors.grey500)),
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
              final balance = double.tryParse(balanceController.text.trim()) ?? 0.0;
              if (name.isNotEmpty) {
                ref.read(mockDatabaseProvider.notifier).addAccount(name, type, 'Manual creation', balance);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddPersonDialog(bool isLending) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        title: Text(isLending ? 'Add Receivable' : 'Add Liability', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Outstanding Amount', labelStyle: TextStyle(color: AppColors.grey500)),
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
              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
              final notes = notesController.text.trim();
              if (name.isNotEmpty) {
                final notifier = ref.read(mockDatabaseProvider.notifier);
                final person = notifier.addPerson(name, null, notes.isNotEmpty ? notes : null);
                
                if (isLending) {
                  notifier.addLendTransaction(person.id, 'acc_primary_bank_uuid', amount, 'Initial lend', DateTime.now().toUtc());
                } else {
                  notifier.addBorrowTransaction(person.id, 'acc_primary_bank_uuid', amount, 'Initial borrow', DateTime.now().toUtc());
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddInvestmentDialog() {
    final nameController = TextEditingController();
    final symbolController = TextEditingController();
    final unitsController = TextEditingController();
    final priceController = TextEditingController();
    
    // MTF Fields
    final brokerController = TextEditingController();
    final ownCapitalController = TextEditingController();
    final interestRateController = TextEditingController();
    bool isMtf = false;
    String type = 'mutual_fund';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final showMtfSwitch = type == 'stock' || type == 'etf';
          final units = double.tryParse(unitsController.text) ?? 0.0;
          final price = double.tryParse(priceController.text) ?? 0.0;
          final totalCost = units * price;
          final ownCapital = double.tryParse(ownCapitalController.text) ?? (isMtf ? totalCost * 0.5 : totalCost);
          final borrowedCapital = totalCost - ownCapital;

          return AlertDialog(
            
            title: const Text('Add Investment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Investment Name', labelStyle: TextStyle(color: AppColors.grey500)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: symbolController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Symbol / Ticker', labelStyle: TextStyle(color: AppColors.grey500)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    dropdownColor: AppColors.layer1,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Type', labelStyle: TextStyle(color: AppColors.grey500)),
                    items: const [
                      DropdownMenuItem(value: 'mutual_fund', child: Text('Mutual Fund')),
                      DropdownMenuItem(value: 'stock', child: Text('Direct Equity')),
                      DropdownMenuItem(value: 'etf', child: Text('ETF')),
                      DropdownMenuItem(value: 'crypto', child: Text('Crypto')),
                      DropdownMenuItem(value: 'bond', child: Text('Bond / FD')),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        type = val!;
                        if (type != 'stock' && type != 'etf') {
                          isMtf = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: unitsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Units', labelStyle: TextStyle(color: AppColors.grey500)),
                          onChanged: (_) {
                            if (isMtf) {
                              final u = double.tryParse(unitsController.text) ?? 0.0;
                              final p = double.tryParse(priceController.text) ?? 0.0;
                              ownCapitalController.text = (u * p * 0.5).toStringAsFixed(2);
                            }
                            setDialogState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Price / Unit', labelStyle: TextStyle(color: AppColors.grey500)),
                          onChanged: (_) {
                            if (isMtf) {
                              final u = double.tryParse(unitsController.text) ?? 0.0;
                              final p = double.tryParse(priceController.text) ?? 0.0;
                              ownCapitalController.text = (u * p * 0.5).toStringAsFixed(2);
                            }
                            setDialogState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  if (showMtfSwitch) ...[
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('MTF Position?', style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: const Text('Margin Trading Facility', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                      value: isMtf,
                      activeColor: AppColors.glow,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() {
                          isMtf = val;
                          if (isMtf) {
                            final u = double.tryParse(unitsController.text) ?? 0.0;
                            final p = double.tryParse(priceController.text) ?? 0.0;
                            ownCapitalController.text = (u * p * 0.5).toStringAsFixed(2);
                          }
                        });
                      },
                    ),
                  ],
                  if (isMtf) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: brokerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Broker', labelStyle: TextStyle(color: AppColors.grey500)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ownCapitalController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Own Capital', labelStyle: TextStyle(color: AppColors.grey500)),
                            onChanged: (_) => setDialogState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: interestRateController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(labelText: 'Interest Rate % p.a.', labelStyle: TextStyle(color: AppColors.grey500)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.layer2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Borrowed Capital:', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                          Text(
                            '${ref.read(mockDatabaseProvider).currency}${borrowedCapital.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                  final name = nameController.text.trim();
                  final symbol = symbolController.text.trim();
                  final unitsVal = double.tryParse(unitsController.text.trim()) ?? 0.0;
                  final priceVal = double.tryParse(priceController.text.trim()) ?? 0.0;

                  if (name.isNotEmpty && unitsVal > 0 && priceVal > 0) {
                    final notifier = ref.read(mockDatabaseProvider.notifier);
                    if (isMtf) {
                      final broker = brokerController.text.trim();
                      final ownCap = double.tryParse(ownCapitalController.text.trim()) ?? (unitsVal * priceVal * 0.5);
                      final intRate = double.tryParse(interestRateController.text.trim()) ?? 12.0;
                      final borrowed = (unitsVal * priceVal) - ownCap;

                      notifier.addMtfPosition(
                        broker: broker.isNotEmpty ? broker : 'Broker',
                        instrument: name,
                        units: unitsVal,
                        averagePrice: priceVal,
                        ownCapital: ownCap,
                        borrowedCapital: borrowed,
                        interestRate: intRate,
                        openingDate: DateTime.now().toUtc(),
                      );
                    } else {
                      final inv = notifier.addInvestment(name, type, symbol.isNotEmpty ? symbol : null, 'Manual creation', priceVal);
                      notifier.buyInvestment(inv.id, 'acc_primary_bank_uuid', unitsVal, priceVal, 'Opening Buy', DateTime.now().toUtc());
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddExpectedDialog() {
    final sourceController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        title: const Text('Add Expected Income', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sourceController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Source Name', labelStyle: TextStyle(color: AppColors.grey500)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Expected Amount', labelStyle: TextStyle(color: AppColors.grey500)),
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
              final src = sourceController.text.trim();
              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
              final notes = notesController.text.trim();
              if (src.isNotEmpty && amount > 0) {
                ref.read(mockDatabaseProvider.notifier).addExpectedIncome(src, amount, DateTime.now().toUtc().add(const Duration(days: 10)), notes.isNotEmpty ? notes : null);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog() {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDeadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          
          title: const Text('Add Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Goal Name', labelStyle: TextStyle(color: AppColors.grey500)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Target Amount', labelStyle: TextStyle(color: AppColors.grey500)),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  selectedDeadline == null
                      ? 'Select Deadline'
                      : 'Deadline: ${DateFormat('yyyy-MM-dd').format(selectedDeadline!)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDeadline = picked;
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text.trim()) ?? 0.0;
                final notes = notesController.text.trim();
                if (name.isNotEmpty && target > 0) {
                  ref.read(mockDatabaseProvider.notifier).addGoal(
                        name,
                        target,
                        selectedDeadline,
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

  // --- Edit Dialogs ---

  void _showEditAccountDialog(Account acc) {
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

  void _showEditPersonDialog(Person person) {
    final nameController = TextEditingController(text: person.name);
    final phoneController = TextEditingController(text: person.phone ?? '');
    final notesController = TextEditingController(text: person.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        title: const Text('Edit Person Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              decoration: const InputDecoration(labelText: 'Phone Number', labelStyle: TextStyle(color: AppColors.grey500)),
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
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditInvestmentDialog(Investment inv) {
    final nameController = TextEditingController(text: inv.name);
    final symbolController = TextEditingController(text: inv.symbol ?? '');
    final notesController = TextEditingController(text: inv.notes ?? '');
    final priceController = TextEditingController(text: inv.marketValue?.toString() ?? '0');
    String type = inv.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          
          title: const Text('Edit Investment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Investment Name', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: symbolController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Symbol / Ticker', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: type,
                  dropdownColor: AppColors.layer1,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Type', labelStyle: TextStyle(color: AppColors.grey500)),
                  items: const [
                    DropdownMenuItem(value: 'mutual_fund', child: Text('Mutual Fund')),
                    DropdownMenuItem(value: 'stock', child: Text('Direct Equity')),
                    DropdownMenuItem(value: 'etf', child: Text('ETF')),
                    DropdownMenuItem(value: 'crypto', child: Text('Crypto')),
                    DropdownMenuItem(value: 'bond', child: Text('Bond / FD')),
                  ],
                  onChanged: (val) => setState(() => type = val!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Live Price / Unit', labelStyle: TextStyle(color: AppColors.grey500)),
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
                final name = nameController.text.trim();
                final symbol = symbolController.text.trim();
                final notes = notesController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                if (name.isNotEmpty) {
                  ref.read(mockDatabaseProvider.notifier).updateInvestment(
                        inv.id,
                        name,
                        type,
                        symbol.isNotEmpty ? symbol : null,
                        notes.isNotEmpty ? notes : null,
                      );
                  if (price > 0) {
                    ref.read(mockDatabaseProvider.notifier).updateInvestmentMarketValue(inv.id, price);
                  }
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

  void _showEditExpectedDialog(ExpectedIncome inc) {
    final sourceController = TextEditingController(text: inc.source);
    final amountController = TextEditingController(text: inc.amount.toStringAsFixed(0));
    final notesController = TextEditingController(text: inc.notes ?? '');
    String status = inc.status;
    DateTime? selectedDate = inc.expectedDate;

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
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Amount', labelStyle: TextStyle(color: AppColors.grey500)),
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
                final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                final notes = notesController.text.trim();
                if (source.isNotEmpty && amount > 0) {
                  ref.read(mockDatabaseProvider.notifier).updateExpectedIncome(
                        ExpectedIncome(
                          id: inc.id,
                          source: source,
                          amount: amount,
                          status: status,
                          expectedDate: selectedDate,
                          receivedTransactionId: inc.receivedTransactionId,
                          notes: notes.isNotEmpty ? notes : null,
                          createdAt: inc.createdAt,
                          updatedAt: DateTime.now().toUtc(),
                          syncStatus: 'pending',
                        ),
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

  void _showEditGoalDialog(Goal goal) {
    final nameController = TextEditingController(text: goal.name);
    final targetController = TextEditingController(text: goal.targetAmount.toStringAsFixed(0));
    final currentController = TextEditingController(text: goal.currentAmount.toStringAsFixed(0));
    final notesController = TextEditingController(text: goal.notes ?? '');
    DateTime? selectedDeadline = goal.deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          
          title: const Text('Edit Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Goal Name', labelStyle: TextStyle(color: AppColors.grey500)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Target Amount', labelStyle: TextStyle(color: AppColors.grey500)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currentController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Current Amount Saved', labelStyle: TextStyle(color: AppColors.grey500)),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  selectedDeadline == null
                      ? 'Select Deadline'
                      : 'Deadline: ${DateFormat('yyyy-MM-dd').format(selectedDeadline!)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDeadline = picked;
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text.trim()) ?? 0.0;
                final current = double.tryParse(currentController.text.trim()) ?? 0.0;
                final notes = notesController.text.trim();
                if (name.isNotEmpty && target > 0) {
                  ref.read(mockDatabaseProvider.notifier).updateGoal(
                        Goal(
                          id: goal.id,
                          name: name,
                          targetAmount: target,
                          currentAmount: current,
                          deadline: selectedDeadline,
                          notes: notes.isNotEmpty ? notes : null,
                          isArchived: goal.isArchived,
                          createdAt: goal.createdAt,
                          updatedAt: DateTime.now().toUtc(),
                          syncStatus: 'pending',
                        ),
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

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Portfolio',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: AppColors.darkPrimary, width: 3),
              insets: EdgeInsets.symmetric(horizontal: 4),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.grey500,
            labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Assets'),
              Tab(text: 'Liabilities'),
              Tab(text: 'Investments'),
              Tab(text: 'MTF Tracker'),
              Tab(text: 'Receivables'),
              Tab(text: 'Expected Income'),
              Tab(text: 'Goals'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(AssetPaths.meshGradient2, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(AssetPaths.portfolioHeroBg, fit: BoxFit.cover),
              ),
            ),
            TabBarView(
              children: [
                _buildAssetsTab(dbState, currency),
                _buildLiabilitiesTab(dbState, currency),
                _buildInvestmentsTab(dbState, currency),
                _buildMtfTab(dbState, currency),
                _buildReceivablesTab(dbState, currency),
                _buildExpectedIncomeTab(dbState, currency),
                _buildGoalsTab(dbState, currency),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsTab(MockDatabaseState state, String currency) {
    final assets = state.accounts.where((a) => a.isArchived == 0 && a.type != 'credit').toList();
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    if (assets.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: EmptyStateWidget(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No Assets Yet',
          description: 'Start building your portfolio to see your wealth grow.',
          action: _buildAddButton('Add New Account', _showAddAccountDialog),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: assets.length + 1,
        itemBuilder: (context, index) {
          if (index == assets.length) {
            return _buildAddButton('Add New Account', _showAddAccountDialog);
          }
          final acc = assets[index];
          final bal = state.getAccountCashBalance(acc.id);

          return _buildDismissibleItem<Account>(
            id: acc.id,
            itemType: 'account',
            item: acc,
            onEdit: () => _showEditAccountDialog(acc),
            onDelete: () async {
              final success = await ref.read(mockDatabaseProvider.notifier).deleteAccountEmpty(acc.id);
              if (!success) {
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
                return false;
              }
              return true;
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () => context.push('/portfolio/asset/${acc.id}'),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.darkPrimary.withOpacity(0.12),
                      child: Icon(_getAccountIcon(acc.type), color: AppColors.darkPrimary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(acc.type.toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text(
                      format.format(bal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiabilitiesTab(MockDatabaseState state, String currency) {
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    final ccLiabilities = state.accounts.where((a) => a.isArchived == 0 && a.type == 'credit').toList();
    final peopleLiabilities = state.people.where((p) => p.isArchived == 0 && state.getPersonLiabilityBalance(p.id) > 0).toList();

    final totalCount = ccLiabilities.length + peopleLiabilities.length;

    if (ccLiabilities.isEmpty && peopleLiabilities.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: EmptyStateWidget(
          icon: Icons.trending_down_outlined,
          title: 'No Liabilities Yet',
          description: 'You have zero outstanding dues and your debt balance is empty.',
          action: _buildAddButton('Add New Liability', () => _showAddPersonDialog(false)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: totalCount + 1,
        itemBuilder: (context, index) {
          if (index == totalCount) {
            return _buildAddButton('Add New Liability', () => _showAddPersonDialog(false));
          }

          if (index < ccLiabilities.length) {
            final acc = ccLiabilities[index];
            final bal = state.getAccountLiabilityBalance(acc.id);
            return _buildDismissibleItem<Account>(
              id: acc.id,
              itemType: 'account',
              item: acc,
              onEdit: () => _showEditAccountDialog(acc),
              onDelete: () async {
                final success = await ref.read(mockDatabaseProvider.notifier).deleteAccountEmpty(acc.id);
                if (!success) {
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
                  return false;
                }
                return true;
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  onTap: () => context.push('/portfolio/liability/acc_${acc.id}'),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.darkDanger.withOpacity(0.1),
                        child: const Icon(Icons.credit_card, color: AppColors.darkDanger),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 4),
                            const Text('CREDIT CARD LINE', style: TextStyle(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text(
                        format.format(bal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkDanger),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            final person = peopleLiabilities[index - ccLiabilities.length];
            final bal = state.getPersonLiabilityBalance(person.id);
            return _buildDismissibleItem<Person>(
              id: person.id,
              itemType: 'person_liability',
              item: person,
              onEdit: () => _showEditPersonDialog(person),
              onDelete: () async {
                final success = await ref.read(mockDatabaseProvider.notifier).deletePerson(person.id);
                if (!success) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      
                      title: const Text('Cannot Delete Person', style: TextStyle(color: Colors.white)),
                      content: const Text('This person has associated transactions. Please delete or archive them instead.', style: TextStyle(color: AppColors.grey400)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: AppColors.darkPrimary))),
                      ],
                    ),
                  );
                  return false;
                }
                return true;
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  onTap: () => context.push('/portfolio/liability/person_${person.id}'),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.darkDanger.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppColors.darkDanger),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(person.notes ?? 'LOAN FROM PERSON', style: const TextStyle(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Text(
                        format.format(bal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkDanger),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInvestmentsTab(MockDatabaseState state, String currency) {
    final investments = state.investments.where((i) => i.isArchived == 0).toList();
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    if (investments.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: EmptyStateWidget(
          icon: Icons.show_chart_outlined,
          title: 'No Investments Yet',
          description: 'Track your stocks, mutual funds, and crypto portfolios here.',
          action: _buildAddButton('Add New Investment', _showAddInvestmentDialog),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: investments.length + 1,
        itemBuilder: (context, index) {
          if (index == investments.length) {
            return _buildAddButton('Add New Investment', _showAddInvestmentDialog);
          }
          final inv = investments[index];
          final value = state.getInvestmentMarketValue(inv.id);
          final gain = state.getInvestmentUnrealizedGain(inv.id);

          return _buildDismissibleItem<Investment>(
            id: inv.id,
            itemType: 'investment',
            item: inv,
            onEdit: () => _showEditInvestmentDialog(inv),
            onDelete: () async {
              final success = await ref.read(mockDatabaseProvider.notifier).deleteInvestment(inv.id);
              if (!success) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    
                    title: const Text('Cannot Delete Investment', style: TextStyle(color: Colors.white)),
                    content: const Text('This investment has transaction lots associated with it. Please delete transactions or archive the investment.', style: TextStyle(color: AppColors.grey400)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: AppColors.darkPrimary))),
                    ],
                  ),
                );
                return false;
              }
              return true;
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () => context.push('/portfolio/investment/${inv.id}'),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.darkPrimary.withOpacity(0.12),
                          child: const Icon(Icons.show_chart, color: AppColors.darkPrimary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(inv.symbol ?? inv.type.toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(format.format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              '${gain >= 0 ? '+' : ''}${format.format(gain)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: gain >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReceivablesTab(MockDatabaseState state, String currency) {
    final receivables = state.people.where((p) => p.isArchived == 0 && state.getPersonReceivableBalance(p.id) > 0).toList();
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    if (receivables.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: EmptyStateWidget(
          icon: Icons.handshake_outlined,
          title: 'No Receivables Yet',
          description: 'Your outstanding payment list is empty. You currently have zero outstanding money owed.',
          action: _buildAddButton('Add New Receivable', () => _showAddPersonDialog(true)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: receivables.length + 1,
        itemBuilder: (context, index) {
          if (index == receivables.length) {
            return _buildAddButton('Add New Receivable', () => _showAddPersonDialog(true));
          }
          final person = receivables[index];
          final bal = state.getPersonReceivableBalance(person.id);

          return _buildDismissibleItem<Person>(
            id: person.id,
            itemType: 'person_receivable',
            item: person,
            onEdit: () => _showEditPersonDialog(person),
            onDelete: () async {
              final success = await ref.read(mockDatabaseProvider.notifier).deletePerson(person.id);
              if (!success) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    
                    title: const Text('Cannot Delete Person', style: TextStyle(color: Colors.white)),
                    content: const Text('This person has associated transactions. Please delete or archive them instead.', style: TextStyle(color: AppColors.grey400)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK', style: TextStyle(color: AppColors.darkPrimary))),
                    ],
                  ),
                );
                return false;
              }
              return true;
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () => context.push('/portfolio/receivable/${person.id}'),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.darkSuccess.withOpacity(0.12),
                      child: const Icon(Icons.people_alt_outlined, color: AppColors.darkSuccess),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(person.notes ?? 'OUTSTANDING DEBT', style: const TextStyle(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Text(
                      format.format(bal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkSuccess),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpectedIncomeTab(MockDatabaseState state, String currency) {
    final expected = state.expectedIncomes;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    if (expected.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: EmptyStateWidget(
          icon: Icons.next_plan_outlined,
          title: 'No Expected Income Yet',
          description: 'Plan and track expected cash flow and future income streams.',
          action: _buildAddButton('Add Expected Income', _showAddExpectedDialog),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: expected.length + 1,
        itemBuilder: (context, index) {
          if (index == expected.length) {
            return _buildAddButton('Add Expected Income', _showAddExpectedDialog);
          }
          final inc = expected[index];
          
          Color statusColor = AppColors.darkWarning;
          if (inc.status == 'received') statusColor = AppColors.darkSuccess;
          if (inc.status == 'expired') statusColor = AppColors.grey500;

          return _buildDismissibleItem<ExpectedIncome>(
            id: inc.id,
            itemType: 'expected_income',
            item: inc,
            onEdit: () => _showEditExpectedDialog(inc),
            onDelete: () async {
              await ref.read(mockDatabaseProvider.notifier).deleteExpectedIncome(inc.id);
              return true;
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () => context.push('/portfolio/expected/${inc.id}'),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.12),
                      child: Icon(
                        inc.status == 'received' ? Icons.check : Icons.hourglass_bottom,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inc.source,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                              decoration: inc.status == 'expired' ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inc.status.toUpperCase(),
                            style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      format.format(inc.amount),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: inc.status == 'expired' ? AppColors.grey500 : Colors.white,
                        decoration: inc.status == 'expired' ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalsTab(MockDatabaseState state, String currency) {
    final goals = state.goals.where((g) => g.isArchived == 0).toList();
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    if (goals.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: EmptyStateWidget(
          icon: Icons.flag_outlined,
          title: 'No Goals Yet',
          description: 'Define financial milestones to keep your savings motivated.',
          action: _buildAddButton('Add New Goal', _showAddGoalDialog),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: goals.length + 1,
        itemBuilder: (context, index) {
          if (index == goals.length) {
            return _buildAddButton('Add New Goal', _showAddGoalDialog);
          }
          final goal = goals[index];
          final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) : 0.0;
          final percent = (progress * 100).clamp(0, 100).toStringAsFixed(0);

          return _buildDismissibleItem<Goal>(
            id: goal.id,
            itemType: 'goal',
            item: goal,
            onEdit: () => _showEditGoalDialog(goal),
            onDelete: () async {
              await ref.read(mockDatabaseProvider.notifier).deleteGoal(goal.id);
              return true;
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                onTap: () => context.push('/portfolio/goal/${goal.id}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.darkPrimary.withOpacity(0.12),
                          child: const Icon(Icons.tour_outlined, color: AppColors.darkPrimary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              const SizedBox(height: 4),
                              Text(
                                goal.deadline != null
                                    ? 'DEADLINE: ${DateFormat('yyyy-MM-dd').format(goal.deadline!)}'
                                    : 'NO DEADLINE',
                                style: const TextStyle(fontSize: 10, color: AppColors.grey500, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(format.format(goal.targetAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              '$percent% SAVED',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.darkPrimary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        color: AppColors.darkPrimary,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMtfTab(MockDatabaseState state, String currency) {
    final activePositions = state.mtfPositions.where((p) => p.isClosed == 0).toList();
    final closedPositions = state.mtfPositions.where((p) => p.isClosed == 1).toList();
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);
    final formatDec = NumberFormat.currency(symbol: currency, decimalDigits: 2);

    if (activePositions.isEmpty && closedPositions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: EmptyStateWidget(
          icon: Icons.trending_up_outlined,
          title: 'No MTF Positions Yet',
          description: 'Leverage your capital with Margin Trading Facility to track margin-funded ETF and stock positions.',
          action: _buildAddButton('Add MTF Position', _showAddInvestmentDialog),
        ),
      );
    }

    // Calculations for dashboard
    double totalBorrowed = 0.0;
    double totalOwn = 0.0;
    double totalValue = 0.0;
    double totalInterestAccrued = 0.0;

    for (final pos in activePositions) {
      final inv = state.investments.firstWhereOrNull((i) => i.id == pos.investmentId);
      final currentPrice = inv?.marketValue ?? pos.averagePrice;
      totalBorrowed += pos.borrowedCapital;
      totalOwn += pos.ownCapital;
      totalValue += pos.units * currentPrice;
      totalInterestAccrued += state.transactions
          .where((t) => t.investmentId == pos.investmentId && t.category == 'MTF Interest')
          .fold(0.0, (sum, t) => sum + t.amount);
    }

    final avgLtv = totalValue > 0 ? (totalBorrowed / totalValue * 100) : 0.0;
    final ownRatio = (totalOwn + totalBorrowed) > 0 ? totalOwn / (totalOwn + totalBorrowed) : 0.5;

    // Risk Indicator level
    String riskLevel = 'LOW';
    Color riskColor = AppColors.darkSuccess;
    if (avgLtv >= 75) {
      riskLevel = 'HIGH';
      riskColor = AppColors.darkDanger;
    } else if (avgLtv >= 60) {
      riskLevel = 'MEDIUM';
      riskColor = AppColors.darkWarning;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Dashboard Card
          if (activePositions.isNotEmpty) ...[
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MTF EXPOSURE DASHBOARD', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey500)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: riskColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Text(
                          '$riskLevel RISK',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: riskColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(format.format(totalBorrowed), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            const Text('Total Borrowed', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(format.format(totalInterestAccrued), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            const Text('Total Interest', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${avgLtv.toStringAsFixed(1)}%', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 4),
                            const Text('Avg LTV Ratio', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 12,
                      child: Row(
                        children: [
                          Expanded(
                            flex: (ownRatio * 100).toInt(),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.darkPrimary, AppColors.glow],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: ((1 - ownRatio) * 100).toInt(),
                            child: Container(
                              color: AppColors.grey700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Own: ${format.format(totalOwn)} (${(ownRatio * 100).toStringAsFixed(0)}%)', style: const TextStyle(color: AppColors.glow, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text('Borrowed: ${format.format(totalBorrowed)} (${((1 - ownRatio) * 100).toStringAsFixed(0)}%)', style: const TextStyle(color: AppColors.grey400, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Active Positions Title
          if (activePositions.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ACTIVE POSITION TRACKING', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey500)),
                Text('${activePositions.length} Open', style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500)),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Active Positions Cards
          ...activePositions.map((pos) {
            final inv = state.investments.firstWhereOrNull((i) => i.id == pos.investmentId);
            final currentPrice = inv?.marketValue ?? pos.averagePrice;
            final currentMarketValue = pos.units * currentPrice;
            final totalCost = pos.units * pos.averagePrice;
            final totalInterestPaid = state.transactions
                .where((t) => t.investmentId == pos.investmentId && t.category == 'MTF Interest')
                .fold(0.0, (sum, t) => sum + t.amount);
            final netProfit = currentMarketValue - totalCost - totalInterestPaid;
            final netRoi = pos.ownCapital > 0 ? (netProfit / pos.ownCapital * 100) : 0.0;
            final dailyInterest = pos.borrowedCapital * (pos.interestRate / 100) / 365;
            final ltv = currentMarketValue > 0 ? (pos.borrowedCapital / currentMarketValue * 100) : 0.0;

            Color posRiskColor = AppColors.darkSuccess;
            if (ltv >= 75) {
              posRiskColor = AppColors.darkDanger;
            } else if (ltv >= 60) {
              posRiskColor = AppColors.darkWarning;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pos.instrument, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text('${pos.broker} • ${DateFormat('yyyy-MM-dd').format(pos.openingDate)}', style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          color: AppColors.layer1,
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showEditMtfDialog(pos);
                            } else if (val == 'close') {
                              _showCloseMtfDialog(pos);
                            } else if (val == 'delete') {
                              _showDeleteMtfConfirmDialog(pos);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit Interest/Broker', style: TextStyle(color: Colors.white))),
                            const PopupMenuItem(value: 'close', child: Text('Close (Sell Position)', style: TextStyle(color: AppColors.glow))),
                            const PopupMenuItem(value: 'delete', child: Text('Delete / Force Close', style: TextStyle(color: AppColors.darkDanger))),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.grey700, height: 20),
                    
                    // Stats grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMtfStat('Units Held', pos.units.toStringAsFixed(2)),
                        _buildMtfStat('Avg Price', formatDec.format(pos.averagePrice)),
                        _buildMtfStat('Current Price', formatDec.format(currentPrice)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMtfStat('Own Capital', format.format(pos.ownCapital)),
                        _buildMtfStat('Borrowed', format.format(pos.borrowedCapital)),
                        _buildMtfStat('LTV Ratio', '${ltv.toStringAsFixed(1)}%', valueColor: posRiskColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMtfStat('Daily Int.', '${formatDec.format(dailyInterest)} (${pos.interestRate.toStringAsFixed(1)}%)'),
                        _buildMtfStat('Total Int. Paid', formatDec.format(totalInterestPaid)),
                        _buildMtfStat(
                          'Net Profit', 
                          '${netProfit >= 0 ? '+' : ''}${format.format(netProfit)}', 
                          valueColor: netProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Return on Own Capital (ROI):', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                        Text(
                          '${netRoi >= 0 ? '+' : ''}${netRoi.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: netRoi >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          // Add buttons and spacer
          _buildAddButton('Add MTF Position', _showAddInvestmentDialog),

          // Closed Positions History Section
          if (closedPositions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('CLOSED HISTORY', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey500)),
            const SizedBox(height: 12),
            ...closedPositions.map((pos) {
              final totalInterestPaid = state.transactions
                  .where((t) => t.investmentId == pos.investmentId && t.category == 'MTF Interest')
                  .fold(0.0, (sum, t) => sum + t.amount);
              
              double salePrice = pos.averagePrice; // fallback
              if (state.transactions.any((t) => t.investmentId == pos.investmentId && t.type == 'investment_sell')) {
                final sellTx = state.transactions.firstWhere((t) => t.investmentId == pos.investmentId && t.type == 'investment_sell');
                salePrice = pos.units > 0 ? sellTx.amount / pos.units : sellTx.amount;
              }
              final totalProceeds = pos.units * salePrice;
              final totalCost = pos.units * pos.averagePrice;
              final realizedNetProfit = totalProceeds - totalCost - totalInterestPaid;
              final realizedRoi = pos.ownCapital > 0 ? (realizedNetProfit / pos.ownCapital * 100) : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      collapsedIconColor: Colors.white,
                      iconColor: Colors.white,
                      title: Text(pos.instrument, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white70)),
                      subtitle: Text(
                        'Closed ${pos.closedDate != null ? DateFormat('yyyy-MM-dd').format(pos.closedDate!) : 'n/a'} • Net: ${realizedNetProfit >= 0 ? '+' : ''}${format.format(realizedNetProfit)} (${realizedRoi.toStringAsFixed(1)}% ROI)',
                        style: TextStyle(fontSize: 11, color: realizedNetProfit >= 0 ? AppColors.darkSuccess.withValues(alpha: 0.8) : AppColors.darkDanger.withValues(alpha: 0.8)),
                      ),
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMtfStat('Broker', pos.broker),
                            _buildMtfStat('Buy Price', formatDec.format(pos.averagePrice)),
                            _buildMtfStat('Sell Price', formatDec.format(salePrice)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMtfStat('Own Capital', format.format(pos.ownCapital)),
                            _buildMtfStat('Borrowed', format.format(pos.borrowedCapital)),
                            _buildMtfStat('Interest Paid', formatDec.format(totalInterestPaid)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Realized Return (ROI):', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                            Text(
                              '${realizedNetProfit >= 0 ? '+' : ''}${realizedNetProfit.toStringAsFixed(2)} (${realizedRoi.toStringAsFixed(2)}% ROI)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: realizedNetProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showDeleteMtfConfirmDialog(pos),
                          icon: const Icon(Icons.delete, color: AppColors.darkDanger, size: 14),
                          label: const Text('Delete from History', style: TextStyle(color: AppColors.darkDanger, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMtfStat(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _showEditMtfDialog(MtfPosition pos) {
    final brokerController = TextEditingController(text: pos.broker);
    final interestRateController = TextEditingController(text: pos.interestRate.toString());

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit MTF Position', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: brokerController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Broker', labelStyle: TextStyle(color: AppColors.grey500)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: interestRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Interest Rate % p.a.', labelStyle: TextStyle(color: AppColors.grey500)),
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
              final broker = brokerController.text.trim();
              final rate = double.tryParse(interestRateController.text.trim()) ?? pos.interestRate;
              if (broker.isNotEmpty) {
                final updated = pos.copyWith(
                  broker: broker,
                  interestRate: rate,
                  updatedAt: DateTime.now().toUtc(),
                );
                ref.read(mockDatabaseProvider.notifier).editMtfPosition(updated);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCloseMtfDialog(MtfPosition pos) {
    final salePriceController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Close MTF Position', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You are closing ${pos.units.toStringAsFixed(2)} units of ${pos.instrument}.', style: const TextStyle(color: AppColors.grey400, fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: salePriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Sale Price / Unit', labelStyle: TextStyle(color: AppColors.grey500)),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  'Sale Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary),
                contentPadding: EdgeInsets.zero,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: pos.openingDate,
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
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
                final salePrice = double.tryParse(salePriceController.text.trim()) ?? 0.0;
                if (salePrice > 0) {
                  ref.read(mockDatabaseProvider.notifier).closeMtfPosition(pos.id, salePrice, selectedDate.toUtc());
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.glow),
              child: const Text('Close & Repay', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteMtfConfirmDialog(MtfPosition pos) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Position?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently delete this MTF position record and its associated investment. All historical interest accrual records will remain in your transaction log, but the tracker will be cleared. This action cannot be undone.',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(mockDatabaseProvider.notifier).deleteMtfPosition(pos.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, color: AppColors.glow, size: 18),
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.layer1.withValues(alpha: 0.5),
          side: const BorderSide(color: AppColors.glassBorder, width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'bank':
        return Icons.account_balance;
      case 'cash':
        return Icons.wallet;
      case 'wallet':
        return Icons.phone_android;
      case 'credit':
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
