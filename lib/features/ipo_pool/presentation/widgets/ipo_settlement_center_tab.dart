import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/ipo_pool_models.dart';
import 'calculation_audit_panel.dart';

class IpoSettlementCenterTab extends ConsumerStatefulWidget {
  final IpoPool pool;
  final String currency;

  const IpoSettlementCenterTab({
    required this.pool,
    required this.currency,
    super.key,
  });

  @override
  ConsumerState<IpoSettlementCenterTab> createState() => _IpoSettlementCenterTabState();
}

class _IpoSettlementCenterTabState extends ConsumerState<IpoSettlementCenterTab> {
  String _activeTab = 'pending'; // 'pending', 'paid', 'history'
  
  // Recording Payout Form State
  String? _selectedContributorId;
  final _payoutAmountController = TextEditingController();
  String _settlementMethod = 'UPI';
  final _payoutTxIdController = TextEditingController();
  final _payoutRefNumController = TextEditingController();
  final _payoutNotesController = TextEditingController();

  @override
  void dispose() {
    _payoutAmountController.dispose();
    _payoutTxIdController.dispose();
    _payoutRefNumController.dispose();
    _payoutNotesController.dispose();
    super.dispose();
  }

  // Auto Distribution Engine calculations per contributor
  Map<String, Map<String, dynamic>> _calculateSettlementSplit(IpoPool pool) {
    final Map<String, Map<String, dynamic>> splits = {};
    final totalGroupContrib = pool.totalGroupContribution;

    for (final c in pool.contributors) {
      final verifiedContrib = pool.getContributorVerifiedContribution(c.id);
      final ownershipFraction = totalGroupContrib > 0 ? (verifiedContrib / totalGroupContrib) : 0.0;
      final appsOwned = pool.groupApplications * ownershipFraction;
      final profitShare = pool.groupProfit * ownershipFraction;
      
      // If listing price is set, amount due is contribution + profit
      // If listing price is not set (e.g. Open/Closed but not listed), amount due is just their verified capital
      final amountDue = pool.listingPrice != null ? (verifiedContrib + profitShare) : verifiedContrib;
      final amountReceived = pool.getContributorTotalSettled(c.id);
      final outstanding = amountDue - amountReceived;

      splits[c.id] = {
        'contribution': verifiedContrib,
        'ownershipFraction': ownershipFraction,
        'appsOwned': appsOwned,
        'profitShare': profitShare,
        'amountDue': amountDue,
        'amountReceived': amountReceived,
        'outstanding': outstanding,
      };
    }
    return splits;
  }

