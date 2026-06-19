import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tactile_button.dart';
import '../../../../core/providers/mock_database.dart';

class PortfolioHistoryArchiveScreen extends ConsumerStatefulWidget {
  const PortfolioHistoryArchiveScreen({super.key});

  @override
  ConsumerState<PortfolioHistoryArchiveScreen> createState() => _PortfolioHistoryArchiveScreenState();
}

class _PortfolioHistoryArchiveScreenState extends ConsumerState<PortfolioHistoryArchiveScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // Timeline Filters
  String _selectedEntityType = 'All';
  String _selectedAction = 'All';

  // Time Machine State
  DateTime _timeMachineDate = DateTime.now();
  MockDatabaseState? _reconstructedState;
  bool _isReconstructing = false;

  // Analytics State
  String _selectedMetric = 'Net Worth'; // 'Net Worth', 'Assets', 'Liabilities', 'Investments', 'Receivables'

  final List<String> _entityTypes = [
    'All',
    'Asset',
    'Liability',
    'Investment',
    'MTF Position',
    'Receivable',
    'Expected Income',
    'Goal',
    'Transaction',
    'SIP Event',
    'IPO Activity',
    'Settlement'
  ];

  final List<String> _actions = [
    'All',
    'Added',
    'Edited',
    'Deleted',
    'Voided',
    'Recovered',
    'Created',
    'Updated'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _runTimeMachineReconstruction() {
    setState(() {
      _isReconstructing = true;
    });
    
    // Defer execution slightly to allow UI spinner to show
    Future.delayed(const Duration(milliseconds: 300), () {
      final reconstructed = ref.read(mockDatabaseProvider).reconstructPortfolioOnDate(_timeMachineDate);
      setState(() {
        _reconstructedState = reconstructed;
        _isReconstructing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'History Archive',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkPrimary,
          labelColor: AppColors.darkPrimary,
          unselectedLabelColor: AppColors.grey500,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Time Machine'),
            Tab(text: 'Analytics'),
            Tab(text: 'Export'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineTab(dbState, currency),
          _buildTimeMachineTab(dbState, currency),
          _buildAnalyticsTab(dbState, currency),
          _buildExportTab(dbState),
        ],
      ),
    );
  }

  // ==========================================
  // TIMELINE TAB
  // ==========================================
  Widget _buildTimelineTab(MockDatabaseState dbState, String currency) {
    // Filter history
    final filteredHistory = dbState.portfolioHistory.where((log) {
      final matchesSearch = _searchController.text.isEmpty ||
          log.entityTitle.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          log.valueChanged.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          log.action.toLowerCase().contains(_searchController.text.toLowerCase());
      
      final matchesEntity = _selectedEntityType == 'All' || 
          log.entityType.toLowerCase() == _selectedEntityType.toLowerCase();
      
      final matchesAction = _selectedAction == 'All' ||
          log.action.toLowerCase() == _selectedAction.toLowerCase() ||
          (_selectedAction == 'Added' && log.action.toLowerCase() == 'created') ||
          (_selectedAction == 'Edited' && log.action.toLowerCase() == 'updated');

      return matchesSearch && matchesEntity && matchesAction;
    }).toList();

    return Column(
      children: [
        // Search & Filters Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search history logs...',
                  hintStyle: const TextStyle(color: AppColors.grey500),
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey500),
                  filled: true,
                  fillColor: AppColors.layer1,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.layer1,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedEntityType,
                          dropdownColor: AppColors.layer2,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: _entityTypes.map((type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedEntityType = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.layer1,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAction,
                          dropdownColor: AppColors.layer2,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: _actions.map((act) {
                            return DropdownMenuItem<String>(
                              value: act,
                              child: Text(act),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedAction = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Timeline list
        Expanded(
          child: filteredHistory.isEmpty
              ? Center(
                  child: Text(
                    'No portfolio activity found.',
                    style: TextStyle(color: AppColors.grey500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredHistory.length,
                  itemBuilder: (context, index) {
                    final log = filteredHistory[index];
                    final dateStr = DateFormat('dd MMM yyyy').format(log.createdAt.toLocal());
                    final timeStr = DateFormat('hh:mm a').format(log.createdAt.toLocal());

                    // Action color coding
                    Color actionColor;
                    if (log.action.toLowerCase().contains('add') || log.action.toLowerCase().contains('create')) {
                      actionColor = AppColors.darkSuccess;
                    } else if (log.action.toLowerCase().contains('edit') || log.action.toLowerCase().contains('update')) {
                      actionColor = AppColors.darkWarning;
                    } else {
                      actionColor = AppColors.darkDanger;
                    }

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left side: Timeline circles & lines
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: actionColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: actionColor.withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  width: 2,
                                  color: index == filteredHistory.length - 1
                                      ? Colors.transparent
                                      : AppColors.grey700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Right side: Content card
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GlassCard(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          log.entityType.toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.grey500,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        Text(
                                          '$dateStr $timeStr',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.grey500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${log.action} ${log.entityTitle}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      log.valueChanged,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: actionColor.withOpacity(0.95),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (log.previousValue != null || log.newValue != null) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (log.previousValue != null)
                                            Expanded(
                                              child: Text(
                                                'Prev: ${log.previousValue}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.grey400,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          if (log.newValue != null)
                                            Expanded(
                                              child: Text(
                                                'New: ${log.newValue}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white70,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // TIME MACHINE TAB
  // ==========================================
  Widget _buildTimeMachineTab(MockDatabaseState dbState, String currency) {
    final hasReconstructed = _reconstructedState != null;
    final recon = _reconstructedState;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Machine Ledger Reconstitution',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reconstruct your assets, liabilities, net worth, and investments balance sheet precisely as of any past date.',
            style: TextStyle(color: AppColors.grey500, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Date Selector card
          GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TARGET DATE',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy').format(_timeMachineDate),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                TactileButton(
                  width: 100,
                  height: 40,
                  color: AppColors.layer1,
                  borderRadius: 12,
                  border: const BorderSide(color: AppColors.glassBorder),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: _timeMachineDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.darkPrimary,
                              onPrimary: Colors.white,
                              surface: AppColors.layer1,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (selected != null) {
                      setState(() {
                        _timeMachineDate = selected;
                        _reconstructedState = null; // reset until run button pressed
                      });
                    }
                  },
                  child: Text(
                    'Pick Date',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action Button
          TactileButton(
            gradient: const LinearGradient(
              colors: [AppColors.darkPrimary, AppColors.glow],
            ),
            borderRadius: 16,
            onTap: _isReconstructing ? null : _runTimeMachineReconstruction,
            child: _isReconstructing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Rebuild Balance Sheet',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          // Reconstructed Results
          if (_isReconstructing)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.darkPrimary),
                    SizedBox(height: 16),
                    Text('Replaying ledgers & matching tax lots...', style: TextStyle(color: AppColors.grey500)),
                  ],
                ),
              ),
            )
          else if (hasReconstructed && recon != null) ...[
            // Net Worth Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkPrimary.withOpacity(0.15),
                    AppColors.glow.withOpacity(0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'RECONSTRUCTED NET WORTH',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currency${NumberFormat('#,##,###.##').format(recon.netWorth)}',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('Assets', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              '$currency${NumberFormat('#,##,###.##').format(recon.totalAssets)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 24, color: AppColors.grey700),
                      Expanded(
                        child: Column(
                          children: [
                            Text('Liabilities', style: TextStyle(color: AppColors.grey500, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              '$currency${NumberFormat('#,##,###.##').format(recon.totalLiabilities)}',
                              style: const TextStyle(color: AppColors.darkDanger, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Detailed breakdowns
            Text(
              'RECONSTRUCTED ACCOUNT BALANCES',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.grey400,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            recon.accounts.isEmpty
                ? const Text('No accounts registered on or before this date.', style: TextStyle(color: AppColors.grey500))
                : Column(
                    children: recon.accounts.map((acc) {
                      final balance = acc.type == 'credit' 
                          ? recon.getAccountLiabilityBalance(acc.id)
                          : recon.getAccountCashBalance(acc.id);
                      final isLiab = acc.type == 'credit';
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.layer1,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              acc.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '$currency${NumberFormat('#,##,###.##').format(balance)}',
                              style: TextStyle(
                                color: isLiab ? AppColors.darkDanger : AppColors.darkSuccess,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),

            Text(
              'RECONSTRUCTED INVESTMENT HOLDINGS',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.grey400,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            recon.investments.isEmpty
                ? const Text('No investment holdings active on or before this date.', style: TextStyle(color: AppColors.grey500))
                : Column(
                    children: recon.investments.map((inv) {
                      final units = recon.getInvestmentUnitsHeld(inv.id);
                      final capital = recon.getInvestmentInvestedCapital(inv.id);
                      if (units == 0 && capital == 0) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.layer1,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inv.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${NumberFormat('#,##,###.####').format(units)} units',
                                  style: TextStyle(color: AppColors.grey500, fontSize: 11),
                                ),
                              ],
                            ),
                            Text(
                              '$currency${NumberFormat('#,##,###.##').format(capital)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Select a historical target date above and tap "Rebuild Balance Sheet" to load reconstruction values.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey500, fontSize: 13, height: 1.5),
                ),
              ),
            )
        ],
      ),
    );
  }

  // ==========================================
  // ANALYTICS TAB
  // ==========================================
  Widget _buildAnalyticsTab(MockDatabaseState dbState, String currency) {
    final snaps = dbState.portfolioSnapshots.reversed.toList();

    if (snaps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, size: 64, color: AppColors.grey700),
              const SizedBox(height: 16),
              Text(
                'Insufficient Snapshots Recorded',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Snapshots will accumulate daily, weekly, and monthly as you record transaction ledger events.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey500, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Prepare line points based on selected metric
    final List<FlSpot> spots = [];
    for (int i = 0; i < snaps.length; i++) {
      final snap = snaps[i];
      double val = 0.0;
      switch (_selectedMetric) {
        case 'Net Worth':
          val = snap.netWorth;
          break;
        case 'Assets':
          val = snap.assets;
          break;
        case 'Liabilities':
          val = snap.liabilities;
          break;
        case 'Investments':
          val = snap.investments;
          break;
        case 'Receivables':
          val = snap.receivables;
          break;
      }
      spots.add(FlSpot(i.toDouble(), val));
    }

    // Determine min/max values to scale chart nicely
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    
    // Safety buffer
    if (minY == maxY) {
      minY = minY - (minY == 0 ? 1000 : minY * 0.1);
      maxY = maxY + (maxY == 0 ? 1000 : maxY * 0.1);
    } else {
      final diff = maxY - minY;
      minY = (minY - diff * 0.15).clamp(0.0, double.infinity);
      maxY = maxY + diff * 0.15;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historical Portfolio Performance',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // Metric Selector Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.layer1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMetric,
                    dropdownColor: AppColors.layer2,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    items: ['Net Worth', 'Assets', 'Liabilities', 'Investments', 'Receivables'].map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedMetric = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Display
          Container(
            height: 260,
            padding: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.layer1,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.grey700.withOpacity(0.4),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (spots.length / 5).clamp(1.0, double.infinity),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < snaps.length) {
                          final date = snaps[idx].snapshotDate;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              DateFormat('dd MMM').format(date),
                              style: TextStyle(color: AppColors.grey500, fontSize: 9),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55,
                      getTitlesWidget: (value, meta) {
                        String formatted;
                        if (value >= 10000000) {
                          formatted = '${(value / 10000000).toStringAsFixed(1)}Cr';
                        } else if (value >= 100000) {
                          formatted = '${(value / 100000).toStringAsFixed(1)}L';
                        } else if (value >= 1000) {
                          formatted = '${(value / 1000).toStringAsFixed(0)}K';
                        } else {
                          formatted = value.toStringAsFixed(0);
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '$currency$formatted',
                            style: TextStyle(color: AppColors.grey500, fontSize: 8),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.darkPrimary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length <= 15,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.glow,
                        strokeWidth: 1.5,
                        strokeColor: AppColors.layer1,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.darkPrimary.withOpacity(0.2),
                          AppColors.darkPrimary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Growth stats cards
          Text(
            'SNAPSHOT METRIC SNAPSHOTS',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dbState.portfolioSnapshots.length,
            itemBuilder: (context, index) {
              final snap = dbState.portfolioSnapshots[index];
              final dateStr = DateFormat('dd MMM yyyy').format(snap.snapshotDate);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.layer1,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        Text(
                          '${snap.snapshotType.toUpperCase()} SNAPSHOT',
                          style: TextStyle(color: AppColors.grey500, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$currency${NumberFormat('#,##,###.##').format(snap.netWorth)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          'Assets: $currency${NumberFormat('#,##,###.##').format(snap.assets)} | Liab: $currency${NumberFormat('#,##,###.##').format(snap.liabilities)}',
                          style: TextStyle(color: AppColors.grey400, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EXPORT TAB
  // ==========================================
  Widget _buildExportTab(MockDatabaseState dbState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Financial Data',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate and download your complete immutable financial log. All files will be exported directly to your local application directory.',
            style: TextStyle(color: AppColors.grey500, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Export PDF Card
          _buildExportOptionCard(
            title: 'Export Portfolio Statement (PDF)',
            description: 'A formal printed summary statement showing your balance sheet, recent activities timeline, and historical net worth snapshot logs.',
            icon: Icons.picture_as_pdf_outlined,
            iconColor: Colors.redAccent,
            onTap: () => _exportToPdf(dbState),
          ),
          const SizedBox(height: 16),

          // Export CSV Card
          _buildExportOptionCard(
            title: 'Export Activity Logs (CSV)',
            description: 'Standard comma-separated value database dump of all actions, value changed metrics, and timeline items.',
            icon: Icons.grid_on_outlined,
            iconColor: Colors.greenAccent,
            onTap: () => _exportToCsv(dbState),
          ),
          const SizedBox(height: 16),

          // Export Excel Workbook Card
          _buildExportOptionCard(
            title: 'Export Full Workbook (Excel)',
            description: 'Multi-sheet spreadsheet format compiling the timeline log sheet and snapshot logs sheet natively for Microsoft Excel.',
            icon: Icons.table_chart_outlined,
            iconColor: Colors.blueAccent,
            onTap: () => _exportToExcel(dbState),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.grey400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EXPORT UTILS
  // ==========================================
  void _showFileExportSuccessSnackBar(String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'File exported successfully: $path',
          style: const TextStyle(fontSize: 12),
        ),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: AppColors.darkPrimary,
          onPressed: () {},
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _exportToCsv(MockDatabaseState dbState) async {
    final sb = StringBuffer();
    // Headers
    sb.writeln('Date,Time,Action,Entity,Value Changed,Previous Value,New Value,Entity ID,Entity Type');
    
    // Data rows
    for (final log in dbState.portfolioHistory) {
      final date = DateFormat('yyyy-MM-dd').format(log.createdAt.toLocal());
      final time = DateFormat('HH:mm:ss').format(log.createdAt.toLocal());
      
      final row = [
        date,
        time,
        log.action,
        log.entityTitle,
        log.valueChanged,
        log.previousValue ?? '',
        log.newValue ?? '',
        log.entityId,
        log.entityType,
      ].map((val) {
        String str = val.toString();
        if (str.contains(',') || str.contains('"') || str.contains('\n')) {
          str = '"${str.replaceAll('"', '""')}"';
        }
        return str;
      }).join(',');
      sb.writeln(row);
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/worth_portfolio_history_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(sb.toString());
      _showFileExportSuccessSnackBar(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export CSV: $e')),
      );
    }
  }

  Future<void> _exportToExcel(MockDatabaseState dbState) async {
    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0"?>');
    sb.writeln('<?mso-application progid="Excel.Sheet"?>');
    sb.writeln('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
    sb.writeln(' xmlns:o="urn:schemas-microsoft-com:office:office"');
    sb.writeln(' xmlns:x="urn:schemas-microsoft-com:office:excel"');
    sb.writeln(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
    sb.writeln(' xmlns:html="http://www.w3.org/TR/REC-html40">');

    // Tab 1: Timeline
    sb.writeln(' <Worksheet ss:Name="Activity Timeline">');
    sb.writeln('  <Table>');
    
    // Header Row
    sb.writeln('   <Row>');
    for (final col in ['Date', 'Time', 'Action', 'Entity Name', 'Value Changed', 'Previous Value', 'New Value', 'Entity Type']) {
      sb.writeln('    <Cell><Data ss:Type="String">$col</Data></Cell>');
    }
    sb.writeln('   </Row>');

    // Values
    for (final log in dbState.portfolioHistory) {
      final date = DateFormat('yyyy-MM-dd').format(log.createdAt.toLocal());
      final time = DateFormat('HH:mm:ss').format(log.createdAt.toLocal());
      sb.writeln('   <Row>');
      sb.writeln('    <Cell><Data ss:Type="String">$date</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="String">$time</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="String">${_xmlEscape(log.action)}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="String">${_xmlEscape(log.entityTitle)}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="String">${_xmlEscape(log.valueChanged)}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="String">${_xmlEscape(log.previousValue ?? '')}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="String">${_xmlEscape(log.newValue ?? '')}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="String">${_xmlEscape(log.entityType)}</Data></Cell>');
      sb.writeln('   </Row>');
    }
    sb.writeln('  </Table>');
    sb.writeln(' </Worksheet>');

    // Tab 2: Snapshots
    sb.writeln(' <Worksheet ss:Name="Portfolio Snapshots">');
    sb.writeln('  <Table>');
    // Header Row
    sb.writeln('   <Row>');
    for (final col in ['Date', 'Snapshot Type', 'Net Worth', 'Assets', 'Liabilities', 'Investments', 'Receivables']) {
      sb.writeln('    <Cell><Data ss:Type="String">$col</Data></Cell>');
    }
    sb.writeln('   </Row>');

    for (final snap in dbState.portfolioSnapshots) {
      final date = DateFormat('yyyy-MM-dd').format(snap.snapshotDate);
      sb.writeln('   <Row>');
      sb.writeln('    <Cell><Data ss:Type="String">$date</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="String">${_xmlEscape(snap.snapshotType)}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="Number">${snap.netWorth}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="Number">${snap.assets}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="Number">${snap.liabilities}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="Number">${snap.investments}</Data></Cell>');
      sb.writeln('    <Cell><Data ss:Type="Number">${snap.receivables}</Data></Cell>');
      sb.writeln('   </Row>');
    }
    sb.writeln('  </Table>');
    sb.writeln(' </Worksheet>');

    sb.writeln('</Workbook>');

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/worth_ledger_workbook_${DateTime.now().millisecondsSinceEpoch}.xls');
      await file.writeAsString(sb.toString());
      _showFileExportSuccessSnackBar(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export Excel: $e')),
      );
    }
  }

  String _xmlEscape(String str) {
    return str
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  Future<void> _exportToPdf(MockDatabaseState dbState) async {
    final pdf = pw.Document();
    
    // Summary values
    final latestSnap = dbState.portfolioSnapshots.firstOrNull;
    final currency = dbState.currency;
    final netWorthStr = latestSnap != null ? '$currency${NumberFormat('#,##,###.##').format(latestSnap.netWorth)}' : 'N/A';
    final assetsStr = latestSnap != null ? '$currency${NumberFormat('#,##,###.##').format(latestSnap.assets)}' : 'N/A';
    final liabStr = latestSnap != null ? '$currency${NumberFormat('#,##,###.##').format(latestSnap.liabilities)}' : 'N/A';
    final invStr = latestSnap != null ? '$currency${NumberFormat('#,##,###.##').format(latestSnap.investments)}' : 'N/A';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Title Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'WORTH - PORTFOLIO LEDGER STATEMENT',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                      color: PdfColors.indigo900,
                    ),
                  ),
                  pw.Text(
                    DateFormat('dd MMM yyyy').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Portfolio Balance Summary
            pw.Text(
              'LEDGER BALANCE SUMMARY',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Net Worth', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Total Assets', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Total Liabilities', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Investments', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(netWorthStr, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(assetsStr, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(liabStr, style: const pw.TextStyle(fontSize: 10)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(invStr, style: const pw.TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 24),

            // History Log Table Header
            pw.Text(
              'RECENT TIMELINE ACTIVITY LOG',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 8),

            // Activity Log Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2), // Date
                1: const pw.FlexColumnWidth(1.2), // Action
                2: const pw.FlexColumnWidth(1.5), // Entity Name
                3: const pw.FlexColumnWidth(2.5), // Value Changed
              },
              children: [
                // Table header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Action', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Entity', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Change Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    ),
                  ],
                ),
                // Log Rows (limit to first 50 rows to fit/prevent rendering hangs)
                ...dbState.portfolioHistory.take(50).map((log) {
                  final dateStr = DateFormat('dd MMM yyyy hh:mm a').format(log.createdAt.toLocal());
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(dateStr, style: const pw.TextStyle(fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(log.action, style: const pw.TextStyle(fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(log.entityTitle, style: const pw.TextStyle(fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(log.valueChanged, style: const pw.TextStyle(fontSize: 7)),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ];
        },
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/worth_portfolio_statement_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());
      _showFileExportSuccessSnackBar(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e')),
      );
    }
  }
}
