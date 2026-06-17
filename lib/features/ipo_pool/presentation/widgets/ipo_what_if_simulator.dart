import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/ipo_pool_models.dart';
import 'calculation_audit_panel.dart';

class IpoWhatIfSimulator extends StatefulWidget {
  final IpoPool pool;
  final String currency;

  const IpoWhatIfSimulator({
    required this.pool,
    required this.currency,
    super.key,
  });

  @override
  State<IpoWhatIfSimulator> createState() => _IpoWhatIfSimulatorState();
}

class _IpoWhatIfSimulatorState extends State<IpoWhatIfSimulator> {
  // Simulator parameters
  late double _expectedListingPrice;
  late int _simulatedAllottedLots;
  String _activeScenario = 'Expected'; // 'Conservative', 'Expected', 'Bull', 'Custom'

  @override
  void initState() {
    super.initState();
    // Default values
    _expectedListingPrice = widget.pool.issuePrice * 1.30; // default expected is +30%
    final currentAllotted = widget.pool.allotments.where((a) => a.status == 'Allotted').length;
    _simulatedAllottedLots = currentAllotted > 0 ? currentAllotted : max(1, widget.pool.fullApplications);
  }

  // Pre-set scenario calculations
  double get _conservativePrice => widget.pool.issuePrice * 1.10; // +10%
  double get _expectedPrice => widget.pool.issuePrice * 1.30;     // +30%
  double get _bullPrice => widget.pool.issuePrice * 1.70;         // +70%

