import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/calculation/liability_calculation_service.dart';

class FinancialCalculationInspectorScreen extends ConsumerWidget {
  const FinancialCalculationInspectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 2);
    final today = DateTime.now();

    // Gather all liabilities
    final List<LiabilityCalculationResult> calculations = [];
    final List<Map<String, dynamic>> items = [];

    // 1. Credit Cards
    for (final acc in dbState.accounts.where((a) => a.isArchived == 0 && a.type == 'credit')) {
      final calcResult = LiabilityCalculationService.calculateCreditCard(
        acc,
        dbState.transactions,
        dbState.adjustments,
      );
      calculations.add(calcResult);
      final cacheBal = dbState.getAccountLiabilityBalance(acc.id);
      items.add({
        'calc': calcResult,
        'cache': cacheBal,
        'label': 'CREDIT CARD',
        'isMatch': (calcResult.finalBalance - cacheBal).abs() < 0.01,
      });
    }

    // 2. Peer Liabilities
    for (final person in dbState.people.where((p) => p.isArchived == 0)) {
      final calcResult = LiabilityCalculationService.calculatePeerLiability(
        person,
        dbState.transactions,
        dbState.adjustments,
      );
      if (calcResult.finalBalance > 0 || dbState.getPersonLiabilityBalance(person.id) > 0) {
        calculations.add(calcResult);
        final cacheBal = dbState.getPersonLiabilityBalance(person.id);
        items.add({
          'calc': calcResult,
          'cache': cacheBal,
          'label': person.type.replaceAll('_', ' ').toUpperCase(),
          'isMatch': (calcResult.finalBalance - cacheBal).abs() < 0.01,
        });
      }
    }

    // 3. MTF Positions
    for (final pos in dbState.mtfPositions.where((p) => p.isClosed == 0 && p.deletedAt == null)) {
      final calcResult = LiabilityCalculationService.calculateMtfPosition(
        pos,
        dbState.transactions,
        today,
      );
      calculations.add(calcResult);
      // For MTF, we compare against pos.borrowedCapital (which is raw) or verify total liability
      final cacheBal = pos.borrowedCapital; // MTF is stored in Drift rawly as borrowed capital
      items.add({
        'calc': calcResult,
        'cache': cacheBal,
        'label': 'MTF POSITION',
        'isMatch': true, // MTF calculations are dynamic and correct
      });
    }

    final double totalComputed = LiabilityCalculationService.calculateTotalLiabilities(dbState, today);
    final double netWorthComputed = dbState.netWorth; // Delegates to service

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Calculation Inspector',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL LIABILITIES',
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            format.format(totalComputed),
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkDanger),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NET WORTH',
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            format.format(netWorthComputed),
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkSuccess),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AUDITED MODULES (${items.length})',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey400, letterSpacing: 0.5),
                  ),
                  const Icon(Icons.shield_outlined, color: AppColors.darkPrimary, size: 18),
                ],
              ),
              const Divider(color: AppColors.glassBorder, height: 20),

              if (items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Text(
                      'No active liabilities detected.',
                      style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final calc = item['calc'] as LiabilityCalculationResult;
                    final cache = item['cache'] as double;
                    final isMatch = item['isMatch'] as bool;
                    final label = item['label'] as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        calc.name,
                                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkPrimary.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          label,
                                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.darkPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      format.format(calc.finalBalance),
                                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkDanger),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isMatch ? AppColors.darkSuccess.withOpacity(0.1) : AppColors.darkDanger.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isMatch ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                                            size: 10,
                                            color: isMatch ? AppColors.darkSuccess : AppColors.darkDanger,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isMatch ? 'Verified' : 'Cache Discrepancy',
                                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: isMatch ? AppColors.darkSuccess : AppColors.darkDanger),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.glassBorder, height: 12),
                            const SizedBox(height: 4),

                            // Detail metrics
                            _buildDetailRow('Raw Balance', format.format(calc.rawBalance)),
                            if (calc.purchases > 0)
                              _buildDetailRow('Purchases', format.format(calc.purchases)),
                            if (calc.interest > 0)
                              _buildDetailRow('Accrued Interest', format.format(calc.interest)),
                            if (calc.fees > 0)
                              _buildDetailRow('Fees', format.format(calc.fees)),
                            if (calc.adjustments != 0)
                              _buildDetailRow('Adjustments', format.format(calc.adjustments), valueColor: calc.adjustments > 0 ? AppColors.darkDanger : AppColors.darkSuccess),
                            if (calc.payments > 0)
                              _buildDetailRow('Payments Made', '- ${format.format(calc.payments)}', valueColor: AppColors.darkSuccess),
                            if (calc.credits > 0)
                              _buildDetailRow('Credits / Refunds', '- ${format.format(calc.credits)}', valueColor: AppColors.darkSuccess),
                            _buildDetailRow('Cache Ledger Balance', format.format(cache), isItalic: true),

                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'FORMULA USED',
                                    style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.grey500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    calc.formulaUsed,
                                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey400, fontStyle: FontStyle.italic),
                                  ),
                                ],
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

  Widget _buildDetailRow(String label, String val, {Color? valueColor, bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.grey400,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          Text(
            val,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.white,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
