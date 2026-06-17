import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/providers/dependency_provider.dart';
import '../providers/achievements_provider.dart';
import '../widgets/crystal_badge.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/achievement_progress.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  void _showAddMilestoneDialog() {
    final currency = ref.read(mockDatabaseProvider).currency;
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F0F15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: Text(
            'Add Custom Milestone',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set a custom target wealth milestone to celebrate.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(color: Colors.white),
                  decoration: InputDecoration(
                    prefixText: '$currency ',
                    prefixStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                    labelText: 'Milestone Amount',
                    labelStyle: GoogleFonts.inter(color: AppColors.grey500),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.darkPrimary),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: AppColors.grey500),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final amount = double.parse(textController.text);
                  Navigator.of(context).pop();
                  await ref.read(mockDatabaseProvider.notifier).addManualMilestone(amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Milestone of $currency${amount.toInt()} added successfully.'),
                      backgroundColor: const Color(0xFF1E1E2C),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Add Milestone',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final milestonesAsync = ref.watch(milestonesProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final progressAsync = ref.watch(achievementProgressProvider);
    final netWorthAsync = ref.watch(netWorthProvider);
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
        title: Text(
          'Wealth Intelligence',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkPrimary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.grey500,
          labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Milestones'),
            Tab(text: 'Achievements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ------------------ TAB 1: MILESTONES ------------------
          milestonesAsync.when(
            data: (milestones) {
              // Sort milestones by amount
              final sorted = List<Milestone>.from(milestones)
                ..sort((a, b) => a.amount.compareTo(b.amount));

              final currentNW = netWorthAsync.valueOrNull?.netWorth ?? 0.0;

              // Find next upcoming milestone
              final nextMilestone = sorted.firstWhereOrNull((m) => m.dateAchieved == null);
              double nextTarget = nextMilestone?.amount ?? 0.0;
              double progressPercent = 0.0;
              if (nextTarget > 0.0) {
                progressPercent = (currentNW / nextTarget).clamp(0.0, 1.0);
              }

              return Column(
                children: [
                  // Next Milestone Hero Header Card
                  if (nextMilestone != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GlassCard(
                        isPrimary: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkPrimary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${(progressPercent * 100).toInt()}% Complete',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _formatAmount(nextMilestone.amount, currency),
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Custom Elegant Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    color: Colors.white.withOpacity(0.06),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: progressPercent,
                                    child: Container(
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF00E676),
                                            AppColors.darkPrimary,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Current net worth: ${_formatAmount(currentNW, currency)}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Actions Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Milestone Timeline',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showAddMilestoneDialog,
                          icon: const Icon(Icons.add, size: 16, color: AppColors.darkPrimary),
                          label: Text(
                            'Add Custom',
                            style: GoogleFonts.inter(
                              color: AppColors.darkPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Timeline
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final milestone = sorted[index];
                        final isAchieved = milestone.dateAchieved != null;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Timeline vertical line with nodes
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Column(
                                  children: [
                                    // Node indicator
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isAchieved
                                            ? const Color(0xFFD4AF37)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isAchieved
                                              ? const Color(0xFFD4AF37)
                                              : Colors.white12,
                                          width: 2.0,
                                        ),
                                        boxShadow: isAchieved
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                                                  blurRadius: 8,
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: isAchieved
                                          ? const Icon(Icons.check, size: 10, color: Colors.black)
                                          : null,
                                    ),
                                    // Vertical line (only if not the last item)
                                    if (index != sorted.length - 1)
                                      Expanded(
                                        child: Container(
                                          width: 1.5,
                                          color: isAchieved
                                              ? const Color(0xFFD4AF37).withOpacity(0.3)
                                              : Colors.white10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // Milestone Card
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Left: Crystal icon
                                        CrystalBadge(
                                          color: isAchieved ? const Color(0xFFD4AF37) : Colors.white24,
                                          progress: isAchieved ? 1.0 : (currentNW / milestone.amount).clamp(0.05, 0.95),
                                          isUnlocked: isAchieved,
                                          size: 48,
                                          category: 'wealth_building',
                                        ),
                                        const SizedBox(width: 16),
                                        // Right: Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    _formatAmount(milestone.amount, currency),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: isAchieved ? Colors.white : Colors.white38,
                                                    ),
                                                  ),
                                                  if (milestone.isManual == 1)
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 8),
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.05),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        'Custom',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 8,
                                                          color: Colors.white60,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                isAchieved
                                                    ? 'Achieved ${DateFormat('d MMM yyyy').format(milestone.dateAchieved!)}'
                                                    : 'Upcoming milestone target',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: isAchieved ? AppColors.grey400 : AppColors.grey500,
                                                ),
                                              ),
                                              if (isAchieved && milestone.daysSincePrevious != null && milestone.daysSincePrevious! > 0) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${milestone.daysSincePrevious} days since previous milestone',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    color: const Color(0xFF00E676).withOpacity(0.7),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ]
                                            ],
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
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading milestones: $err', style: const TextStyle(color: Colors.white))),
          ),

          // ------------------ TAB 2: ACHIEVEMENTS ------------------
          achievementsAsync.when(
            data: (achievements) {
              final progress = progressAsync.valueOrNull ?? [];

              // Group achievements by category
              final categories = {
                'wealth_building': <Achievement>[],
                'investment': <Achievement>[],
                'debt_management': <Achievement>[],
                'receivables': <Achievement>[],
                'consistency': <Achievement>[],
                'goals': <Achievement>[],
              };

              for (final ach in achievements) {
                if (categories.containsKey(ach.category)) {
                  categories[ach.category]!.add(ach);
                }
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

              String getCatTitle(String cat) {
                switch (cat) {
                  case 'wealth_building':
                    return 'Wealth Building';
                  case 'investment':
                    return 'Investments';
                  case 'debt_management':
                    return 'Debt Management';
                  case 'receivables':
                    return 'Receivables';
                  case 'consistency':
                    return 'Consistency';
                  case 'goals':
                    return 'Goals';
                  default:
                    return 'Achievements';
                }
              }

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                children: categories.entries.map((entry) {
                  final catKey = entry.key;
                  final catList = entry.value;
                  final catColor = getCatColor(catKey);
                  final catTitle = getCatTitle(catKey);

                  if (catList.isEmpty) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 12.0),
                        child: Text(
                          catTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...catList.map((ach) {
                        final isUnlocked = ach.unlockedStatus == 1;
                        final progRow = progress.firstWhereOrNull((p) => p.achievementId == ach.id);

                        double progressRatio = isUnlocked ? 1.0 : 0.05;
                        if (!isUnlocked && progRow != null && progRow.targetValue > 0.0) {
                          progressRatio = (progRow.currentValue / progRow.targetValue).clamp(0.05, 0.95);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GlassCard(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                // Left: Badge CustomPainter
                                CrystalBadge(
                                  color: isUnlocked ? catColor : Colors.white12,
                                  progress: progressRatio,
                                  isUnlocked: isUnlocked,
                                  size: 50.0,
                                  category: catKey,
                                ),
                                const SizedBox(width: 16),
                                // Right: Text details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ach.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? Colors.white : Colors.white38,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ach.description,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: isUnlocked ? AppColors.grey400 : AppColors.grey500,
                                          height: 1.3,
                                        ),
                                      ),
                                      // If locked and has progress row, show slim slider
                                      if (!isUnlocked && progRow != null && progRow.targetValue > 1.0) ...[
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(2),
                                                child: Stack(
                                                  children: [
                                                    Container(height: 3, color: Colors.white.withOpacity(0.05)),
                                                    FractionallySizedBox(
                                                      widthFactor: progressRatio,
                                                      child: Container(height: 3, color: catColor.withOpacity(0.4)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${progRow.currentValue.toInt()}/${progRow.targetValue.toInt()}',
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.grey500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      // If unlocked, show date
                                      if (isUnlocked && ach.dateUnlocked != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          'Unlocked ${DateFormat('d MMM yyyy').format(ach.dateUnlocked!)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: catColor.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading achievements: $err', style: const TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }
}
