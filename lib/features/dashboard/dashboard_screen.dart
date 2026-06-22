import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:collection/collection.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/constants/app_version.dart';
import '../../core/services/update_service.dart';
import '../../core/widgets/update_prompt_sheet.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/widgets/animated_number_text.dart';
import '../../core/widgets/premium_chart.dart';
import '../../core/providers/mock_database.dart';
import '../../core/providers/dependency_provider.dart';
import '../../core/providers/app_providers.dart';
import '../../database/database.dart' hide Transaction, Snapshot, Account, Investment, Goal, ExpectedIncome, Milestone, Achievement, AchievementProgress;
import '../transactions/domain/entities/transaction.dart';
import '../reports/domain/entities/snapshot.dart';
import '../accounts/domain/entities/account.dart';
import '../investments/domain/entities/investment.dart';
import '../goals/domain/entities/goal.dart';
import '../expected_income/domain/entities/expected_income.dart';
import '../transactions/presentation/widgets/add_transaction_sheet.dart';
import '../checkins/presentation/widgets/check_in_dashboard_widget.dart';
import '../spending/presentation/widgets/spending_dashboard_widget.dart';
import '../education_loan/presentation/widgets/edu_loan_dashboard_widget.dart';
import 'presentation/widgets/calendar_widget.dart';
import '../../core/mock_data/mock_constants.dart';
import '../achievements/presentation/providers/achievements_provider.dart';
import '../achievements/domain/entities/milestone.dart';
import '../achievements/domain/entities/achievement.dart';
import '../sync/presentation/widgets/sync_status_widget.dart';
import 'presentation/widgets/update_banner_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _chartRange = 'ALL'; // '30D' | '90D' | '1Y' | 'ALL'
  FlSpot? _hoveredSpot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(mockModeProvider)) {
        ref.read(realReportServiceProvider).generateMissingSnapshots();
      }
      _checkWhatsNewChangelog();
    });
  }

  Future<void> _checkWhatsNewChangelog() async {
    try {
      final db = ref.read(realDatabaseProvider);
      final row = await (db.select(db.settings)..where((tbl) => tbl.key.equals('last_displayed_changelog_version'))).getSingleOrNull();
      final lastSeen = row?.value;
      if (lastSeen == null) {
        // Fresh install: save version, don't show
        await db.into(db.settings).insertOnConflictUpdate(
          Setting(
            key: 'last_displayed_changelog_version',
            value: AppVersion.version,
            updatedAt: DateTime.now(),
          ),
        );
      } else if (lastSeen != AppVersion.version) {
        if (mounted) {
          context.push('/settings/whats_new');
        }
      }
    } catch (_) {}
  }

  void _openAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionSheet(),
    );
  }

  void _showNaturalLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const NaturalLanguageQueryDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[ROUTING] Dashboard route reached');
    ref.listen<UpdateState>(updateServiceProvider, (previous, next) {
      if (next.status == UpdateStatus.optionalAvailable && next.updateInfo != null) {
        UpdatePromptSheet.show(context, next.updateInfo!, next.hasPendingSync);
      }
    });

    final netWorthAsync = ref.watch(netWorthProvider);
    final activeAccountsAsync = ref.watch(activeAccountsProvider);
    final activePeopleAsync = ref.watch(activePeopleProvider);
    final activeInvestmentsAsync = ref.watch(activeInvestmentsProvider);
    final pendingIncomeAsync = ref.watch(pendingExpectedIncomesProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final snapshotsAsync = ref.watch(allSnapshotsProvider);
    
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    return Scaffold(
      body: Stack(
        children: [
          // Background soft glows
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkPrimary.withOpacity(0.06),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium Navigation Header
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Worth',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Wealth Management',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // AI Query Action
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.layer1.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: IconButton(
                          onPressed: () => _showNaturalLanguageDialog(context),
                          icon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                          tooltip: 'AI Query',
                        ),
                      ),
                      // Search Action
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.layer1.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: IconButton(
                          onPressed: () => context.push('/search'),
                          icon: SvgPicture.asset(
                            AssetPaths.icSearch,
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      // Profile Action
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.layer1.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: IconButton(
                          onPressed: () => context.push('/profile'),
                          icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const UpdateBannerWidget(),

                  // Cloud Sync Status Indicator
                  const Align(
                    alignment: Alignment.centerRight,
                    child: SyncStatusWidget(),
                  ),
                  const SizedBox(height: 16),

                  // 1. Flagship Net Worth Card
                  netWorthAsync.when(
                    data: (data) {
                      final snapshots = snapshotsAsync.value ?? [];
                      return _buildNetWorthCard(data, currency, snapshots);
                    },
                    loading: () => const CardShimmer(height: 140, isPrimary: true),
                    error: (e, s) => GlassCard(
                      isPrimary: true,
                      child: Padding(padding: const EdgeInsets.all(16), child: Text('Error calculating Net Worth: $e')),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Summary Grid (Assets, Liabilities, Investments, Expected Income)
                  netWorthAsync.when(
                    data: (data) => _buildSummaryGrid(data, currency, dbState),
                    loading: () => GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.35,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        CardShimmer(height: 100),
                        CardShimmer(height: 100),
                        CardShimmer(height: 100),
                        CardShimmer(height: 100),
                      ],
                    ),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // Funding & Debt Analysis Card
                  netWorthAsync.when(
                    data: (data) => _buildFundingDebtAnalysisCard(data, currency),
                    loading: () => const CardShimmer(height: 240),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // 3. Trend Chart
                  snapshotsAsync.when(
                    data: (snapshots) => _buildTrendChartCard(snapshots, currency),
                    loading: () => const ChartShimmer(height: 240),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  const CheckInDashboardWidget(),
                  const SizedBox(height: 24),

                  const SpendingDashboardWidget(),
                  const SizedBox(height: 24),

                  const CalendarWidget(),
                  const SizedBox(height: 24),

                  const EduLoanDashboardWidget(),
                  const SizedBox(height: 24),

                  _buildMtfAndSipWidgets(dbState),
                  const SizedBox(height: 24),

                  // Milestones & Achievements Card
                  netWorthAsync.when(
                    data: (data) => _buildGamificationCard(
                      ref.watch(milestonesProvider),
                      ref.watch(achievementsProvider),
                      data.netWorth,
                      currency,
                    ),
                    loading: () => const CardShimmer(height: 100),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // 4. Recent Activity Feed
                  transactionsAsync.when(
                    data: (transactions) => _buildRecentActivityCard(transactions, currency),
                    loading: () => const GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerLoading(width: 140, height: 18, borderRadius: 4),
                          SizedBox(height: 16),
                          ListShimmer(count: 4),
                        ],
                      ),
                    ),
                    error: (e, s) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 90), // Spacing for custom FAB
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Floating Action Button
      floatingActionButton: TactileFAB(
        onTap: () => _openAddTransactionSheet(context),
        icon: Icons.add,
        label: 'Transaction',
      ),
    );
  }

  Widget _buildNetWorthCard(dynamic data, String currency, List<Snapshot> snapshots) {
    // Filter and sort snapshots for correct index mapping
    final now = DateTime.now();
    final List<Snapshot> filtered;
    if (_chartRange == '30D') {
      filtered = snapshots.where((s) => now.difference(s.snapshotDate).inDays <= 30).toList();
    } else if (_chartRange == '90D') {
      filtered = snapshots.where((s) => now.difference(s.snapshotDate).inDays <= 90).toList();
    } else if (_chartRange == '1Y') {
      filtered = snapshots.where((s) => now.difference(s.snapshotDate).inDays <= 365).toList();
    } else {
      filtered = List.from(snapshots);
    }

    final sorted = filtered.length >= 2
        ? (filtered..sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate)))
        : (List<Snapshot>.from(snapshots)..sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate)));

    final hoveredIdx = _hoveredSpot?.x.toInt();
    final Snapshot? hoveredSnapshot = (hoveredIdx != null && hoveredIdx >= 0 && hoveredIdx < sorted.length)
        ? sorted[hoveredIdx]
        : null;

    final double displayNetWorth = hoveredSnapshot != null ? hoveredSnapshot.netWorth : (data.netWorth as double);

    // Calculate growth compared to previous snapshots dynamically
    double growth = 0.0;
    if (snapshots.isNotEmpty) {
      final allSorted = List<Snapshot>.from(snapshots)..sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate));
      final prev = allSorted.last.netWorth;
      if (prev > 0) {
        growth = (((data.netWorth as double) - prev) / prev) * 100;
      }
    }
    
    final isPositive = growth >= 0;
    final growthText = '${isPositive ? '+' : ''}${growth.toStringAsFixed(1)}% this month';
    final growthColor = isPositive ? AppColors.darkSuccess : AppColors.darkDanger;
    final growthIcon = isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    
    return GlassCard(
      isPrimary: true,
      borderColor: hoveredSnapshot != null 
          ? AppColors.darkWarning.withOpacity(0.5)
          : AppColors.darkPrimary.withOpacity(0.35),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background soft orb glow inside card
          Positioned(
            right: -60,
            top: -60,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: hoveredSnapshot != null
                        ? AppColors.darkWarning.withOpacity(0.12)
                        : AppColors.darkPrimary.withOpacity(0.18),
                    blurRadius: 40,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'NET WORTH',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey400,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.push('/definitions'),
                    child: const Icon(Icons.info_outline, size: 14, color: AppColors.grey500),
                  ),
                  const Spacer(),
                  // Live vs Historical Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hoveredSnapshot != null
                          ? AppColors.darkWarning.withOpacity(0.12)
                          : AppColors.darkSuccess.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hoveredSnapshot != null
                            ? AppColors.darkWarning.withOpacity(0.2)
                            : AppColors.darkSuccess.withOpacity(0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: hoveredSnapshot != null ? AppColors.darkWarning : AppColors.darkSuccess,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hoveredSnapshot != null ? 'HISTORICAL' : 'LIVE',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: hoveredSnapshot != null ? AppColors.darkWarning : AppColors.darkSuccess,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Use plain Text if scrubbing (hoveredSnapshot != null) to avoid lagginess, otherwise AnimatedNumberText
              hoveredSnapshot != null
                  ? Text(
                      NumberFormat.currency(symbol: currency, decimalDigits: 0).format(displayNetWorth),
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    )
                  : AnimatedNumberText(
                      value: displayNetWorth,
                      currency: currency,
                      style: GoogleFonts.inter(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: hoveredSnapshot != null
                          ? AppColors.darkWarning.withOpacity(0.12)
                          : growthColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hoveredSnapshot != null
                              ? Icons.history_toggle_off_rounded
                              : growthIcon,
                          size: 14,
                          color: hoveredSnapshot != null ? AppColors.darkWarning : growthColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hoveredSnapshot != null
                              ? 'As of ${DateFormat('dd MMM yyyy').format(hoveredSnapshot.snapshotDate)}'
                              : growthText,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: hoveredSnapshot != null ? AppColors.darkWarning : growthColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.push('/monthly_snapshot'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      backgroundColor: Colors.white.withOpacity(0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: AppColors.glassBorder, width: 1.0),
                      ),
                    ),
                    child: Text(
                      'History',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.glow,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount, String symbol) {
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}L';
    } else {
      final formatter = NumberFormat.decimalPattern();
      return '$symbol${formatter.format(amount.toInt())}';
    }
  }

  Widget _buildGamificationCard(
    AsyncValue<List<Milestone>> milestonesAsync,
    AsyncValue<List<Achievement>> achievementsAsync,
    double currentNW,
    String currency,
  ) {
    return milestonesAsync.when(
      data: (milestones) {
        final sorted = List<Milestone>.from(milestones)
          ..sort((a, b) => a.amount.compareTo(b.amount));
        
        final nextMilestone = sorted.firstWhereOrNull((m) => m.dateAchieved == null);
        
        return achievementsAsync.when(
          data: (achievements) {
            final unlocked = achievements.where((a) => a.unlockedStatus == 1).toList()
              ..sort((a, b) => (b.dateUnlocked ?? DateTime.fromMillisecondsSinceEpoch(0))
                  .compareTo(a.dateUnlocked ?? DateTime.fromMillisecondsSinceEpoch(0)));
            final recentAch = unlocked.firstOrNull;

            double progressPercent = 0.0;
            if (nextMilestone != null && nextMilestone.amount > 0.0) {
              progressPercent = (currentNW / nextMilestone.amount).clamp(0.0, 1.0);
            }

            Color getCatColor(String cat) {
              switch (cat) {
                case 'wealth_building':
                  return const Color(0xFF00E676);
                case 'investment':
                  return const Color(0xFF00B0FF);
                case 'debt_management':
                  return const Color(0xFFE040FB);
                case 'receivables':
                  return const Color(0xFFFF9100);
                case 'consistency':
                  return const Color(0xFFB0BEC5);
                case 'goals':
                  return const Color(0xFFFF1744);
                default:
                  return const Color(0xFFD4AF37);
              }
            }

            final catColor = recentAch != null ? getCatColor(recentAch.category) : const Color(0xFFD4AF37);

            return GlassCard(
              onTap: () => context.push('/achievements'),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEXT MILESTONE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey500,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (nextMilestone != null) ...[
                          Text(
                            _formatAmount(nextMilestone.amount, currency),
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Stack(
                              children: [
                                Container(
                                  height: 4,
                                  color: Colors.white.withOpacity(0.06),
                                ),
                                FractionallySizedBox(
                                  widthFactor: progressPercent,
                                  child: Container(
                                    height: 4,
                                    color: const Color(0xFF00E676),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${(progressPercent * 100).toInt()}% Complete',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey400,
                            ),
                          ),
                        ] else ...[
                          Text(
                            'All Achieved!',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 1,
                    color: Colors.white10,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECENT UNLOCK',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey500,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (recentAch != null) ...[
                          Text(
                            recentAch.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: catColor.withOpacity(0.2), width: 0.8),
                            ),
                            child: Text(
                              recentAch.category.replaceAll('_', ' ').toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'No unlocks yet',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }

  Widget _buildSummaryGrid(dynamic data, String currency, MockDatabaseState dbState) {
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Assets Card
        _buildSummaryCard(
          title: 'ASSETS',
          value: format.format(data.assets),
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.darkSuccess,
          onTap: () {
            context.push('/portfolio');
          },
        ),
        
        // Liabilities Card
        _buildSummaryCard(
          title: 'LIABILITIES',
          value: format.format(data.liabilities),
          icon: Icons.trending_down_outlined,
          color: AppColors.darkDanger,
          onTap: () {
            context.push('/portfolio');
          },
        ),
        
        // Invested Capital Card
        _buildSummaryCard(
          title: 'INVESTED CAPITAL',
          value: format.format(data.investedCapital),
          icon: Icons.trending_up_outlined,
          color: AppColors.darkPrimary,
          onTap: () {
            context.push('/portfolio');
          },
        ),
        
        // Expected Income Card
        _buildSummaryCard(
          title: 'EXPECTED INCOME',
          value: format.format(dbState.totalExpectedIncome),
          icon: Icons.hourglass_empty_rounded,
          color: AppColors.darkWarning,
          onTap: () {
            context.push('/portfolio');
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.grey500),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.grey400,
              letterSpacing: 1.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFundingDebtAnalysisCard(dynamic data, String currency) {
    final double totalAssets = (data.assets as num?)?.toDouble() ?? 0.0;
    final double debtFunded = (data.debtFundedAssets as num?)?.toDouble() ?? 0.0;
    final double selfFunded = (data.selfFundedAssets as num?)?.toDouble() ?? 0.0;
    final double debtPct = totalAssets > 0 ? (debtFunded / totalAssets) * 100 : 0.0;
    final double selfPct = totalAssets > 0 ? (selfFunded / totalAssets) * 100 : 0.0;
    
    final breakdown = data.fundingSourceBreakdown as Map<String, double>;
    
    final sourceNames = {
      'existing_cash': 'Existing Cash',
      'salary_income': 'Salary Income',
      'business_income': 'Business Income',
      'receivable_collected': 'Receivables Collected',
      'liability_borrowed': 'Liability / Borrowed',
      'mixed_sources': 'Mixed Sources',
    };
    
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline_rounded, size: 20, color: AppColors.glow),
              const SizedBox(width: 8),
              Text(
                'Funding & Debt Analysis',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Debt-Funded vs Self-Funded details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELF-FUNDED ASSETS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${format.format(selfFunded)} (${selfPct.toStringAsFixed(1)}%)',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E676),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'DEBT-FUNDED ASSETS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${format.format(debtFunded)} (${debtPct.toStringAsFixed(1)}%)',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkDanger,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar for Ratio
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: totalAssets > 0 ? selfFunded / totalAssets : 1.0,
                backgroundColor: AppColors.darkDanger,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),
          Text(
            'FUNDING SOURCES BREAKDOWN',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          ...breakdown.entries
              .where((entry) => entry.value > 0)
              .map((entry) {
            final name = sourceNames[entry.key] ?? entry.key;
            final val = entry.value;
            final pct = totalAssets > 0 ? (val / totalAssets) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${format.format(val)} (${pct.toStringAsFixed(1)}%)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: totalAssets > 0 ? val / totalAssets : 0.0,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        entry.key == 'liability_borrowed'
                            ? AppColors.darkDanger
                            : entry.key == 'mixed_sources'
                                ? AppColors.darkWarning
                                : AppColors.darkPrimary,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (breakdown.values.every((v) => v == 0))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  'No assets recorded to analyze',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard(List<Snapshot> snapshots, String currency) {
    final now = DateTime.now();
    final List<Snapshot> filtered;
    if (_chartRange == '30D') {
      filtered = snapshots.where((s) => now.difference(s.snapshotDate).inDays <= 30).toList();
    } else if (_chartRange == '90D') {
      filtered = snapshots.where((s) => now.difference(s.snapshotDate).inDays <= 90).toList();
    } else if (_chartRange == '1Y') {
      filtered = snapshots.where((s) => now.difference(s.snapshotDate).inDays <= 365).toList();
    } else {
      filtered = List.from(snapshots);
    }

    final sorted = filtered.length >= 2
        ? (filtered..sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate)))
        : (List<Snapshot>.from(snapshots)..sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate)));

    final List<FlSpot> spots = [];
    final List<String> dates = [];
    
    for (int i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), sorted[i].netWorth));
      dates.add(DateFormat('dd MMM').format(sorted[i].snapshotDate));
    }

    // Compute period difference
    double difference = 0.0;
    double percentage = 0.0;
    if (sorted.length >= 2) {
      final firstVal = sorted.first.netWorth;
      final lastVal = sorted.last.netWorth;
      difference = lastVal - firstVal;
      if (firstVal != 0) {
        percentage = (difference / firstVal.abs()) * 100;
      }
    }

    final hasGrowth = difference >= 0;
    final growthColor = hasGrowth ? AppColors.darkSuccess : AppColors.darkDanger;
    final growthSign = hasGrowth ? '+' : '-';
    final growthIcon = hasGrowth ? Icons.trending_up : Icons.trending_down;

    final formatter = NumberFormat.compact();

    // Calculate period stats
    double peakVal = 0.0;
    double lowestVal = 0.0;
    double averageVal = 0.0;
    final isActualPlaceholder = sorted.length < 2;

    if (!isActualPlaceholder) {
      final netWorths = sorted.map((s) => s.netWorth).toList();
      peakVal = netWorths.reduce((a, b) => a > b ? a : b);
      lowestVal = netWorths.reduce((a, b) => a < b ? a : b);
      averageVal = netWorths.reduce((a, b) => a + b) / netWorths.length;
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Worth Trend',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (sorted.length >= 2) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(growthIcon, size: 12, color: growthColor),
                        const SizedBox(width: 4),
                        Text(
                          '$growthSign$currency${formatter.format(difference.abs())} (${percentage.toStringAsFixed(1)}%)',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: growthColor),
                        ),
                        Text(
                          ' this period',
                          style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              // Filter Range selector
              Row(
                children: ['30D', '90D', '1Y', 'ALL'].map((range) {
                  final isSelected = _chartRange == range;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _chartRange = range;
                        _hoveredSpot = null; // Reset hovered spot when range changes
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.darkPrimary : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        range,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : AppColors.grey400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: NetWorthLineChart(
              spots: spots,
              dates: dates,
              currency: currency,
              onSpotHover: (spot) {
                setState(() {
                  _hoveredSpot = spot;
                });
              },
            ),
          ),
          if (!isActualPlaceholder) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('PEAK NW', peakVal, currency, formatter),
                _buildStatColumn('LOWEST NW', lowestVal, currency, formatter),
                _buildStatColumn('AVERAGE NW', averageVal, currency, formatter),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, double value, String currency, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.grey500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$currency${formatter.format(value)}',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  List<DateTime> _getScheduledDates(Sip sip, DateTime start, DateTime endLimit) {
    final List<DateTime> dates = [];
    final startDay = DateTime(sip.startDate.year, sip.startDate.month, sip.startDate.day);
    DateTime current = DateTime(start.year, start.month, start.day);
    if (current.isBefore(startDay)) {
      current = startDay;
    }
    
    while (current.isBefore(endLimit) || current.isAtSameMomentAs(endLimit)) {
      if (sip.endDate != null && current.isAfter(sip.endDate!)) {
        break;
      }
      
      bool isScheduled = false;
      if (sip.frequency == 'weekly') {
        isScheduled = current.weekday == sip.sipDate;
      } else if (sip.frequency == 'monthly') {
        isScheduled = current.day == sip.sipDate;
      } else if (sip.frequency == 'quarterly') {
        final monthDiff = (current.year - sip.startDate.year) * 12 + (current.month - sip.startDate.month);
        isScheduled = monthDiff % 3 == 0 && current.day == sip.sipDate;
      }
      
      if (isScheduled && (current.isAfter(startDay) || current.isAtSameMomentAs(startDay))) {
        dates.add(current);
      }
      
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  Widget _buildMtfAndSipWidgets(MockDatabaseState dbState) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currency = dbState.currency;

    final activeMtfPositions = dbState.mtfPositions.where((p) => p.isClosed == 0).toList();
    final mtfInterestToday = activeMtfPositions.fold<double>(0.0, (sum, pos) {
      return sum + (pos.borrowedCapital * (pos.interestRate / 100) / 365);
    });

    final mtfInterestThisMonth = dbState.transactions.where((t) =>
        t.type == 'expense' &&
        t.category == 'MTF Interest' &&
        t.transactionDate.year == now.year &&
        t.transactionDate.month == now.month).fold<double>(0.0, (sum, t) => sum + t.amount);

    final activeSips = dbState.sips.where((s) => s.isActive == 1).toList();

    // 1. Upcoming SIPs
    final List<Map<String, dynamic>> upcomingSipsList = [];
    for (final sip in activeSips) {
      final nextDate = _calculateNextSipDate(sip);
      if (sip.endDate == null || !nextDate.isAfter(sip.endDate!)) {
        final inv = dbState.investments.firstWhereOrNull((i) => i.id == sip.investmentId);
        upcomingSipsList.add({
          'sip': sip,
          'date': nextDate,
          'investmentName': inv?.name ?? 'Investment',
          'amount': sip.amount,
        });
      }
    }
    upcomingSipsList.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // 2. Missed SIPs
    final List<Map<String, dynamic>> missedSipsList = [];
    for (final sip in activeSips) {
      final creationDate = sip.worthCreationDate ?? sip.createdAt;
      final checkStartDate = creationDate.isAfter(sip.startDate) ? creationDate : sip.startDate;
      final pastOccurrences = _getScheduledDates(sip, checkStartDate, today.subtract(const Duration(days: 1)));
      for (final occ in pastOccurrences) {
        final hasTx = dbState.transactions.any((t) {
          final isSameInv = t.investmentId == sip.investmentId;
          final diffDays = t.transactionDate.difference(occ).inDays.abs();
          return isSameInv && diffDays <= 2;
        });
        if (!hasTx) {
          final inv = dbState.investments.firstWhereOrNull((i) => i.id == sip.investmentId);
          missedSipsList.add({
            'sip': sip,
            'date': occ,
            'investmentName': inv?.name ?? 'Investment',
            'amount': sip.amount,
          });
        }
      }
    }
    missedSipsList.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MTF & SIP Overview',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            GestureDetector(
              onTap: () {
                context.push('/sip');
              },
              child: Text(
                'SIP Dashboard',
                style: GoogleFonts.inter(
                  color: AppColors.glow,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            // MTF Card
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.percent_rounded, size: 14, color: Colors.purpleAccent),
                      const SizedBox(width: 4),
                      Text('MTF INTEREST TODAY', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.grey500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('$currency${mtfInterestToday.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('This Month: $currency${mtfInterestThisMonth.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500)),
                ],
              ),
            ),
            // Active SIPs Card
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.loop, size: 14, color: Colors.tealAccent),
                      const SizedBox(width: 4),
                      Text('ACTIVE SIPS', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.grey500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${activeSips.length} Active', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(activeSips.isEmpty ? 'Setup recurring' : activeSips.map((s) => dbState.investments.firstWhereOrNull((i) => i.id == s.investmentId)?.name ?? 'Plan').take(2).join(', '), style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Upcoming SIPs Card
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.upcoming, size: 14, color: Color(0xFF00F2FE)),
                      const SizedBox(width: 4),
                      Text('UPCOMING SIPS', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.grey500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${upcomingSipsList.length} Pending', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(upcomingSipsList.isEmpty ? 'No upcoming' : 'Next: ${upcomingSipsList.first['investmentName']}', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            // Missed SIPs Card
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.darkDanger),
                      const SizedBox(width: 4),
                      Text('MISSED SIPS', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.grey500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${missedSipsList.length} Missed', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: missedSipsList.isNotEmpty ? AppColors.darkDanger : AppColors.darkSuccess)),
                  Text(missedSipsList.isEmpty ? 'All paid' : 'Requires action!', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500)),
                ],
              ),
            ),
          ],
        ),
        if (missedSipsList.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'ACTION REQUIRED: MISSED SIPS',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkDanger, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          ...missedSipsList.take(3).map((item) {
            final date = item['date'] as DateTime;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.darkDanger.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline, size: 18, color: AppColors.darkDanger),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['investmentName'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Scheduled: ${DateFormat('dd MMM yyyy').format(date)}', style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(
                      '$currency${(item['amount'] as double).toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(color: AppColors.darkDanger, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
        if (upcomingSipsList.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'UPCOMING OCCURRENCES',
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          ...upcomingSipsList.take(3).map((item) {
            final date = item['date'] as DateTime;
            final days = date.difference(today).inDays;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.darkPrimary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.darkPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['investmentName'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(
                            days == 0 ? 'Due Today' : 'Due in $days days (${DateFormat('dd MMM').format(date)})',
                            style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$currency${(item['amount'] as double).toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  DateTime _calculateNextSipDate(Sip sip) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(sip.startDate.year, sip.startDate.month, sip.startDate.day);

    DateTime candidate;
    if (sip.frequency == 'weekly') {
      int daysUntil = sip.sipDate - today.weekday;
      if (daysUntil < 0) daysUntil += 7;
      candidate = today.add(Duration(days: daysUntil));
    } else if (sip.frequency == 'monthly') {
      candidate = DateTime(today.year, today.month, sip.sipDate);
      if (candidate.isBefore(today)) {
        candidate = DateTime(today.year, today.month + 1, sip.sipDate);
      }
    } else {
      int monthsToAdd = 0;
      while (true) {
        final tempDate = DateTime(sip.startDate.year, sip.startDate.month + monthsToAdd, sip.sipDate);
        if (tempDate.isAfter(today) || tempDate.isAtSameMomentAs(today)) {
          candidate = tempDate;
          break;
        }
        monthsToAdd += 3;
      }
    }

    if (candidate.isBefore(startDay)) {
      candidate = startDay;
    }

    return candidate;
  }

  Widget _buildRecentActivityCard(List<Transaction> transactions, String currency) {
    final recent = transactions.take(4).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  context.go('/transactions');
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    color: AppColors.glow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text('No transactions recorded yet.', style: TextStyle(color: AppColors.grey500)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              itemBuilder: (context, index) {
                final tx = recent[index];
                final isVoided = tx.voidedTransactionId != null || tx.type == 'void';
                final isNegative = ['expense', 'lend_money', 'repay_money', 'investment_buy'].contains(tx.type);
                
                String symbol = isNegative ? '-' : '+';
                Color valueColor = isNegative ? AppColors.darkDanger : AppColors.darkSuccess;
                if (tx.type == 'transfer' || tx.type == 'void') {
                  symbol = '';
                  valueColor = isDark ? Colors.white : AppColors.lightText;
                }
                
                final formattedDate = DateFormat('dd MMM').format(tx.transactionDate);
                final valueText = '$symbol$currency${NumberFormat.decimalPattern().format(tx.amount)}';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: [
                      _getTransactionIcon(tx.type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.notes ?? tx.type.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                color: isVoided ? AppColors.grey500 : Colors.white,
                                decoration: isVoided ? TextDecoration.lineThrough : null,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$formattedDate · ${tx.type.replaceAll('_', ' ').toUpperCase()}',
                              style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            valueText,
                            style: TextStyle(
                              color: isVoided ? AppColors.grey500 : valueColor,
                              decoration: isVoided ? TextDecoration.lineThrough : null,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (isVoided)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.darkDanger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Voided',
                                style: TextStyle(color: AppColors.darkDanger, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
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

  Widget _getTransactionIcon(String type) {
    IconData iconData = Icons.swap_horiz_rounded;
    Color color = AppColors.grey500;
    
    if (['expense', 'investment_buy'].contains(type)) {
      iconData = Icons.arrow_outward_rounded;
      color = AppColors.darkDanger;
    } else if (['income', 'investment_sell'].contains(type)) {
      iconData = Icons.call_received_rounded;
      color = AppColors.darkSuccess;
    } else if (['lend_money', 'repay_money'].contains(type)) {
      iconData = Icons.handshake_rounded;
      color = AppColors.darkWarning;
    } else if (type == 'transfer') {
      iconData = Icons.compare_arrows_rounded;
      color = AppColors.darkPrimary;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}


// Tactile press-scaling Floating Action Button
class TactileFAB extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const TactileFAB({
    required this.onTap,
    required this.label,
    required this.icon,
    super.key,
  });

  @override
  State<TactileFAB> createState() => _TactileFABState();
}

class _TactileFABState extends State<TactileFAB> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [AppColors.darkPrimary, AppColors.glow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkPrimary.withOpacity(0.35),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Constrained Natural Language Dialog
class NaturalLanguageQueryDialog extends ConsumerStatefulWidget {
  const NaturalLanguageQueryDialog({super.key});

  @override
  ConsumerState<NaturalLanguageQueryDialog> createState() => _NaturalLanguageQueryDialogState();
}

class _NaturalLanguageQueryDialogState extends ConsumerState<NaturalLanguageQueryDialog> {
  final _queryController = TextEditingController();
  String _response = '';
  bool _loading = false;

  final List<String> _suggestedQueries = [
    'What is my net worth?',
    'Show my assets',
    'Show my debts',
    'What expected incomes are pending?',
  ];

  void _runQuery(String query) {
    setState(() {
      _queryController.text = query;
      _loading = true;
      _response = '';
    });

    final db = ref.read(mockDatabaseProvider);
    final currency = db.currency;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      
      String res = '';
      final lower = query.toLowerCase();

      if (lower.contains('asset')) {
        res = 'Your total Asset value is $currency${NumberFormat.decimalPattern().format(db.totalAssets)}:\n';
        for (final acc in db.accounts.where((a) => a.isArchived == 0 && a.type != 'credit')) {
          res += '• ${acc.name}: $currency${NumberFormat.decimalPattern().format(db.getAccountCashBalance(acc.id))}\n';
        }
        if (db.investments.isNotEmpty) {
          res += '\nInvestments:\n';
          for (final inv in db.investments.where((i) => i.isArchived == 0)) {
            res += '• ${inv.name}: $currency${NumberFormat.decimalPattern().format(db.getInvestmentMarketValue(inv.id))}\n';
          }
        }
      } else if (lower.contains('liability') || lower.contains('debt') || lower.contains('owe')) {
        res = 'Your total Liability value is $currency${NumberFormat.decimalPattern().format(db.totalLiabilities)}:\n';
        for (final acc in db.accounts.where((a) => a.isArchived == 0 && a.type == 'credit')) {
          res += '• ${acc.name} (Credit Card): $currency${NumberFormat.decimalPattern().format(db.getAccountLiabilityBalance(acc.id))}\n';
        }
        for (final p in db.people.where((p) => p.isArchived == 0 && db.getPersonLiabilityBalance(p.id) > 0)) {
          res += '• ${p.name}: $currency${NumberFormat.decimalPattern().format(db.getPersonLiabilityBalance(p.id))}\n';
        }
      } else if (lower.contains('income') || lower.contains('expected')) {
        final pending = db.expectedIncomes.where((i) => i.status == 'pending').toList();
        if (pending.isEmpty) {
          res = 'You have no pending expected incomes.';
        } else {
          res = 'Pending expected incomes:\n';
          for (final inc in pending) {
            res += '• ${inc.source}: $currency${NumberFormat.decimalPattern().format(inc.amount)} (Expected: ${inc.expectedDate != null ? DateFormat('dd MMM').format(inc.expectedDate!) : 'No Date'})\n';
          }
        }
      } else if (lower.contains('worth') || lower.contains('net')) {
        res = 'Your current calculated Net Worth is $currency${NumberFormat.decimalPattern().format(db.netWorth)}.\n• Assets: $currency${NumberFormat.decimalPattern().format(db.totalAssets)}\n• Liabilities: $currency${NumberFormat.decimalPattern().format(db.totalLiabilities)}';
      } else {
        // Dynamic search for person in people list
        var foundPerson = false;
        for (final p in db.people) {
          if (lower.contains(p.name.toLowerCase())) {
            foundPerson = true;
            final rec = db.getPersonReceivableBalance(p.id);
            final lia = db.getPersonLiabilityBalance(p.id);
            if (rec > 0) {
              res = '${p.name} owes you $currency${NumberFormat.decimalPattern().format(rec)} outstanding.';
            } else if (lia > 0) {
              res = 'You owe ${p.name} $currency${NumberFormat.decimalPattern().format(lia)} outstanding.';
            } else {
              res = '${p.name} has no outstanding balances with you.';
            }
            break;
          }
        }
        if (!foundPerson) {
          res = 'I couldn\'t understand that query. Try asking about "net worth", "assets", "debts", or a specific person\'s name.';
        }
      }

      setState(() {
        _loading = false;
        _response = res;
      });
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.layer1,
      elevation: 24,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: const BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      title: Row(
        children: const [
          Icon(Icons.auto_awesome, color: Colors.amber),
          SizedBox(width: 8),
          Text('Personal AI Query', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text query field
            TextField(
              controller: _queryController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask your personal database...',
                hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.darkPrimary),
                  onPressed: () {
                    if (_queryController.text.trim().isNotEmpty) {
                      _runQuery(_queryController.text.trim());
                    }
                  },
                ),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.glassBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.darkPrimary)),
                filled: true,
                fillColor: AppColors.layer2,
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) _runQuery(val.trim());
              },
            ),
            const SizedBox(height: 16),

            if (_response.isEmpty && !_loading) ...[
              const Text('Suggested queries:', style: TextStyle(color: AppColors.grey500, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _suggestedQueries.map((query) => ActionChip(
                  label: Text(query, style: const TextStyle(fontSize: 11, color: Colors.white)),
                  backgroundColor: AppColors.layer2,
                  side: const BorderSide(color: AppColors.glassBorder),
                  onPressed: () => _runQuery(query),
                )).toList(),
              ),
            ],

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: CircularProgressIndicator(color: AppColors.darkPrimary)),
              ),

            if (_response.isNotEmpty) ...[
              const Text('Response:', style: TextStyle(color: AppColors.grey500, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  _response,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: AppColors.grey500)),
        ),
      ],
    );
  }
}
