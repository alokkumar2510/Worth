import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class NetWorthLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final List<String> dates;
  final String currency;

  const NetWorthLineChart({
    required this.spots,
    required this.dates,
    required this.currency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Add transactions across multiple months to view trend.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.grey500,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: isDark ? const Color(0x11FFFFFF) : const Color(0x0A000000),
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int idx = value.toInt();
                if (idx < 0 || idx >= dates.length) return const SizedBox.shrink();
                
                // Show first, middle, and last date label for spacing
                if (idx == 0 || idx == dates.length - 1 || idx == (dates.length / 2).floor()) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dates[idx],
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.grey500 : AppColors.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.9,
        maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => isDark ? const Color(0xFF1F1F2E) : Colors.white,
            tooltipBorder: BorderSide(
              color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            tooltipRoundedRadius: 8.0,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final amount = NumberFormat.compact().format(touchedSpot.y);
                return LineTooltipItem(
                  '$currency$amount',
                  TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.darkPrimary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.darkPrimary.withOpacity(0.25),
                  AppColors.darkPrimary.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AllocationPieChart extends StatelessWidget {
  final Map<String, double> data;
  final String currency;

  const AllocationPieChart({
    required this.data,
    required this.currency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No allocation data available.'),
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colors = [
      AppColors.darkPrimary,
      AppColors.glow,
      const Color(0xFF22C55E), // Emerald Green
      const Color(0xFF06B6D4), // Cyan Blue
      const Color(0xFFF59E0B), // Amber Gold
      const Color(0xFFEC4899), // Hot Pink
    ];

    double total = data.values.fold(0, (sum, val) => sum + val);

    int colorIdx = 0;
    final sections = data.entries.map((entry) {
      final color = colors[colorIdx % colors.length];
      colorIdx++;
      
      final double percentage = total > 0 ? (entry.value / total) * 100 : 0;
      
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
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
            children: List.generate(data.length, (index) {
              final entry = data.entries.elementAt(index);
              final color = colors[index % colors.length];
              final amount = NumberFormat.compact().format(entry.value);
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
                    Text(
                      '$currency$amount',
                      style: TextStyle(
                        fontSize: 12,
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
