import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/widgets/glass_card.dart';

/// Full-page recovery allocation report accessible from Settings.
/// Shows recovered money flow across all receivables.
class RecoveryAllocationReportScreen extends ConsumerWidget {
  const RecoveryAllocationReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final fmt = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    final allAllocations = dbState.recoveryAllocations;
    final allDestinations = dbState.recoveryDestinations;

    // Aggregate totals
    final double totalRecovered = allAllocations.fold(0.0, (s, a) => s + a.totalAmount);
    final double totalAllocated = allDestinations.fold(0.0, (s, d) => s + d.amount);

    // Group by destination type
    final Map<String, double> byType = {};
    for (final dest in allDestinations) {
      byType[dest.destinationType] = (byType[dest.destinationType] ?? 0.0) + dest.amount;
    }

    // Sort by amount descending
    final sortedEntries = byType.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: Text('Recovery Allocation Report',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: allAllocations.isEmpty
          ? _buildEmpty()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryHeader(fmt, totalRecovered, totalAllocated),
                  const SizedBox(height: 24),
                  if (sortedEntries.isNotEmpty) ...[
                    _buildFlowBreakdown(sortedEntries, totalRecovered, fmt),
                    const SizedBox(height: 24),
                  ],
                  _buildPersonBreakdown(dbState, fmt),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.accentGlow,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_tree_rounded, color: AppColors.darkPrimary, size: 48),
          ),
          const SizedBox(height: 20),
          Text('No Recovery Allocations Yet',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'When you recover money from a receivable,\nallocations will appear here.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.grey400, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(NumberFormat fmt, double totalRecovered, double totalAllocated) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'TOTAL RECOVERED',
            value: fmt.format(totalRecovered),
            icon: Icons.call_received_rounded,
            color: AppColors.darkSuccess,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'TOTAL ALLOCATED',
            value: fmt.format(totalAllocated),
            icon: Icons.account_tree_rounded,
            color: AppColors.darkPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFlowBreakdown(
    List<MapEntry<String, double>> entries,
    double total,
    NumberFormat fmt,
  ) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppColors.darkPrimary, size: 18),
              const SizedBox(width: 8),
              Text('Money Flow Breakdown',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          // Stacked bar
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: SizedBox(
                height: 16,
                child: Row(
                  children: entries.map((e) {
                    final frac = (e.value / total).clamp(0.0, 1.0);
                    return Expanded(
                      flex: (frac * 1000).round().clamp(1, 1000),
                      child: Container(color: _typeColor(e.key)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Individual rows
          ...entries.map((e) {
            final pct = total > 0 ? (e.value / total * 100) : 0.0;
            final color = _typeColor(e.key);
            final icon = _typeIcon(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_typeLabel(e.key),
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: pct / 100,
                            minHeight: 4,
                            backgroundColor: AppColors.glassSurface,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmt.format(e.value),
                          style: GoogleFonts.outfit(
                              fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                      Text('${pct.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPersonBreakdown(MockDatabaseState dbState, NumberFormat fmt) {
    // Group allocations by person
    final Map<String, List<RecoveryAllocation>> byPerson = {};
    for (final alloc in dbState.recoveryAllocations) {
      byPerson.putIfAbsent(alloc.personId, () => []).add(alloc);
    }

    if (byPerson.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('By Receivable',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 12),
        ...byPerson.entries.map((entry) {
          final person = dbState.people.where((p) => p.id == entry.key).firstOrNull;
          final personName = person?.name ?? 'Unknown';
          final allocations = entry.value;
          final totalForPerson = allocations.fold(0.0, (s, a) => s + a.totalAmount);
          final destIds = allocations.map((a) => a.id).toSet();
          final dests = dbState.recoveryDestinations.where((d) => destIds.contains(d.allocationId)).toList();

          // Group dests by type for this person
          final Map<String, double> personByType = {};
          for (final d in dests) {
            personByType[d.destinationType] = (personByType[d.destinationType] ?? 0.0) + d.amount;
          }

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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.darkSuccess.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: AppColors.darkSuccess, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Text(personName,
                              style: GoogleFonts.outfit(
                                  fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                      Text(fmt.format(totalForPerson),
                          style: GoogleFonts.outfit(
                              fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkSuccess)),
                    ],
                  ),
                  if (personByType.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.glassBorder),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: personByType.entries.map((e) {
                        final color = _typeColor(e.key);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            '${_typeLabel(e.key)}: ${fmt.format(e.value)}',
                            style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600, color: color),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.grey500, letterSpacing: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

Color _typeColor(String type) {
  switch (type) {
    case 'Cash':          return const Color(0xFF22C55E);
    case 'BankAccount':   return const Color(0xFF3B82F6);
    case 'Investment':    return const Color(0xFFA855F7);
    case 'MTFPosition':   return const Color(0xFFF59E0B);
    case 'EmergencyFund': return const Color(0xFFEF4444);
    case 'Goal':          return const Color(0xFF06B6D4);
    case 'Asset':         return const Color(0xFF84CC16);
    default:              return const Color(0xFF94A3B8);
  }
}

IconData _typeIcon(String type) {
  switch (type) {
    case 'Cash':          return Icons.money_rounded;
    case 'BankAccount':   return Icons.account_balance_rounded;
    case 'Investment':    return Icons.trending_up_rounded;
    case 'MTFPosition':   return Icons.bolt_rounded;
    case 'EmergencyFund': return Icons.emergency_rounded;
    case 'Goal':          return Icons.flag_rounded;
    case 'Asset':         return Icons.home_rounded;
    default:              return Icons.edit_rounded;
  }
}

String _typeLabel(String type) {
  switch (type) {
    case 'Cash':          return 'Cash';
    case 'BankAccount':   return 'Bank Account';
    case 'Investment':    return 'Investment';
    case 'MTFPosition':   return 'MTF Position';
    case 'EmergencyFund': return 'Emergency Fund';
    case 'Goal':          return 'Goal';
    case 'Asset':         return 'Asset';
    default:              return 'Custom';
  }
}
