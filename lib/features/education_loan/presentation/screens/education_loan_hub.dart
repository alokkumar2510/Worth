import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/education_loan_provider.dart';
import '../../domain/entities/education_loan.dart';
import 'tabs/loan_dashboard_tab.dart';
import 'tabs/loan_timeline_tab.dart';
import 'tabs/disbursement_tracker_tab.dart';
import 'tabs/interest_tracker_tab.dart';
import 'tabs/moratorium_manager_tab.dart';
import 'tabs/emi_simulator_tab.dart';
import 'tabs/prepayment_planner_tab.dart';
import 'tabs/loan_forecast_tab.dart';
import 'tabs/semester_expense_tab.dart';

class EducationLoanHub extends ConsumerStatefulWidget {
  const EducationLoanHub({super.key});

  @override
  ConsumerState<EducationLoanHub> createState() => _EducationLoanHubState();
}

class _EducationLoanHubState extends ConsumerState<EducationLoanHub>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    ('Dashboard', Icons.dashboard_outlined),
    ('Timeline', Icons.timeline_outlined),
    ('Funds', Icons.account_balance_outlined),
    ('Interest', Icons.trending_up_outlined),
    ('Moratorium', Icons.hourglass_empty_outlined),
    ('EMI Sim', Icons.calculate_outlined),
    ('Prepay', Icons.flash_on_outlined),
    ('Forecast', Icons.bar_chart_outlined),
    ('Semesters', Icons.school_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loanState = ref.watch(educationLoanProvider);

    if (loanState.loan == null) {
      return _buildNoLoanScreen(context);
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(loanState.loan!),
          _buildTabBar(innerBoxIsScrolled),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            const LoanDashboardTab(),
            const LoanTimelineTab(),
            const DisbursementTrackerTab(),
            const InterestTrackerTab(),
            const MoratoriumManagerTab(),
            const EmiSimulatorTab(),
            const PrepaymentPlannerTab(),
            const LoanForecastTab(),
            const SemesterExpenseTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(EducationLoan loan) {
    return SliverAppBar(
      backgroundColor: AppColors.darkBackground,
      expandedHeight: 160,
      floating: false,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.darkPrimary, size: 20),
          onPressed: () => _showEditLoanSheet(context, loan),
          tooltip: 'Edit Loan',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 64, bottom: 70),
        title: Text(
          'Education Loan',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: _buildHeroBackground(loan),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildHeroBackground(EducationLoan loan) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0EA5E9).withOpacity(0.15),
            AppColors.darkPrimary.withOpacity(0.10),
            AppColors.darkBackground,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0EA5E9).withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.3)),
                  ),
                  child: Text(
                    loan.status.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0EA5E9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.glassSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    loan.lenderName,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverPersistentHeader _buildTabBar(bool innerBoxIsScrolled) {
    return SliverPersistentHeader(
      delegate: _TabBarDelegate(
        tabBar: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          labelColor: const Color(0xFF0EA5E9),
          unselectedLabelColor: AppColors.grey500,
          indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
          labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          tabs: _tabs
              .map((t) => Tab(
                    height: 44,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(t.$2, size: 14),
                        const SizedBox(width: 5),
                        Text(t.$1),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildNoLoanScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Education Loan Center',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0EA5E9).withOpacity(0.10),
                  border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 48,
                  color: Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Education Loan Center',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Track your entire education loan lifecycle — from disbursements to final closure. Simulate EMIs, plan prepayments, and forecast your debt-free date.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.grey400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkSuccess.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkSuccess.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.darkSuccess),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Completely isolated — never affects your Net Worth or Portfolio',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.darkSuccess,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () => context.push('/settings/education_loan/setup'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    'Set Up My Education Loan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditLoanSheet(BuildContext context, EducationLoan loan) {
    context.push('/settings/education_loan/setup', extra: loan);
  }
}

// ----------------------------------------------------------
// Tab bar sticky delegate
// ----------------------------------------------------------
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.darkBackground,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => tabBar != oldDelegate.tabBar;
}
