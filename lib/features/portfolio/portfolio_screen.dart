import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/providers/mock_database.dart';
import '../../core/providers/dependency_provider.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/constants/asset_constants.dart';
import '../../database/database.dart';

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
    String type = 'mutual_fund';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
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
                onChanged: (val) => type = val!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: unitsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Units', labelStyle: TextStyle(color: AppColors.grey500)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Price / Unit', labelStyle: TextStyle(color: AppColors.grey500)),
                    ),
                  ),
                ],
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
              final units = double.tryParse(unitsController.text.trim()) ?? 0.0;
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;

              if (name.isNotEmpty && units > 0 && price > 0) {
                final notifier = ref.read(mockDatabaseProvider.notifier);
                final inv = notifier.addInvestment(name, type, symbol.isNotEmpty ? symbol : null, 'Manual creation', units * price);
                notifier.buyInvestment(inv.id, 'acc_primary_bank_uuid', units, price, 'Opening Buy', DateTime.now().toUtc());
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
    String type = inv.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          
          title: const Text('Edit Investment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
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
                final symbol = symbolController.text.trim();
                final notes = notesController.text.trim();
                if (name.isNotEmpty) {
                  ref.read(mockDatabaseProvider.notifier).updateInvestment(
                        inv.id,
                        name,
                        type,
                        symbol.isNotEmpty ? symbol : null,
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
      length: 6,
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetPaths.noAssets,
                height: AssetConstants.emptyStateImageHeight,
                semanticLabel: AssetConstants.noAssetsLabel,
              ),
              const SizedBox(height: 8),
              _buildAddButton('Add New Account', _showAddAccountDialog),
            ],
          ),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetPaths.noLiabilities,
                height: AssetConstants.emptyStateImageHeight,
                semanticLabel: AssetConstants.noLiabilitiesLabel,
              ),
              const SizedBox(height: 8),
              _buildAddButton('Add New Liability', () => _showAddPersonDialog(false)),
            ],
          ),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetPaths.noInvestments,
                height: AssetConstants.emptyStateImageHeight,
                semanticLabel: AssetConstants.noInvestmentsLabel,
              ),
              const SizedBox(height: 8),
              _buildAddButton('Add New Investment', _showAddInvestmentDialog),
            ],
          ),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetPaths.noReceivables,
                height: AssetConstants.emptyStateImageHeight,
                semanticLabel: AssetConstants.noReceivablesLabel,
              ),
              const SizedBox(height: 8),
              _buildAddButton('Add New Receivable', () => _showAddPersonDialog(true)),
            ],
          ),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetPaths.noExpectedIncome,
                height: AssetConstants.emptyStateImageHeight,
                semanticLabel: AssetConstants.noExpectedIncomeLabel,
              ),
              const SizedBox(height: 8),
              _buildAddButton('Add Expected Income', _showAddExpectedDialog),
            ],
          ),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AssetPaths.noGoals,
                height: AssetConstants.emptyStateImageHeight,
                semanticLabel: AssetConstants.noGoalsLabel,
              ),
              const SizedBox(height: 8),
              _buildAddButton('Add New Goal', _showAddGoalDialog),
            ],
          ),
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
          backgroundColor: AppColors.layer1.withOpacity(0.5),
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
