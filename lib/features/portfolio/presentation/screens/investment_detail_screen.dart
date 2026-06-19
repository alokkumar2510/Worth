import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import '../../../../core/widgets/calculation_audit_panel.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart';
import '../widgets/adjustment_widgets.dart';
import '../../../../features/investments/domain/entities/sip.dart' as domain;
import '../../../../core/providers/dependency_provider.dart';

class InvestmentDetailScreen extends ConsumerStatefulWidget {
  final String investmentId;

  const InvestmentDetailScreen({required this.investmentId, super.key});

  @override
  ConsumerState<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends ConsumerState<InvestmentDetailScreen> {
  final _marketValueController = TextEditingController();
  final _buyUnitsController = TextEditingController();
  final _buyPriceController = TextEditingController();
  
  final _sellUnitsController = TextEditingController();
  final _sellPriceController = TextEditingController();

  @override
  void dispose() {
    _marketValueController.dispose();
    _buyUnitsController.dispose();
    _buyPriceController.dispose();
    _sellUnitsController.dispose();
    _sellPriceController.dispose();
    super.dispose();
  }

  void _showUpdateMarketValueDialog(Investment inv, String currency) {
    _marketValueController.text = inv.marketValue?.toString() ?? '0';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Update Market Value', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _marketValueController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'New Market Value',
            labelStyle: const TextStyle(color: AppColors.grey500),
            prefixText: '$currency ',
            prefixStyle: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_marketValueController.text.trim()) ?? 0.0;
              if (val > 0) {
                ref.read(mockDatabaseProvider.notifier).updateInvestmentMarketValue(inv.id, val);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Market value updated.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
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
    DateTime? purchaseDate = inv.purchaseDate;
    String? purchaseTime = inv.purchaseTime;

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
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: purchaseDate ?? inv.createdAt,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => purchaseDate = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Purchase Date',
                      labelStyle: const TextStyle(color: AppColors.grey500),
                      suffixIcon: purchaseDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: AppColors.grey500),
                              onPressed: () {
                                setState(() => purchaseDate = null);
                              },
                            )
                          : null,
                    ),
                    child: Text(
                      purchaseDate == null ? 'Not Set (Defaults to Created Date)' : DateFormat('dd MMM yyyy').format(purchaseDate!),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    TimeOfDay initial = const TimeOfDay(hour: 9, minute: 30);
                    if (purchaseTime != null) {
                      final parts = purchaseTime!.split(':');
                      if (parts.length == 2) {
                        initial = TimeOfDay(
                          hour: int.tryParse(parts[0]) ?? 9,
                          minute: int.tryParse(parts[1]) ?? 30,
                        );
                      }
                    }
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: initial,
                    );
                    if (picked != null) {
                      setState(() {
                        purchaseTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Purchase Time',
                      labelStyle: const TextStyle(color: AppColors.grey500),
                      suffixIcon: purchaseTime != null
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: AppColors.grey500),
                              onPressed: () {
                                setState(() => purchaseTime = null);
                              },
                            )
                          : null,
                    ),
                    child: Text(
                      purchaseTime == null ? 'Not Set' : purchaseTime!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
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
                        purchaseDate: purchaseDate,
                        purchaseTime: purchaseTime,
                      );
                  if (price > 0) {
                    ref.read(mockDatabaseProvider.notifier).updateInvestmentMarketValue(inv.id, price);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Investment details updated.')),
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

  void _confirmDeleteInvestment(Investment inv) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Investment?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this investment? This will hide it from all views and calculations. You can undo this action immediately.',
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
              await notifier.deleteInvestmentSoft(inv.id);
              context.pop(); // pop details screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Investment "${inv.name}" deleted.'),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: AppColors.darkPrimary,
                    onPressed: () {
                      notifier.restoreInvestment(inv);
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

  void _showBuyDialog(Investment inv, String currency) {
    DateTime? purchaseDate;
    final purchaseTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Purchase Lot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _buyUnitsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Units Purchased', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _buyPriceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Price per Unit',
                    labelStyle: const TextStyle(color: AppColors.grey500),
                    prefixText: '$currency ',
                    prefixStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Purchase Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    purchaseDate != null
                        ? 'Purchase Date: ${DateFormat('dd MMM yyyy').format(purchaseDate!)}'
                        : 'Purchase Date: Not Selected',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  subtitle: const Text('Tap to select purchase date', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: purchaseDate ?? DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        purchaseDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: purchaseTimeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Purchase Time (Optional, e.g. 10:30 AM)',
                    labelStyle: TextStyle(color: AppColors.grey500),
                    hintText: 'HH:MM or standard format',
                    hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                purchaseTimeController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
            ElevatedButton(
              onPressed: () async {
                final units = double.tryParse(_buyUnitsController.text.trim()) ?? 0.0;
                final price = double.tryParse(_buyPriceController.text.trim()) ?? 0.0;
                if (units > 0 && price > 0) {
                  DateTime finalPurchaseDate;
                  if (purchaseDate == null) {
                    final confirmToday = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('No Purchase Date Selected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        content: const Text(
                          'You have not selected a purchase date. Would you like to use today\'s date as the purchase date?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Select Date', style: TextStyle(color: AppColors.darkPrimary)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
                            child: const Text('Use Today', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirmToday == true) {
                      finalPurchaseDate = DateTime.now();
                    } else {
                      return; // Abort saving
                    }
                  } else {
                    finalPurchaseDate = purchaseDate!;
                  }

                  final purchaseTimeStr = purchaseTimeController.text.trim();
                  final notes = purchaseTimeStr.isNotEmpty ? 'Purchase at $purchaseTimeStr' : null;

                  await ref.read(mockDatabaseProvider.notifier).buyInvestment(
                    inv.id,
                    'acc_primary_bank_uuid',
                    units,
                    price,
                    notes,
                    finalPurchaseDate,
                  );
                  _buyUnitsController.clear();
                  _buyPriceController.clear();
                  purchaseTimeController.dispose();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lot recorded: $units units bought.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
              child: const Text('Save Lot', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSellDialog(Investment inv, String currency, List<InvestmentLot> lots) {
    final activeLots = lots.where((l) => l.unitsRemaining > 0).toList()..sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final double unitsToSell = double.tryParse(_sellUnitsController.text.trim()) ?? 0.0;
            final double salePrice = double.tryParse(_sellPriceController.text.trim()) ?? 0.0;
            
            final List<String> lotSimulationLogs = [];
            double remainingUnitsToAllocate = unitsToSell;
            double estimatedCostBasis = 0.0;
            double estimatedProceeds = unitsToSell * salePrice;
            
            if (unitsToSell > 0 && salePrice > 0) {
              for (final lot in activeLots) {
                if (remainingUnitsToAllocate <= 0) break;
                final double unitsConsumed = (lot.unitsRemaining >= remainingUnitsToAllocate) 
                    ? remainingUnitsToAllocate 
                    : lot.unitsRemaining;
                
                remainingUnitsToAllocate -= unitsConsumed;
                estimatedCostBasis += unitsConsumed * lot.costPerUnit;
                
                lotSimulationLogs.add(
                  '• Lot ${DateFormat('dd MMM yy').format(lot.purchaseDate)}: $unitsConsumed units @ $currency${lot.costPerUnit}',
                );
              }
            }
            
            final double estimatedGain = estimatedProceeds - estimatedCostBasis;
            final hasSufficientUnits = activeLots.fold(0.0, (double sum, l) => sum + l.unitsRemaining) >= unitsToSell;

            return AlertDialog(
              
              
              title: const Text('Record FIFO Sale', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _sellUnitsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Units to Sell', labelStyle: TextStyle(color: AppColors.grey500)),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sellPriceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Sale Price per Unit',
                        labelStyle: const TextStyle(color: AppColors.grey500),
                        prefixText: '$currency ',
                        prefixStyle: const TextStyle(color: Colors.white),
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    
                    if (unitsToSell > 0 && salePrice > 0) ...[
                      const Text(
                        'FIFO CONSUMPTION SIMULATION',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(18)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!hasSufficientUnits)
                              const Text('⚠️ INSUFFICIENT UNITS HELD!', style: TextStyle(color: AppColors.darkDanger, fontWeight: FontWeight.bold, fontSize: 11))
                            else ...[
                              ...lotSimulationLogs.map((log) => Text(log, style: const TextStyle(color: AppColors.grey400, fontSize: 12))),
                              const Divider(color: AppColors.glassBorder, height: 16),
                              Text(
                                'Est. Realized Gain: $currency${NumberFormat.decimalPattern().format(estimatedGain)}',
                                style: TextStyle(
                                  color: estimatedGain >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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
                  onPressed: (unitsToSell <= 0 || salePrice <= 0 || !hasSufficientUnits) 
                      ? null 
                      : () async {
                          await ref.read(mockDatabaseProvider.notifier).sellInvestment(
                            inv.id,
                            'acc_primary_bank_uuid',
                            unitsToSell,
                            salePrice,
                            null,
                            DateTime.now().toUtc(),
                          );
                          _sellUnitsController.clear();
                          _sellPriceController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sale transaction and FIFO consumption logged.')),
                          );
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
                  child: const Text('Confirm Sale', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    final inv = dbState.investments.firstWhereOrNull((i) => i.id == widget.investmentId);

    if (inv == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Investment not found.', style: TextStyle(color: Colors.white))),
      );
    }

    final sipsAsync = ref.watch(activeSipsProvider);
    final sip = sipsAsync.value?.firstWhereOrNull((s) => s.investmentId == inv.id);

    final cap = dbState.getInvestmentInvestedCapital(inv.id);
    final value = dbState.getInvestmentMarketValue(inv.id);
    final unrealized = dbState.getInvestmentUnrealizedGain(inv.id);
    final realized = dbState.getInvestmentRealizedGain(inv.id);
    final units = dbState.getInvestmentUnitsHeld(inv.id);
    
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    final purchaseDateTime = inv.purchaseDate ?? inv.createdAt;
    final today = DateTime.now();
    final difference = today.difference(purchaseDateTime);
    final holdingDays = difference.inDays >= 0 ? difference.inDays : 0;

    final lots = dbState.investmentLots.where((l) => l.investmentId == inv.id).toList();
    final txs = dbState.transactions.where((t) => t.investmentId == inv.id && t.voidedTransactionId == null).toList();

    final createdStr = DateFormat('dd MMM yyyy, hh:mm a').format(inv.createdAt.toLocal());
    final updatedStr = DateFormat('dd MMM yyyy, hh:mm a').format(inv.updatedAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(inv.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer1,
            onSelected: (menuVal) async {
              if (menuVal == 'edit') {
                _showEditInvestmentDialog(inv);
              } else if (menuVal == 'update_price') {
                _showUpdateMarketValueDialog(inv, currency);
              } else if (menuVal == 'adjust_units') {
                _showAdjustUnitsDialog(context, ref, inv, units);
              } else if (menuVal == 'view_history') {
                showAdjustmentHistorySheet(context, inv.id, 'investment', inv.name);
              } else if (menuVal == 'duplicate') {
                await ref.read(mockDatabaseProvider.notifier).duplicateInvestment(inv.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Investment "${inv.name}" duplicated.')),
                );
              } else if (menuVal == 'archive') {
                await ref.read(mockDatabaseProvider.notifier).archiveInvestment(inv.id);
                if (context.mounted) {
                  context.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Investment "${inv.name}" archived.')),
                  );
                }
              } else if (menuVal == 'restore') {
                await ref.read(mockDatabaseProvider.notifier).unarchiveInvestment(inv.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Investment "${inv.name}" unarchived successfully.')),
                  );
                }
              } else if (menuVal == 'delete') {
                _confirmDeleteInvestment(inv);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Details', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'update_price',
                child: Text('Update Live Price', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'adjust_units',
                child: Text('Adjust Units', style: TextStyle(color: Colors.white)),
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
                value: inv.isArchived == 1 ? 'restore' : 'archive',
                child: Text(inv.isArchived == 1 ? 'Restore from Archive' : 'Archive', style: const TextStyle(color: Colors.white)),
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
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _showUpdateMarketValueDialog(inv, currency),
                      child: _buildMetricCard('MARKET VALUE', format.format(value), Colors.white, isEditable: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard('INVESTED CAPITAL', format.format(cap), AppColors.grey400),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'UNREALIZED GAIN', 
                      '${unrealized >= 0 ? '+' : ''}${format.format(unrealized)}',
                      unrealized >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'REALIZED GAIN (FIFO)', 
                      format.format(realized),
                      realized >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'HOLDING PERIOD', 
                      '$holdingDays Days',
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'PURCHASE DATE', 
                      inv.purchaseDate != null
                          ? DateFormat('dd MMM yyyy').format(inv.purchaseDate!)
                          : DateFormat('dd MMM yyyy').format(inv.createdAt),
                      AppColors.grey400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFundingDetailsCard(inv, dbState),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Units Held: ${units.toStringAsFixed(2)}  ·  Last Value Sync: 2 days ago',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showBuyDialog(inv, currency),
                      icon: const Icon(Icons.add),
                      label: const Text('Record Buy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showSellDialog(inv, currency, lots),
                      icon: const Icon(Icons.remove),
                      label: const Text('Record Sell', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Builder(
                builder: (context) {
                  final double mvAdjs = dbState.adjustments
                      .where((a) => a.entityId == inv.id && a.entityType == 'investment_market_value')
                      .fold(0.0, (sum, a) => sum + a.adjustedAmount);
                  final double capAdjs = dbState.adjustments
                      .where((a) => a.entityId == inv.id && a.entityType == 'investment_capital')
                      .fold(0.0, (sum, a) => sum + a.adjustedAmount);

                  return CalculationAuditPanel(
                    title: 'Verify Investment Calculations',
                    formula: 'Market Value = (Live Price * Units Held) + MV Adjustments\n'
                        'Invested Capital = Sum(lot.unitsRemaining * lot.costPerUnit) + Capital Adjustments\n'
                        'Unrealized Gain = Market Value - Invested Capital',
                    inputs: {
                      'Live Price / Unit': format.format(inv.marketValue ?? 0.0),
                      'Units Held': units.toStringAsFixed(4),
                      'Market Value Adjustments': format.format(mvAdjs),
                      'Capital Adjustments': format.format(capAdjs),
                      'Computed Market Value': format.format(value),
                      'Computed Invested Capital': format.format(cap),
                    },
                    output: 'Unrealized Gain: ${format.format(unrealized)}',
                    steps: [
                      'Get the current price per unit: ${format.format(inv.marketValue ?? 0.0)}.',
                      'Calculate current units held by summing remaining lots: ${units.toStringAsFixed(4)} units.',
                      'Calculate initial market value: Price * Units = ${format.format((inv.marketValue ?? 0.0) * units)}.',
                      'Apply market value adjustments (${format.format(mvAdjs)}) to get final Market Value: ${format.format(value)}.',
                      'Sum cost basis of remaining lots plus capital adjustments (${format.format(capAdjs)}) to get Invested Capital: ${format.format(cap)}.',
                      'Calculate Unrealized Gain: Market Value (${format.format(value)}) - Invested Capital (${format.format(cap)}) = ${format.format(unrealized)}.',
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              _buildSipSection(inv, currency, sip),
              const SizedBox(height: 28),

              ExpansionTile(
                title: Text('View purchase lots (${lots.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                childrenPadding: EdgeInsets.zero,
                tilePadding: EdgeInsets.zero,
                children: [
                  if (lots.isEmpty)
                    const Padding(padding: EdgeInsets.all(16.0), child: Text('No purchase lots found.', style: TextStyle(color: AppColors.grey500)))
                  else
                    ...lots.map((lot) {
                      final lotDate = DateFormat('dd MMM yyyy').format(lot.purchaseDate);
                      final remainingUnits = lot.unitsRemaining;
                      final totalCost = lot.unitsPurchased * lot.costPerUnit;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lotDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Remaining: ${remainingUnits.toStringAsFixed(2)} / ${lot.unitsPurchased.toStringAsFixed(2)} units',
                                    style: const TextStyle(fontSize: 11, color: AppColors.grey500),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(format.format(totalCost), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text('@ $currency${lot.costPerUnit} / unit', style: const TextStyle(fontSize: 10, color: AppColors.grey500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Investment Transaction Logs',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              if (txs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: Text('No transactions recorded for this asset.', style: TextStyle(color: AppColors.grey500))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: txs.length,
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    final isBuy = tx.type == 'investment_buy';
                    final symbol = isBuy ? '-' : '+';
                    final color = isBuy ? AppColors.darkDanger : AppColors.darkSuccess;
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
                                  Text(tx.notes ?? tx.type.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(formattedDate, style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                                ],
                              ),
                            ),
                            Text(
                              '$symbol$currency${NumberFormat.decimalPattern().format(tx.amount)}',
                              style: TextStyle(
                                color: color,
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

  Widget _buildMetricCard(String title, String value, Color valueColor, {bool isEditable = false}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isEditable)
                const Icon(Icons.edit, size: 10, color: AppColors.grey500),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFundingDetailsCard(Investment inv, MockDatabaseState dbState) {
    final source = inv.fundingSource ?? 'existing_cash';
    final sourceNames = {
      'existing_cash': 'Existing Cash',
      'salary_income': 'Salary Income',
      'business_income': 'Business Income',
      'receivable_collected': 'Receivables Collected',
      'liability_borrowed': 'Liability / Borrowed Money',
      'mixed_sources': 'Mixed Sources',
    };
    
    final sourceName = sourceNames[source] ?? source;
    
    // Find linked liability name if applicable
    String? linkedLiabilityName;
    if (inv.fundingLiabilityId != null) {
      final account = dbState.accounts.firstWhereOrNull((a) => a.id == inv.fundingLiabilityId);
      if (account != null) {
        linkedLiabilityName = '${account.name} (Credit Account)';
      } else {
        final person = dbState.people.firstWhereOrNull((p) => p.id == inv.fundingLiabilityId);
        if (person != null) {
          linkedLiabilityName = '${person.name} (Person Creditor)';
        }
      }
    }

    // Determine debt percentage or description
    String debtInfo = '0% (Self-Funded)';
    if (source == 'liability_borrowed') {
      debtInfo = '100% (Debt-Funded)';
    } else if (source == 'mixed_sources') {
      if (inv.fundingDetails != null && inv.fundingDetails!.isNotEmpty) {
        try {
          final decoded = jsonDecode(inv.fundingDetails!);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('debt_pct')) {
              debtInfo = '${decoded['debt_pct']}% Debt / ${100 - (decoded['debt_pct'] as num)}% Self';
            } else {
              debtInfo = inv.fundingDetails!;
            }
          }
        } catch (e) {
          debtInfo = inv.fundingDetails!;
        }
      } else {
        debtInfo = '50% Debt (Estimated Mixed)';
      }
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      borderColor: source == 'liability_borrowed' 
          ? AppColors.darkDanger.withOpacity(0.3) 
          : source == 'mixed_sources'
              ? AppColors.darkWarning.withOpacity(0.3)
              : AppColors.darkSuccess.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                source == 'liability_borrowed' 
                    ? Icons.trending_down_outlined 
                    : Icons.account_balance_wallet_outlined,
                color: source == 'liability_borrowed' 
                    ? AppColors.darkDanger 
                    : AppColors.darkSuccess,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'FUNDING SOURCE & DEBT STATUS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Source', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(
                sourceName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Debt Ratio / Details', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(
                debtInfo,
                style: TextStyle(
                  color: source == 'liability_borrowed' 
                      ? AppColors.darkDanger 
                      : source == 'mixed_sources' 
                          ? AppColors.darkWarning 
                          : AppColors.darkSuccess,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (linkedLiabilityName != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Linked Liability', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
                Text(
                  linkedLiabilityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAdjustUnitsDialog(BuildContext context, WidgetRef ref, Investment inv, double currentUnits) {
    final controller = TextEditingController(text: currentUnits.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Units', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the new number of units purchased. This will update your investment holdings.',
              style: TextStyle(color: AppColors.grey400, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Number of Units',
                labelStyle: TextStyle(color: AppColors.grey500),
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
              final newUnits = double.tryParse(controller.text.trim());
              if (newUnits == null || newUnits <= 0) return;
              
              Navigator.pop(context); // close dialog
              
              await ref.read(mockDatabaseProvider.notifier).updateInvestmentUnits(inv.id, newUnits);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Units updated successfully.')),
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

  Widget _buildSipSection(Investment inv, String currency, domain.Sip? sip) {
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);
    
    if (sip == null) {
      return GlassCard(
        borderColor: AppColors.darkPrimary.withOpacity(0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.autorenew, color: AppColors.darkPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'RECURRING SIP PLAN',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.8),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Set up a recurring systematic investment plan to automate your wealth building.',
              style: TextStyle(color: AppColors.grey500, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showSipDialog(inv: inv, currency: currency),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Set up SIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    final frequencyLabel = sip.frequency.substring(0, 1).toUpperCase() + sip.frequency.substring(1);
    String dateLabel = '';
    if (sip.frequency == 'weekly') {
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      dateLabel = days[sip.sipDate - 1];
    } else {
      dateLabel = 'Day ${sip.sipDate}';
    }

    final isPaused = sip.isActive == 0;

    return GlassCard(
      borderColor: isPaused ? AppColors.grey500.withOpacity(0.15) : AppColors.darkPrimary.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isPaused ? Icons.pause_circle_outline : Icons.autorenew,
                    color: isPaused ? AppColors.grey500 : AppColors.darkPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ACTIVE SIP PLAN',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPaused ? AppColors.grey500 : Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaused ? AppColors.grey500.withOpacity(0.12) : AppColors.darkPrimary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPaused ? AppColors.grey500.withOpacity(0.3) : AppColors.darkPrimary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  isPaused ? 'PAUSED' : 'ACTIVE',
                  style: TextStyle(
                    color: isPaused ? AppColors.grey500 : AppColors.darkPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(format.format(sip.amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Frequency', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(frequencyLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Schedule', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(dateLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.grey500),
              const SizedBox(width: 6),
              Text(
                'Starts: ${DateFormat('dd MMM yyyy').format(sip.startDate)}',
                style: const TextStyle(color: AppColors.grey500, fontSize: 11),
              ),
              const Spacer(),
              Icon(
                sip.autoCreate == 1 ? Icons.bolt : Icons.notifications_none,
                size: 12,
                color: AppColors.grey500,
              ),
              const SizedBox(width: 4),
              Text(
                sip.autoCreate == 1 ? 'Auto-Invest On' : 'Reminders Only',
                style: const TextStyle(color: AppColors.grey500, fontSize: 11),
              ),
            ],
          ),
          const Divider(color: AppColors.glassBorder, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => ref.read(sipServiceProvider).toggleSipActive(sip.id),
                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause, size: 16, color: Colors.white),
                label: Text(isPaused ? 'Resume' : 'Pause', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showSipDialog(existingSip: sip, inv: inv, currency: currency),
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                label: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDeleteSip(sip),
                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.darkDanger),
                label: const Text('Delete', style: TextStyle(color: AppColors.darkDanger, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSip(domain.Sip sip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete SIP Plan?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('This will delete the recurring SIP configuration. Existing transactions will not be affected.', style: TextStyle(color: AppColors.grey400, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(sipServiceProvider).deleteSip(sip.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SIP plan deleted.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSipDialog({domain.Sip? existingSip, required Investment inv, required String currency}) {
    final amountController = TextEditingController(text: existingSip?.amount.toString() ?? '2000');
    String frequency = existingSip?.frequency ?? 'monthly';
    int sipDate = existingSip?.sipDate ?? 5;
    DateTime startDate = existingSip?.startDate ?? DateTime.now();
    DateTime? endDate = existingSip?.endDate;
    bool autoCreate = (existingSip?.autoCreate ?? 1) == 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          
          return AlertDialog(
            title: Text(
              existingSip == null ? 'Create SIP Plan' : 'Edit SIP Plan',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'SIP Installment Amount',
                      labelStyle: const TextStyle(color: AppColors.grey500),
                      prefixText: '$currency ',
                      prefixStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: frequency,
                    dropdownColor: AppColors.layer1,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      labelStyle: TextStyle(color: AppColors.grey500),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          frequency = val;
                          if (frequency == 'weekly') {
                            sipDate = 1;
                          } else {
                            sipDate = 5;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  if (frequency == 'weekly')
                    DropdownButtonFormField<int>(
                      value: sipDate,
                      dropdownColor: AppColors.layer1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Weekly SIP Day',
                        labelStyle: TextStyle(color: AppColors.grey500),
                      ),
                      items: List.generate(7, (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(daysOfWeek[i]),
                      )),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => sipDate = val);
                        }
                      },
                    )
                  else
                    DropdownButtonFormField<int>(
                      value: sipDate > 31 ? 31 : sipDate,
                      dropdownColor: AppColors.layer1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Day of the Month',
                        labelStyle: TextStyle(color: AppColors.grey500),
                      ),
                      items: List.generate(31, (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('Day ${i + 1}'),
                      )),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => sipDate = val);
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() => startDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        labelStyle: TextStyle(color: AppColors.grey500),
                      ),
                      child: Text(
                        DateFormat('dd MMM yyyy').format(startDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // End Date picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? startDate.add(const Duration(days: 365)),
                        firstDate: startDate,
                        lastDate: DateTime(2040),
                      );
                      if (picked != null) {
                        setDialogState(() => endDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'End Date (Optional)',
                        labelStyle: const TextStyle(color: AppColors.grey500),
                        suffixIcon: endDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16, color: AppColors.grey500),
                                onPressed: () {
                                  setDialogState(() => endDate = null);
                                },
                              )
                            : null,
                      ),
                      child: Text(
                        endDate == null ? 'No End Date' : DateFormat('dd MMM yyyy').format(endDate!),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Auto-Create Transactions', style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text('Automatically record purchase lot on SIP day', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                    value: autoCreate,
                    activeColor: AppColors.darkPrimary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setDialogState(() => autoCreate = val),
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
                  final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                  if (amount > 0) {
                    if (existingSip == null) {
                      ref.read(sipServiceProvider).addSip(
                        investmentId: inv.id,
                        amount: amount,
                        frequency: frequency,
                        sipDate: sipDate,
                        startDate: startDate,
                        endDate: endDate,
                        autoCreate: autoCreate ? 1 : 0,
                      );
                    } else {
                      final updated = existingSip.copyWith(
                        amount: amount,
                        frequency: frequency,
                        sipDate: sipDate,
                        startDate: startDate,
                        endDate: endDate,
                        autoCreate: autoCreate ? 1 : 0,
                      );
                      ref.read(sipServiceProvider).editSip(updated);
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(existingSip == null ? 'SIP created successfully.' : 'SIP updated successfully.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
                child: const Text('Save Plan', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}
