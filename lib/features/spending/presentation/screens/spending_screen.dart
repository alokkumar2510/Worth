import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../providers/spending_providers.dart';

class SpendingScreen extends ConsumerStatefulWidget {
  const SpendingScreen({super.key});

  @override
  ConsumerState<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends ConsumerState<SpendingScreen> {
  int _activeChartTab = 0; // 0: Category Ratios, 1: Monthly Trends

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant_rounded;
      case 'Travel': return Icons.flight_takeoff_rounded;
      case 'Shopping': return Icons.shopping_bag_outlined;
      case 'Education': return Icons.school_outlined;
      case 'Bills': return Icons.receipt_long_outlined;
      case 'Subscriptions': return Icons.subscriptions_outlined;
      case 'Health': return Icons.favorite_border_rounded;
      case 'Entertainment': return Icons.movie_filter_outlined;
      case 'Fees': return Icons.account_balance_outlined;
      default: return Icons.widgets_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return const Color(0xFFF59E0B); // Amber
      case 'Travel': return const Color(0xFF3B82F6); // Blue
      case 'Shopping': return const Color(0xFFEC4899); // Pink
      case 'Education': return const Color(0xFF8B5CF6); // Purple
      case 'Bills': return const Color(0xFF10B981); // Emerald
      case 'Subscriptions': return const Color(0xFF6366F1); // Indigo
      case 'Health': return const Color(0xFFEF4444); // Red
      case 'Entertainment': return const Color(0xFF06B6D4); // Cyan
      case 'Fees': return const Color(0xFF84CC16); // Lime
      default: return const Color(0xFF64748B); // Slate
    }
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(spendingAnalyticsProvider);
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background soft violet glowing orb
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkPrimary.withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glow.withOpacity(0.04),
                    blurRadius: 120,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium Glass Navigation Header
                SliverAppBar(
                  expandedHeight: 100.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.darkBackground.withOpacity(0.8),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 56, bottom: 12),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spending Intelligence',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track permanent wealth outflows.',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Core Scrollable Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // SECTION 1: KPI OVERVIEW CARD
                      _buildKPIOverview(analytics, format, currency),
                      const SizedBox(height: 20),

                      // SECTION 2: CHARTS CARD (Category Ratios / Trends)
                      _buildChartsCard(analytics, currency),
                      const SizedBox(height: 20),

                      // SECTION 3: SPENDING HEATMAP (LAST 90 DAYS)
                      _buildHeatmapCard(analytics),
                      const SizedBox(height: 20),

                      // SECTION 4: CATEGORY BREAKDOWN LIST
                      _buildCategoryAnalysisCard(analytics, format),
                      const SizedBox(height: 20),

                      // SECTION 5: SNAPSHOT INSIGHTS
                      _buildInsightsCard(analytics),
                      const SizedBox(height: 20),

                      // SECTION 6: CHRONOLOGICAL TIMELINE FEED
                      _buildTimelineCard(analytics, format, currency),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Component Builders ---