  void _applyScenario(String scenario) {
    setState(() {
      _activeScenario = scenario;
      if (scenario == 'Conservative') {
        _expectedListingPrice = _conservativePrice;
      } else if (scenario == 'Expected') {
        _expectedListingPrice = _expectedPrice;
      } else if (scenario == 'Bull') {
        _expectedListingPrice = _bullPrice;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final issuePrice = widget.pool.issuePrice;
    final sharesPerLot = widget.pool.sharesPerLot;
    final pool = widget.pool;
    final currency = widget.currency;

    // Calculations based on current sliders
    final simulatedShares = _simulatedAllottedLots * sharesPerLot;
    final simulatedSoloShares = min(pool.soloApplications, _simulatedAllottedLots) * sharesPerLot;
    final simulatedGroupShares = max(0, _simulatedAllottedLots - pool.soloApplications) * sharesPerLot;

    final gainPerShare = _expectedListingPrice - issuePrice;
    final gainPercent = issuePrice > 0 ? (gainPerShare / issuePrice) * 100 : 0.0;

    final simulatedSoloProfit = gainPerShare * simulatedSoloShares;
    final simulatedGroupProfit = gainPerShare * simulatedGroupShares;
    final totalSimulatedProfit = simulatedSoloProfit + simulatedGroupProfit;

    final totalPoolAmount = pool.totalPoolAmount;
    final simulatedRoi = totalPoolAmount > 0 ? (totalSimulatedProfit / totalPoolAmount) * 100 : 0.0;

    // Compile scenario profits for comparative charts
    final conservativeProfit = (_conservativePrice - issuePrice) * simulatedShares;
    final expectedProfit = (_expectedPrice - issuePrice) * simulatedShares;
    final bullProfit = (_bullPrice - issuePrice) * simulatedShares;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scenario Selector Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScenarioButton('Conservative (+10%)', 'Conservative'),
              _buildScenarioButton('Expected (+30%)', 'Expected'),
              _buildScenarioButton('Bull Case (+70%)', 'Bull'),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Sliders Control Panel
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulation Sliders',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 16),

                // 1. Expected Listing Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Simulated Listing Price',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400),
                    ),
                    Text(
                      '$currency${_expectedListingPrice.toStringAsFixed(2)} (${gainPercent >= 0 ? "+" : ""}${gainPercent.toStringAsFixed(1)}%)',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: gainPerShare >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _expectedListingPrice,
                  min: issuePrice * 0.5,
                  max: issuePrice * 3.0,
                  activeColor: AppColors.darkPrimary,
                  inactiveColor: AppColors.glassBorder,
                  onChanged: (val) {
                    setState(() {
                      _expectedListingPrice = val;
                      _activeScenario = 'Custom';
                    });
                  },
                ),

                // 2. Simulated Allotted Lots
                if (pool.fullApplications > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Simulated Allotted Lots',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.grey400),
                      ),
                      Text(
                        '$_simulatedAllottedLots / ${pool.fullApplications} Lots',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  Slider(
                    value: _simulatedAllottedLots.toDouble(),
                    min: 0,
                    max: pool.fullApplications.toDouble(),
                    divisions: pool.fullApplications,
                    activeColor: const Color(0xFF00F2FE),
                    inactiveColor: AppColors.glassBorder,
                    onChanged: (val) {
                      setState(() {
                        _simulatedAllottedLots = val.toInt();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          CalculationAuditPanel(
            title: 'Verify What-If Simulation Calculations',
            formula: 'Gain Per Share = simulatedListingPrice - issuePrice\n'
                'Simulated Solo Shares = min(soloApplications, simulatedAllottedLots) * sharesPerLot\n'
                'Simulated Group Shares = max(0, simulatedAllottedLots - soloApplications) * sharesPerLot\n'
                'Simulated Solo Profit = simulatedSoloShares * gainPerShare\n'
                'Simulated Group Profit = simulatedGroupShares * gainPerShare\n'
                'Total Simulated Profit = simulatedSoloProfit + simulatedGroupProfit\n'
                'Simulated ROI % = (totalSimulatedProfit / totalPoolAmount) * 100',
            inputs: {
              'Simulated Listing Price': '$currency${_expectedListingPrice.toStringAsFixed(2)}',
              'Issue Price': '$currency${issuePrice.toStringAsFixed(2)}',
              'Simulated Allotted Lots': '$_simulatedAllottedLots',
              'Shares Per Lot': '$sharesPerLot',
              'Solo Applications Limit': '${pool.soloApplications}',
              'Total Pool Amount (Verified)': '$currency${totalPoolAmount.toStringAsFixed(2)}',
            },
            output: 'Simulated Profit: $currency${totalSimulatedProfit.toStringAsFixed(2)}',
            steps: [
              'Gain per share is the difference between simulated listing price and issue price: $currency${_expectedListingPrice.toStringAsFixed(2)} - $currency${issuePrice.toStringAsFixed(2)} = $currency${gainPerShare.toStringAsFixed(2)}.',
              'Solo shares receives allocations first, up to solo applications count: min(${pool.soloApplications}, $_simulatedAllottedLots) * $sharesPerLot = $simulatedSoloShares shares.',
              'Group shares receives the remaining allotted lots: max(0, $_simulatedAllottedLots - ${pool.soloApplications}) * $sharesPerLot = $simulatedGroupShares shares.',
              'Simulated Solo Profit: $simulatedSoloShares shares * $currency${gainPerShare.toStringAsFixed(2)} = $currency${simulatedSoloProfit.toStringAsFixed(2)}.',
              'Simulated Group Profit: $simulatedGroupShares shares * $currency${gainPerShare.toStringAsFixed(2)} = $currency${simulatedGroupProfit.toStringAsFixed(2)}.',
              'Total profit: solo profit + group profit = $currency${totalSimulatedProfit.toStringAsFixed(2)}.',
              'Simulated ROI is calculated on total pool contributions: ($currency${totalSimulatedProfit.toStringAsFixed(0)} / $currency${totalPoolAmount.toStringAsFixed(0)}) * 100 = ${simulatedRoi.toStringAsFixed(1)}%.',
            ],
          ),
          const SizedBox(height: 16),

          // Simulation Metrics Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildMetricTile(
                'Gain Per Share',
                '$currency${gainPerShare.toStringAsFixed(2)}',
                gainPerShare >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                subtitle: 'Issue Price: $currency${issuePrice.toStringAsFixed(0)}',
              ),
              _buildMetricTile(
                'Total Simulated Profit',
                '$currency${totalSimulatedProfit.toStringAsFixed(0)}',
                totalSimulatedProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                subtitle: 'Lots: $_simulatedAllottedLots ($simulatedShares Shares)',
              ),
              _buildMetricTile(
                'Simulated ROI %',
                '${simulatedRoi.toStringAsFixed(1)}%',
                simulatedRoi >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                subtitle: 'Overall ROI share',
              ),
              _buildMetricTile(
                'Solo vs Group Profit',
                '$currency${simulatedSoloProfit.toStringAsFixed(0)} / $currency${simulatedGroupProfit.toStringAsFixed(0)}',
                const Color(0xFF8E2DE2),
                subtitle: 'Solo shares vs Group',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Comparative Scenarios Chart
          Text(
            'SCENARIO COMPARATIVE OUTCOME',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          _buildScenarioChart(
            conservative: conservativeProfit,
            expected: expectedProfit,
            bull: bullProfit,
            custom: totalSimulatedProfit,
          ),
          const SizedBox(height: 24),

          // Contributor Split Details
          Text(
            'CONTRIBUTOR SIMULATED DISTRIBUTION & SETTLEMENT',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
          ),
          const SizedBox(height: 10),
          pool.contributors.isEmpty
              ? const GlassCard(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('No contributors added to perform simulation split.', style: TextStyle(color: AppColors.grey500)),
                    ),
                  ),
                )
              : Column(
                  children: pool.contributors.map((c) {
                    final totalGroupContrib = pool.totalGroupContribution;
                    final verifiedContrib = pool.getContributorVerifiedContribution(c.id);
                    final ownershipFraction = totalGroupContrib > 0 ? (verifiedContrib / totalGroupContrib) : 0.0;
                    final simulatedUserProfit = simulatedGroupProfit * ownershipFraction;
                    final simulatedPayout = verifiedContrib + simulatedUserProfit;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  c.name,
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  '${(ownershipFraction * 100).toStringAsFixed(1)}% Share',
                                  style: const TextStyle(color: AppColors.darkPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(color: AppColors.glassBorder, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSubItem('Original Capital', '$currency${verifiedContrib.toStringAsFixed(0)}'),
                                _buildSubItem('Simulated Profit', '$currency${simulatedUserProfit.toStringAsFixed(0)}',
                                    color: simulatedUserProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger),
                                _buildSubItem('Simulated Payout', '$currency${simulatedPayout.toStringAsFixed(0)}',
                                    isBold: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildScenarioButton(String label, String scenario) {
    final isSelected = _activeScenario == scenario;
    return Expanded(
      child: GestureDetector(
        onTap: () => _applyScenario(scenario),
        child: Container(
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkPrimary.withOpacity(0.18) : Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color, {required String subtitle}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 9, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSubItem(String label, String val, {Color? color, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 8)),
        const SizedBox(height: 2),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.white,
          ),
        ),
      ],
    );
  }

  // Comparative scenario bar chart
  Widget _buildScenarioChart({
    required double conservative,
    required double expected,
    required double bull,
    required double custom,
  }) {
    final double maxVal = [conservative.abs(), expected.abs(), bull.abs(), custom.abs(), 100.0].reduce(max);
    
    return SizedBox(
      height: 180,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxVal * 1.15,
            minY: 0,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, meta) {
                    const style = TextStyle(color: AppColors.grey500, fontSize: 9, fontWeight: FontWeight.bold);
                    switch (val.toInt()) {
                      case 0:
                        return const Text('CONSERV', style: style);
                      case 1:
                        return const Text('EXPECT', style: style);
                      case 2:
                        return const Text('BULL', style: style);
                      case 3:
                        return const Text('SIMULATED', style: style);
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            barGroups: [
              _buildBarGroup(0, conservative, AppColors.darkPrimary),
              _buildBarGroup(1, expected, AppColors.darkWarning),
              _buildBarGroup(2, bull, AppColors.darkSuccess),
              _buildBarGroup(3, custom, const Color(0xFF00F2FE)),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double val, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: val < 0 ? 0 : val,
          color: color,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 0,
            color: Colors.white.withOpacity(0.03),
          ),
        ),
      ],
    );
  }
}
