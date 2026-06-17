import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart';

Future<bool> showAdjustmentWarningDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Adjust Financial Amount?',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You are manually changing a financial value.',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'This may affect:\n• Net Worth\n• Reports\n• Analytics\n• Historical Calculations',
            style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Use this only if the current value is incorrect.\n\nWould you like to continue?',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<String?> showAdjustmentReasonSheet(BuildContext context) async {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _ReasonSelectionSheet(),
  );
}

class _ReasonSelectionSheet extends StatefulWidget {
  const _ReasonSelectionSheet();

  @override
  State<_ReasonSelectionSheet> createState() => _ReasonSelectionSheetState();
}

class _ReasonSelectionSheetState extends State<_ReasonSelectionSheet> {
  final List<String> _options = [
    'Correction',
    'Bank Reconciliation',
    'Manual Fix',
    'Migration',
  ];
  final _customReasonController = TextEditingController();
  bool _showCustomInput = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassCard(
        borderRadius: 32.0,
        padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 32),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Reason for Adjustment',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!_showCustomInput) ...[
                ..._options.map((opt) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => Navigator.pop(context, opt),
                        borderRadius: BorderRadius.circular(16),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          borderColor: AppColors.glassBorder,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(opt, style: const TextStyle(color: Colors.white, fontSize: 14)),
                              const Icon(Icons.chevron_right, color: AppColors.grey500, size: 18),
                            ],
                          ),
                        ),
                      ),
                    )),
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showCustomInput = true;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const GlassCard(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      borderColor: AppColors.glassBorder,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Other', style: TextStyle(color: Colors.white, fontSize: 14)),
                          Icon(Icons.edit, color: AppColors.darkPrimary, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _customReasonController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter Custom Reason',
                    labelStyle: const TextStyle(color: AppColors.grey500),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _showCustomInput = false;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.glassBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Back', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final text = _customReasonController.text.trim();
                          if (text.isNotEmpty) {
                            Navigator.pop(context, text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

void showAdjustmentHistorySheet(BuildContext context, String entityId, String entityType, String title) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _AdjustmentHistorySheet(
      entityId: entityId,
      entityType: entityType,
      title: title,
    ),
  );
}

class _AdjustmentHistorySheet extends ConsumerWidget {
  final String entityId;
  final String entityType;
  final String title;

  const _AdjustmentHistorySheet({
    required this.entityId,
    required this.entityType,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    final history = dbState.adjustments
        .where((adj) => adj.entityId == entityId && (adj.entityType == entityType ||
            (entityType == 'investment' && (adj.entityType == 'investment_capital' || adj.entityType == 'investment_market_value'))))
        .toList();

    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) => GlassCard(
        borderRadius: 32.0,
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 20),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Adjustment History',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Text(
                          'No adjustment history found.',
                          style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final adj = history[index];
                          final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(adj.createdAt.toLocal());
                          final isNegative = adj.adjustedAmount < 0;
                          final deltaText = '${format.format(adj.oldAmount)} → ${format.format(adj.newAmount)}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16.0),
                              borderColor: isNegative
                                  ? AppColors.darkDanger.withOpacity(0.12)
                                  : AppColors.darkSuccess.withOpacity(0.12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: (isNegative ? AppColors.darkDanger : AppColors.darkSuccess).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${isNegative ? "" : "+"}${format.format(adj.adjustedAmount)}',
                                          style: TextStyle(
                                            color: isNegative ? AppColors.darkDanger : AppColors.darkSuccess,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    adj.entityType == 'investment_capital'
                                        ? 'Principal Invested changed'
                                        : adj.entityType == 'investment_market_value'
                                            ? 'Market Value changed'
                                            : 'Balance changed',
                                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    deltaText,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Reason: ',
                                        style: TextStyle(color: AppColors.grey500, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      Expanded(
                                        child: Text(
                                          adj.reason,
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
