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
import 'package:drift/drift.dart' show Value;

class MtfDetailScreen extends ConsumerStatefulWidget {
  final String mtfPositionId;

  const MtfDetailScreen({required this.mtfPositionId, super.key});

  @override
  ConsumerState<MtfDetailScreen> createState() => _MtfDetailScreenState();
}

class _MtfDetailScreenState extends ConsumerState<MtfDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final pos = dbState.mtfPositions.firstWhereOrNull((p) => p.id == widget.mtfPositionId);

    if (pos == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('MTF Position Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: Text(
            'MTF Position not found or has been deleted.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 2);
    final formatDec = NumberFormat.decimalPattern();
    final today = DateTime.now();

    final inv = dbState.investments.firstWhereOrNull((i) => i.id == pos.investmentId);
    final currentPrice = inv?.marketValue ?? pos.averagePrice;
    final currentMarketValue = pos.units * currentPrice;
    final totalCost = pos.units * pos.averagePrice;

    // Calculate holding days and accrued interest
    final endDate = pos.isClosed == 1 && pos.closedDate != null ? pos.closedDate! : today;
    final daysHeld = endDate.difference(DateTime(pos.interestStartDate.year, pos.interestStartDate.month, pos.interestStartDate.day)).inDays;
    final dailyInterest = pos.borrowedCapital * (pos.interestRate / 100) / 365;
    final totalInterestTillToday = dailyInterest * daysHeld;

    final netProfit = currentMarketValue - totalCost - totalInterestTillToday;
    final netRoi = pos.ownCapital > 0 ? (netProfit / pos.ownCapital * 100) : 0.0;
    final ltv = currentMarketValue > 0 ? (pos.borrowedCapital / currentMarketValue * 100) : 0.0;

    Color ltvColor = AppColors.darkSuccess;
    if (ltv >= 75) {
      ltvColor = AppColors.darkDanger;
    } else if (ltv >= 60) {
      ltvColor = AppColors.darkWarning;
    }

    final createdStr = DateFormat('dd MMM yyyy, hh:mm a').format(pos.createdAt.toLocal());
    final updatedStr = DateFormat('dd MMM yyyy, hh:mm a').format(pos.updatedAt.toLocal());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pos.instrument,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer2,
            onSelected: (value) {
              if (value == 'edit') {
                _showEditMtfDialog(pos);
              } else if (value == 'close') {
                _showCloseMtfDialog(pos);
              } else if (value == 'duplicate') {
                _handleDuplicate(pos);
              } else if (value == 'delete') {
                _handleDelete(pos);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: AppColors.darkPrimary, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Position', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              if (pos.isClosed == 0)
                const PopupMenuItem(
                  value: 'close',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppColors.glow, size: 18),
                      SizedBox(width: 8),
                      Text('Close Position', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_outlined, color: AppColors.darkSecondary, size: 18),
                    SizedBox(width: 8),
                    Text('Duplicate', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.darkDanger, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // High-level summary metrics card
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('LTV Ratio', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: ltvColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: ltvColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            '${ltv.toStringAsFixed(1)}%',
                            style: TextStyle(color: ltvColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('Borrowed Funding', format.format(pos.borrowedCapital), AppColors.darkDanger),
                        _buildStatItem('Interest Rate', '${pos.interestRate}% p.a.', AppColors.darkPrimary),
                        _buildStatItem('Days Held', '$daysHeld days', Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detail Specification Fields
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('POSITION OVERVIEW', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500)),
                    const Divider(color: AppColors.glassBorder, height: 20),
                    _buildOverviewRow('Broker', pos.broker),
                    _buildOverviewRow('Instrument', pos.instrument),
                    _buildOverviewRow('Quantity', formatDec.format(pos.units)),
                    _buildOverviewRow('Average Price', format.format(pos.averagePrice)),
                    _buildOverviewRow('Total Purchase Value', format.format(totalCost)),
                    _buildOverviewRow('Own Capital', format.format(pos.ownCapital)),
                    _buildOverviewRow('Open Date', DateFormat('dd MMM yyyy').format(pos.openingDate)),
                    _buildOverviewRow('Interest Start Date', DateFormat('dd MMM yyyy').format(pos.interestStartDate)),
                    if (pos.purchaseDate != null)
                      _buildOverviewRow('Purchase Date', DateFormat('dd MMM yyyy').format(pos.purchaseDate!)),
                    if (pos.purchaseTime != null)
                      _buildOverviewRow('Purchase Time', pos.purchaseTime!),
                    if (pos.isClosed == 1 && pos.closedDate != null)
                      _buildOverviewRow('Status', 'Closed (${DateFormat('dd MMM yyyy').format(pos.closedDate!)})', color: AppColors.grey500),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calculation Audit Panel for Accrued Interest
              CalculationAuditPanel(
                title: 'Accrued Interest Audit',
                formula: 'Accrued Interest = Borrowed Capital * (Rate / 100) * (Days Held / 365)',
                inputs: {
                  'Borrowed Funding': format.format(pos.borrowedCapital),
                  'Interest Rate': '${pos.interestRate}% p.a.',
                  'Days Held': '$daysHeld days',
                },
                output: format.format(totalInterestTillToday),
                steps: [
                  'Days Held between interest start date (${DateFormat('dd MMM yyyy').format(pos.interestStartDate)}) and end/today (${DateFormat('dd MMM yyyy').format(endDate)}): $daysHeld days.',
                  'Daily Interest: ${format.format(pos.borrowedCapital)} * (${pos.interestRate}% / 100) / 365 = ${format.format(dailyInterest)}.',
                  'Accrued Interest Till Date: ${format.format(dailyInterest)} * $daysHeld = ${format.format(totalInterestTillToday)}.',
                ],
              ),
              const SizedBox(height: 16),

              // Calculation Audit Panel for Net Returns / ROI
              CalculationAuditPanel(
                title: 'Returns & Net ROI Audit',
                formula: 'Net Return = Market Value - Purchase Value - Accrued Interest',
                inputs: {
                  'Market Value': format.format(currentMarketValue),
                  'Purchase Value': format.format(totalCost),
                  'Accrued Interest': format.format(totalInterestTillToday),
                },
                output: '${format.format(netProfit)} (ROI: ${netRoi.toStringAsFixed(2)}%)',
                steps: [
                  'Current Market Value: Units (${pos.units}) * Current Price (${format.format(currentPrice)}) = ${format.format(currentMarketValue)}.',
                  'Total Purchase Cost: Units (${pos.units}) * Avg Price (${format.format(pos.averagePrice)}) = ${format.format(totalCost)}.',
                  'Net Returns: Market Value (${format.format(currentMarketValue)}) - Purchase Value (${format.format(totalCost)}) - Accrued Interest (${format.format(totalInterestTillToday)}) = ${format.format(netProfit)}.',
                  'Return on Investment (ROI): Net Return (${format.format(netProfit)}) / Own Capital (${format.format(pos.ownCapital)}) * 100 = ${netRoi.toStringAsFixed(2)}%.',
                ],
              ),
              const SizedBox(height: 16),

              // Audit Log information panel
              GlassCard(
                padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildOverviewRow(String label, String value, {Color color = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey400, fontSize: 12)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }

  void _handleDuplicate(MtfPosition pos) async {
    await ref.read(mockDatabaseProvider.notifier).duplicateMtfPosition(pos.id);
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Position in "${pos.instrument}" duplicated.')),
      );
    }
  }

  void _handleDelete(MtfPosition pos) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete MTF Position?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this MTF Position? This will hide it from all views and calculations. You can undo this action immediately.',
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
              await ref.read(mockDatabaseProvider.notifier).deleteMtfPositionSoft(pos.id);
              if (mounted) {
                context.pop(); // pop details page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('MTF Position for "${pos.instrument}" deleted.'),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: AppColors.darkPrimary,
                      onPressed: () {
                        ref.read(mockDatabaseProvider.notifier).restoreMtfPosition(pos);
                      },
                    ),
                    duration: const Duration(seconds: 5),
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

  void _showEditMtfDialog(MtfPosition pos) {
    final brokerController = TextEditingController(text: pos.broker);
    final interestRateController = TextEditingController(text: pos.interestRate.toString());
    final purchaseTimeController = TextEditingController(text: pos.purchaseTime ?? '');
    DateTime? purchaseDate = pos.purchaseDate;
    DateTime openingDate = pos.openingDate;
    DateTime interestStartDate = pos.interestStartDate;

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit MTF Position', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    labelText: 'Purchase Time (Optional)',
                    labelStyle: TextStyle(color: AppColors.grey500),
                    hintText: 'e.g. 10:30 AM',
                    hintStyle: TextStyle(color: AppColors.grey500, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Position Open Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Position Open Date: ${DateFormat('dd MMM yyyy').format(openingDate)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  subtitle: const Text('Required - Tap to select date', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                  trailing: const Icon(Icons.calendar_month, color: AppColors.darkPrimary, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: openingDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        openingDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Interest Start Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Interest Start Date: ${DateFormat('dd MMM yyyy').format(interestStartDate)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  subtitle: const Text('Required - Tap to select date', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                  trailing: const Icon(Icons.percent, color: AppColors.darkPrimary, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: interestStartDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        interestStartDate = picked;
                      });
                    }
                  },
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
              onPressed: () async {
                final broker = brokerController.text.trim();
                final rate = double.tryParse(interestRateController.text.trim()) ?? pos.interestRate;
                if (broker.isNotEmpty) {
                  // Confirmation Dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Date Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      content: const Text(
                        'Are you sure you want to update these dates? Changing Position Open Date or Interest Start Date will affect the holding days and interest accrual calculations.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
                          child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  final purchaseTimeVal = purchaseTimeController.text.trim();
                  final updated = pos.copyWith(
                    broker: broker,
                    interestRate: rate,
                    openingDate: openingDate,
                    interestStartDate: interestStartDate,
                    purchaseDate: Value(purchaseDate),
                    purchaseTime: Value(purchaseTimeVal.isNotEmpty ? purchaseTimeVal : null),
                    updatedAt: DateTime.now().toUtc(),
                  );
                  await ref.read(mockDatabaseProvider.notifier).editMtfPosition(updated);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
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
}
