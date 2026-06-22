import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/ipo_pool_models.dart';

class ContributorLedgerSummary {
  final String name;
  final String phone;
  final String upiId;
  final List<String> activePools;
  final double totalContributions;
  final double totalProfitEarned;
  final double totalSettlementsReceived;
  final double pendingSettlements;
  final double roiPercent;
  final double averageReturnPercent;
  final int ipoParticipationCount;

  ContributorLedgerSummary({
    required this.name,
    required this.phone,
    required this.upiId,
    required this.activePools,
    required this.totalContributions,
    required this.totalProfitEarned,
    required this.totalSettlementsReceived,
    required this.pendingSettlements,
    required this.roiPercent,
    required this.averageReturnPercent,
    required this.ipoParticipationCount,
  });
}

class IpoContributorsListScreen extends ConsumerStatefulWidget {
  const IpoContributorsListScreen({super.key});

  @override
  ConsumerState<IpoContributorsListScreen> createState() => _IpoContributorsListScreenState();
}

class _IpoContributorsListScreenState extends ConsumerState<IpoContributorsListScreen> {
  String _searchQuery = '';
  String _sortBy = 'name'; // 'name', 'contribution', 'roi', 'pending'
  bool _sortAscending = true;

  List<ContributorLedgerSummary> _compileLedger(List<IpoPool> pools) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final pool in pools) {
      final totalGroupContrib = pool.totalGroupContribution;
      for (final c in pool.contributors) {
        final key = c.name.trim().toLowerCase();
        final verifiedContrib = pool.getContributorVerifiedContribution(c.id);
        
        double profitShare = 0.0;
        if (totalGroupContrib > 0) {
          final ownershipFraction = verifiedContrib / totalGroupContrib;
          profitShare = pool.groupProfit * ownershipFraction;
        }

        final entry = {
          'pool': pool,
          'contributor': c,
          'verifiedContribution': verifiedContrib,
          'profitShare': profitShare,
        };

        if (grouped.containsKey(key)) {
          grouped[key]!.add(entry);
        } else {
          grouped[key] = [entry];
        }
      }
    }

    final List<ContributorLedgerSummary> list = [];

    grouped.forEach((key, entries) {
      final firstEntry = entries.first;
      final firstContrib = firstEntry['contributor'] as IpoContributor;
      final name = firstContrib.name;

      // Find the most recently added details (e.g. upiId, phone)
      String phone = '';
      String upiId = '';
      DateTime latestDate = DateTime(1970);
      for (final entry in entries) {
        final p = entry['pool'] as IpoPool;
        if (p.createdAt.isAfter(latestDate)) {
          latestDate = p.createdAt;
          final c = entry['contributor'] as IpoContributor;
          if (c.phone.isNotEmpty) phone = c.phone;
          if (c.upiId.isNotEmpty) upiId = c.upiId;
        }
      }

      double totalContrib = 0.0;
      double totalProfit = 0.0;
      double totalReceived = 0.0;
      final List<String> activeList = [];
      final List<double> returnPercentages = [];

      for (final entry in entries) {
        final p = entry['pool'] as IpoPool;
        final c = entry['contributor'] as IpoContributor;
        final verifiedContrib = entry['verifiedContribution'] as double;
        final profit = entry['profitShare'] as double;

        totalContrib += verifiedContrib;
        totalProfit += profit;
        totalReceived += p.getContributorTotalSettled(c.id);

        if (p.status == 'Open' || p.status == 'Upcoming' || p.status == 'Listed') {
          activeList.add(p.name);
        }

        if (verifiedContrib > 0) {
          returnPercentages.add((profit / verifiedContrib) * 100);
        }
      }

      final pending = (totalContrib + totalProfit) - totalReceived;
      final roi = totalContrib > 0 ? (totalProfit / totalContrib) * 100 : 0.0;
      final avgReturn = returnPercentages.isNotEmpty
          ? returnPercentages.reduce((a, b) => a + b) / returnPercentages.length
          : 0.0;

      list.add(ContributorLedgerSummary(
        name: name,
        phone: phone.isNotEmpty ? phone : firstContrib.phone,
        upiId: upiId.isNotEmpty ? upiId : firstContrib.upiId,
        activePools: activeList,
        totalContributions: totalContrib,
        totalProfitEarned: totalProfit,
        totalSettlementsReceived: totalReceived,
        pendingSettlements: pending,
        roiPercent: roi,
        averageReturnPercent: avgReturn,
        ipoParticipationCount: entries.length,
      ));
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final ledgerList = _compileLedger(dbState.ipoPools.where((p) => p.deletedAt == null).toList());

    // Apply Search Filter
    final filteredList = ledgerList.where((c) {
      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.upiId.toLowerCase().contains(q);
    }).toList();

    // Apply Sorting
    filteredList.sort((a, b) {
      int comparison = 0;
      if (_sortBy == 'name') {
        comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else if (_sortBy == 'contribution') {
        comparison = a.totalContributions.compareTo(b.totalContributions);
      } else if (_sortBy == 'roi') {
        comparison = a.roiPercent.compareTo(b.roiPercent);
      } else if (_sortBy == 'pending') {
        comparison = a.pendingSettlements.compareTo(b.pendingSettlements);
      }

      return _sortAscending ? comparison : -comparison;
    });

    // Ledger aggregates
    final totalContributors = ledgerList.length;
    final totalContributions = ledgerList.fold(0.0, (sum, c) => sum + c.totalContributions);
    final totalProfits = ledgerList.fold(0.0, (sum, c) => sum + c.totalProfitEarned);
    final avgRoi = totalContributions > 0 ? (totalProfits / totalContributions) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contributor Ledger',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Overview summary card
            if (ledgerList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryItem('Contributors', '$totalContributors'),
                      _buildSummaryItem('Total Capital', '$currency${totalContributions.toStringAsFixed(0)}'),
                      _buildSummaryItem('Total Gain', '$currency${totalProfits.toStringAsFixed(0)}'),
                      _buildSummaryItem('Avg ROI', '${avgRoi.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
              ),

            // Search and sort bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Search by name or phone...',
                          hintStyle: TextStyle(color: AppColors.grey500),
                          icon: Icon(Icons.search, size: 18, color: AppColors.grey500),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Sort dropdown
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: DropdownButton<String>(
                      value: _sortBy,
                      dropdownColor: AppColors.layer2,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey500),
                      items: const [
                        DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
                        DropdownMenuItem(value: 'contribution', child: Text('Sort: Contribution')),
                        DropdownMenuItem(value: 'roi', child: Text('Sort: ROI %')),
                        DropdownMenuItem(value: 'pending', child: Text('Sort: Pending')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            if (_sortBy == val) {
                              _sortAscending = !_sortAscending;
                            } else {
                              _sortBy = val;
                              _sortAscending = true;
                            }
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Contributors List
            Expanded(
              child: filteredList.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.contact_mail_outlined,
                      title: 'No Contributors Found',
                      description: _searchQuery.isEmpty
                          ? 'Contributors will appear here automatically when added to IPO Pools.'
                          : 'Try modifying your search or filters.',
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final c = filteredList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            onTap: () => context.push(
                              '/settings/ipo_pool/contributors/${Uri.encodeComponent(c.name)}',
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            c.name,
                                            style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.darkPrimary.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'ROI: ${c.roiPercent.toStringAsFixed(1)}%',
                                              style: const TextStyle(
                                                  color: AppColors.darkPrimary,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Pooled: $currency${c.totalContributions.toStringAsFixed(0)}',
                                            style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                                          ),
                                          Text(
                                            'IPOs: ${c.ipoParticipationCount}',
                                            style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      if (c.phone.isNotEmpty || c.upiId.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            if (c.phone.isNotEmpty) c.phone,
                                            if (c.upiId.isNotEmpty) 'UPI: ${c.upiId}'
                                          ].join('  |  '),
                                          style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 10),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'PENDING DUES',
                                      style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 9, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$currency${c.pendingSettlements.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: c.pendingSettlements > 0
                                            ? AppColors.darkDanger
                                            : c.pendingSettlements < 0
                                                ? const Color(0xFF00FFCC)
                                                : AppColors.darkSuccess,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.grey500),
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
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 10)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
