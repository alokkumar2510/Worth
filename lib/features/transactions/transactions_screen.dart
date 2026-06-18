import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/providers/mock_database.dart';
import '../../core/providers/dependency_provider.dart';
import 'presentation/widgets/add_transaction_sheet.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/constants/asset_constants.dart';
import '../../database/database.dart' hide Transaction;
import '../../database/database.dart' as db show Transaction;
import 'domain/entities/transaction.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _formatTransactionDate(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDay = DateTime(localDate.year, localDate.month, localDate.day);

    if (txDay == today) {
      return 'Today, ${DateFormat('h:mm a').format(localDate)}';
    } else if (txDay == yesterday) {
      return 'Yesterday, ${DateFormat('h:mm a').format(localDate)}';
    } else {
      return DateFormat('d MMM yyyy').format(localDate);
    }
  }

  // Collapsible search state
  bool _isSearchOpen = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Smart Filter state
  String _selectedFilterChip = 'All';

  // Advanced Filters state
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterAccountId;
  String? _filterType;
  String? _filterPersonId;
  String? _filterInvestmentId;
  double? _filterMinAmount;
  double? _filterMaxAmount;
  String? _filterStatus; // 'active', 'voided'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddTransactionSheet(BuildContext context, {int? initialTab, String? initialMoreType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        initialSegmentedIndex: initialTab,
        initialMoreType: initialMoreType,
      ),
    );
  }

  void _confirmVoid(BuildContext context, String txId, String? notes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Void Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to void this transaction: "${notes ?? 'Untitled'}"?\nThis will create an inverse adjustment transaction and reverse all balance cache effects.',
          style: const TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(mockDatabaseProvider.notifier).voidTransaction(txId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction successfully voided.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Void', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditTransactionDialog(BuildContext context, Transaction tx) {
    final amountController = TextEditingController(text: tx.amount.toStringAsFixed(2));
    final notesController = TextEditingController(text: tx.notes ?? '');
    DateTime selectedDate = tx.transactionDate;
    final dbState = ref.read(mockDatabaseProvider);
    String selectedCategory = tx.category ?? '';
    if (dbState.categories.isNotEmpty && !dbState.categories.contains(selectedCategory)) {
      selectedCategory = dbState.categories.first;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                const SizedBox(height: 16),
                if (tx.type == 'income' || tx.type == 'expense') ...[
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
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
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
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
                  decoration: const InputDecoration(labelText: 'Notes'),
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
                final amt = double.tryParse(amountController.text.trim()) ?? tx.amount;
                final cat = selectedCategory;
                final notes = notesController.text.trim();

                final updated = db.Transaction(
                  id: tx.id,
                  type: tx.type,
                  amount: amt,
                  category: cat.isNotEmpty ? cat : tx.category,
                  fromAccountId: tx.fromAccountId,
                  toAccountId: tx.toAccountId,
                  personId: tx.personId,
                  investmentId: tx.investmentId,
                  voidedTransactionId: tx.voidedTransactionId,
                  notes: notes.isNotEmpty ? notes : null,
                  pricePerUnit: tx.pricePerUnit,
                  units: tx.units,
                  transactionDate: selectedDate,
                  createdAt: tx.createdAt,
                  updatedAt: DateTime.now().toUtc(),
                  syncStatus: 'pending',
                );

                ref.read(mockDatabaseProvider.notifier).editTransaction(updated);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction updated successfully.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLongPressMenu(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        borderRadius: 32.0,
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.grey700, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text(
                tx.notes ?? tx.type.replaceAll('_', ' ').toUpperCase(),
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.glow),
                title: const Text('View Details', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showTransactionDetailsSheet(context, tx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.darkPrimary),
                title: const Text('Edit Transaction', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditTransactionDialog(context, tx);
                },
              ),
              if (tx.voidedTransactionId == null && tx.type != 'void')
                ListTile(
                  leading: const Icon(Icons.block_outlined, color: AppColors.darkDanger),
                  title: const Text('Void Transaction', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmVoid(context, tx.id, tx.notes);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.copy_outlined, color: AppColors.darkSuccess),
                title: const Text('Duplicate Transaction', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(mockDatabaseProvider.notifier).duplicateTransaction(tx.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction duplicated.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.darkDanger),
                title: const Text('Delete Transaction', style: TextStyle(color: AppColors.darkDanger)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await _showDeleteConfirmDialog(context);
                  if (confirm == true) {
                    ref.read(mockDatabaseProvider.notifier).deleteTransaction(tx.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction deleted.')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This action cannot be undone and will permanently remove this record.',
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
  }

  void _showTransactionDetailsSheet(BuildContext context, Transaction tx) {
    final dbState = ref.read(mockDatabaseProvider);
    final currency = dbState.currency;

    String fromAccName = dbState.accounts.firstWhere((a) => a.id == tx.fromAccountId, orElse: () => Account(id: '', name: 'None', type: 'bank', notes: null, isArchived: 0, createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 'synced')).name;
    String toAccName = dbState.accounts.firstWhere((a) => a.id == tx.toAccountId, orElse: () => Account(id: '', name: 'None', type: 'bank', notes: null, isArchived: 0, createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 'synced')).name;
    String linkedPerson = tx.personId != null ? dbState.people.firstWhere((p) => p.id == tx.personId, orElse: () => Person(id: '', name: 'Unknown', phone: null, notes: null, isArchived: 0, createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 'synced')).name : 'None';
    String linkedInvestment = tx.investmentId != null ? dbState.investments.firstWhere((i) => i.id == tx.investmentId, orElse: () => Investment(id: '', name: 'None', type: 'mutual_fund', symbol: '', marketValue: 0.0, marketValueUpdatedAt: DateTime.now(), isArchived: 0, notes: null, createdAt: DateTime.now(), updatedAt: DateTime.now(), syncStatus: 'synced')).name : 'None';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassCard(
        borderRadius: 32.0,
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.grey700, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'TRANSACTION DETAILS',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Text(
                '$currency${NumberFormat.decimalPattern().format(tx.amount)}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.0),
              ),
              const SizedBox(height: 24),

              _buildDetailRow('Date & Time', DateFormat('EEEE, d MMMM yyyy, h:mm a').format(tx.transactionDate.toLocal())),
              _buildDetailRow('Type', tx.type.replaceAll('_', ' ').toUpperCase()),
              if (tx.category != null) _buildDetailRow('Category', tx.category!),
              if (tx.fromAccountId != null) _buildDetailRow('Source Account', fromAccName),
              if (tx.toAccountId != null) _buildDetailRow('Destination Account', toAccName),
              if (tx.personId != null) _buildDetailRow('Linked Entity / Person', linkedPerson),
              if (tx.investmentId != null) _buildDetailRow('Linked Investment', linkedInvestment),
              if (tx.units != null && tx.pricePerUnit != null)
                _buildDetailRow('Units / Price', '${tx.units} units @ $currency${tx.pricePerUnit}'),
              if (tx.notes != null) _buildDetailRow('Notes', tx.notes!),
              _buildDetailRow('Status', tx.voidedTransactionId != null ? 'VOIDED' : 'ACTIVE', 
                valueColor: tx.voidedTransactionId != null ? AppColors.darkDanger : AppColors.darkSuccess),
              
              const SizedBox(height: 24),
              TactileButton(
                color: AppColors.layer2,
                border: const BorderSide(color: AppColors.glassBorder),
                onTap: () {
                  Navigator.pop(context);
                  _showEditTransactionDialog(context, tx);
                },
                child: const Text('Edit Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showAdvancedFiltersModal(BuildContext context) {
    final dbState = ref.read(mockDatabaseProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Advanced Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date Range Button
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date Range', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                  subtitle: Text(
                    _filterStartDate == null && _filterEndDate == null
                        ? 'All Time'
                        : '${_filterStartDate != null ? DateFormat('MM/dd/yy').format(_filterStartDate!) : 'Any'} - ${_filterEndDate != null ? DateFormat('MM/dd/yy').format(_filterEndDate!) : 'Any'}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.date_range_outlined, color: AppColors.darkPrimary),
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: _filterStartDate != null && _filterEndDate != null
                          ? DateTimeRange(start: _filterStartDate!, end: _filterEndDate!)
                          : null,
                    );
                    if (picked != null) {
                      setModalState(() {
                        _filterStartDate = picked.start;
                        _filterEndDate = picked.end;
                      });
                    }
                  },
                ),
                const Divider(color: AppColors.glassBorder),

                // Account Filter
                DropdownButtonFormField<String?>(
                  value: _filterAccountId,
                  dropdownColor: AppColors.layer1,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Filter by Account'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Accounts')),
                    ...dbState.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                  ],
                  onChanged: (val) => setModalState(() => _filterAccountId = val),
                ),
                const SizedBox(height: 16),

                // Type Filter
                DropdownButtonFormField<String?>(
                  value: _filterType,
                  dropdownColor: AppColors.layer1,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Filter by Type'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Types')),
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                    DropdownMenuItem(value: 'transfer', child: Text('Transfer')),
                    DropdownMenuItem(value: 'borrow_money', child: Text('Borrow Loan')),
                    DropdownMenuItem(value: 'repay_money', child: Text('Repay Loan')),
                    DropdownMenuItem(value: 'lend_money', child: Text('Lend Money')),
                    DropdownMenuItem(value: 'recover_money', child: Text('Recover Debt')),
                    DropdownMenuItem(value: 'investment_buy', child: Text('Buy Investment')),
                    DropdownMenuItem(value: 'investment_sell', child: Text('Sell Investment')),
                    DropdownMenuItem(value: 'expected_income_received', child: Text('Received Expected')),
                  ],
                  onChanged: (val) => setModalState(() => _filterType = val),
                ),
                const SizedBox(height: 16),

                // Linked Person Filter
                DropdownButtonFormField<String?>(
                  value: _filterPersonId,
                  dropdownColor: AppColors.layer1,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Filter by Person'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No Person Filter')),
                    ...dbState.people.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                  ],
                  onChanged: (val) => setModalState(() => _filterPersonId = val),
                ),
                const SizedBox(height: 16),

                // Linked Investment Filter
                DropdownButtonFormField<String?>(
                  value: _filterInvestmentId,
                  dropdownColor: AppColors.layer1,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Filter by Investment'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('No Investment Filter')),
                    ...dbState.investments.map((i) => DropdownMenuItem(value: i.id, child: Text(i.name))),
                  ],
                  onChanged: (val) => setModalState(() => _filterInvestmentId = val),
                ),
                const SizedBox(height: 16),

                // Amount range
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(labelText: 'Min Amount'),
                        onChanged: (val) => _filterMinAmount = double.tryParse(val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(labelText: 'Max Amount'),
                        onChanged: (val) => _filterMaxAmount = double.tryParse(val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Filter
                DropdownButtonFormField<String?>(
                  value: _filterStatus,
                  dropdownColor: AppColors.layer1,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: 'active', child: Text('Active Only')),
                    DropdownMenuItem(value: 'voided', child: Text('Voided Only')),
                  ],
                  onChanged: (val) => setModalState(() => _filterStatus = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filterStartDate = null;
                  _filterEndDate = null;
                  _filterAccountId = null;
                  _filterType = null;
                  _filterPersonId = null;
                  _filterInvestmentId = null;
                  _filterMinAmount = null;
                  _filterMaxAmount = null;
                  _filterStatus = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Reset', style: TextStyle(color: AppColors.darkDanger)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Apply state change globally to filter the feed
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
              child: const Text('Apply', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    // Precompile account lookup maps for instant search query intelligence
    final accountsMap = {for (final a in dbState.accounts) a.id: a.name};
    final peopleMap = {for (final p in dbState.people) p.id: p.name};
    final investmentsMap = {for (final i in dbState.investments) i.id: i.name};

    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits root WorthBackground
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Premium Glass Header
                _buildGlassHeader(),

                Expanded(
                  child: transactionsAsync.when(
                    data: (txList) {
                      // Perform calculation of inflows/outflows for the Summary Strip
                      final now = DateTime.now();
                      final todayStart = DateTime(now.year, now.month, now.day);
                      final weekStart = todayStart.subtract(const Duration(days: 7));
                      final monthStart = DateTime(now.year, now.month, 1);

                      double todayIn = 0, todayOut = 0;
                      double weekIn = 0, weekOut = 0;
                      double monthIn = 0, monthOut = 0;

                      for (final tx in txList) {
                        if (tx.voidedTransactionId != null || tx.type == 'void') continue;

                        final date = tx.transactionDate;
                        final amt = tx.amount;
                        final isToday = date.isAfter(todayStart) || date.isAtSameMomentAs(todayStart);
                        final isThisWeek = date.isAfter(weekStart) || date.isAtSameMomentAs(weekStart);
                        final isThisMonth = date.isAfter(monthStart) || date.isAtSameMomentAs(monthStart);

                        final isInf = ['income', 'recover_money', 'borrow_money', 'investment_sell', 'expected_income_received'].contains(tx.type);
                        final isOutf = ['expense', 'lend_money', 'repay_money', 'investment_buy'].contains(tx.type);

                        if (isInf) {
                          if (isToday) todayIn += amt;
                          if (isThisWeek) weekIn += amt;
                          if (isThisMonth) monthIn += amt;
                        } else if (isOutf) {
                          if (isToday) todayOut += amt;
                          if (isThisWeek) weekOut += amt;
                          if (isThisMonth) monthOut += amt;
                        }
                      }

                      // Apply filter transformations
                      final filteredTxs = txList.where((tx) {
                        // A. Search Matcher
                        if (_searchQuery.isNotEmpty) {
                          final query = _searchQuery.toLowerCase();
                          final notesMatch = tx.notes?.toLowerCase().contains(query) ?? false;
                          final categoryMatch = tx.category?.toLowerCase().contains(query) ?? false;
                          final typeMatch = tx.type.toLowerCase().contains(query);
                          final fromAccMatch = tx.fromAccountId != null && (accountsMap[tx.fromAccountId]?.toLowerCase().contains(query) ?? false);
                          final toAccMatch = tx.toAccountId != null && (accountsMap[tx.toAccountId]?.toLowerCase().contains(query) ?? false);
                          final personMatch = tx.personId != null && (peopleMap[tx.personId]?.toLowerCase().contains(query) ?? false);
                          final investMatch = tx.investmentId != null && (investmentsMap[tx.investmentId]?.toLowerCase().contains(query) ?? false);
                          final amtMatch = tx.amount.toString().contains(query);
                          
                          if (!notesMatch && !categoryMatch && !typeMatch && !fromAccMatch && !toAccMatch && !personMatch && !investMatch && !amtMatch) {
                            return false;
                          }
                        }

                        // B. Smart Filter Chip Selection
                        if (_selectedFilterChip != 'All') {
                          if (_selectedFilterChip == 'Income' && tx.type != 'income') return false;
                          if (_selectedFilterChip == 'Expense' && tx.type != 'expense') return false;
                          if (_selectedFilterChip == 'Transfer' && tx.type != 'transfer') return false;
                          if (_selectedFilterChip == 'Investment' && !['investment_buy', 'investment_sell'].contains(tx.type)) return false;
                          if (_selectedFilterChip == 'Receivable' && !['lend_money', 'recover_money'].contains(tx.type)) return false;
                          if (_selectedFilterChip == 'Liability' && !['borrow_money', 'repay_money'].contains(tx.type)) return false;
                          if (_selectedFilterChip == 'Expected Income' && tx.type != 'expected_income_received') return false;
                        }

                        // C. Advanced Filtering parameters
                        if (_filterStartDate != null && tx.transactionDate.isBefore(_filterStartDate!)) return false;
                        if (_filterEndDate != null && tx.transactionDate.isAfter(_filterEndDate!.add(const Duration(days: 1)))) return false;
                        if (_filterAccountId != null && tx.fromAccountId != _filterAccountId && tx.toAccountId != _filterAccountId) return false;
                        if (_filterType != null && tx.type != _filterType) return false;
                        if (_filterPersonId != null && tx.personId != _filterPersonId) return false;
                        if (_filterInvestmentId != null && tx.investmentId != _filterInvestmentId) return false;
                        if (_filterMinAmount != null && tx.amount < _filterMinAmount!) return false;
                        if (_filterMaxAmount != null && tx.amount > _filterMaxAmount!) return false;
                        if (_filterStatus != null) {
                          final isVoided = tx.voidedTransactionId != null || tx.type == 'void';
                          if (_filterStatus == 'voided' && !isVoided) return false;
                          if (_filterStatus == 'active' && isVoided) return false;
                        }

                        return true;
                      }).toList();

                      // Group filtered list into Timeline structure
                      final Map<String, List<Transaction>> timelineMap = {};

                      for (final tx in filteredTxs) {
                        final localDate = tx.transactionDate.toLocal();
                        final today = DateTime(now.year, now.month, now.day);
                        final yesterday = today.subtract(const Duration(days: 1));
                        final txDay = DateTime(localDate.year, localDate.month, localDate.day);

                        String groupKey;
                        if (txDay == today) {
                          groupKey = 'Today';
                        } else if (txDay == yesterday) {
                          groupKey = 'Yesterday';
                        } else {
                          groupKey = DateFormat('d MMM yyyy').format(localDate);
                        }
                        timelineMap.putIfAbsent(groupKey, () => []).add(tx);
                      }

                      final groupKeys = timelineMap.keys.toList();

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // 2. Financial Summary Strip
                          SliverToBoxAdapter(
                            child: _buildSummaryStrip(
                              currency: currency,
                              todayIn: todayIn, todayOut: todayOut,
                              weekIn: weekIn, weekOut: weekOut,
                              monthIn: monthIn, monthOut: monthOut,
                            ),
                          ),

                          // 3. Smart Filters Row
                          SliverToBoxAdapter(
                            child: _buildSmartFiltersRow(),
                          ),

                          // 4. Timeline Feed
                          if (groupKeys.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 96),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, groupIdx) {
                                    final dateTitle = groupKeys[groupIdx];
                                    final dayList = timelineMap[dateTitle]!;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Timeline Date Header
                                        Padding(
                                          padding: const EdgeInsets.only(left: 36.0, top: 20.0, bottom: 8.0),
                                          child: Text(
                                            dateTitle.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.grey500,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),

                                        // Timeline events list
                                        ...List.generate(dayList.length, (idx) {
                                          final tx = dayList[idx];
                                          // Connect indicators continuously
                                          final isFirst = groupIdx == 0 && idx == 0;
                                          final isLast = groupIdx == groupKeys.length - 1 && idx == dayList.length - 1;

                                          return StaggeredTransitionWidget(
                                            index: idx + (groupIdx * 3),
                                            child: _buildTimelineEventRow(tx, currency, isFirst, isLast),
                                          );
                                        }),
                                      ],
                                    );
                                  },
                                  childCount: groupKeys.length,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.darkPrimary)),
                    error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),

            // 5. Expandable Morphing FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: ExpandableFab(
                onSelectType: (tabIdx, moreType) {
                  _openAddTransactionSheet(context, initialTab: tabIdx, initialMoreType: moreType);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER BUILDER
  Widget _buildGlassHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.glassBorder, width: 1.0)),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _isSearchOpen
                      ? TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search amount, notes, or accounts...',
                            hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 13),
                            prefixIcon: const Icon(Icons.search_outlined, color: AppColors.grey500, size: 18),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _isSearchOpen = false;
                                });
                              },
                              child: const Icon(Icons.close_rounded, color: AppColors.grey500, size: 18),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Activity',
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'All financial movements',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                ),
                if (!_isSearchOpen) ...[
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                    onPressed: () {
                      setState(() {
                        _isSearchOpen = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.tune_rounded,
                      color: (_filterStartDate != null || _filterAccountId != null || _filterType != null || _filterPersonId != null || _filterInvestmentId != null || _filterStatus != null)
                          ? AppColors.glow
                          : Colors.white,
                      size: 22,
                    ),
                    onPressed: () => _showAdvancedFiltersModal(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SUMMARY STRIP BUILDER
  Widget _buildSummaryStrip({
    required String currency,
    required double todayIn, required double todayOut,
    required double weekIn, required double weekOut,
    required double monthIn, required double monthOut,
  }) {
    final summaries = [
      {'title': 'Today', 'in': todayIn, 'out': todayOut, 'net': todayIn - todayOut},
      {'title': 'This Week', 'in': weekIn, 'out': weekOut, 'net': weekIn - weekOut},
      {'title': 'This Month', 'in': monthIn, 'out': monthOut, 'net': monthIn - monthOut},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: summaries.length,
        itemBuilder: (context, idx) {
          final s = summaries[idx];
          final netVal = s['net'] as double;
          final netColor = netVal >= 0 ? AppColors.darkSuccess : AppColors.darkDanger;

          return Container(
            width: 190,
            margin: const EdgeInsets.only(right: 12),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s['title'] as String,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward, color: AppColors.darkSuccess, size: 10),
                              const SizedBox(width: 2),
                              AnimatedMoneyText(value: s['in'] as double, currency: currency, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward, color: AppColors.darkDanger, size: 10),
                              const SizedBox(width: 2),
                              AnimatedMoneyText(value: s['out'] as double, currency: currency, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'NET',
                            style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.grey500),
                          ),
                          AnimatedMoneyText(
                            value: netVal.abs(),
                            currency: '${netVal < 0 ? '-' : ''}$currency',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
                            color: netColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // SMART FILTERS BUILDER
  Widget _buildSmartFiltersRow() {
    final chips = ['All', 'Income', 'Expense', 'Transfer', 'Investment', 'Receivable', 'Liability', 'Expected Income'];

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: chips.length,
        itemBuilder: (context, idx) {
          final label = chips[idx];
          final isSelected = _selectedFilterChip == label;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.grey400,
              ),
              selectedColor: AppColors.darkPrimary.withOpacity(0.25),
              backgroundColor: AppColors.layer1.withOpacity(0.35),
              checkmarkColor: Colors.white,
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder,
                  width: 1.0,
                ),
              ),
              shadowColor: AppColors.darkPrimary.withOpacity(0.3),
              elevation: isSelected ? 4 : 0,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilterChip = label;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  // TIMELINE EVENT ROW BUILDER
  Widget _buildTimelineEventRow(Transaction tx, String currency, bool isFirst, bool isLast) {
    final isVoided = tx.voidedTransactionId != null || tx.type == 'void';
    
    // Determine Type Colors
    Color typeColor;
    if (isVoided) {
      typeColor = AppColors.grey500;
    } else {
      switch (tx.type) {
        case 'income':
          typeColor = AppColors.darkSuccess;
          break;
        case 'expense':
          typeColor = AppColors.darkDanger;
          break;
        case 'transfer':
          typeColor = Colors.blueAccent;
          break;
        case 'investment_buy':
        case 'investment_sell':
          typeColor = AppColors.darkPrimary;
          break;
        case 'borrow_money':
        case 'repay_money':
          typeColor = Colors.orangeAccent;
          break;
        case 'lend_money':
        case 'recover_money':
          typeColor = Colors.tealAccent;
          break;
        case 'expected_income_received':
          typeColor = Colors.amber;
          break;
        default:
          typeColor = Colors.white;
      }
    }

    final isNegative = ['expense', 'lend_money', 'repay_money', 'investment_buy'].contains(tx.type);
    String directionSymbol = isNegative ? '↓' : '↑';
    if (tx.type == 'transfer') directionSymbol = '↔';
    if (tx.type == 'void') directionSymbol = '⟲';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    String sign = isNegative ? '-' : '+';
    Color valueColor = isNegative ? AppColors.darkDanger : AppColors.darkSuccess;

    if (tx.type == 'transfer' || tx.type == 'void') {
      sign = '';
      valueColor = isDark ? Colors.white : AppColors.lightText;
    }

    final amountText = '$sign$currency${NumberFormat.decimalPattern().format(tx.amount)}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline vertical track column
        SizedBox(
          width: 32,
          height: 96,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Top Line Segment
              if (!isFirst)
                Positioned(
                  top: 0,
                  bottom: 56,
                  child: Container(width: 2, color: AppColors.glassBorder),
                ),
              // Glowing Node Circle
              Positioned(
                top: 40,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: typeColor.withOpacity(0.2),
                    border: Border.all(color: typeColor, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Line Segment
              if (!isLast)
                Positioned(
                  top: 54,
                  bottom: 0,
                  child: Container(width: 2, color: AppColors.glassBorder),
                ),
            ],
          ),
        ),

        // Event Card (Dismissible and sliding wrapper)
        Expanded(
          child: Dismissible(
            key: Key('timeline_tx_${tx.id}'),
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
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
              child: const Icon(Icons.edit_outlined, color: AppColors.glow),
            ),
            secondaryBackground: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
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
              child: const Icon(Icons.delete_outline, color: AppColors.darkDanger),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _showEditTransactionDialog(context, tx);
                return false;
              } else {
                final confirm = await _showDeleteConfirmDialog(context);
                if (confirm == true) {
                  ref.read(mockDatabaseProvider.notifier).deleteTransaction(tx.id);
                  return true;
                }
                return false;
              }
            },
             child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onLongPress: () => _showLongPressMenu(context, tx),
                child: GlassCard(
                  borderRadius: 28.0,
                  onTap: () => _showTransactionDetailsSheet(context, tx),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  borderColor: typeColor.withOpacity(0.12),
                  child: Row(
                  children: [
                    // Flow Direction Indicator
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: typeColor.withOpacity(0.08),
                      ),
                      child: Center(
                        child: Text(
                          directionSymbol,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: typeColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Transaction Event Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.notes ?? tx.type.replaceAll('_', ' ').toUpperCase(),
                            style: GoogleFonts.inter(
                              color: isVoided ? AppColors.grey500 : Colors.white,
                              decoration: isVoided ? TextDecoration.lineThrough : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                tx.type.replaceAll('_', ' ').toUpperCase(),
                                style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                              if (tx.category != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.grey700),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tx.category!,
                                  style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Amount Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountText,
                          style: GoogleFonts.inter(
                            color: isVoided ? AppColors.grey500 : valueColor,
                            decoration: isVoided ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isVoided)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.darkDanger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'VOID',
                              style: TextStyle(color: AppColors.darkDanger, fontSize: 7, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              _formatTransactionDate(tx.transactionDate),
                              style: const TextStyle(fontSize: 10, color: AppColors.grey500),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ],
    );
  }

  // EMPTY STATE BUILDER
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkPrimary.withOpacity(0.06),
                border: Border.all(color: AppColors.darkPrimary.withOpacity(0.18), width: 1.5),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.darkPrimary,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Transactions Yet',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first financial record to activate the activity timeline feed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.grey500,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            TactileButton(
              gradient: const LinearGradient(
                colors: [AppColors.darkPrimary, AppColors.glow],
              ),
              width: 180,
              onTap: () => _openAddTransactionSheet(context),
              child: const Text(
                'Add Transaction',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAGGERED TRANSITION ANIMATION WRAPPER
// ─────────────────────────────────────────────────────────────────────────────
class StaggeredTransitionWidget extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayStep;

  const StaggeredTransitionWidget({
    required this.child,
    required this.index,
    this.delayStep = const Duration(milliseconds: 35),
    super.key,
  });

  @override
  State<StaggeredTransitionWidget> createState() => _StaggeredTransitionWidgetState();
}

class _StaggeredTransitionWidgetState extends State<StaggeredTransitionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.delayStep * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED MONEY COUNTER
// ─────────────────────────────────────────────────────────────────────────────
class AnimatedMoneyText extends StatelessWidget {
  final double value;
  final String currency;
  final TextStyle style;
  final Color? color;

  const AnimatedMoneyText({
    required this.value,
    required this.currency,
    required this.style,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final formatted = NumberFormat.decimalPattern().format(val);
        return Text(
          '$currency$formatted',
          style: style.copyWith(color: color),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXPANDABLE MORPHING FAB
// ─────────────────────────────────────────────────────────────────────────────
class ExpandableFab extends StatefulWidget {
  final Function(int segmentedIndex, String? moreType) onSelectType;
  const ExpandableFab({required this.onSelectType, super.key});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab> with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 480,
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return _isOpen
        ? Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          )
        : const SizedBox.shrink();
  }

  List<Widget> _buildExpandingActionButtons() {
    final actions = [
      {'label': 'Income', 'color': AppColors.darkSuccess, 'index': 0, 'moreType': null, 'icon': Icons.arrow_downward},
      {'label': 'Expense', 'color': AppColors.darkDanger, 'index': 1, 'moreType': null, 'icon': Icons.arrow_upward},
      {'label': 'Transfer', 'color': Colors.blueAccent, 'index': 2, 'moreType': null, 'icon': Icons.swap_horiz},
      {'label': 'Investment', 'color': AppColors.darkPrimary, 'index': 3, 'moreType': 'investment_buy', 'icon': Icons.add_chart},
      {'label': 'Receivable', 'color': Colors.tealAccent, 'index': 3, 'moreType': 'lend_money', 'icon': Icons.keyboard_double_arrow_right},
      {'label': 'Liability', 'color': Colors.orangeAccent, 'index': 3, 'moreType': 'borrow_money', 'icon': Icons.call_received},
    ];

    final children = <Widget>[];
    final count = actions.length;
    
    for (int i = 0; i < count; i++) {
      final act = actions[i];
      
      children.add(
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            final progress = _expandAnimation.value;
            final offset = (i + 1) * 58.0 * progress;
            final scale = 0.5 + (0.5 * progress);
            final opacity = progress.clamp(0.0, 1.0);
            
            return Positioned(
              right: 4.0,
              bottom: 4.0 + offset,
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xEC0B0B0F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  act['label'] as String,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  _toggle();
                  widget.onSelectType(act['index'] as int, act['moreType'] as String?);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.layer2,
                    border: Border.all(color: (act['color'] as Color).withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: (act['color'] as Color).withOpacity(0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    act['icon'] as IconData,
                    color: act['color'] as Color,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            final progress = _expandAnimation.value;
            return Transform.rotate(
              angle: progress * (math.pi / 4.0), // Rotate to create an X close button
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.darkPrimary, AppColors.glow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(0.35),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Tactile press-scaling Button
class TactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final BorderSide? border;
  final double borderRadius;
  final double? width;
  final double height;

  const TactileButton({
    required this.child,
    this.onTap,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius = 18.0,
    this.width,
    this.height = 50.0,
    super.key,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _controller.forward(),
      onTapUp: widget.onTap == null ? null : (_) => _controller.reverse(),
      onTapCancel: widget.onTap == null ? null : () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border != null ? Border.fromBorderSide(widget.border!) : null,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
