import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/ipo_pool_models.dart';

class IpoArchiveScreen extends ConsumerStatefulWidget {
  const IpoArchiveScreen({super.key});

  @override
  ConsumerState<IpoArchiveScreen> createState() => _IpoArchiveScreenState();
}

class _IpoArchiveScreenState extends ConsumerState<IpoArchiveScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'All'; // 'All', 'Upcoming', 'Open', 'Closed', 'Listed', 'Archived'
  String _selectedSettlement = 'All'; // 'All', 'Pending', 'Partially Settled', 'Settled'
  String _sortBy = 'date'; // 'name', 'date', 'poolSize', 'profit'
  bool _sortAscending = false; // default newest first for date
  String _viewMode = 'timeline'; // 'timeline', 'table', 'card'

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final pools = dbState.ipoPools.where((p) => p.deletedAt == null).toList();
    final currency = dbState.currency;

    // Filtered lists
    final filteredPools = pools.where((p) {
      // Search
      final q = _searchQuery.trim().toLowerCase();
      if (q.isNotEmpty &&
          !p.name.toLowerCase().contains(q) &&
          !p.companyName.toLowerCase().contains(q)) {
        return false;
      }
      // Status
      if (_selectedStatus != 'All' && p.status != _selectedStatus) {
        return false;
      }
      // Settlement
      if (_selectedSettlement != 'All' && p.settlementStatus != _selectedSettlement) {
        return false;
      }
      return true;
    }).toList();

    // Sorting
    filteredPools.sort((a, b) {
      int comp = 0;
      if (_sortBy == 'name') {
        comp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else if (_sortBy == 'date') {
        comp = a.createdAt.compareTo(b.createdAt);
      } else if (_sortBy == 'poolSize') {
        comp = a.totalPoolAmount.compareTo(b.totalPoolAmount);
      } else if (_sortBy == 'profit') {
        comp = a.totalProfit.compareTo(b.totalProfit);
      }
      return _sortAscending ? comp : -comp;
    });

    // Statistics Calculations
    final totalIpos = pools.length;
    final totalProfit = pools.fold(0.0, (sum, p) => sum + p.totalProfit);

    IpoPool? bestIpo;
    IpoPool? worstIpo;
    double maxProfit = -double.infinity;
    double minProfit = double.infinity;

    for (final p in pools) {
      if (p.listingPrice != null) {
        final profit = p.totalProfit;
        if (profit > maxProfit) {
          maxProfit = profit;
          bestIpo = p;
        }
        if (profit < minProfit) {
          minProfit = profit;
          worstIpo = p;
        }
      }
    }

    final listedOrArchived = pools.where((p) =>
        p.status == 'Listed' || p.status == 'Archived' || p.listingPrice != null);
    final successful = listedOrArchived.where((p) => p.totalProfit > 0);
    final successRate = listedOrArchived.isNotEmpty
        ? (successful.length / listedOrArchived.length) * 100
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'IPO History Archive',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Statistics Header Carousel / Roll
            _buildStatsHeader(
              totalIpos: totalIpos,
              totalProfit: totalProfit,
              bestIpo: bestIpo,
              worstIpo: worstIpo,
              successRate: successRate,
              currency: currency,
            ),

            // Search, Filter & View Mode Controls
            _buildControlPanel(),

            const SizedBox(height: 8),

            // Main View Content
            Expanded(
              child: filteredPools.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.history_edu_outlined,
                      title: 'No IPO Pools Found',
                      description: pools.isEmpty
                          ? 'IPO history pools will appear here once created in the dashboard.'
                          : 'Try modifying your search queries or filters.',
                    )
                  : _buildMainView(filteredPools, currency),
            ),
          ],
        ),
      ),
    );
  }

  // Statistics Header (Horizontal Roll)
  Widget _buildStatsHeader({
    required int totalIpos,
    required double totalProfit,
    required IpoPool? bestIpo,
    required IpoPool? worstIpo,
    required double successRate,
    required String currency,
  }) {
    return Container(
      height: 85,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildStatCard(
            label: 'Total Pools',
            value: '$totalIpos',
            color: AppColors.darkPrimary,
            icon: Icons.inventory_2_outlined,
          ),
          _buildStatCard(
            label: 'Net Gain',
            value: '$currency${totalProfit.toStringAsFixed(0)}',
            color: totalProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
            icon: Icons.trending_up_outlined,
          ),
          _buildStatCard(
            label: 'Success Rate',
            value: '${successRate.toStringAsFixed(1)}%',
            subtitle: '${successRate > 0 ? "Gain on listed pools" : "No pools listed yet"}',
            color: successRate >= 50 ? AppColors.darkSuccess : AppColors.darkWarning,
            icon: Icons.check_circle_outline,
          ),
          if (bestIpo != null)
            _buildStatCard(
              label: 'Best Performer',
              value: bestIpo.name,
              subtitle: 'Gain: $currency${bestIpo.totalProfit.toStringAsFixed(0)}',
              color: AppColors.darkSuccess,
              icon: Icons.star_border,
            ),
          if (worstIpo != null)
            _buildStatCard(
              label: 'Worst Performer',
              value: worstIpo.name,
              subtitle: 'Gain: $currency${worstIpo.totalProfit.toStringAsFixed(0)}',
              color: AppColors.darkDanger,
              icon: Icons.trending_down_outlined,
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    String? subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 8, color: AppColors.grey500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Search & Filter Panel
  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        children: [
          // Row 1: Search & View Modes
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search IPOs...',
                      hintStyle: TextStyle(color: AppColors.grey500),
                      icon: Icon(Icons.search, size: 16, color: AppColors.grey500),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 4),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // View mode segmented selector
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    _buildViewModeButton('timeline', Icons.route_outlined),
                    _buildViewModeButton('card', Icons.grid_view),
                    _buildViewModeButton('table', Icons.table_chart_outlined),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Status, Settlement Filters & Sorting
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Filter Dropdown
                _buildDropdownFilter(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('Status: All')),
                    DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'Open', child: Text('Open')),
                    DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                    DropdownMenuItem(value: 'Listed', child: Text('Listed')),
                    DropdownMenuItem(value: 'Archived', child: Text('Archived')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStatus = val);
                  },
                ),
                const SizedBox(width: 8),
                // Settlement Filter Dropdown
                _buildDropdownFilter(
                  value: _selectedSettlement,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('Settlement: All')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Partially Settled', child: Text('Partial')),
                    DropdownMenuItem(value: 'Settled', child: Text('Settled')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSettlement = val);
                  },
                ),
                const SizedBox(width: 8),
                // Sort Dropdown
                _buildDropdownFilter(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'date', child: Text('Sort: Date')),
                    DropdownMenuItem(value: 'name', child: Text('Sort: Name')),
                    DropdownMenuItem(value: 'poolSize', child: Text('Sort: Pool')),
                    DropdownMenuItem(value: 'profit', child: Text('Sort: Profit')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        if (_sortBy == val) {
                          _sortAscending = !_sortAscending;
                        } else {
                          _sortBy = val;
                          _sortAscending = (val == 'name' || val == 'date') ? true : false;
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(String mode, IconData icon) {
    final isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : AppColors.grey500,
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: AppColors.layer2,
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white, fontSize: 11),
        icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey500, size: 16),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  // --- Main View Selector ---
  Widget _buildMainView(List<IpoPool> filteredPools, String currency) {
    if (_viewMode == 'timeline') {
      return _buildTimelineView(filteredPools, currency);
    } else if (_viewMode == 'table') {
      return _buildTableView(filteredPools, currency);
    } else {
      return _buildCardView(filteredPools, currency);
    }
  }

  // 1. TIMELINE VIEW
  Widget _buildTimelineView(List<IpoPool> pools, String currency) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 12, bottom: 24),
      itemCount: pools.length,
      itemBuilder: (context, index) {
        final pool = pools[index];
        final dateStr = '${pool.createdAt.day}/${pool.createdAt.month}/${pool.createdAt.year}';
        
        // Status color mapping
        Color statusColor = AppColors.grey500;
        if (pool.status == 'Open') statusColor = const Color(0xFF00FFCC);
        if (pool.status == 'Upcoming') statusColor = AppColors.darkPrimary;
        if (pool.status == 'Closed') statusColor = AppColors.darkWarning;
        if (pool.status == 'Listed') statusColor = AppColors.darkSuccess;
        if (pool.status == 'Archived') statusColor = AppColors.grey500;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Node Line
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2,
                      color: index == pools.length - 1
                          ? Colors.transparent
                          : AppColors.glassBorder,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Timeline Card Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GlassCard(
                    onTap: () => context.push('/settings/ipo_pool/${pool.id}'),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pool.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500),
                            ),
                          ],
                        ),
                        if (pool.companyName.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            pool.companyName,
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniMeta('POOL AMOUNT', '$currency${pool.totalPoolAmount.toStringAsFixed(0)}'),
                            _buildMiniMeta('APPLICATIONS', '${pool.fullApplications} (Allot: ${pool.allotments.where((a) => a.status == "Allotted").length})'),
                            _buildMiniMeta('STATUS', pool.status, valueColor: statusColor),
                          ],
                        ),
                        if (pool.listingPrice != null) ...[
                          const SizedBox(height: 10),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gain Profit:',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400),
                              ),
                              Text(
                                '$currency${pool.totalProfit.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniMeta(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 8, color: AppColors.grey500, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  // 2. TABLE VIEW
  Widget _buildTableView(List<IpoPool> pools, String currency) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                padding: EdgeInsets.zero,
                child: DataTable(
                  headingTextStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.grey400,
                  ),
                  dataTextStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  columnSpacing: 20,
                  columns: const [
                    DataColumn(label: Text('IPO NAME')),
                    DataColumn(label: Text('COMPANY')),
                    DataColumn(label: Text('POOL SIZE')),
                    DataColumn(label: Text('APPS (ALLOT)')),
                    DataColumn(label: Text('PROFIT')),
                    DataColumn(label: Text('SETTLED')),
                    DataColumn(label: Text('STATUS')),
                  ],
                  rows: pools.map((p) {
                    final allotted = p.allotments.where((a) => a.status == 'Allotted').length;
                    
                    Color statusColor = AppColors.grey500;
                    if (p.status == 'Open') statusColor = const Color(0xFF00FFCC);
                    if (p.status == 'Upcoming') statusColor = AppColors.darkPrimary;
                    if (p.status == 'Closed') statusColor = AppColors.darkWarning;
                    if (p.status == 'Listed') statusColor = AppColors.darkSuccess;

                    Color settColor = AppColors.darkWarning;
                    if (p.settlementStatus == 'Settled') settColor = AppColors.darkSuccess;
                    if (p.settlementStatus == 'Pending') settColor = AppColors.darkDanger;

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () => context.push('/settings/ipo_pool/${p.id}'),
                        ),
                        DataCell(Text(p.companyName.isEmpty ? '-' : p.companyName)),
                        DataCell(Text('$currency${p.totalPoolAmount.toStringAsFixed(0)}')),
                        DataCell(Text('${p.fullApplications} ($allotted)')),
                        DataCell(
                          Text(
                            '$currency${p.totalProfit.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: p.totalProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            p.settlementStatus,
                            style: TextStyle(color: settColor, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.status,
                              style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 3. CARD VIEW
  Widget _buildCardView(List<IpoPool> pools, String currency) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: pools.length,
      itemBuilder: (context, index) {
        final pool = pools[index];
        final dateStr = '${pool.createdAt.day}/${pool.createdAt.month}/${pool.createdAt.year}';
        final allotted = pool.allotments.where((a) => a.status == 'Allotted').length;

        Color statusColor = AppColors.grey500;
        if (pool.status == 'Open') statusColor = const Color(0xFF00FFCC);
        if (pool.status == 'Upcoming') statusColor = AppColors.darkPrimary;
        if (pool.status == 'Closed') statusColor = AppColors.darkWarning;
        if (pool.status == 'Listed') statusColor = AppColors.darkSuccess;

        Color settColor = AppColors.darkWarning;
        if (pool.settlementStatus == 'Settled') settColor = AppColors.darkSuccess;
        if (pool.settlementStatus == 'Pending') settColor = AppColors.darkDanger;

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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pool.status.toUpperCase(),
                        style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
                if (pool.companyName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    pool.companyName,
                    style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('POOL CASH', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500)),
                        const SizedBox(height: 2),
                        Text(
                          '$currency${pool.totalPoolAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('APPLICATIONS', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500)),
                        const SizedBox(height: 2),
                        Text(
                          '${pool.fullApplications} (Allot: $allotted)',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('SETTLEMENT', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500)),
                        const SizedBox(height: 2),
                        Text(
                          pool.settlementStatus,
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: settColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.glassBorder, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Created on: $dateStr  |  Contributors: ${pool.contributors.length}',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500),
                    ),
                    Text(
                      pool.listingPrice != null
                          ? 'Gains: $currency${pool.totalProfit.toStringAsFixed(0)}'
                          : 'No Listing Gains Set',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: pool.listingPrice != null
                            ? (pool.totalProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger)
                            : AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
