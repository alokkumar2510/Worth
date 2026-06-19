import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/widgets/glass_card.dart';

/// Shows a breakdown of recovered money flow:
/// total recovered → how it was allocated across destinations.
/// Embeddable in receivable_detail_screen and any report page.
class RecoveryFlowReportWidget extends StatelessWidget {
  final String personId;
  final MockDatabaseState dbState;

  const RecoveryFlowReportWidget({
    super.key,
    required this.personId,
    required this.dbState,
  });

  @override
  Widget build(BuildContext context) {
    final currency = dbState.currency;
    final fmt = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    // Filter allocations for this person
    final allocations = dbState.recoveryAllocations
        .where((a) => a.personId == personId)
        .toList();

    if (allocations.isEmpty) return const SizedBox.shrink();

    final allocationIds = allocations.map((a) => a.id).toSet();
    final destinations = dbState.recoveryDestinations
        .where((d) => allocationIds.contains(d.allocationId))
        .toList();

    // Total recovered
    final double totalRecovered = allocations.fold(0.0, (sum, a) => sum + a.totalAmount);
    final double totalAllocated = destinations.fold(0.0, (sum, d) => sum + d.amount);

    // Group destinations by type
    final Map<String, double> byType = {};
    for (final dest in destinations) {
      byType[dest.destinationType] = (byType[dest.destinationType] ?? 0.0) + dest.amount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.darkSuccess.withOpacity(0.3), AppColors.darkSuccess.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_tree_rounded, color: AppColors.darkSuccess, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Recovery Money Flow',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Summary card
        GlassCard(
          borderColor: AppColors.darkSuccess.withOpacity(0.3),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL RECOVERED',
                          style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.grey500, letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      Text(fmt.format(totalRecovered),
                          style: GoogleFonts.outfit(
                              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkSuccess)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('ALLOCATED',
                          style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.grey500, letterSpacing: 0.8)),
                      const SizedBox(height: 4),
                      Text(fmt.format(totalAllocated),
                          style: GoogleFonts.outfit(
                              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkPrimary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Stacked bar
              _StackedAllocationBar(byType: byType, total: totalRecovered),
              const SizedBox(height: 12),
              // Legend
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: byType.entries.map((e) {
                  final color = _typeColor(e.key);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('${_typeLabel(e.key)}: ${fmt.format(e.value)}',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Allocation History
        Text('Allocation History',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey400)),
        const SizedBox(height: 10),
        ...allocations.map((alloc) {
          final destList = destinations
              .where((d) => d.allocationId == alloc.id)
              .toList();
          return _AllocationHistoryCard(
            allocation: alloc,
            destinations: destList,
            currency: currency,
            fmt: fmt,
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stacked bar showing flow by type
// ─────────────────────────────────────────────────────────────────────────────
class _StackedAllocationBar extends StatelessWidget {
  final Map<String, double> byType;
  final double total;
  const _StackedAllocationBar({required this.byType, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        height: 14,
        child: Row(
          children: byType.entries.map((e) {
            final frac = (e.value / total).clamp(0.0, 1.0);
            return Expanded(
              flex: (frac * 1000).round(),
              child: Container(color: _typeColor(e.key)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual allocation event card
// ─────────────────────────────────────────────────────────────────────────────
class _AllocationHistoryCard extends StatelessWidget {
  final RecoveryAllocation allocation;
  final List<RecoveryDestination> destinations;
  final String currency;
  final NumberFormat fmt;

  const _AllocationHistoryCard({
    required this.allocation,
    required this.destinations,
    required this.currency,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(allocation.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.call_received_rounded, color: AppColors.darkSuccess, size: 16),
                    const SizedBox(width: 6),
                    Text(fmt.format(allocation.totalAmount),
                        style: GoogleFonts.outfit(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkSuccess)),
                  ],
                ),
                Text(dateStr, style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
              ],
            ),
            if (destinations.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.glassBorder),
              const SizedBox(height: 10),
              ...destinations.map((d) => _DestinationRow(dest: d, currency: currency, fmt: fmt)),
            ],
            if (allocation.unallocatedAmount > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.grey500, size: 13),
                  const SizedBox(width: 6),
                  Text('${fmt.format(allocation.unallocatedAmount)} unallocated',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DestinationRow extends StatelessWidget {
  final RecoveryDestination dest;
  final String currency;
  final NumberFormat fmt;
  const _DestinationRow({required this.dest, required this.currency, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(dest.destinationType);
    final icon = _typeIcon(dest.destinationType);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dest.destinationLabel,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(_typeLabel(dest.destinationType),
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500)),
              ],
            ),
          ),
          Text(fmt.format(dest.amount),
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
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
