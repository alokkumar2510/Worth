import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class NetWorthLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> dates;
  final String currency;
  final Function(FlSpot?)? onSpotHover;
  final bool isPlaceholder;

  const NetWorthLineChart({
    required this.spots,
    required this.dates,
    required this.currency,
    this.onSpotHover,
    this.isPlaceholder = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isActualPlaceholder = isPlaceholder || spots.length < 2;
    
    // Fallback/Simulated Data for placeholder
    final List<FlSpot> finalSpots = isActualPlaceholder
        ? const [
            FlSpot(0, 150000),
            FlSpot(1, 195000),
            FlSpot(2, 175000),
            FlSpot(3, 235000),
            FlSpot(4, 210000),
            FlSpot(5, 290000),
          ]
        : spots;

    final List<String> finalDates = isActualPlaceholder
        ? const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun']
        : dates;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final minX = finalSpots.map((s) => s.x).reduce((a, b) => a < b ? a : b);
    final maxX = finalSpots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    final range = maxX - minX;
    final intervalVal = range > 0 ? (range / 3) : 1.0;

    final yValues = finalSpots.map((s) => s.y).toList();
    final minYVal = yValues.reduce((a, b) => a < b ? a : b);
    final maxYVal = yValues.reduce((a, b) => a > b ? a : b);
    final yRange = maxYVal - minYVal;
    final padding = yRange > 0 ? yRange * 0.15 : 10000.0;
    final finalMinY = minYVal - padding;
    final finalMaxY = maxYVal + padding;

    final lineChart = LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yRange > 0 ? yRange / 4 : 50000.0,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? const Color(0x0AFFFFFF) : const Color(0x05000000),
              strokeWidth: 1.0,
              dashArray: [4, 4],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: intervalVal,
              getTitlesWidget: (value, meta) {
                if (value > 1000000) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      DateFormat('MMM yy').format(date),
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? AppColors.grey500 : AppColors.grey500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                final int idx = value.toInt();
                if (idx < 0 || idx >= finalDates.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    finalDates[idx],
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? AppColors.grey500 : AppColors.grey500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: minX,
        maxX: maxX,
        minY: finalMinY,
        maxY: finalMaxY,
        lineTouchData: LineTouchData(
          enabled: !isActualPlaceholder,
          handleBuiltInTouches: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
            if (onSpotHover == null || isActualPlaceholder) return;
            if (response == null || response.lineBarSpots == null || response.lineBarSpots!.isEmpty) {
              onSpotHover!(null);
              return;
            }
            if (event is FlTapUpEvent || event is FlPanEndEvent) {
              onSpotHover!(null);
            } else {
              onSpotHover!(response.lineBarSpots!.first);
            }
          },
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: AppColors.glow.withOpacity(0.2), 
                  strokeWidth: 2,
                  dashArray: [3, 3],
                ),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.glow,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => isDark ? const Color(0xFF16152B) : Colors.white,
            tooltipBorder: BorderSide(
              color: isDark ? AppColors.glow.withOpacity(0.3) : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            tooltipRoundedRadius: 8.0,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final idx = touchedSpot.x.toInt();
                final String dateStr;
                if (touchedSpot.x > 1000000) {
                  final date = DateTime.fromMillisecondsSinceEpoch(idx);
                  dateStr = DateFormat('dd MMM yyyy').format(date);
                } else {
                  dateStr = (idx >= 0 && idx < finalDates.length) ? finalDates[idx] : '';
                }
                final amount = NumberFormat.decimalPattern().format(touchedSpot.y);
                return LineTooltipItem(
                  '$dateStr\n$currency$amount',
                  GoogleFonts.inter(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    height: 1.4,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: finalSpots,
            isCurved: true,
            preventCurveOverShooting: true,
            gradient: LinearGradient(
              colors: isActualPlaceholder
                  ? [
                      AppColors.darkPrimary.withOpacity(0.25),
                      AppColors.glow.withOpacity(0.25),
                    ]
                  : const [
                      Color(0xFF8B5CF6), // Violet
                      Color(0xFF3B82F6), // Blue
                      Color(0xFF00F2FE), // Cyan
                    ],
            ),
            barWidth: isActualPlaceholder ? 2 : 3,
            isStrokeCapRound: true,
            dashArray: isActualPlaceholder ? const [6, 4] : null,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: isActualPlaceholder
                    ? [
                        AppColors.darkPrimary.withOpacity(0.05),
                        AppColors.glow.withOpacity(0.0),
                      ]
                    : [
                        const Color(0xFF8B5CF6).withOpacity(0.2),
                        const Color(0xFF00F2FE).withOpacity(0.0),
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );

    if (isActualPlaceholder) {
      return Stack(
        children: [
          Opacity(
            opacity: 0.4,
            child: lineChart,
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(0.08),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.darkPrimary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: AppColors.glow,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Visualize Your Wealth Trend',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add transactions or log your assets across multiple dates to build your historical net worth trend.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.grey500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return lineChart;
  }
}

class AllocationPieChart extends StatefulWidget {
  final Map<String, double> data;
  final String currency;

  const AllocationPieChart({
    required this.data,
    required this.currency,
    super.key,
  });

  @override
  State<AllocationPieChart> createState() => _AllocationPieChartState();
}

class _AllocationPieChartState extends State<AllocationPieChart> {
  bool _showBarList = false;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text('No allocation data available.'),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sortedEntries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    double total = sortedEntries.fold(0, (sum, entry) => sum + entry.value);

    final List<MapEntry<String, double>> processedEntries = [];
    if (sortedEntries.length <= 5) {
      processedEntries.addAll(sortedEntries);
    } else {
      processedEntries.addAll(sortedEntries.sublist(0, 4));
      double otherSum = 0.0;
      for (int i = 4; i < sortedEntries.length; i++) {
        otherSum += sortedEntries[i].value;
      }
      if (otherSum > 0) {
        processedEntries.add(MapEntry('Other Assets', otherSum));
      }
    }

    final colors = [
      AppColors.darkPrimary,
      AppColors.glow,
      const Color(0xFF22C55E), // Emerald Green
      const Color(0xFF06B6D4), // Cyan Blue
      const Color(0xFFF59E0B), // Amber Gold
      const Color(0xFFEC4899), // Hot Pink
    ];

    int colorIdx = 0;
    final sections = processedEntries.map((entry) {
      final color = colors[colorIdx % colors.length];
      colorIdx++;
      
      final double percentage = total > 0 ? (entry.value / total) * 100 : 0;
      final String title = percentage >= 5.0 ? '${percentage.toStringAsFixed(0)}%' : '';
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: title,
        radius: 36,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _showBarList ? 'Horizontal Bar View' : 'Donut Chart View',
              style: const TextStyle(color: AppColors.grey500, fontSize: 11, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                _showBarList ? Icons.donut_large : Icons.format_list_bulleted,
                color: AppColors.darkPrimary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _showBarList = !_showBarList;
                });
              },
              tooltip: _showBarList ? 'Show Donut Chart' : 'Show Progress Bar List',
            ),
          ],
        ),
        const SizedBox(height: 8),
        _showBarList
            ? _buildProgressBarList(processedEntries, colors, total, isDark)
            : _buildDonutLayout(processedEntries, colors, sections, total, isDark),
      ],
    );
  }

  Widget _buildProgressBarList(
    List<MapEntry<String, double>> processedEntries,
    List<Color> colors,
    double total,
    bool isDark,
  ) {
    return Column(
      children: List.generate(processedEntries.length, (index) {
        final entry = processedEntries[index];
        final color = colors[index % colors.length];
        final double percentage = total > 0 ? (entry.value / total) * 100 : 0;
        final amount = NumberFormat.compact().format(entry.value);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.grey400 : AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${widget.currency}$amount (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.lightText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total > 0 ? (entry.value / total) : 0,
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDonutLayout(
    List<MapEntry<String, double>> processedEntries,
    List<Color> colors,
    List<PieChartSectionData> sections,
    double total,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 36,
                sections: sections,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(processedEntries.length, (index) {
              final entry = processedEntries[index];
              final color = colors[index % colors.length];
              final amount = NumberFormat.compact().format(entry.value);
              final double percentage = total > 0 ? (entry.value / total) * 100 : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.grey400 : AppColors.grey700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.currency}$amount (${percentage.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class GrowthBarChart extends StatelessWidget {
  final List<double> growthData; // growth amount or values per month
  final List<String> months;
  final String currency;

  const GrowthBarChart({
    required this.growthData,
    required this.months,
    required this.currency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (growthData.isEmpty) {
      return const Center(
        child: Text('No growth data available.'),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final barGroups = List.generate(growthData.length, (index) {
      final value = growthData[index];
      final isPositive = value >= 0;
      final color = isPositive ? AppColors.darkSuccess : AppColors.darkDanger;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: color,
            width: 14,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(6),
              topRight: const Radius.circular(6),
              bottomLeft: isPositive ? Radius.zero : const Radius.circular(6),
              bottomRight: isPositive ? Radius.zero : const Radius.circular(6),
            ),
          ),
        ],
      );
    });

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? const Color(0x0DFFFFFF) : const Color(0x05000000),
              strokeWidth: 1.0,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final int idx = value.toInt();
                if (idx < 0 || idx >= months.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    months[idx],
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.grey500 : AppColors.grey500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => isDark ? const Color(0xFF1F1F2E) : Colors.white,
            tooltipRoundedRadius: 6.0,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final amount = NumberFormat.compact().format(rod.toY.abs());
              final sign = rod.toY >= 0 ? '+' : '-';
              return BarTooltipItem(
                '$sign$currency$amount',
                TextStyle(
                  color: rod.toY >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
