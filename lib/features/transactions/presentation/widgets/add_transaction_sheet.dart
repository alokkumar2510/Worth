import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_segmented_control.dart';
import '../../../../core/providers/mock_database.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final int? initialSegmentedIndex;
  final String? initialMoreType;

  const AddTransactionSheet({
    this.initialSegmentedIndex,
    this.initialMoreType,
    super.key,
  });

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _transactionDate = DateTime.now();
  TimeOfDay _transactionTime = TimeOfDay.now();
  
  // Custom segment index: 0 = Income, 1 = Expense, 2 = Transfer, 3 = More
  late int _segmentedIndex;
  
  // Advanced Transaction Type (visible when segment is "More")
  late String _selectedMoreType;

  @override
  void initState() {
    super.initState();
    _segmentedIndex = widget.initialSegmentedIndex ?? 1; // Default to Expense
    _selectedMoreType = widget.initialMoreType ?? 'borrow_money'; // Default
    _category = _segmentedIndex == 0 ? 'General' : 'Food';
  }
  
  // Field selectors
  String? _selectedFromAccountId;
  String? _selectedToAccountId;
  String? _selectedPersonId;
  String? _selectedInvestmentId;
  String? _selectedExpectedIncomeId;
  
  // Additional fields for investments
  final _unitsController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _purchaseDate;
  final _purchaseTimeController = TextEditingController();
  
  // MTF Fields
  bool _isMtf = false;
  final _brokerController = TextEditingController();
  final _ownCapitalController = TextEditingController();
  final _interestRateController = TextEditingController();
  
  String _category = 'Food';
  bool _showNotes = false;

  final List<String> _incomeCategories = [
    'General', 'Salary', 'Investment Return', 'Miscellaneous'
  ];

  final List<String> _expenseCategories = [
    'Food',
    'Travel',
    'Shopping',
    'Education',
    'Bills',
    'Subscriptions',
    'Health',
    'Entertainment',
    'Fees',
    'Miscellaneous'
  ];


  final List<Map<String, String>> _moreTypes = [
    {'type': 'borrow_money', 'label': 'Borrow Money'},
    {'type': 'repay_money', 'label': 'Repay Loan'},
    {'type': 'lend_money', 'label': 'Lend Money'},
    {'type': 'recover_money', 'label': 'Recover Debt'},
    {'type': 'investment_buy', 'label': 'Buy Investment'},
    {'type': 'investment_sell', 'label': 'Sell Investment'},
    {'type': 'expected_income_received', 'label': 'Receive Expected Income'},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _unitsController.dispose();
    _priceController.dispose();
    _purchaseTimeController.dispose();
    _brokerController.dispose();
    _ownCapitalController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0 && _segmentedIndex != 3) return; // Allow investment buys/sells to calculate amount

    final notifier = ref.read(mockDatabaseProvider.notifier);
    
    // Determine active type
    String finalType = 'expense';
    if (_segmentedIndex == 0) finalType = 'income';
    if (_segmentedIndex == 2) finalType = 'transfer';
    if (_segmentedIndex == 3) finalType = _selectedMoreType;

    final notes = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;

    final txDateTime = DateTime(
      _transactionDate.year,
      _transactionDate.month,
      _transactionDate.day,
      _transactionTime.hour,
      _transactionTime.minute,
    ).toUtc();

    if (finalType == 'income') {
      await notifier.addTransaction(
        type: 'income',
        amount: amount,
        category: _category,
        toAccountId: _selectedToAccountId,
        notes: notes,
        date: txDateTime,
      );
    } else if (finalType == 'expense') {
      await notifier.addTransaction(
        type: 'expense',
        amount: amount,
        category: _category,
        fromAccountId: _selectedFromAccountId,
        notes: notes,
        date: txDateTime,
      );
    } else if (finalType == 'transfer') {
      await notifier.addTransaction(
        type: 'transfer',
        amount: amount,
        fromAccountId: _selectedFromAccountId,
        toAccountId: _selectedToAccountId,
        notes: notes ?? 'Funds Transfer',
        date: txDateTime,
      );
    } else if (finalType == 'borrow_money') {
      if (_selectedPersonId != null) {
        await notifier.addBorrowTransaction(_selectedPersonId!, _selectedToAccountId ?? 'acc_primary_bank_uuid', amount, notes, txDateTime);
      }
    } else if (finalType == 'repay_money') {
      if (_selectedPersonId != null) {
        await notifier.addRepayTransaction(_selectedPersonId!, _selectedFromAccountId ?? 'acc_primary_bank_uuid', amount, notes, txDateTime);
      }
    } else if (finalType == 'lend_money') {
      if (_selectedPersonId != null) {
        await notifier.addLendTransaction(_selectedPersonId!, _selectedFromAccountId ?? 'acc_primary_bank_uuid', amount, notes, txDateTime);
      }
    } else if (finalType == 'recover_money') {
      if (_selectedPersonId != null) {
        await notifier.addRecoverTransaction(_selectedPersonId!, _selectedToAccountId ?? 'acc_primary_bank_uuid', amount, notes, txDateTime);
      }
    } else if (finalType == 'investment_buy') {
      final units = double.tryParse(_unitsController.text.trim()) ?? 0.0;
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      if (_selectedInvestmentId != null && units > 0 && price > 0) {
        final finalPurchaseDate = _purchaseDate ?? txDateTime;
        final purchaseTimeStr = _purchaseTimeController.text.trim().isNotEmpty
            ? _purchaseTimeController.text.trim()
            : null;

        if (_isMtf) {
          final broker = _brokerController.text.trim();
          final ownCap = double.tryParse(_ownCapitalController.text.trim()) ?? (units * price * 0.5);
          final intRate = double.tryParse(_interestRateController.text.trim()) ?? 12.0;
          final borrowed = (units * price) - ownCap;

          final inv = ref.read(mockDatabaseProvider).investments.firstWhere((i) => i.id == _selectedInvestmentId);
          await notifier.addMtfPosition(
            broker: broker.isNotEmpty ? broker : 'Broker',
            instrument: inv.name,
            units: units,
            averagePrice: price,
            ownCapital: ownCap,
            borrowedCapital: borrowed,
            interestRate: intRate,
            openingDate: finalPurchaseDate,
            interestStartDate: finalPurchaseDate,
            purchaseDate: finalPurchaseDate,
            purchaseTime: purchaseTimeStr,
            investmentId: _selectedInvestmentId,
            notes: notes,
          );
        } else {
          await notifier.buyInvestment(_selectedInvestmentId!, _selectedFromAccountId ?? 'acc_primary_bank_uuid', units, price, notes, finalPurchaseDate);
        }
      }
    } else if (finalType == 'investment_sell') {
      final units = double.tryParse(_unitsController.text.trim()) ?? 0.0;
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      if (_selectedInvestmentId != null && units > 0 && price > 0) {
        await notifier.sellInvestment(_selectedInvestmentId!, _selectedToAccountId ?? 'acc_primary_bank_uuid', units, price, notes, txDateTime);
      }
    } else if (finalType == 'expected_income_received') {
      if (_selectedExpectedIncomeId != null) {
        await notifier.markExpectedIncomeReceived(_selectedExpectedIncomeId!, _selectedToAccountId ?? 'acc_primary_bank_uuid');
      }
    }

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction saved successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    if (dbState.categories.isNotEmpty && !dbState.categories.contains(_category)) {
      _category = dbState.categories.first;
    }

    // Accounts available
    final activeAccounts = dbState.accounts.where((a) => a.isArchived == 0).toList();
    final cashAccounts = activeAccounts.where((a) => a.type != 'credit').toList();

    // Default select
    if (activeAccounts.isNotEmpty) {
      _selectedFromAccountId ??= activeAccounts.first.id;
      _selectedToAccountId ??= cashAccounts.isNotEmpty ? cashAccounts.first.id : activeAccounts.first.id;
    }
    if (dbState.people.isNotEmpty) {
      _selectedPersonId ??= dbState.people.first.id;
    }
    if (dbState.investments.isNotEmpty) {
      _selectedInvestmentId ??= dbState.investments.first.id;
    }
    if (dbState.expectedIncomes.isNotEmpty) {
      _selectedExpectedIncomeId ??= dbState.expectedIncomes.firstWhere((i) => i.status == 'pending', orElse: () => dbState.expectedIncomes.first).id;
    }

    final isTransfer = _segmentedIndex == 2;
    final isIncome = _segmentedIndex == 0;
    final isExpense = _segmentedIndex == 1;
    final isMore = _segmentedIndex == 3;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13131F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1.5)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Slide indicator
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.grey700, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header Title
            Text(
              'Add Transaction',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // 1. Transaction Type Segmented Control
            CustomSegmentedControl(
              segments: const ['Income', 'Expense', 'Transfer', 'More ▾'],
              selectedIndex: _segmentedIndex,
              onValueChanged: (index) {
                setState(() {
                  _segmentedIndex = index;
                  if (index == 0) {
                    _category = 'General';
                  } else if (index == 1) {
                    _category = 'Food';
                  }
                });
              },
            ),
            const SizedBox(height: 20),

            // 2. Advanced Type Selector (shows when "More" is selected)
            if (isMore) ...[
              DropdownButtonFormField<String>(
                value: _selectedMoreType,
                dropdownColor: AppColors.layer1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Select Event Type',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
                items: _moreTypes.map((t) => DropdownMenuItem(
                  value: t['type'],
                  child: Text(t['label']!),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMoreType = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // 3. Amount Field (Except for Expected Income conversion which has fixed amount)
            if (!(isMore && _selectedMoreType == 'expected_income_received')) ...[
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: AppColors.grey700),
                  prefixText: '$currency ',
                  prefixStyle: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 4. Dynamic/Progressive Disclosure Fields based on type
            
            // From Account Selector (Where money leaves)
            if (isExpense || isTransfer || (isMore && ['repay_money', 'lend_money', 'investment_buy'].contains(_selectedMoreType))) ...[
              DropdownButtonFormField<String>(
                value: _selectedFromAccountId,
                dropdownColor: AppColors.layer1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Source Account (Paid From)',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
                items: activeAccounts.map((acc) => DropdownMenuItem(
                  value: acc.id,
                  child: Text('${acc.name} (${acc.type.toUpperCase()})'),
                )).toList(),
                onChanged: (val) => setState(() => _selectedFromAccountId = val),
              ),
              const SizedBox(height: 16),
            ],

            // To Account Selector (Where money deposits)
            if (isIncome || isTransfer || (isMore && ['borrow_money', 'recover_money', 'investment_sell', 'expected_income_received'].contains(_selectedMoreType))) ...[
              DropdownButtonFormField<String>(
                value: _selectedToAccountId,
                dropdownColor: AppColors.layer1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Destination Account (Received Into)',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
                items: cashAccounts.map((acc) => DropdownMenuItem(
                  value: acc.id,
                  child: Text(acc.name),
                )).toList(),
                onChanged: (val) => setState(() => _selectedToAccountId = val),
              ),
              const SizedBox(height: 16),
            ],

            // Person Selector (For lending/borrowing)
            if (isMore && ['borrow_money', 'repay_money', 'lend_money', 'recover_money'].contains(_selectedMoreType)) ...[
              DropdownButtonFormField<String>(
                value: _selectedPersonId,
                dropdownColor: AppColors.layer1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Linked Person',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
                 items: dbState.people.whereType<Person>().map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.name),
                )).toList(),
                onChanged: (val) => setState(() => _selectedPersonId = val),
              ),
              const SizedBox(height: 16),
            ],

            // Investment Selector & Lot buy/sell details
            if (isMore && ['investment_buy', 'investment_sell'].contains(_selectedMoreType)) ...[
              DropdownButtonFormField<String>(
                value: _selectedInvestmentId,
                dropdownColor: AppColors.layer1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Select Investment',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
                items: dbState.investments.map((i) => DropdownMenuItem(
                  value: i.id,
                  child: Text(i.name),
                )).toList(),
                onChanged: (val) => setState(() => _selectedInvestmentId = val),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _unitsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Units', labelStyle: TextStyle(color: AppColors.grey500)),
                      onChanged: (val) => _calculateInvestmentAmount(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Price per Unit',
                        labelStyle: const TextStyle(color: AppColors.grey500),
                        prefixText: '$currency ',
                        prefixStyle: const TextStyle(color: Colors.white),
                      ),
                      onChanged: (val) => _calculateInvestmentAmount(),
                    ),
                  ),
                ],
              ),
              if (_selectedMoreType == 'investment_buy') ...[
                // Purchase Date & Time Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _purchaseDate != null
                        ? 'Purchase Date: ${DateFormat('dd MMM yyyy').format(_purchaseDate!)}'
                        : 'Purchase Date: Not Selected',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  subtitle: const Text('Tap to select purchase date', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _purchaseDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _purchaseDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _purchaseTimeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Purchase Time (Optional, e.g. 10:30 AM)',
                    labelStyle: TextStyle(color: AppColors.grey500),
                    hintText: 'HH:MM or standard format',
                    hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('MTF Position?', style: TextStyle(color: Colors.white, fontSize: 14)),
                  subtitle: const Text('Margin Trading Facility', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                  value: _isMtf,
                  activeColor: AppColors.glow,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) {
                    setState(() {
                      _isMtf = val;
                      if (_isMtf) {
                        final u = double.tryParse(_unitsController.text.trim()) ?? 0.0;
                        final p = double.tryParse(_priceController.text.trim()) ?? 0.0;
                        _ownCapitalController.text = (u * p * 0.5).toStringAsFixed(2);
                      }
                    });
                  },
                ),
                if (_isMtf) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _brokerController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Broker', labelStyle: TextStyle(color: AppColors.grey500)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ownCapitalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Own Capital', labelStyle: TextStyle(color: AppColors.grey500)),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _interestRateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Interest Rate % p.a.', labelStyle: TextStyle(color: AppColors.grey500)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      final u = double.tryParse(_unitsController.text.trim()) ?? 0.0;
                      final p = double.tryParse(_priceController.text.trim()) ?? 0.0;
                      final own = double.tryParse(_ownCapitalController.text.trim()) ?? (u * p * 0.5);
                      final borrowed = (u * p) - own;
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.layer2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Borrowed Capital:', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                            Text(
                              '$currency${borrowed.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                ],
              ],
              const SizedBox(height: 16),
            ],

            // Expected Income Selector
            if (isMore && _selectedMoreType == 'expected_income_received') ...[
              DropdownButtonFormField<String>(
                value: _selectedExpectedIncomeId,
                dropdownColor: AppColors.layer1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Select Expected Income item',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
                items: dbState.expectedIncomes.where((i) => i.status == 'pending').map((i) => DropdownMenuItem(
                  value: i.id,
                  child: Text('${i.source} ($currency${i.amount})'),
                )).toList(),
                onChanged: (val) => setState(() => _selectedExpectedIncomeId = val),
              ),
              const SizedBox(height: 16),
            ],

            // Category Selector (Income/Expense only)
            if (isIncome || isExpense) ...[
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppColors.layer1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
                items: dbState.categories.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                )).toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),
            ],

            // Date & Time Picker
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date: ${DateFormat('dd MMM yyyy').format(_transactionDate)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary, size: 16),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _transactionDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _transactionDate = picked;
                          _purchaseDate = picked;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Time: ${_transactionTime.format(context)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.access_time, color: AppColors.darkPrimary, size: 16),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _transactionTime,
                      );
                      if (picked != null) {
                        setState(() {
                          _transactionTime = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 5. Notes Toggle & Field
            GestureDetector(
              onTap: () => setState(() => _showNotes = !_showNotes),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      _showNotes ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                      color: AppColors.grey500,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    const Text('Add notes / details', style: TextStyle(color: AppColors.grey500, fontSize: 13)),
                  ],
                ),
              ),
            ),
            if (_showNotes) ...[
              TextField(
                controller: _notesController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter notes description...',
                  hintStyle: TextStyle(color: AppColors.grey700, fontSize: 13),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder)),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 6. Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                
              ),
              child: const Text('Save Transaction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _calculateInvestmentAmount() {
    final units = double.tryParse(_unitsController.text.trim()) ?? 0.0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    if (units > 0 && price > 0) {
      _amountController.text = (units * price).toStringAsFixed(2);
      if (_isMtf) {
        _ownCapitalController.text = (units * price * 0.5).toStringAsFixed(2);
      }
    }
  }
}
