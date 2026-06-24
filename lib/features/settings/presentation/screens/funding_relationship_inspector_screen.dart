import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart' as db;

class FundingRelationshipInspectorScreen extends ConsumerWidget {
  const FundingRelationshipInspectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 2);

    // Analyze funding relationships
    double totalDebtFundedAssets = 0.0;
    final Set<String> lenders = {};
    int matchCount = 0;
    int discrepancyCount = 0;

    final List<Map<String, dynamic>> inspectorItems = [];

    for (final inv in dbState.investments) {
      final lots = dbState.investmentLots.where((l) => l.investmentId == inv.id).toList();
      final debtLots = lots.where((l) => l.fundingSource == 'liability_borrowed').toList();

      if (debtLots.isEmpty) continue;

      double invBorrowedAmount = 0.0;
      final List<Map<String, dynamic>> linkedTxDetails = [];
      bool hasDiscrepancy = false;
      String lenderName = 'Unknown';

      for (final lot in debtLots) {
        final lotAmount = lot.unitsPurchased * lot.costPerUnit;
        invBorrowedAmount += lotAmount;
        totalDebtFundedAssets += lotAmount;

        if (lot.fundingLiabilityId != null) {
          lenders.add(lot.fundingLiabilityId!);
          if (lot.fundingLiabilityId!.startsWith('person_')) {
            final person = dbState.people.firstWhereOrNull((p) => p.id == lot.fundingLiabilityId);
            lenderName = person?.name ?? 'Peer Lender';
          } else if (lot.fundingLiabilityId!.startsWith('acc_')) {
            final acc = dbState.accounts.firstWhereOrNull((a) => a.id == lot.fundingLiabilityId);
            lenderName = acc?.name ?? 'Credit Card';
          }
        }

        // Find Buy Transaction
        final buyTx = dbState.transactions.firstWhereOrNull((t) => t.id == lot.buyTransactionId);
        if (buyTx != null) {
          linkedTxDetails.add({
            'id': buyTx.id,
            'type': 'Buy Investment',
            'amount': buyTx.amount,
            'date': buyTx.transactionDate,
            'notes': buyTx.notes,
            'status': buyTx.voidedTransactionId != null ? 'Voided' : 'Active',
            'uuid': buyTx.transactionUuid,
          });
        }

        // Find Borrow Transaction (id starts with buyTxId_borrow or operationUuid is buyTxId)
        final borrowTx = dbState.transactions.firstWhereOrNull(
          (t) => t.id == '${lot.buyTransactionId}_borrow' || 
                 (t.operationUuid == lot.buyTransactionId && t.type == 'borrow_money')
        );

        if (borrowTx != null) {
          linkedTxDetails.add({
            'id': borrowTx.id,
            'type': 'Borrow Money',
            'amount': borrowTx.amount,
            'date': borrowTx.transactionDate,
            'notes': borrowTx.notes,
            'status': borrowTx.voidedTransactionId != null ? 'Voided' : 'Active',
            'uuid': borrowTx.transactionUuid,
          });

          // Check if amounts match (only for non-voided transactions)
          if (buyTx != null && buyTx.voidedTransactionId == null && borrowTx.voidedTransactionId == null) {
            final diff = (buyTx.amount - borrowTx.amount).abs();
            if (diff > 0.01) {
              hasDiscrepancy = true;
            }
          }
        } else {
          // Borrow transaction is missing!
          if (buyTx != null && buyTx.voidedTransactionId == null) {
            hasDiscrepancy = true;
            linkedTxDetails.add({
              'id': '${lot.buyTransactionId}_borrow',
              'type': 'Borrow Money',
              'amount': buyTx.amount,
              'date': buyTx.transactionDate,
              'notes': 'Missing linked borrow transaction!',
              'status': 'Missing',
              'uuid': null,
            });
          }
        }
      }

      if (hasDiscrepancy) {
        discrepancyCount++;
      } else {
        matchCount++;
      }

      inspectorItems.add({
        'investment': inv,
        'lenderName': lenderName,
        'borrowedAmount': invBorrowedAmount,
        'hasDiscrepancy': hasDiscrepancy,
        'linkedTxs': linkedTxDetails,
      });
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Funding Inspector',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                childAspectRatio: 1.1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSummaryCard(
                    context,
                    'Debt Assets',
                    format.format(totalDebtFundedAssets),
                    Icons.account_balance,
                    AppColors.darkPrimary,
                  ),
                  _buildSummaryCard(
                    context,
                    'Lenders',
                    '${lenders.length}',
                    Icons.people_alt_rounded,
                    Colors.purpleAccent,
                  ),
                  _buildSummaryCard(
                    context,
                    'Status',
                    discrepancyCount > 0 ? '$discrepancyCount Alerts' : 'Aligned',
                    discrepancyCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                    discrepancyCount > 0 ? AppColors.darkDanger : AppColors.darkSuccess,
                  ),
                ],
              ),
            ),
            
            // List Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Debt-Funded Investments',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),

            // Investments List
            Expanded(
              child: inspectorItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 64,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No debt-funded investments found.',
                            style: GoogleFonts.outfit(color: Colors.white38),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: inspectorItems.length,
                      itemBuilder: (context, index) {
                        final item = inspectorItems[index];
                        final inv = item['investment'] as db.Investment;
                        final lender = item['lenderName'] as String;
                        final amount = item['borrowedAmount'] as double;
                        final hasAlert = item['hasDiscrepancy'] as bool;
                        final linkedTxs = item['linkedTxs'] as List<Map<String, dynamic>>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: GlassCard(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Title and Badge
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          inv.name,
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: hasAlert
                                              ? AppColors.darkDanger.withOpacity(0.1)
                                              : AppColors.darkSuccess.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: hasAlert ? AppColors.darkDanger : AppColors.darkSuccess,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              hasAlert ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                                              size: 14,
                                              color: hasAlert ? AppColors.darkDanger : AppColors.darkSuccess,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              hasAlert ? 'Discrepancy' : 'Aligned',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: hasAlert ? AppColors.darkDanger : AppColors.darkSuccess,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Lender & Borrowed portion
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'LENDER',
                                            style: GoogleFonts.outfit(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white38,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            lender,
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.87),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'BORROWED AMOUNT',
                                            style: GoogleFonts.outfit(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white38,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            format.format(amount),
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24, color: Colors.white10),

                                  // Timeline header
                                  Text(
                                    'LINKED TRANSACTIONS',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white30,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Transaction list inside card
                                  ...linkedTxs.map((tx) {
                                    final txDate = tx['date'] as DateTime;
                                    final isVoided = tx['status'] == 'Voided';
                                    final isMissing = tx['status'] == 'Missing';

                                    Color statusColor = Colors.white54;
                                    if (isVoided) statusColor = Colors.orangeAccent;
                                    if (isMissing) statusColor = Colors.redAccent;

                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                                      padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.02),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isMissing 
                                              ? Colors.redAccent.withOpacity(0.3) 
                                              : Colors.white.withOpacity(0.05),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: isMissing 
                                                ? Colors.redAccent.withOpacity(0.1) 
                                                : Colors.white.withOpacity(0.05),
                                            child: Icon(
                                              tx['type'] == 'Buy Investment' 
                                                  ? Icons.shopping_bag_outlined 
                                                  : Icons.account_balance_wallet_outlined,
                                              size: 14,
                                              color: isMissing ? Colors.redAccent : AppColors.darkPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      (tx['type'] ?? '').toString(),
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: isMissing ? Colors.redAccent : Colors.white70,
                                                      ),
                                                    ),
                                                    Text(
                                                      format.format(tx['amount']),
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: isVoided 
                                                            ? Colors.orangeAccent.withOpacity(0.6) 
                                                            : (isMissing ? Colors.redAccent.withOpacity(0.6) : Colors.white),
                                                        decoration: isVoided ? TextDecoration.lineThrough : null,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'ID: ${tx['id']}',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 9,
                                                    color: Colors.white24,
                                                  ),
                                                ),
                                                if (tx['notes'] != null) ...[
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    (tx['notes'] ?? '').toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 10,
                                                      color: isMissing ? Colors.redAccent.withOpacity(0.8) : Colors.white38,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(height: 6),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white30,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
