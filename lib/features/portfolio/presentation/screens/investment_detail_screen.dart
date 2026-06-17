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
              final success = await ref.read(mockDatabaseProvider.notifier).deleteInvestment(inv.id);
              Navigator.pop(context);
              if (success) {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Investment "${inv.name}" deleted.')),
                );
              } else {
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
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBuyDialog(Investment inv, String currency) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Record Purchase Lot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              final units = double.tryParse(_buyUnitsController.text.trim()) ?? 0.0;
              final price = double.tryParse(_buyPriceController.text.trim()) ?? 0.0;
              if (units > 0 && price > 0) {
                ref.read(mockDatabaseProvider.notifier).buyInvestment(inv.id, 'acc_primary_bank_uuid', units, price, null, DateTime.now().toUtc());
                _buyUnitsController.clear();
                _buyPriceController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lot recorded: $units units bought.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save Lot', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                      : () {
                          ref.read(mockDatabaseProvider.notifier).sellInvestment(
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

    final cap = dbState.getInvestmentInvestedCapital(inv.id);
    final value = dbState.getInvestmentMarketValue(inv.id);
    final unrealized = dbState.getInvestmentUnrealizedGain(inv.id);
    final realized = dbState.getInvestmentRealizedGain(inv.id);
    final units = dbState.getInvestmentUnitsHeld(inv.id);
    
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    final lots = dbState.investmentLots.where((l) => l.investmentId == inv.id).toList();
    final txs = dbState.transactions.where((t) => t.investmentId == inv.id && t.voidedTransactionId == null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(inv.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer1,
            onSelected: (menuVal) {
              if (menuVal == 'edit') {
                _showEditInvestmentDialog(inv);
              } else if (menuVal == 'update_price') {
                _showUpdateMarketValueDialog(inv, currency);
              } else if (menuVal == 'adjust_amount') {
                _showChooseAdjustmentTypeDialog(context, ref, inv, cap, value);
              } else if (menuVal == 'view_history') {
                showAdjustmentHistorySheet(context, inv.id, 'investment', inv.name);
              } else if (menuVal == 'archive') {
                ref.read(mockDatabaseProvider.notifier).archiveInvestment(inv.id);
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Investment "${inv.name}" archived.')),
                );
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

  void _showChooseAdjustmentTypeDialog(BuildContext context, WidgetRef ref, Investment inv, double cap, double marketValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Investment Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Which value would you like to adjust manually?',
          style: TextStyle(color: AppColors.grey400, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAdjustInvestmentFieldDialog(context, ref, inv, 'investment_capital', 'Principal Invested', cap);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Principal Invested'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAdjustInvestmentFieldDialog(context, ref, inv, 'investment_market_value', 'Market Value', marketValue);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Market Value'),
          ),
        ],
      ),
    );
  }

  void _showAdjustInvestmentFieldDialog(
    BuildContext context,
    WidgetRef ref,
    Investment inv,
    String entityType,
    String fieldName,
    double currentVal,
  ) {
    final controller = TextEditingController(text: currentVal.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust $fieldName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'New $fieldName',
            labelStyle: const TextStyle(color: AppColors.grey500),
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
              
              Navigator.pop(context); // close dialog

              // 1. Warning
              final continueAdj = await showAdjustmentWarningDialog(context);
              if (!continueAdj) return;

              // 2. Reason
              final reason = await showAdjustmentReasonSheet(context);
              if (reason == null) return;

              // 3. Save
              await ref.read(mockDatabaseProvider.notifier).addAdjustment(
                entityType: entityType,
                entityId: inv.id,
                oldAmount: currentVal,
                newAmount: newAmt,
                reason: reason,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$fieldName adjusted successfully.')),
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
