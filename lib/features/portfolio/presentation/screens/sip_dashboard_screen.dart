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
import '../../../../features/investments/domain/entities/sip.dart' as domain;
import '../../../../database/database.dart';

class SipDashboardScreen extends ConsumerStatefulWidget {
  const SipDashboardScreen({super.key});

  @override
  ConsumerState<SipDashboardScreen> createState() => _SipDashboardScreenState();
}

class _SipDashboardScreenState extends ConsumerState<SipDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilterIndex = 0; // 0 = Active, 1 = Paused, 2 = Completed

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

  // Generate occurrences from startDate to today + 30 days
  List<SipOccurrence> _generateOccurrences(domain.Sip sip, List<Transaction> transactions, DateTime today) {
    final List<SipOccurrence> list = [];
    DateTime current = DateTime(sip.startDate.year, sip.startDate.month, sip.startDate.day);
    final end = sip.endDate != null && sip.endDate!.isBefore(today.add(const Duration(days: 30)))
        ? DateTime(sip.endDate!.year, sip.endDate!.month, sip.endDate!.day)
        : today.add(const Duration(days: 30));

    // Safety check: don't loop endlessly if start date is in the future
    if (current.isAfter(end)) {
      list.add(SipOccurrence(
        date: current,
        isCompleted: false,
        isMissed: false,
        isUpcoming: true,
      ));
      return list;
    }

    int loops = 0;
    while ((current.isBefore(end) || current.isAtSameMomentAs(end)) && loops < 500) {
      loops++;
      bool matches = false;
      if (sip.frequency == 'weekly') {
        if (current.weekday == sip.sipDate) {
          matches = true;
        }
      } else if (sip.frequency == 'monthly') {
        final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
        final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
        if (current.day == targetDay) {
          matches = true;
        }
      } else if (sip.frequency == 'quarterly') {
        final monthDiff = current.month - sip.startDate.month;
        if (monthDiff % 3 == 0) {
          final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
          final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
          if (current.day == targetDay) {
            matches = true;
          }
        }
      }

      if (matches) {
        final isCompleted = transactions.any((t) =>
            t.type == 'investment_buy' &&
            t.investmentId == sip.investmentId &&
            t.notes != null &&
            t.notes!.contains('SIP ID: ${sip.id}') &&
            t.transactionDate.year == current.year &&
            t.transactionDate.month == current.month &&
            t.transactionDate.day == current.day);

        final isUpcoming = current.isAfter(today) || (current.isAtSameMomentAs(today) && !isCompleted);
        final isMissed = current.isBefore(today) && !isCompleted;

        list.add(SipOccurrence(
          date: current,
          isCompleted: isCompleted,
          isMissed: isMissed,
          isUpcoming: isUpcoming,
        ));
      }

      current = current.add(const Duration(days: 1));
    }

    // If no upcoming date was generated (e.g. weekly start date falls outside the window), generate the next logical occurrence
    if (list.where((o) => o.isUpcoming).isEmpty) {
      DateTime nextOcc = DateTime(today.year, today.month, today.day);
      int attempts = 0;
      while (attempts < 100) {
        attempts++;
        bool matches = false;
        if (sip.frequency == 'weekly') {
          if (nextOcc.weekday == sip.sipDate) matches = true;
        } else if (sip.frequency == 'monthly') {
          final daysInMonth = DateTime(nextOcc.year, nextOcc.month + 1, 0).day;
          final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
          if (nextOcc.day == targetDay) matches = true;
        } else if (sip.frequency == 'quarterly') {
          final monthDiff = nextOcc.month - sip.startDate.month;
          if (monthDiff % 3 == 0) {
            final daysInMonth = DateTime(nextOcc.year, nextOcc.month + 1, 0).day;
            final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
            if (nextOcc.day == targetDay) matches = true;
          }
        }
        if (matches && nextOcc.isAfter(today)) {
          list.add(SipOccurrence(
            date: nextOcc,
            isCompleted: false,
            isMissed: false,
            isUpcoming: true,
          ));
          break;
        }
        nextOcc = nextOcc.add(const Duration(days: 1));
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final sipsAsync = ref.watch(activeSipsProvider);
    final transactions = dbState.transactions;
    final investments = dbState.investments;
    final currency = dbState.currency;

    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return Scaffold(
      appBar: AppBar(
        title: Text('SIP Automation', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.amber),
            tooltip: 'Run SIP Scheduler Now',
            onPressed: () async {
              await ref.read(mockDatabaseProvider.notifier).runAutoSipProcessing();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recurring SIP scheduler triggered and executed.')),
                );
              }
            },
          ),
        ],
      ),
      body: sipsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading SIPs: $err', style: const TextStyle(color: Colors.white))),
        data: (sips) {
          // Pre-calculate occurrences and stats
          double totalInvested = 0.0;
          double totalCostBasis = 0.0;
          double totalCurrentValue = 0.0;
          double monthlyContribution = 0.0;
          int totalPastOccurrences = 0;
          int completedOccurrences = 0;

          final List<CalendarItem> calendarItems = [];

          for (final sip in sips) {
            final investment = investments.firstWhereOrNull((i) => i.id == sip.investmentId);
            if (investment == null) continue;

            final occurrences = _generateOccurrences(sip, transactions, today);
            
            // Stats from occurrences
            for (final occ in occurrences) {
              if (occ.date.isBefore(today) || (occ.date.isAtSameMomentAs(today) && occ.isCompleted)) {
                totalPastOccurrences++;
                if (occ.isCompleted) {
                  completedOccurrences++;
                }
              }
              if (occ.isUpcoming && sip.isActive == 1) {
                calendarItems.add(CalendarItem(
                  date: occ.date,
                  sip: sip,
                  investmentName: investment.name,
                ));
              }
            }

            // Transactions linked to this SIP
            final sipTxs = transactions.where((t) =>
                t.type == 'investment_buy' &&
                t.investmentId == sip.investmentId &&
                t.notes != null &&
                t.notes!.contains('SIP ID: ${sip.id}') &&
                t.voidedTransactionId == null);

            final double investedAmt = sipTxs.fold(0.0, (sum, t) => sum + t.amount);
            final double unitsBought = sipTxs.fold(0.0, (sum, t) => sum + (t.units ?? 0.0));

            totalInvested += investedAmt;
            totalCostBasis += investedAmt;
            totalCurrentValue += unitsBought * (investment.marketValue ?? 1.0);

            // Monthly commitments
            if (sip.isActive == 1) {
              if (sip.frequency == 'weekly') {
                monthlyContribution += sip.amount * 4.33;
              } else if (sip.frequency == 'monthly') {
                monthlyContribution += sip.amount;
              } else if (sip.frequency == 'quarterly') {
                monthlyContribution += sip.amount / 3.0;
              }
            }
          }

          final double growth = totalCurrentValue - totalCostBasis;
          final double growthPercent = totalCostBasis > 0 ? (growth / totalCostBasis) * 100 : 0.0;
          final double consistency = totalPastOccurrences > 0 ? (completedOccurrences / totalPastOccurrences) * 100 : 100.0;

          // Group calendar items by date and sort
          calendarItems.sort((a, b) => a.date.compareTo(b.date));
          final groupedCalendar = groupBy(calendarItems, (CalendarItem item) => item.date);

          // Categorize sips
          final activeSips = sips.where((s) => s.isActive == 1 && (s.endDate == null || s.endDate!.isAfter(today))).toList();
          final pausedSips = sips.where((s) => s.isActive == 0 && (s.endDate == null || s.endDate!.isAfter(today))).toList();
          final completedSips = sips.where((s) => s.endDate != null && s.endDate!.isBefore(today)).toList();

          final List<domain.Sip> currentFilteredList;
          if (_selectedFilterIndex == 0) {
            currentFilteredList = activeSips;
          } else if (_selectedFilterIndex == 1) {
            currentFilteredList = pausedSips;
          } else {
            currentFilteredList = completedSips;
          }

          final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Analytics Cards Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildAnalyticCard(
                        'MONTHLY BUDGET',
                        format.format(monthlyContribution),
                        AppColors.darkPrimary,
                      ),
                      _buildAnalyticCard(
                        'TOTAL INVESTED',
                        format.format(totalInvested),
                        Colors.white,
                      ),
                      _buildAnalyticCard(
                        'SIP GROWTH',
                        '${growth >= 0 ? '+' : ''}${format.format(growth)} (${growthPercent.toStringAsFixed(1)}%)',
                        growth >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                      ),
                      _buildAnalyticCard(
                        'CONSISTENCY RATE',
                        '${consistency.toStringAsFixed(0)}%',
                        consistency >= 80 ? AppColors.darkSuccess : (consistency >= 50 ? Colors.orange : AppColors.darkDanger),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.layer1,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.darkPrimary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.grey500,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: 'Schedules'),
                      Tab(text: 'Calendar'),
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Schedules Tab
                      Column(
                        children: [
                          // Filters
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                _buildFilterButton('Active', activeSips.length, 0),
                                const SizedBox(width: 8),
                                _buildFilterButton('Paused', pausedSips.length, 1),
                                const SizedBox(width: 8),
                                _buildFilterButton('Completed', completedSips.length, 2),
                              ],
                            ),
                          ),
                          Expanded(
                            child: currentFilteredList.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.autorenew, size: 48, color: AppColors.grey500.withOpacity(0.5)),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No ${_selectedFilterIndex == 0 ? "active" : _selectedFilterIndex == 1 ? "paused" : "completed"} SIP plans.',
                                          style: const TextStyle(color: AppColors.grey500),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: currentFilteredList.length,
                                    itemBuilder: (context, index) {
                                      final sip = currentFilteredList[index];
                                      final investment = investments.firstWhereOrNull((i) => i.id == sip.investmentId);
                                      final invName = investment?.name ?? 'Investment';
                                      
                                      final frequencyLabel = sip.frequency.substring(0, 1).toUpperCase() + sip.frequency.substring(1);
                                      String dateLabel = '';
                                      if (sip.frequency == 'weekly') {
                                        final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                                        dateLabel = days[sip.sipDate - 1];
                                      } else {
                                        dateLabel = 'Day ${sip.sipDate}';
                                      }

                                      // Calculate statistics for this specific SIP
                                      final sipTxs = transactions.where((t) =>
                                          t.type == 'investment_buy' &&
                                          t.investmentId == sip.investmentId &&
                                          t.notes != null &&
                                          t.notes!.contains('SIP ID: ${sip.id}') &&
                                          t.voidedTransactionId == null);
                                      final double invested = sipTxs.fold(0.0, (sum, t) => sum + t.amount);
                                      
                                      // Calculate days remaining
                                      DateTime? nextDate;
                                      int? daysRemaining;
                                      final occs = _generateOccurrences(sip, transactions, today);
                                      final nextOcc = occs.firstWhereOrNull((o) => o.isUpcoming);
                                      if (nextOcc != null) {
                                        nextDate = nextOcc.date;
                                        daysRemaining = nextOcc.date.difference(today).inDays;
                                      }

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(16),
                                          onTap: () => context.push('/portfolio/investment/${sip.investmentId}'),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      invName,
                                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    format.format(sip.amount),
                                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.darkPrimary, fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '$frequencyLabel · $dateLabel',
                                                    style: const TextStyle(color: AppColors.grey500, fontSize: 12),
                                                  ),
                                                  Text(
                                                    'Invested: ${format.format(invested)}',
                                                    style: const TextStyle(color: AppColors.grey500, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              const Divider(color: AppColors.glassBorder, height: 16),
                                              Row(
                                                children: [
                                                  Icon(
                                                    sip.autoCreate == 1 ? Icons.bolt : Icons.notifications_none,
                                                    size: 14,
                                                    color: AppColors.grey500,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    sip.autoCreate == 1 ? 'Auto-Invest' : 'Reminder Only',
                                                    style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                                                  ),
                                                  const Spacer(),
                                                  if (nextDate != null && sip.isActive == 1)
                                                    Text(
                                                      daysRemaining == 0
                                                          ? 'Due Today!'
                                                          : (daysRemaining == 1 ? 'Due Tomorrow' : 'Due in $daysRemaining days'),
                                                      style: TextStyle(
                                                        color: daysRemaining == 0
                                                            ? AppColors.darkDanger
                                                            : (daysRemaining == 1 ? Colors.orange : AppColors.darkSuccess),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),

                      // Calendar Tab
                      groupedCalendar.isEmpty
                          ? const Center(
                              child: Text('No upcoming scheduled SIP payments.', style: TextStyle(color: AppColors.grey500)),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              itemCount: groupedCalendar.keys.length,
                              itemBuilder: (context, index) {
                                final date = groupedCalendar.keys.elementAt(index);
                                final items = groupedCalendar[date]!;
                                final daysRemaining = date.difference(today).inDays;
                                final formattedDate = DateFormat('EE, dd MMM yyyy').format(date);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formattedDate,
                                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                            ),
                                            Text(
                                              daysRemaining == 0
                                                  ? 'TODAY'
                                                  : (daysRemaining == 1 ? 'TOMORROW' : 'IN $daysRemaining DAYS'),
                                              style: TextStyle(
                                                color: daysRemaining == 0
                                                    ? AppColors.darkDanger
                                                    : (daysRemaining == 1 ? Colors.orange : AppColors.darkSuccess),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ...items.map((item) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 6),
                                          child: GlassCard(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            onTap: () => context.push('/portfolio/investment/${item.sip.investmentId}'),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.investmentName,
                                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Frequency: ${item.sip.frequency.toUpperCase()}',
                                                        style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      format.format(item.sip.amount),
                                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.darkPrimary, fontSize: 14),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      item.sip.autoCreate == 1 ? 'Auto-Invest' : 'Manual Remind',
                                                      style: const TextStyle(color: AppColors.grey500, fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalyticCard(String title, String val, Color highlightColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: highlightColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, int count, int index) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkPrimary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkPrimary.withOpacity(0.3) : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.grey500,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                color: isSelected ? AppColors.darkPrimary : AppColors.grey500,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SipOccurrence {
  final DateTime date;
  final bool isCompleted;
  final bool isMissed;
  final bool isUpcoming;

  SipOccurrence({
    required this.date,
    required this.isCompleted,
    required this.isMissed,
    required this.isUpcoming,
  });
}

class CalendarItem {
  final DateTime date;
  final domain.Sip sip;
  final String investmentName;

  CalendarItem({
    required this.date,
    required this.sip,
    required this.investmentName,
  });
}
