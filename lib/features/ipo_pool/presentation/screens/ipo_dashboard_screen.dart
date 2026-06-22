import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/ipo_pool_models.dart';
import '../widgets/calculation_audit_panel.dart';

class IpoDashboardScreen extends ConsumerStatefulWidget {
  const IpoDashboardScreen({super.key});

  @override
  ConsumerState<IpoDashboardScreen> createState() => _IpoDashboardScreenState();
}

class _IpoDashboardScreenState extends ConsumerState<IpoDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _priceController = TextEditingController();
  final _lotSizeController = TextEditingController();
  final _sharesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _lotSizeController.dispose();
    _sharesController.dispose();
    super.dispose();
  }

  void _showCreatePoolSheet() {
    _nameController.clear();
    _costController.clear();
    _priceController.clear();
    _lotSizeController.clear();
    _sharesController.clear();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create IPO Pool',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up a new pool based on your real-world pooling workflow.',
                  style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'IPO Name',
                    hintText: 'e.g. CMR GREEN TECHNOLOGIES LTD',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter IPO Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Application Cost (₹)',
                          hintText: 'e.g. 14976',
                          labelStyle: TextStyle(color: AppColors.grey500),
                        ),
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Invalid cost';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Issue Price (₹)',
                          hintText: 'e.g. 100',
                          labelStyle: TextStyle(color: AppColors.grey500),
                        ),
                        validator: (value) {
                          if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _lotSizeController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Lot Size (Qty)',
                          hintText: 'e.g. 150',
                          labelStyle: TextStyle(color: AppColors.grey500),
                        ),
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Invalid lot';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _sharesController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Shares Per Lot',
                          hintText: 'e.g. 150',
                          labelStyle: TextStyle(color: AppColors.grey500),
                        ),
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Invalid shares';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final pool = IpoPool(
                        id: const Uuid().v4(),
                        name: _nameController.text.trim(),
                        applicationCost: double.parse(_costController.text.trim()),
                        issuePrice: double.parse(_priceController.text.trim()),
                        lotSize: int.parse(_lotSizeController.text.trim()),
                        sharesPerLot: int.parse(_sharesController.text.trim()),
                        contributors: [],
                        allotments: [],
                        createdAt: DateTime.now(),
                      );
                      ref.read(mockDatabaseProvider.notifier).addIpoPool(pool);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Created IPO pool: ${pool.name}'),
                          backgroundColor: AppColors.darkPrimary,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Create Pool',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final pools = dbState.ipoPools.where((p) => p.deletedAt == null).toList();
    final currency = dbState.currency;

    // Aggregations
    double totalPoolAmount = 0.0;
    double totalApplications = 0.0;
    double soloApplications = 0.0;
    double groupApplications = 0.0;
    int totalContributors = 0;
    double totalProfit = 0.0;

    for (final p in pools) {
      totalPoolAmount += p.totalPoolAmount;
      totalApplications += p.totalApplications;
      soloApplications += p.soloApplications.toDouble();
      groupApplications += p.groupApplications;
      totalContributors += p.contributors.length;
      totalProfit += p.totalProfit;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IPO Co-Investment Pools',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu),
            onPressed: () => context.push('/settings/ipo_pool/archive'),
            tooltip: 'Archive & History',
          ),
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            onPressed: () => context.push('/settings/ipo_pool/contributors'),
            tooltip: 'Contributor Ledger',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePoolSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Pool', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkPrimary,
      ),
      body: SafeArea(
        child: pools.isEmpty
            ? const EmptyStateWidget(
                icon: Icons.pie_chart_outline,
                title: 'No IPO Pools',
                description: 'Create a new co-investment pool to start tracking contributions and allotments.',
              )
            : ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Aggregated metrics grid
                  _buildMetricsGrid(
                    currency: currency,
                    totalPoolAmount: totalPoolAmount,
                    totalApplications: totalApplications,
                    soloApplications: soloApplications,
                    groupApplications: groupApplications,
                    totalContributors: totalContributors,
                    totalProfit: totalProfit,
                  ),
                  const SizedBox(height: 12),
                  CalculationAuditPanel(
                    title: 'Verify Dashboard Aggregations',
                    formula: 'Total Pool Amount = sum(Pool.totalPoolAmount)\n'
                        'Total Applications = sum(Pool.totalApplications)\n'
                        'Solo Applications = sum(Pool.soloApplications)\n'
                        'Group Applications = sum(Pool.groupApplications)\n'
                        'Accumulated Profit = sum(Pool.totalProfit)',
                    inputs: {
                      'Active IPO Pools Count': '${pools.length}',
                      'Total Pool Amount (Raw Sum)': '$currency${totalPoolAmount.toStringAsFixed(2)}',
                      'Total Applications (Raw Sum)': totalApplications.toStringAsFixed(2),
                      'Solo Applications (Raw Sum)': soloApplications.toStringAsFixed(0),
                      'Group Applications (Raw Sum)': groupApplications.toStringAsFixed(2),
                      'Accumulated Profit (Raw Sum)': '$currency${totalProfit.toStringAsFixed(2)}',
                    },
                    output: 'Dashboard Aggregated Successfully',
                    steps: [
                      'We retrieve all co-investment pools that have not been soft deleted.',
                      'For each pool, we read the total verified group contributions (Pool Cash).',
                      'Total Applications is calculated for each pool as Pool Cash / Application Cost, then summed up: ${totalApplications.toStringAsFixed(2)}.',
                      'Solo Applications is the sum of reserved solo applications: ${soloApplications.toStringAsFixed(0)}.',
                      'Group Applications is the remaining applications for each pool: total - solo = ${groupApplications.toStringAsFixed(2)}.',
                      'Accumulated Profit sums the listing gains from all listed pools: $currency${totalProfit.toStringAsFixed(2)}.',
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE IPO POOLS',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey500,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${pools.length} Pools',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Pools List
                  ...pools.map((pool) => _buildPoolCard(context, pool, currency)),
                ],
              ),
      ),
    );
  }

  Widget _buildMetricsGrid({
    required String currency,
    required double totalPoolAmount,
    required double totalApplications,
    required double soloApplications,
    required double groupApplications,
    required int totalContributors,
    required double totalProfit,
  }) {
    final formatCurrency = (double value) {
      if (value == 0.0) return '${currency}0';
      if (value >= 100000) {
        return '$currency${(value / 100000).toStringAsFixed(2)}L';
      }
      return '$currency${value.toStringAsFixed(0)}';
    };

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildMetricItem(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Total Pool Amount',
          value: formatCurrency(totalPoolAmount),
          color: AppColors.darkPrimary,
        ),
        _buildMetricItem(
          icon: Icons.assessment_outlined,
          title: 'Total Applications',
          value: totalApplications.toStringAsFixed(2),
          subtitle: 'Solo: ${soloApplications.toStringAsFixed(0)} | Group: ${groupApplications.toStringAsFixed(2)}',
          color: const Color(0xFF8E2DE2),
        ),
        _buildMetricItem(
          icon: Icons.people_outline,
          title: 'Total Contributors',
          value: '$totalContributors',
          color: const Color(0xFF00F2FE),
        ),
        _buildMetricItem(
          icon: Icons.trending_up_outlined,
          title: 'Accumulated Profit',
          value: formatCurrency(totalProfit),
          color: totalProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 10, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPoolCard(BuildContext context, IpoPool pool, String currency) {
    final dateStr = '${pool.createdAt.day}/${pool.createdAt.month}/${pool.createdAt.year}';
    final allottedApps = pool.allotments.where((a) => a.status == 'Allotted').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () => context.push('/settings/ipo_pool/${pool.id}'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pool.name,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('POOL CASH', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
                    const SizedBox(height: 2),
                    Text(
                      '$currency${pool.totalPoolAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('APPLICATIONS', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
                    const SizedBox(height: 2),
                    Text(
                      '${pool.totalApplications.toStringAsFixed(2)} (Solo: ${pool.soloApplications})',
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('ALLOTMENTS', style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
                    const SizedBox(height: 2),
                    Text(
                      '$allottedApps Allotted',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: allottedApps > 0 ? AppColors.darkSuccess : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (pool.listingPrice != null) ...[
              const SizedBox(height: 12),
              const Divider(color: AppColors.glassBorder, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Listing Gain Profit:',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400),
                  ),
                  Text(
                    '$currency${pool.totalProfit.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: pool.totalProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
