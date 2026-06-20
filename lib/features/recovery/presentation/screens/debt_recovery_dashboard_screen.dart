import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/providers/dependency_provider.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/utils/recovery_calculator.dart';

class DebtRecoveryDashboardScreen extends ConsumerWidget {
  const DebtRecoveryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final fmt = NumberFormat.currency(symbol: currency, decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter active debtors (non-archived people)
    final activeDebtors = dbState.people.where((p) => p.isArchived == 0).toList();

    // Calculations
    double totalPending = 0.0;
    double totalRecovered = 0.0;

    // Buckets
    double bucket0to30 = 0.0;
    double bucket31to60 = 0.0;
    double bucket61to90 = 0.0;
    double bucket90Plus = 0.0;

    final List<int> recoveryTimes = [];

    for (final debtor in activeDebtors) {
      final outstanding = dbState.getPersonReceivableBalance(debtor.id);
      if (outstanding > 0) {
        totalPending += outstanding;
        final borrowDate = debtor.borrowDate ?? debtor.createdAt;
        final days = RecoveryCalculator.calculateDaysPending(borrowDate);
        if (days <= 30) {
          bucket0to30 += outstanding;
        } else if (days <= 60) {
          bucket31to60 += outstanding;
        } else if (days <= 90) {
          bucket61to90 += outstanding;
        } else {
          bucket90Plus += outstanding;
        }
      }

      // Find all recovery transactions for this debtor
      final debtorRecoveries = dbState.transactions
          .where((t) => t.personId == debtor.id && t.type == 'recover_money' && t.voidedTransactionId == null)
          .toList();

      for (final tx in debtorRecoveries) {
        totalRecovered += tx.amount;
        final borrowDate = debtor.borrowDate ?? debtor.createdAt;
        final duration = tx.transactionDate.difference(borrowDate).inDays;
        if (duration > 0) {
          recoveryTimes.add(duration);
        }
      }
    }

    final double totalReceivables = totalPending + totalRecovered;
    final double recoveryRate = totalReceivables > 0 ? (totalRecovered / totalReceivables) * 100 : 0.0;
    final double avgRecoveryTime = recoveryTimes.isNotEmpty ? recoveryTimes.average : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        title: Text(
          'Debt Recovery Center',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            onPressed: () => context.push('/recovery/upi_settings'),
            tooltip: 'UPI Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (!ref.read(mockModeProvider)) {
              await ref.read(mockDatabaseProvider.notifier).loadStateFromDatabase();
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Metrics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'PENDING COLLECTION',
                        fmt.format(totalPending),
                        AppColors.darkDanger,
                        Icons.hourglass_empty_rounded,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'TOTAL RECOVERED',
                        fmt.format(totalRecovered),
                        AppColors.darkSuccess,
                        Icons.verified_rounded,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'RECOVERY RATE',
                        '${recoveryRate.toStringAsFixed(1)}%',
                        AppColors.darkPrimary,
                        Icons.trending_up,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        'AVG RECOVERY TIME',
                        '${avgRecoveryTime.toStringAsFixed(0)} Days',
                        Colors.cyan,
                        Icons.speed_rounded,
                        isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Aging buckets Chart
                Text(
                  'RECEIVABLES AGING BUCKETS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Outstanding Amount by Days Pending',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: [bucket0to30, bucket31to60, bucket61to90, bucket90Plus].max + 1000,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => AppColors.layer1,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    fmt.format(rod.toY),
                                    TextStyle(color: AppColors.darkPrimary, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    String text = '';
                                    switch (value.toInt()) {
                                      case 0:
                                        text = '0-30d';
                                        break;
                                      case 1:
                                        text = '31-60d';
                                        break;
                                      case 2:
                                        text = '61-90d';
                                        break;
                                      case 3:
                                        text = '90d+';
                                        break;
                                    }
                                    return Text(
                                      text,
                                      style: const TextStyle(color: AppColors.grey500, fontSize: 10, fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _makeBarGroup(0, bucket0to30, const Color(0xFF3B82F6)),
                              _makeBarGroup(1, bucket31to60, const Color(0xFFF59E0B)),
                              _makeBarGroup(2, bucket61to90, const Color(0xFFEF4444)),
                              _makeBarGroup(3, bucket90Plus, const Color(0xFF7F1D1D)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Active Debtors List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE DEBTORS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${activeDebtors.where((d) => dbState.getPersonReceivableBalance(d.id) > 0).length} People',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.darkPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (activeDebtors.isEmpty || activeDebtors.every((d) => dbState.getPersonReceivableBalance(d.id) <= 0))
                  _buildEmptyState(isDark)
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeDebtors.length,
                    itemBuilder: (context, index) {
                      final debtor = activeDebtors[index];
                      final balance = dbState.getPersonReceivableBalance(debtor.id);
                      if (balance <= 0) return const SizedBox.shrink();

                      final borrowDate = debtor.borrowDate ?? debtor.createdAt;
                      final daysPending = RecoveryCalculator.calculateDaysPending(borrowDate);
                      final stage = RecoveryCalculator.calculateFollowUpStage(daysPending);
                      final stageLabel = RecoveryCalculator.getStageLabel(stage);
                      final stageColor = RecoveryCalculator.getStageColor(stage);
                      final risk = RecoveryCalculator.calculateRiskLevel(daysPending);
                      final riskLabel = RecoveryCalculator.getRiskLabel(risk);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => context.push('/portfolio/receivable/${debtor.id}'),
                          borderRadius: BorderRadius.circular(16),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: stageColor.withOpacity(0.12),
                                  child: Icon(Icons.person_rounded, color: stageColor),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        debtor.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: stageColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: stageColor.withOpacity(0.3)),
                                            ),
                                            child: Text(
                                              stageLabel,
                                              style: TextStyle(
                                                color: stageColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$daysPending days pending',
                                            style: const TextStyle(
                                              color: AppColors.grey500,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      fmt.format(balance),
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppColors.darkDanger,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      riskLabel,
                                      style: TextStyle(
                                        color: RecoveryCalculator.getRiskColor(risk),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, IconData icon, bool isDark) {
    return GlassCard(
      borderColor: color.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey500,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 28,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: y == 0 ? 100 : 0,
            color: AppColors.glassSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accentGlow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_outlined, color: AppColors.darkSuccess, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Zero Outstanding Debt',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great job! There are no pending receivables on Worth right now.',
            style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 13, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