  void _showRecordPayoutSheet(Map<String, Map<String, dynamic>> splits) {
    // Default contributor is the first one with outstanding > 0
    final outstandingContribs = widget.pool.contributors.where((c) {
      final double out = (splits[c.id]?['outstanding'] as num?)?.toDouble() ?? 0.0;
      return out > 0.01;
    }).toList();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    setState(() {
      _selectedContributorId = outstandingContribs.isNotEmpty ? outstandingContribs.first.id : (widget.pool.contributors.isNotEmpty ? widget.pool.contributors.first.id : null);
      if (_selectedContributorId != null) {
        final double outstanding = (splits[_selectedContributorId]?['outstanding'] as num?)?.toDouble() ?? 0.0;
        _payoutAmountController.text = outstanding.toStringAsFixed(2);
      } else {
        _payoutAmountController.clear();
      }
      _settlementMethod = 'UPI';
      _payoutTxIdController.clear();
      _payoutRefNumController.clear();
      _payoutNotesController.clear();
    });

    if (_selectedContributorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All contributors are fully settled!')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF13131F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1.5)),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.grey700, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Record Payout / Settlement',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 16),

                // Contributor Picker
                DropdownButtonFormField<String>(
                  value: _selectedContributorId,
                  dropdownColor: AppColors.layer2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Contributor'),
                  items: widget.pool.contributors.map((c) {
                    final outstanding = splits[c.id]?['outstanding'] ?? 0.0;
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} (Outstanding: ${widget.currency}${outstanding.toStringAsFixed(0)})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() {
                        _selectedContributorId = val;
                        final double outstanding = (splits[val]?['outstanding'] as num?)?.toDouble() ?? 0.0;
                        _payoutAmountController.text = outstanding.toStringAsFixed(2);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                TextField(
                  controller: _payoutAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Payout Amount',
                    hintText: 'Enter amount paid',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                ),
                const SizedBox(height: 16),

                // Method
                DropdownButtonFormField<String>(
                  value: _settlementMethod,
                  dropdownColor: AppColors.layer2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Settlement Method'),
                  items: const [
                    DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => _settlementMethod = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Tx ID / Ref Number
                TextField(
                  controller: _payoutTxIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Transaction ID / UPI Reference',
                    hintText: 'e.g. TXN28492049284',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _payoutRefNumController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Reference Number / Check Number',
                    hintText: 'e.g. REF9832093',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                TextField(
                  controller: _payoutNotesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Settlement Notes',
                    hintText: 'Any reference notes or remarks',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                ),
                const SizedBox(height: 16),

                // Date Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Payout Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setSheetState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Payout Time: ${selectedTime.format(context)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.access_time, color: AppColors.darkPrimary, size: 18),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setSheetState(() => selectedTime = picked);
                    }
                  },
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: () {
                    final amt = double.tryParse(_payoutAmountController.text.trim()) ?? 0.0;
                    if (amt <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid payout amount')),
                      );
                      return;
                    }

                    final contrib = widget.pool.contributors.firstWhere((c) => c.id == _selectedContributorId);
                    
                    final txDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    // Create Settlement record
                    final record = SettlementRecord(
                      id: const Uuid().v4(),
                      contributorId: contrib.id,
                      contributorName: contrib.name,
                      amount: amt,
                      method: _settlementMethod,
                      transactionId: _payoutTxIdController.text.trim(),
                      referenceNumber: _payoutRefNumController.text.trim(),
                      notes: _payoutNotesController.text.trim(),
                      date: txDateTime,
                    );

                    // Add to system audit trail
                    final updatedActivities = List<PoolActivity>.from(widget.pool.activities)
                      ..add(PoolActivity(
                        id: const Uuid().v4(),
                        type: 'settlement_payout',
                        description: 'Recorded settlement payout of ${widget.currency}${amt.toStringAsFixed(0)} to ${contrib.name} via $_settlementMethod',
                        timestamp: txDateTime,
                        userId: 'Me',
                      ));

                    // Add to pool settlements list
                    final updatedSettlements = [...widget.pool.settlements, record];

                    // Check if settlement status of pool changes
                    final newSplits = _calculateSettlementSplit(widget.pool.copyWith(settlements: updatedSettlements));
                    double netOutstanding = 0.0;
                    newSplits.forEach((key, val) {
                      netOutstanding += (val['outstanding'] as double);
                    });

                    // Update pool settlement status
                    String poolSettleStatus = 'Partially Settled';
                    if (netOutstanding < 1.0) {
                      poolSettleStatus = 'Settled';
                    } else {
                      // check if any payout made
                      final totalPaid = updatedSettlements.fold(0.0, (sum, s) => sum + s.amount);
                      if (totalPaid == 0) poolSettleStatus = 'Pending';
                    }

                    final updatedPool = widget.pool.copyWith(
                      settlements: updatedSettlements,
                      settlementStatus: poolSettleStatus,
                      activities: updatedActivities,
                    );

                    ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payout of ${widget.currency}${amt.toStringAsFixed(0)} recorded for ${contrib.name}'),
                        backgroundColor: AppColors.darkPrimary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Submit Payout', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditSettlementDialog(SettlementRecord rec) {
    final amtController = TextEditingController(text: rec.amount.toString());
    String method = rec.method;
    final txIdController = TextEditingController(text: rec.transactionId);
    final refNumController = TextEditingController(text: rec.referenceNumber);
    final notesController = TextEditingController(text: rec.notes);
    DateTime selectedDate = rec.date;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(rec.date);

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Settlement Payout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Contributor: ${rec.contributorName}', style: const TextStyle(color: AppColors.grey400, fontSize: 13)),
                const SizedBox(height: 12),
                TextField(
                  controller: amtController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Payout Amount', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: method,
                  dropdownColor: AppColors.layer2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Settlement Method'),
                  items: const [
                    DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => method = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: txIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Transaction ID / Reference', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: refNumController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Ref Number / Check Number', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Payout Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Payout Time: ${selectedTime.format(context)}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.access_time, color: AppColors.darkPrimary, size: 18),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmDeleteSettlement(rec);
              },
              child: const Text('Delete Payout', style: TextStyle(color: AppColors.darkDanger)),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amtController.text.trim()) ?? 0.0;
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount')),
                  );
                  return;
                }

                final txDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final updatedRecord = rec.copyWith(
                  amount: amt,
                  method: method,
                  transactionId: txIdController.text.trim(),
                  referenceNumber: refNumController.text.trim(),
                  notes: notesController.text.trim(),
                  date: txDateTime,
                );

                final updatedSettlements = widget.pool.settlements.map((s) => s.id == rec.id ? updatedRecord : s).toList();

                final updatedActivities = List<PoolActivity>.from(widget.pool.activities)
                  ..add(PoolActivity(
                    id: const Uuid().v4(),
                    type: 'settlement_edited',
                    description: 'Updated settlement payout of ${widget.currency}${amt.toStringAsFixed(0)} to ${rec.contributorName} via $method',
                    timestamp: DateTime.now(),
                    userId: 'Me',
                  ));

                final newSplits = _calculateSettlementSplit(widget.pool.copyWith(settlements: updatedSettlements));
                double netOutstanding = 0.0;
                newSplits.forEach((key, val) {
                  netOutstanding += (val['outstanding'] as double);
                });

                String poolSettleStatus = 'Partially Settled';
                if (netOutstanding < 1.0) {
                  poolSettleStatus = 'Settled';
                } else {
                  final totalPaid = updatedSettlements.fold(0.0, (sum, s) => sum + s.amount);
                  if (totalPaid == 0) poolSettleStatus = 'Pending';
                }

                final updatedPool = widget.pool.copyWith(
                  settlements: updatedSettlements,
                  settlementStatus: poolSettleStatus,
                  activities: updatedActivities,
                );

                ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payout updated successfully')),
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

  void _confirmDeleteSettlement(SettlementRecord rec) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payout?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete the settlement payout of ${widget.currency}${rec.amount.toStringAsFixed(0)} to ${rec.contributorName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedSettlements = widget.pool.settlements.where((s) => s.id != rec.id).toList();

              final updatedActivities = List<PoolActivity>.from(widget.pool.activities)
                ..add(PoolActivity(
                  id: const Uuid().v4(),
                  type: 'settlement_deleted',
                  description: 'Deleted settlement payout of ${widget.currency}${rec.amount.toStringAsFixed(0)} to ${rec.contributorName}',
                  timestamp: DateTime.now(),
                  userId: 'Me',
                ));

              final newSplits = _calculateSettlementSplit(widget.pool.copyWith(settlements: updatedSettlements));
              double netOutstanding = 0.0;
              newSplits.forEach((key, val) {
                netOutstanding += (val['outstanding'] as double);
              });

              String poolSettleStatus = 'Partially Settled';
              if (netOutstanding < 1.0) {
                poolSettleStatus = 'Settled';
              } else {
                final totalPaid = updatedSettlements.fold(0.0, (sum, s) => sum + s.amount);
                if (totalPaid == 0) poolSettleStatus = 'Pending';
              }

              final updatedPool = widget.pool.copyWith(
                settlements: updatedSettlements,
                settlementStatus: poolSettleStatus,
                activities: updatedActivities,
              );

              ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payout deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String reportName) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied $reportName to Clipboard!'), backgroundColor: AppColors.darkPrimary),
    );
  }

