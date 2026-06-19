import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'dart:io';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/premium_chart.dart';
import '../../core/providers/dependency_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../core/providers/mock_database.dart';
import 'presentation/providers/wealth_intelligence_provider.dart';
import 'presentation/widgets/export_success_sheet.dart';
import 'presentation/widgets/export_failure_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _activeAllocationTab = 0; // 0: Assets, 1: Liabilities, 2: Investments
  bool _showGrowthChart = false;
  bool _isExporting = false;

  Future<void> _exportPdfReport(MockDatabaseState dbState, {bool forcePrivateDirectory = false}) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdfService = ref.read(pdfExportServiceProvider);
      final pdfBytes = await pdfService.generateReportBytes(dbState);
      final savedPath = await pdfService.savePdfToDownloads(pdfBytes, forcePrivateDirectory: forcePrivateDirectory);
      final fileName = savedPath.split(Platform.pathSeparator).last;
      
      final file = File(savedPath);
      final fileSize = await file.length();

      setState(() {
        _isExporting = false;
      });

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => ExportSuccessSheet(
          filePath: savedPath,
          fileName: fileName,
          pdfBytes: pdfBytes,
          fileSizeInBytes: fileSize,
        ),
      );
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => ExportFailureSheet(
          errorMessage: e.toString(),
          onRetry: () => _exportPdfReport(dbState, forcePrivateDirectory: false),
          onSavePrivate: () => _exportPdfReport(dbState, forcePrivateDirectory: true),
        ),
      );
    }
  }

  Widget _buildPdfExportCard(BuildContext context, MockDatabaseState dbState) {
    final goldAccent = const Color(0xFFD4AF37);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F112A),
            Color(0xFF1B1D38),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: goldAccent.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: goldAccent.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _exportPdfReport(dbState),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: goldAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: goldAccent.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf_outlined,
                        color: goldAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worth Private Wealth Report',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'EXECUTIVE INTEL DOSSIER',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: goldAccent,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Compile a comprehensive multi-page private PDF document detailing your net worth performance, asset allocation distributions, debt metrics, and systematic insights.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.grey400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [goldAccent, const Color(0xFFB8860B)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.insights_outlined,
                          color: Colors.black,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Compile Private Report',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Lazy snapshots creation on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(mockModeProvider)) {
        ref.read(realReportServiceProvider).generateMissingSnapshots();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(wealthIntelligenceProvider);
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    if (!data.hasData || (data.trendSpots.isEmpty && data.totalAssets == 0)) {
      return _buildEmptyState(context);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Elegant Header
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wealth Intelligence',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Understand how your financial position evolved.',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Core Content
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // SECTION 0: PREMIUM PDF DOSSIER EXPORT CARD
                    _buildPdfExportCard(context, dbState),
                    const SizedBox(height: 24),

                    // SECTION 1: NET WORTH PERFORMANCE CARD
                    _buildNetWorthPerformanceCard(data, format, currency),
                    const SizedBox(height: 24),

                    // SECTION 2: WEALTH BREAKDOWN & ALLOCATIONS
                    _buildWealthBreakdownCard(data, format, currency),
                    const SizedBox(height: 24),

                    // SECTION 3: THIS MONTH SUMMARY
                    _buildThisMonthSummary(data, format),
                    const SizedBox(height: 24),

                    // SECTION 5: BIGGEST CHANGES (Logical order before timeline)
                    _buildBiggestChanges(data, format),
                    const SizedBox(height: 24),

                    // SECTION 6: AUTOMATIC INSIGHTS
                    _buildInsightsCard(data),
                    const SizedBox(height: 24),

                    // SECTION 7: PORTFOLIO PERFORMANCE & METRICS
                    _buildPortfolioMetricsCard(data, format, currency),
                    const SizedBox(height: 24),

                    // SECTION 4: WEALTH TIMELINE FEED
                    _buildWealthTimeline(data, format),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
          if (_isExporting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.75),
                child: Center(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Assembling Intelligence...',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Compiling multi-page premium PDF dossier',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- UI Section Builders ---

  Widget _buildNetWorthPerformanceCard(WealthIntelligenceData data, NumberFormat format, String currency) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title & Sparkline Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NET WORTH PERFORMANCE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey500,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showGrowthChart = !_showGrowthChart),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _showGrowthChart ? 'Show Curve' : 'Show Growth',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Large Net Worth Text
          Text(
            format.format(data.currentNetWorth),
            style: GoogleFonts.outfit(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // 3-Column Changes (Monthly, Quarterly, Yearly)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildChangeColumn('Monthly Change', data.monthlyChange, data.monthlyChangePercent, format),
              _buildChangeColumn('Quarterly Change', data.quarterlyChange, data.quarterlyChangePercent, format),
              _buildChangeColumn('Yearly Change', data.yearlyChange, data.yearlyChangePercent, format),
            ],
          ),
          const SizedBox(height: 28),

          // Performance Charts
          AnimatedCrossFade(
            firstChild: SizedBox(
              height: 200,
              child: NetWorthLineChart(
                spots: data.trendSpots,
                dates: data.trendDates,
                currency: currency,
              ),
            ),
            secondChild: SizedBox(
              height: 200,
              child: GrowthBarChart(
                growthData: data.growthData,
                months: data.growthMonths,
                currency: currency,
              ),
            ),
            crossFadeState: _showGrowthChart ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeColumn(String title, double value, double percent, NumberFormat format) {
    final isPositive = value >= 0;
    final color = isPositive ? AppColors.darkSuccess : AppColors.darkDanger;
    final prefix = isPositive ? '+' : '';

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.grey500),
          ),
          const SizedBox(height: 4),
          Text(
            '$prefix${format.format(value)}',
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '$prefix${percent.toStringAsFixed(1)}%',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildWealthBreakdownCard(WealthIntelligenceData data, NumberFormat format, String currency) {
    Map<String, double> activeAllocation;
    if (_activeAllocationTab == 0) {
      activeAllocation = data.assetAllocation;
    } else if (_activeAllocationTab == 1) {
      activeAllocation = data.liabilityAllocation;
    } else {
      activeAllocation = data.investmentAllocation;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid of 5 Wealth Breakdown Pillars
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildPillarTile('Assets', data.totalAssets, format, const Color(0xFF22C55E), Icons.account_balance_wallet_outlined),
            _buildPillarTile('Liabilities', data.totalLiabilities, format, const Color(0xFFEF4444), Icons.trending_down_outlined),
            _buildPillarTile('Invested Capital', data.totalInvestedCapital, format, AppColors.darkPrimary, Icons.show_chart_outlined),
            _buildPillarTile('Receivables', data.totalReceivables, format, const Color(0xFF06B6D4), Icons.call_received_outlined),
          ],
        ),
        const SizedBox(height: 12),
        _buildPillarTile('Expected Income', data.totalExpectedIncome, format, const Color(0xFFF59E0B), Icons.hourglass_empty_outlined, isWide: true),
        const SizedBox(height: 24),

        // Allocation Card
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Text(
                    'ALLOCATION BREAKDOWN',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTabPill('Assets', 0),
                      _buildTabPill('Liabilities', 1),
                      _buildTabPill('Investments', 2),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Allocation Pie Chart
              AllocationPieChart(
                data: activeAllocation,
                currency: currency,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPillarTile(String label, double value, NumberFormat format, Color accentColor, IconData icon, {bool isWide = false}) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  format.format(value),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    final isActive = _activeAllocationTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeAllocationTab = index),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.darkPrimary.withOpacity(0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.grey500,
          ),
        ),
      ),
    );
  }

  Widget _buildThisMonthSummary(WealthIntelligenceData data, NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'THIS MONTH ACTIVITY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildActivityRingCard('New Assets', data.newAssetsAdded, format, const Color(0xFF22C55E), Icons.add_circle_outline),
              _buildActivityRingCard('Liabilities Reduced', data.liabilitiesReduced, format, const Color(0xFFEF4444), Icons.remove_circle_outline),
              _buildActivityRingCard('Receivables Recovered', data.receivablesRecovered, format, const Color(0xFF06B6D4), Icons.replay_circle_filled_outlined),
              _buildActivityRingCard('Investments Added', data.investmentsAdded, format, AppColors.darkPrimary, Icons.trending_up_outlined),
              _buildActivityRingCard('Expected Received', data.expectedIncomeReceived, format, const Color(0xFFF59E0B), Icons.check_circle_outline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityRingCard(String label, double val, NumberFormat format, Color color, IconData icon) {
    final maxValue = val > 100000 ? val : 100000.0;
    final pct = (val / maxValue).clamp(0.0, 1.0);

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 4.5,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Icon(icon, color: color, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.grey400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              format.format(val),
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWealthTimeline(WealthIntelligenceData data, NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'WEALTH TIMELINE',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.timeline.length,
          itemBuilder: (context, index) {
            final item = data.timeline[index];
            final isLast = index == data.timeline.length - 1;

            return IntrinsicHeight(
              child: Row(
                children: [
                  // Vertical timeline line and node
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isLast ? AppColors.darkPrimary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isLast ? Colors.white : AppColors.grey500,
                            width: 2,
                          ),
                          boxShadow: isLast
                              ? [
                                  BoxShadow(
                                    color: AppColors.darkPrimary.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isLast ? Colors.transparent : AppColors.glassBorder,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Timeline details card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.month,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                                color: isLast ? Colors.white : AppColors.grey400,
                              ),
                            ),
                            Text(
                              format.format(item.netWorth),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isLast ? AppColors.darkPrimary : Colors.white,
                              ),
                            ),
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
      ],
    );
  }

  Widget _buildBiggestChanges(WealthIntelligenceData data, NumberFormat format) {
    if (data.biggestChanges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'BIGGEST CHANGES THIS MONTH',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: data.biggestChanges.length,
            itemBuilder: (context, index) {
              final change = data.biggestChanges[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        change.label.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        change.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        format.format(change.amount),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsCard(WealthIntelligenceData data) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.darkPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'WEALTH INSIGHTS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey500,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.darkPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPortfolioMetricsCard(WealthIntelligenceData data, NumberFormat format, String currency) {
    final sipPerf = data.sipPerformance;
    final mtfSummary = data.mtfInterestSummary;
    final formatDec = NumberFormat.currency(symbol: currency, decimalDigits: 2);

    final double consistencyRate = (sipPerf['consistencyRate'] as num?)?.toDouble() ?? 100.0;
    final double investedCapital = (sipPerf['investedCapital'] as num?)?.toDouble() ?? 0.0;
    final double currentValuation = (sipPerf['currentValuation'] as num?)?.toDouble() ?? 0.0;
    final double growth = (sipPerf['growth'] as num?)?.toDouble() ?? 0.0;

    final double accruedInterest = (mtfSummary['accrued'] as num?)?.toDouble() ?? 0.0;
    final double paidInterest = (mtfSummary['paid'] as num?)?.toDouble() ?? 0.0;
    final double outstandingInterest = (mtfSummary['outstanding'] as num?)?.toDouble() ?? 0.0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline_outlined, color: AppColors.darkPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'PORTFOLIO PERFORMANCE & METRICS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey500,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sub-Section 1: Average Holding Period & Holding Durations
          Text(
            'HOLDING ANALYSIS',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Average Holding Period', style: TextStyle(color: AppColors.grey400, fontSize: 13)),
              Text(
                '${data.averageHoldingPeriod.toStringAsFixed(1)} Days',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.holdingDurations.isEmpty)
            const Text('No active investments found.', style: TextStyle(color: AppColors.grey500, fontSize: 12))
          else
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text('View Individual Holding Periods', style: TextStyle(color: AppColors.darkPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                children: data.holdingDurations.map((hd) {
                  final String hdName = hd['name']?.toString() ?? 'Unknown';
                  final int hdDays = (hd['days'] as num?)?.toInt() ?? 0;
                  final int ageDays = (hd['age'] as num?)?.toInt() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(hdName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text('Age: $ageDays Days', style: const TextStyle(color: AppColors.grey500, fontSize: 10)),
                            ],
                          ),
                        ),
                        Text('Held: $hdDays Days', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          const Divider(color: AppColors.glassBorder, height: 24),

          // Sub-Section 2: SIP Performance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SIP PERFORMANCE',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: consistencyRate >= 80.0
                      ? AppColors.darkSuccess.withOpacity(0.12)
                      : (consistencyRate >= 50.0
                          ? Colors.orange.withOpacity(0.12)
                          : AppColors.darkDanger.withOpacity(0.12)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Consistency: ${consistencyRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: consistencyRate >= 80.0
                        ? AppColors.darkSuccess
                        : (consistencyRate >= 50.0 ? Colors.orange : AppColors.darkDanger),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total SIP Capital Invested', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(format.format(investedCapital), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current SIP Valuation', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(format.format(currentValuation), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Growth (SIP Profits)', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(
                '${growth >= 0.0 ? '+' : ''}${format.format(growth)}',
                style: TextStyle(
                  color: growth >= 0.0 ? AppColors.darkSuccess : AppColors.darkDanger,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const Divider(color: AppColors.glassBorder, height: 24),

          // Sub-Section 3: MTF Interest Summary
          Text(
            'MTF INTEREST SUMMARY',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Interest Accrued', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(formatDec.format(accruedInterest), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Interest Paid', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(formatDec.format(paidInterest), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Outstanding Unpaid Interest', style: TextStyle(color: AppColors.grey400, fontSize: 12)),
              Text(
                formatDec.format(outstandingInterest),
                style: TextStyle(
                  color: outstandingInterest > 0.0 ? AppColors.darkWarning : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (data.mtfInterestHistory.isEmpty)
            const Text('No MTF interest accrual history found.', style: TextStyle(color: AppColors.grey500, fontSize: 12))
          else
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text('View Interest Accrual History', style: TextStyle(color: AppColors.darkPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                children: data.mtfInterestHistory.map((item) {
                  final String instrument = item['instrument'] as String;
                  final double amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
                  final DateTime date = item['date'] as DateTime;
                  final String notes = item['notes'] as String;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(instrument, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(notes, style: const TextStyle(color: AppColors.grey500, fontSize: 10)),
                              Text(DateFormat('dd MMM yyyy').format(date), style: const TextStyle(color: AppColors.grey500, fontSize: 9)),
                            ],
                          ),
                        ),
                        Text(formatDec.format(amount), style: const TextStyle(color: AppColors.darkDanger, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Wealth Intelligence',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium layered illustration showing depth
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glowing rings
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkPrimary.withOpacity(0.05), width: 1),
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.darkPrimary.withOpacity(0.1), width: 1.5),
                    ),
                  ),
                  // Layered glass card illustration
                  Transform.translate(
                    offset: const Offset(-15, -10),
                    child: Transform.rotate(
                      angle: -0.15,
                      child: Container(
                        width: 70,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(15, 10),
                    child: Transform.rotate(
                      angle: 0.15,
                      child: Container(
                        width: 70,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.darkPrimary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.15)),
                        ),
                      ),
                    ),
                  ),
                  // Central glass sphere
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkPrimary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.insights_rounded, size: 32, color: AppColors.darkPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                'No reports available yet.',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add more transactions to generate wealth insights.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.grey500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/monthly_snapshot'),
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                label: const Text('Capture First Snapshot', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                  shadowColor: AppColors.darkPrimary.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
