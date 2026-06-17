import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../database/database.dart';

class SnapshotScreen extends ConsumerWidget {
  const SnapshotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    // Get snapshots sorted newest first
    final snapshots = List<Snapshot>.from(dbState.snapshots)..sort((a, b) => b.snapshotDate.compareTo(a.snapshotDate));

    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Snapshots', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: snapshots.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetPaths.noExpectedIncome,
                        height: AssetConstants.emptyStateImageHeight,
                        semanticLabel: 'No Snapshots',
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Snapshots Yet',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Take a snapshot of your current net worth to lock in your progress and start tracking historical changes.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppColors.grey500, height: 1.4),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: snapshots.length,
                itemBuilder: (context, index) {
                  final snap = snapshots[index];
                  final monthYear = DateFormat('MMMM yyyy').format(snap.snapshotDate.toLocal());
                  
                  // Calculate growth against previous snapshot if available
                  double growthPct = 0.0;
                  if (index < snapshots.length - 1) {
                    final prev = snapshots[index + 1];
                    growthPct = prev.netWorth > 0 ? ((snap.netWorth - prev.netWorth) / prev.netWorth) * 100 : 0.0;
                  } else {
                    growthPct = 0.0;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(monthYear, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: growthPct >= 0 
                                      ? AppColors.darkSuccess.withOpacity(0.12) 
                                      : AppColors.darkDanger.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${growthPct >= 0 ? '+' : ''}${growthPct.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: growthPct >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.glassBorder, height: 24),
                          
                          // Net Worth Value
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('NET WORTH', style: TextStyle(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                              Text(format.format(snap.netWorth), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Breakdown Details
                          _buildSnapDetailRow('Total Assets', format.format(snap.assets), Colors.white70),
                          const SizedBox(height: 6),
                          _buildSnapDetailRow('Total Liabilities', format.format(snap.liabilities), AppColors.darkDanger.withOpacity(0.8)),
                          const SizedBox(height: 6),
                          _buildSnapDetailRow('Invested Cost Basis', format.format(snap.investedCapital), AppColors.darkPrimary.withOpacity(0.8)),
                          const SizedBox(height: 6),
                          _buildSnapDetailRow('Expected Income (Pending)', format.format(snap.expectedIncome), AppColors.grey500),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
          try {
            await ref.read(realSnapshotServiceProvider).createSnapshot();
            if (context.mounted) {
              Navigator.pop(context); // Dismiss loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Net worth snapshot captured successfully.')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Dismiss loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to capture snapshot: $e')),
              );
            }
          }
        },
        backgroundColor: AppColors.darkPrimary,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text('Capture Snapshot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSnapDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 12)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