  String _exportCSV(Map<String, Map<String, dynamic>> splits) {
    final buffer = StringBuffer();
    buffer.writeln('Contributor,Contribution,Ownership %,Apps Owned,Profit Share,Amount Due,Amount Received,Outstanding Amount');
    for (final c in widget.pool.contributors) {
      final data = splits[c.id]!;
      final contrib = (data['contribution'] as num?)?.toDouble() ?? 0.0;
      final ownership = (data['ownershipFraction'] as num?)?.toDouble() ?? 0.0;
      final apps = (data['appsOwned'] as num?)?.toDouble() ?? 0.0;
      final profit = (data['profitShare'] as num?)?.toDouble() ?? 0.0;
      final due = (data['amountDue'] as num?)?.toDouble() ?? 0.0;
      final received = (data['amountReceived'] as num?)?.toDouble() ?? 0.0;
      final outstanding = (data['outstanding'] as num?)?.toDouble() ?? 0.0;
      buffer.writeln(
        '"${c.name}",'
        '$contrib,'
        '${(ownership * 100).toStringAsFixed(2)},'
        '$apps,'
        '$profit,'
        '$due,'
        '$received,'
        '$outstanding'
      );
    }
    return buffer.toString();
  }

  String _exportMarkdown(Map<String, Map<String, dynamic>> splits) {
    final buffer = StringBuffer();
    buffer.writeln('| Contributor | Contribution | Ownership % | Apps | Profit Share | Amount Due | Settled | Outstanding |');
    buffer.writeln('| --- | --- | --- | --- | --- | --- | --- | --- |');
    for (final c in widget.pool.contributors) {
      final data = splits[c.id]!;
      final contrib = (data['contribution'] as num?)?.toDouble() ?? 0.0;
      final ownership = (data['ownershipFraction'] as num?)?.toDouble() ?? 0.0;
      final apps = (data['appsOwned'] as num?)?.toDouble() ?? 0.0;
      final profit = (data['profitShare'] as num?)?.toDouble() ?? 0.0;
      final due = (data['amountDue'] as num?)?.toDouble() ?? 0.0;
      final received = (data['amountReceived'] as num?)?.toDouble() ?? 0.0;
      final outstanding = (data['outstanding'] as num?)?.toDouble() ?? 0.0;
      buffer.writeln(
        '| ${c.name} | '
        '${widget.currency}${contrib.toStringAsFixed(0)} | '
        '${(ownership * 100).toStringAsFixed(1)}% | '
        '${apps.toStringAsFixed(1)} | '
        '${widget.currency}${profit.toStringAsFixed(0)} | '
        '${widget.currency}${due.toStringAsFixed(0)} | '
        '${widget.currency}${received.toStringAsFixed(0)} | '
        '${widget.currency}${outstanding.toStringAsFixed(0)} |'
      );
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final pool = widget.pool;
    final currency = widget.currency;

    // Run Auto Distribution calculations
    final splits = _calculateSettlementSplit(pool);

    // Compute aggregate metrics
    double totalDue = 0.0;
    double totalPaid = 0.0;
    splits.forEach((key, val) {
      totalDue += (val['amountDue'] as num?)?.toDouble() ?? 0.0;
      totalPaid += (val['amountReceived'] as num?)?.toDouble() ?? 0.0;
    });
    double totalOutstanding = max(0.0, totalDue - totalPaid);

    // Lists split by payout status
    final pendingSettlements = pool.contributors.where((c) {
      final double out = (splits[c.id]?['outstanding'] as num?)?.toDouble() ?? 0.0;
      return out > 0.1;
    }).toList();

    final paidSettlements = pool.contributors.where((c) {
      final double out = (splits[c.id]?['outstanding'] as num?)?.toDouble() ?? 0.0;
      final double amountDue = (splits[c.id]?['amountDue'] as num?)?.toDouble() ?? 0.0;
      return out <= 0.1 && amountDue > 0.1;
    }).toList();

    final settlementHistory = pool.settlements.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Dashboard Header Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(child: _buildMetricCard('Total Amount Due', '$currency${totalDue.toStringAsFixed(0)}', Colors.white)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Paid Settlements', '$currency${totalPaid.toStringAsFixed(0)}', AppColors.darkSuccess)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Outstanding Dues', '$currency${totalOutstanding.toStringAsFixed(0)}', totalOutstanding > 0 ? AppColors.darkDanger : AppColors.darkSuccess)),
              ],
            ),
          ),

          // 2. Visual Analytics Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildCircularProgressChart(totalPaid, totalDue),
                _buildContributorPayoutChart(splits),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Button: Record Payout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _showRecordPayoutSheet(splits),
              icon: const Icon(Icons.payment, size: 16, color: Colors.white),
              label: const Text('Record Payout / Settlement', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CalculationAuditPanel(
              title: 'Verify Settlement Calculations',
              formula: 'Total Amount Due = sum(Contributor.amountDue)\n'
                  'Contributor.amountDue = listingPrice != null ? (verifiedContribution + profitShare) : verifiedContribution\n'
                  'profitShare = groupProfit * ownershipFraction\n'
                  'ownershipFraction = verifiedContribution / totalGroupContribution\n'
                  'Outstanding Dues = Total Amount Due - Paid Settlements',
              inputs: {
                'Listing Price Set': '${pool.listingPrice != null ? "Yes ($currency${pool.listingPrice})" : "No"}',
                'Group Profit': '$currency${pool.groupProfit.toStringAsFixed(2)}',
                'Total Verified Group Contribution': '$currency${pool.totalGroupContribution.toStringAsFixed(2)}',
                'Total Amount Due Sum': '$currency${totalDue.toStringAsFixed(2)}',
                'Paid Settlements Sum': '$currency${totalPaid.toStringAsFixed(2)}',
                'Outstanding Dues Sum': '$currency${totalOutstanding.toStringAsFixed(2)}',
              },
              output: 'Dues Summary Verified',
              steps: [
                'First, we calculate verified contributions and ownership percentage for each contributor.',
                'If listing price is set, each contributor is due their verified contribution + their share of the group profit ($currency${pool.groupProfit.toStringAsFixed(0)}).',
                'If not listed yet, each contributor is only due their verified principal capital.',
                ...pool.contributors.map((c) {
                  final split = splits[c.id]!;
                  final verified = split['contribution'] as double;
                  final ownFrac = split['ownershipFraction'] as double;
                  final profit = split['profitShare'] as double;
                  final due = split['amountDue'] as double;
                  final paid = split['amountReceived'] as double;
                  final out = split['outstanding'] as double;
                  return '${c.name}: Verified Contrib = $currency${verified.toStringAsFixed(0)}, '
                      'Ownership % = ${(ownFrac * 100).toStringAsFixed(2)}%, '
                      'Profit Share = $currency${profit.toStringAsFixed(0)}, '
                      'Due = $currency${due.toStringAsFixed(0)}, '
                      'Paid = $currency${paid.toStringAsFixed(0)}, '
                      'Outstanding = $currency${out.toStringAsFixed(0)}.';
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Tab selectors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildSegmentTab('pending', 'Pending (${pendingListCount(splits)})'),
                _buildSegmentTab('paid', 'Paid (${paidListCount(splits)})'),
                _buildSegmentTab('history', 'History (${settlementHistory.length})'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Tab List View
          _buildActiveList(pendingSettlements, paidSettlements, settlementHistory, splits),
          const SizedBox(height: 24),

          // 5. Exporters section
          if (pool.contributors.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'EXPORT SETTLEMENT REPORTS',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 32.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(_exportCSV(splits), 'Settlement CSV Ledger'),
                      icon: const Icon(Icons.grid_on, size: 14, color: Colors.white),
                      label: const Text('Copy CSV', style: TextStyle(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.layer2,
                        side: const BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(_exportMarkdown(splits), 'Settlement Markdown Table'),
                      icon: const Icon(Icons.table_chart_outlined, size: 14, color: Colors.white),
                      label: const Text('Copy Markdown', style: TextStyle(fontSize: 12, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.layer2,
                        side: const BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  int pendingListCount(Map<String, Map<String, dynamic>> splits) {
    return widget.pool.contributors.where((c) {
      final double out = (splits[c.id]?['outstanding'] as num?)?.toDouble() ?? 0.0;
      return out > 0.1;
    }).length;
  }

  int paidListCount(Map<String, Map<String, dynamic>> splits) {
    return widget.pool.contributors.where((c) {
      final double out = (splits[c.id]?['outstanding'] as num?)?.toDouble() ?? 0.0;
      final double amountDue = (splits[c.id]?['amountDue'] as num?)?.toDouble() ?? 0.0;
      return out <= 0.1 && amountDue > 0.1;
    }).length;
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(String tabKey, String label) {
    final isSelected = _activeTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkPrimary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.grey500,
            ),
          ),
        ),
      ),
    );
  }

  // Visual paid vs pending gauge
  Widget _buildCircularProgressChart(double paid, double total) {
    final double percent = total > 0.1 ? (paid / total) : 0.0;
    
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Settlement Progress',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                Center(
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 8,
                    color: Colors.white.withOpacity(0.03),
                  ),
                ),
                Center(
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    color: AppColors.darkSuccess,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Center(
                  child: Text(
                    '${(percent * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.currency}${paid.toStringAsFixed(0)} / ${widget.currency}${total.toStringAsFixed(0)} Paid',
            style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey400),
          ),
        ],
      ),
    );
  }

  // Contributor payout distribution chart
  Widget _buildContributorPayoutChart(Map<String, Map<String, dynamic>> splits) {
    if (widget.pool.contributors.isEmpty) {
      return const GlassCard(
        child: Center(child: Text('No contributors', style: TextStyle(fontSize: 11, color: AppColors.grey500))),
      );
    }

    final List<BarChartGroupData> barGroups = [];
    double maxAmt = 100.0;

    int idx = 0;
    for (final c in widget.pool.contributors) {
      final double amountDue = (splits[c.id]?['amountDue'] as num?)?.toDouble() ?? 0.0;
      maxAmt = max(maxAmt, amountDue);
      barGroups.add(
        BarChartGroupData(
          x: idx,
          barRods: [
            BarChartRodData(
              toY: amountDue,
              color: AppColors.darkPrimary,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
      idx++;
    }

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            'Distribution Shares',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxAmt * 1.2,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final index = val.toInt();
                        if (index >= 0 && index < widget.pool.contributors.length) {
                          final name = widget.pool.contributors[index].name;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              name.length > 5 ? name.substring(0, 4) + '..' : name,
                              style: const TextStyle(color: AppColors.grey500, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveList(
    List<IpoContributor> pending,
    List<IpoContributor> paid,
    List<SettlementRecord> history,
    Map<String, Map<String, dynamic>> splits,
  ) {
    if (_activeTab == 'pending') {
      return pending.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No pending settlements.', style: TextStyle(color: AppColors.grey500))),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pending.length,
              itemBuilder: (context, idx) => _buildContributorSettlementRow(pending[idx], splits),
            );
    } else if (_activeTab == 'paid') {
      return paid.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No paid settlements yet.', style: TextStyle(color: AppColors.grey500))),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: paid.length,
              itemBuilder: (context, idx) => _buildContributorSettlementRow(paid[idx], splits),
            );
    } else {
      return history.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: Text('No settlement transaction history.', style: TextStyle(color: AppColors.grey500))),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: history.length,
              itemBuilder: (context, idx) => _buildHistoryRow(history[idx]),
            );
    }
  }

  Widget _buildContributorSettlementRow(IpoContributor c, Map<String, Map<String, dynamic>> splits) {
    final data = splits[c.id]!;
    final contribution = (data['contribution'] as num?)?.toDouble() ?? 0.0;
    final ownership = (data['ownershipFraction'] as num?)?.toDouble() ?? 0.0;
    final profit = (data['profitShare'] as num?)?.toDouble() ?? 0.0;
    final amountDue = (data['amountDue'] as num?)?.toDouble() ?? 0.0;
    final amountPaid = (data['amountReceived'] as num?)?.toDouble() ?? 0.0;
    final outstanding = (data['outstanding'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(c.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  '${(ownership * 100).toStringAsFixed(1)}% Share',
                  style: const TextStyle(color: AppColors.darkPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(color: AppColors.glassBorder, height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDataSubCol('Contribution', '${widget.currency}${contribution.toStringAsFixed(0)}'),
                _buildDataSubCol('Profit Share', '${widget.currency}${profit.toStringAsFixed(0)}', color: profit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger),
                _buildDataSubCol('Amount Due', '${widget.currency}${amountDue.toStringAsFixed(0)}', isBold: true),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDataSubCol('Settled Amount', '${widget.currency}${amountPaid.toStringAsFixed(0)}', color: AppColors.darkSuccess),
                _buildDataSubCol('Outstanding Amount', '${widget.currency}${outstanding.toStringAsFixed(0)}',
                    color: outstanding > 0 ? AppColors.darkDanger : AppColors.darkSuccess, isBold: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSubCol(String label, String value, {Color? color, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.grey500)),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryRow(SettlementRecord rec) {
    final dateStr = '${rec.date.day}/${rec.date.month}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: () => _showEditSettlementDialog(rec),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(rec.contributorName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.darkSuccess.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.darkSuccess.withOpacity(0.3)),
                        ),
                        child: Text(
                          rec.method.toUpperCase(),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.darkSuccess),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (rec.transactionId.isNotEmpty) ...[
                        Text('Tx ID: ${rec.transactionId}', style: const TextStyle(fontSize: 10, color: AppColors.grey400)),
                        const SizedBox(width: 12),
                      ],
                      if (rec.notes.isNotEmpty)
                        Expanded(
                          child: Text(
                            'Notes: ${rec.notes}',
                            style: const TextStyle(fontSize: 10, color: AppColors.grey500, fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.currency}${rec.amount.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkSuccess),
                ),
                const SizedBox(height: 4),
                Text(dateStr, style: const TextStyle(fontSize: 9, color: AppColors.grey500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