  Widget _buildKPIOverview(SpendingAnalyticsData data, NumberFormat format, String currency) {
    final isNegativeChange = data.momChange < 0;
    final changeColor = isNegativeChange ? AppColors.darkSuccess : AppColors.darkDanger; // Less spend is success!
    final changeIcon = isNegativeChange ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final changePrefix = data.momChange >= 0 ? '+' : '';

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL OUTFLOWS THIS MONTH',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey500,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(changeIcon, size: 12, color: changeColor),
                    const SizedBox(width: 4),
                    Text(
                      '$changePrefix${data.momChangePercent.abs().toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            format.format(data.thisMonthTotal),
            style: GoogleFonts.outfit(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY AVERAGE',
                      style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      format.format(data.dailyAverage),
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.glassBorder),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREVIOUS MONTH',
                      style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      format.format(data.lastMonthTotal),
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsCard(SpendingAnalyticsData data, String currency) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPENDING ANALYTICS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey500,
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  _buildTabPill('Ratios', 0),
                  _buildTabPill('Trends', 1),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: _activeChartTab == 0
                ? _buildDonutChart(data, currency)
                : _buildBarTrendChart(data, currency),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    final isActive = _activeChartTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeChartTab = index),
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  Widget _buildDonutChart(SpendingAnalyticsData data, String currency) {
    if (data.thisMonthTotal == 0.0) {
      return Center(
        child: Text(
          'No spending transactions to visualize.',
          style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 13),
        ),
      );
    }

    final activeEntries = data.categoryBreakdown.entries
        .where((e) => e.value > 0.0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 46,
              sections: activeEntries.map((e) {
                final double value = e.value;
                final double percent = data.thisMonthTotal > 0.0 ? (value / data.thisMonthTotal) * 100 : 0.0;
                return PieChartSectionData(
                  color: _getCategoryColor(e.key),
                  value: value,
                  title: '${percent.toStringAsFixed(0)}%',
                  radius: 26,
                  showTitle: percent >= 8,
                  titleStyle: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: activeEntries.take(5).map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(e.key),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.key,
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$currency${e.value.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarTrendChart(SpendingAnalyticsData data, String currency) {
    if (data.monthlyTrend.isEmpty) return const SizedBox.shrink();

    final maxVal = data.monthlyTrend.map((e) => e.amount).fold(100.0, (m, e) => e > m ? e : m) * 1.15;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx >= 0 && idx < data.monthlyTrend.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data.monthlyTrend[idx].label,
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.monthlyTrend.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: item.amount,
                color: AppColors.darkPrimary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxVal,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeatmapCard(SpendingAnalyticsData data) {
    final entries = data.heatmapData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (entries.isEmpty) return const SizedBox.shrink();

    // Group items into columns of 7 elements (representing weeks)
    final List<List<MapEntry<DateTime, double>>> weeks = [];
    List<MapEntry<DateTime, double>> currentWeek = [];

    for (final entry in entries) {
      currentWeek.add(entry);
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    final double maxVal = entries.map((e) => e.value).fold(1.0, (m, e) => e > m ? e : m);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SPENDING HEATMAP (LAST 90 DAYS)',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: weeks.map((week) {
                return Column(
                  children: week.map((day) {
                    final amt = day.value;
                    Color color = Colors.white.withOpacity(0.04);
                    if (amt > 0) {
                      final intensity = (amt / maxVal).clamp(0.2, 1.0);
                      color = AppColors.darkPrimary.withOpacity(intensity);
                    }

                    return GestureDetector(
                      onTap: () {
                        final dateStr = DateFormat('EEEE, d MMM').format(day.key);
                        final amountStr = amt > 0 ? '\$${amt.toStringAsFixed(0)}' : 'No spend';
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$dateStr: $amountStr'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.layer2,
                          ),
                        );
                      },
                      child: Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: amt > 0 ? Colors.white.withOpacity(0.1) : Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500)),
              const SizedBox(width: 4),
              _buildLegendBox(Colors.white.withOpacity(0.04)),
              _buildLegendBox(AppColors.darkPrimary.withOpacity(0.25)),
              _buildLegendBox(AppColors.darkPrimary.withOpacity(0.5)),
              _buildLegendBox(AppColors.darkPrimary.withOpacity(0.75)),
              _buildLegendBox(AppColors.darkPrimary.withOpacity(1.0)),
              const SizedBox(width: 4),
              Text('More', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color c) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _buildCategoryAnalysisCard(SpendingAnalyticsData data, NumberFormat format) {
    final activeEntries = data.categoryBreakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'CATEGORY ANALYSIS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeEntries.length,
            itemBuilder: (context, index) {
              final item = activeEntries[index];
              final pct = data.categoryPercentages[item.key] ?? 0.0;
              final color = _getCategoryColor(item.key);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getCategoryIcon(item.key), color: color, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.key,
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${pct.toStringAsFixed(1)}% of total',
                                style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          format.format(item.value),
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress Indicator Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: Colors.white.withOpacity(0.04),
                        valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.85)),
                        minHeight: 5,
                      ),
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

  Widget _buildInsightsCard(SpendingAnalyticsData data) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: AppColors.darkPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'SPENDING INTELLIGENCE INSIGHTS',
                style: GoogleFonts.inter(
                  fontSize: 10,
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
                      width: 5,
                      height: 5,
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
                          fontSize: 12.5,
                          height: 1.4,
                          color: Colors.white.withOpacity(0.87),
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

  Widget _buildTimelineCard(SpendingAnalyticsData data, NumberFormat format, String currency) {
    if (data.recentExpenses.isEmpty) return const SizedBox.shrink();

    // Group expenses by day for local date timeline representation
    final Map<String, List<Transaction>> grouped = {};
    final now = DateTime.now();

    for (final tx in data.recentExpenses) {
      final localDate = tx.transactionDate.toLocal();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final txDay = DateTime(localDate.year, localDate.month, localDate.day);

      String groupKey;
      if (txDay == today) {
        groupKey = 'Today';
      } else if (txDay == yesterday) {
        groupKey = 'Yesterday';
      } else {
        groupKey = DateFormat('d MMMM yyyy').format(localDate);
      }
      grouped.putIfAbsent(groupKey, () => []).add(tx);
    }

    final groupKeys = grouped.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'SPENDING TIMELINE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: groupKeys.length,
          itemBuilder: (context, groupIdx) {
            final dayTitle = groupKeys[groupIdx];
            final list = grouped[dayTitle]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 6.0),
                  child: Text(
                    dayTitle.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                ...list.map((tx) {
                  final color = _getCategoryColor(tx.category ?? 'Miscellaneous');
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(_getCategoryIcon(tx.category ?? 'Miscellaneous'), color: color, size: 18),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.notes ?? tx.category ?? 'Miscellaneous',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('h:mm a').format(tx.transactionDate.toLocal()),
                                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '-$currency${NumberFormat.decimalPattern().format(tx.amount.toInt())}',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }
}
