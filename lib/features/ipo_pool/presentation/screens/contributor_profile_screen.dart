import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/ipo_pool_models.dart';

class ContributorProfileScreen extends ConsumerStatefulWidget {
  final String contributorName;
  const ContributorProfileScreen({required this.contributorName, super.key});

  @override
  ConsumerState<ContributorProfileScreen> createState() => _ContributorProfileScreenState();
}

class _ContributorProfileScreenState extends ConsumerState<ContributorProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _upiController = TextEditingController();
  
  // Filtering state
  DateTimeRange? _selectedDateRange;
  String _selectedPool = 'All';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  // Aggregate participant events
  List<Map<String, dynamic>> _compileEvents(List<IpoPool> pools) {
    final List<Map<String, dynamic>> events = [];
    final targetName = widget.contributorName.trim().toLowerCase();

    for (final pool in pools) {
      final c = pool.contributors.firstWhereOrNull(
        (cont) => cont.name.trim().toLowerCase() == targetName,
      );

      if (c != null) {
        double profitShare = 0.0;
        final totalGroupContrib = pool.totalGroupContribution;
        final verifiedContrib = pool.getContributorVerifiedContribution(c.id);
        if (totalGroupContrib > 0) {
          profitShare = pool.groupProfit * (verifiedContrib / totalGroupContrib);
        }

        events.add({
          'poolId': pool.id,
          'poolName': pool.name,
          'companyName': pool.companyName,
          'date': pool.createdAt,
          'contribution': verifiedContrib,
          'profitShare': profitShare,
          'amountReceived': pool.getContributorTotalSettled(c.id),
          'status': pool.status,
          'contributorRaw': c,
          'poolRaw': pool,
        });
      }
    }

    // Sort by date ascending for charts
    events.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    return events;
  }

  void _updateUpiId(String newUpi) {
    final notifier = ref.read(mockDatabaseProvider.notifier);
    final pools = ref.read(mockDatabaseProvider).ipoPools.where((p) => p.deletedAt == null).toList();
    int updateCount = 0;

    for (final pool in pools) {
      bool hasChange = false;
      final updatedContribs = pool.contributors.map((c) {
        if (c.name.trim().toLowerCase() == widget.contributorName.trim().toLowerCase()) {
          hasChange = true;
          return c.copyWith(upiId: newUpi);
        }
        return c;
      }).toList();
      
      if (hasChange) {
        notifier.updateIpoPool(pool.copyWith(contributors: updatedContribs));
        updateCount++;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('UPI ID updated across $updateCount pool records.'),
        backgroundColor: AppColors.darkPrimary,
      ),
    );
  }

  String _generateCsv(List<Map<String, dynamic>> events) {
    final buffer = StringBuffer();
    buffer.writeln('IPO Name,Company Name,Date,Contribution,Profit Share,Amount Received,Pool Status');
    for (final ev in events) {
      final date = ev['date'] as DateTime;
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      buffer.writeln('"${ev['poolName']}","${ev['companyName']}",$dateStr,${ev['contribution']},${ev['profitShare']},${ev['amountReceived']},"${ev['status']}"');
    }
    return buffer.toString();
  }

  String _generateMarkdownReport(List<Map<String, dynamic>> events, String currency) {
    final buffer = StringBuffer();
    buffer.writeln('# Contributor Ledger: ${widget.contributorName}');
    buffer.writeln('Generated on: ${DateTime.now().toLocal().toString().split('.').first}');
    buffer.writeln('\n| IPO Pool Name | Date | Contribution | Profit Share | Received Back | Status |');
    buffer.writeln('| --- | --- | --- | --- | --- | --- |');

    double totalC = 0;
    double totalP = 0;
    double totalR = 0;

    for (final ev in events) {
      final date = ev['date'] as DateTime;
      final dateStr = '${date.day}/${date.month}/${date.year}';
      final c = ev['contribution'] as double;
      final p = ev['profitShare'] as double;
      final r = ev['amountReceived'] as double;

      totalC += c;
      totalP += p;
      totalR += r;

      buffer.writeln('| ${ev['poolName']} | $dateStr | $currency${c.toStringAsFixed(0)} | $currency${p.toStringAsFixed(0)} | $currency${r.toStringAsFixed(0)} | ${ev['status']} |');
    }

    buffer.writeln('| **TOTALS** | | **$currency${totalC.toStringAsFixed(0)}** | **$currency${totalP.toStringAsFixed(0)}** | **$currency${totalR.toStringAsFixed(0)}** | |');
    buffer.writeln('\nPending Settlement: **$currency${(totalC + totalP - totalR).toStringAsFixed(0)}**');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    final allEvents = _compileEvents(dbState.ipoPools.where((p) => p.deletedAt == null).toList());

    // Initial UPI load
    final activeUpiMap = allEvents.firstWhereOrNull(
      (e) => (e['contributorRaw'] as IpoContributor).upiId.isNotEmpty,
    );
    final String activeUpi = activeUpiMap != null
        ? (activeUpiMap['contributorRaw'] as IpoContributor).upiId
        : '';
    if (_upiController.text.isEmpty && activeUpi.isNotEmpty) {
      _upiController.text = activeUpi;
    }

    // Unique pools for filter dropdown
    final List<String> poolNames = ['All', ...allEvents.map((e) => e['poolName'] as String).toSet().toList()];

    // Apply Filter Logic
    final filteredEvents = allEvents.where((e) {
      final evDate = e['date'] as DateTime;
      
      // Date range filter
      if (_selectedDateRange != null) {
        if (evDate.isBefore(_selectedDateRange!.start) || evDate.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      // Pool filter
      if (_selectedPool != 'All' && e['poolName'] != _selectedPool) {
        return false;
      }

      // Status filter
      if (_selectedStatus != 'All' && e['status'] != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();

    // Stats calculations
    double totalContributions = 0.0;
    double totalProfit = 0.0;
    double totalReceived = 0.0;
    final List<double> roiList = [];

    for (final ev in filteredEvents) {
      final c = ev['contribution'] as double;
      final p = ev['profitShare'] as double;
      final r = ev['amountReceived'] as double;

      totalContributions += c;
      totalProfit += p;
      totalReceived += r;
      if (c > 0) {
        roiList.add((p / c) * 100);
      }
    }

    final pendingSettlement = (totalContributions + totalProfit) - totalReceived;
    final overallRoi = totalContributions > 0 ? (totalProfit / totalContributions) * 100 : 0.0;
    final avgRoi = roiList.isNotEmpty ? roiList.reduce((a, b) => a + b) / roiList.length : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contributorName,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tab bar navigation
            TabBar(
              controller: _tabController,
              labelColor: AppColors.darkPrimary,
              unselectedLabelColor: AppColors.grey500,
              indicatorColor: AppColors.darkPrimary,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Trends'),
                Tab(text: 'History'),
                Tab(text: 'Export'),
              ],
            ),

            // Filters Drawer/Row
            _buildFiltersRow(context, poolNames),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(currency, totalContributions, totalProfit, totalReceived, pendingSettlement, overallRoi, avgRoi, filteredEvents.length),
                  _buildTrendsTab(filteredEvents, currency),
                  _buildHistoryTab(filteredEvents, currency),
                  _buildExportTab(filteredEvents, currency),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context, List<String> poolNames) {
    final dateStr = _selectedDateRange == null
        ? 'Select Date Range'
        : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Date Range Chip
          ActionChip(
            label: Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 11)),
            backgroundColor: _selectedDateRange == null ? Colors.white.withOpacity(0.04) : AppColors.darkPrimary.withOpacity(0.12),
            side: const BorderSide(color: AppColors.glassBorder),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: _selectedDateRange,
              );
              if (picked != null) {
                setState(() => _selectedDateRange = picked);
              }
            },
          ),
          const SizedBox(width: 8),

          // Pool Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            height: 32,
            child: DropdownButton<String>(
              value: _selectedPool,
              dropdownColor: AppColors.layer2,
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white, fontSize: 11),
              items: poolNames.map((n) => DropdownMenuItem(value: n, child: Text('Pool: $n'))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPool = val);
              },
            ),
          ),
          const SizedBox(width: 8),

          // Status Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            height: 32,
            child: DropdownButton<String>(
              value: _selectedStatus,
              dropdownColor: AppColors.layer2,
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white, fontSize: 11),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('Status: All')),
                DropdownMenuItem(value: 'Open', child: Text('Status: Open')),
                DropdownMenuItem(value: 'Listed', child: Text('Status: Listed')),
                DropdownMenuItem(value: 'Closed', child: Text('Status: Closed')),
                DropdownMenuItem(value: 'Archived', child: Text('Status: Archived')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedStatus = val);
              },
            ),
          ),
          
          if (_selectedDateRange != null || _selectedPool != 'All' || _selectedStatus != 'All') ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedDateRange = null;
                  _selectedPool = 'All';
                  _selectedStatus = 'All';
                });
              },
              child: const Text('Reset', style: TextStyle(color: AppColors.darkDanger, fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }

  // --- 1. OVERVIEW TAB ---
  Widget _buildOverviewTab(
    String currency,
    double totalContrib,
    double totalProfit,
    double totalReceived,
    double pendingSettlement,
    double overallRoi,
    double avgRoi,
    int count,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16.0),
      children: [
        // Profile Info Details
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Payment details',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _upiController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'UPI ID (For payouts)',
                  hintText: 'e.g. name@upi',
                  labelStyle: const TextStyle(color: AppColors.grey500),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save_outlined, color: AppColors.darkPrimary),
                    onPressed: () {
                      _updateUpiId(_upiController.text.trim());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Grid metrics
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildMetricTile('Contributions', '$currency${totalContrib.toStringAsFixed(0)}', AppColors.darkPrimary),
            _buildMetricTile('Profit Earned', '$currency${totalProfit.toStringAsFixed(0)}', AppColors.darkSuccess),
            _buildMetricTile('Settlements Paid', '$currency${totalReceived.toStringAsFixed(0)}', const Color(0xFF00F2FE)),
            _buildMetricTile('Participation Count', '$count IPOs', const Color(0xFF8E2DE2)),
          ],
        ),
        const SizedBox(height: 16),

        // Balance Due Sheet Card
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Average Return ROI:', style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13)),
                  Text('${avgRoi.toStringAsFixed(1)}%', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overall Pool ROI:', style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13)),
                  Text('${overallRoi.toStringAsFixed(1)}%', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              const Divider(color: AppColors.glassBorder, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PENDING SETTLEMENT DUE:', style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(
                    '$currency${pendingSettlement.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: pendingSettlement > 0 ? AppColors.darkDanger : AppColors.darkSuccess,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 2. TRENDS TAB ---
  Widget _buildTrendsTab(List<Map<String, dynamic>> events, String currency) {
    if (events.length < 2) {
      return const EmptyStateWidget(
        icon: Icons.show_chart,
        title: 'No Trend Available',
        description: 'Participate in at least 2 IPOs to render growth trends.',
      );
    }

    final double maxContribution = events.map((e) => e['contribution'] as double).reduce(max);
    final double maxProfit = events.map((e) => e['profitShare'] as double).reduce(max);
    final double maxRoi = events.map((e) {
      final double c = e['contribution'] as double;
      return c > 0 ? ((e['profitShare'] as double) / c) * 100 : 0.0;
    }).reduce(max);

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'CONTRIBUTION TREND',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                minY: 0,
                maxY: maxContribution == 0 ? 100 : maxContribution * 1.15,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(events.length, (idx) {
                      return FlSpot(idx.toDouble(), events[idx]['contribution'] as double);
                    }),
                    isCurved: true,
                    color: AppColors.darkPrimary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'PROFIT SHARE TREND',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                minY: 0,
                maxY: maxProfit == 0 ? 100 : maxProfit * 1.15,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(events.length, (idx) {
                      return FlSpot(idx.toDouble(), events[idx]['profitShare'] as double);
                    }),
                    isCurved: true,
                    color: AppColors.darkSuccess,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'ROI TREND (%)',
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                minY: 0,
                maxY: maxRoi == 0 ? 100 : maxRoi * 1.15,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(events.length, (idx) {
                      final c = events[idx]['contribution'] as double;
                      final r = c > 0 ? ((events[idx]['profitShare'] as double) / c) * 100 : 0.0;
                      return FlSpot(idx.toDouble(), r);
                    }),
                    isCurved: true,
                    color: const Color(0xFF00F2FE),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 3. HISTORY TAB ---
  Widget _buildHistoryTab(List<Map<String, dynamic>> events, String currency) {
    if (events.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.history,
        title: 'No Transaction History',
        description: 'No transactions found matching active filters.',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, idx) {
        final ev = events[idx];
        final date = ev['date'] as DateTime;
        final dateStr = '${date.day}/${date.month}/${date.year}';
        final c = ev['contribution'] as double;
        final p = ev['profitShare'] as double;
        final r = ev['amountReceived'] as double;
        final poolRoi = c > 0 ? (p / c) * 100 : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ev['poolName'] as String,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
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
                if ((ev['companyName'] as String).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(ev['companyName'] as String, style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHistoryColumn('Contribution', '$currency${c.toStringAsFixed(0)}'),
                    _buildHistoryColumn('Profit Share', '$currency${p.toStringAsFixed(0)}'),
                    _buildHistoryColumn('Received Back', '$currency${r.toStringAsFixed(0)}'),
                    _buildHistoryColumn('Pool ROI', '${poolRoi.toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 9)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  // --- 4. EXPORT TAB ---
  Widget _buildExportTab(List<Map<String, dynamic>> events, String currency) {
    final csv = _generateCsv(events);
    final md = _generateMarkdownReport(events, currency);

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      children: [
        _buildExportBox('Copy Markdown Report', md, 'Markdown'),
        const SizedBox(height: 16),
        _buildExportBox('Copy CSV Data', csv, 'CSV'),
      ],
    );
  }

  Widget _buildExportBox(String title, String content, String label) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied $label to Clipboard!'), backgroundColor: AppColors.darkPrimary),
                  );
                },
                icon: const Icon(Icons.copy, size: 12, color: Colors.white),
                label: const Text('Copy', style: TextStyle(color: Colors.white, fontSize: 11)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.grey700, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 120,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Text(
                content,
                style: GoogleFonts.shareTechMono(fontSize: 10, color: const Color(0xFF00FFCC)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
