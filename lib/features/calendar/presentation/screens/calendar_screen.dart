import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/services/calendar_engine.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _selectedView = 'Month'; // Month | Week | Agenda | Timeline | Load
  String _searchQuery = '';
  String _selectedCategoryFilter = 'All';
  String _upcomingRange = '30 Days'; // 7 Days | 30 Days | This Month | Next Month

  // Text Controllers for Search and Event Creation
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper: Event color mapping
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Income':
        return AppColors.darkSuccess;
      case 'Investment':
        return AppColors.darkPrimary;
      case 'Liability':
        return AppColors.darkDanger;
      case 'Receivables':
        return const Color(0xFF3B82F6); // Blue
      case 'Goals':
        return AppColors.darkWarning; // Gold
      case 'IPO':
        return const Color(0xFFF97316); // Orange
      case 'Subscription':
        return const Color(0xFF6366F1); // Indigo
      case 'Insurance':
        return const Color(0xFF14B8A6); // Teal
      default:
        return AppColors.grey500;
    }
  }

  // Compile and filter events
  List<CalendarEvent> _getFilteredEvents(MockDatabaseState dbState) {
    // Generate events within a window around selected month to keep it optimized
    final startRange = _selectedMonth.subtract(const Duration(days: 90));
    final endRange = _selectedMonth.add(const Duration(days: 450));

    final rawEvents = CalendarEngine.compileAllEvents(
      dbState: dbState,
      startRange: startRange,
      endRange: endRange,
    );

    return rawEvents.where((e) {
      // Category filter
      if (_selectedCategoryFilter != 'All' && e.category != _selectedCategoryFilter) {
        return false;
      }

      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = e.title.toLowerCase().contains(query);
        final matchesNotes = (e.notes ?? '').toLowerCase().contains(query);
        final matchesCategory = e.category.toLowerCase().contains(query);
        final matchesAmount = e.amount.toString().contains(query);
        if (!matchesTitle && !matchesNotes && !matchesCategory && !matchesAmount) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // Switch month helper
  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset, 1);
      _selectedDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    });
  }

  // Build grid of days in selected month
  List<DateTime> _buildMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysCount = DateTime(month.year, month.month + 1, 0).day;

    final List<DateTime> days = [];

    // Pad previous month days to align Monday as first column
    // Mon=1, Sun=7. Padding count = firstDay.weekday - 1
    final int paddingCount = firstDay.weekday - 1;
    final prevMonthEnd = DateTime(month.year, month.month, 0);
    for (int i = paddingCount - 1; i >= 0; i--) {
      days.add(DateTime(prevMonthEnd.year, prevMonthEnd.month, prevMonthEnd.day - i));
    }

    // Current month days
    for (int i = 1; i <= daysCount; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // Pad next month days to complete last week row
    final totalCells = ((days.length / 7).ceil() * 7);
    final nextMonthPadCount = totalCells - days.length;
    for (int i = 1; i <= nextMonthPadCount; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;
    final allCompiledEvents = _getFilteredEvents(dbState);

    // Filter events for selected day (Month / Week View detail listings)
    final selectedDayEvents = allCompiledEvents.where((e) =>
        e.date.year == _selectedDay.year &&
        e.date.month == _selectedDay.month &&
        e.date.day == _selectedDay.day).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/portfolio'),
        ),
        title: Text(
          'Financial Calendar',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_outlined, color: Colors.white),
            onPressed: _showNotificationSettingsSheet,
            tooltip: 'Notification Config',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mesh_gradient_2.png'),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: Column(
          children: [
            // 1. Search Bar and Filter Pills
            _buildSearchAndFilters(),

            // 2. Insights Card (Cash Flow Scheduled Summary)
            _buildInsightsCard(allCompiledEvents, currency),

            // 3. View Switcher Tabs (Month, Week, Agenda, Timeline, Load)
            _buildViewTabs(),

            const SizedBox(height: 8),

            // 4. Calendar View Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSelectedView(dbState, allCompiledEvents, selectedDayEvents, currency),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkPrimary,
        onPressed: () => _showAddEventSheet(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // --- Search & Filters Widget ---
  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Search TextField
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.layer1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey700.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search calendar events...',
                hintStyle: GoogleFonts.inter(color: AppColors.grey500, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey500, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.grey500, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Horizontal Category Filter Pills
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                'All',
                'Income',
                'Investment',
                'Liability',
                'Receivables',
                'Goals',
                'IPO',
                'Subscription',
                'Insurance',
                'Manual'
              ].map((category) {
                final isSelected = _selectedCategoryFilter == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryFilter = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.darkPrimary : AppColors.layer1,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppColors.grey700.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.white : AppColors.grey400,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- Insights Panel Card ---
  Widget _buildInsightsCard(List<CalendarEvent> events, String currency) {
    // We compute insights based on the selected month range
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    final monthEvents = events.where((e) =>
        e.date.isAfter(firstDayOfMonth.subtract(const Duration(seconds: 1))) &&
        e.date.isBefore(lastDayOfMonth.add(const Duration(seconds: 1)))).toList();

    final insights = CalendarEngine.calculateInsights(monthEvents);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CASH FLOW INSIGHTS',
                  style: GoogleFonts.outfit(
                    color: AppColors.glow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightColumn(
                    'Expected Income',
                    '$currency${NumberFormat.decimalPattern().format(insights.expectedIncome.toInt())}',
                    AppColors.darkSuccess,
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.grey700.withOpacity(0.5)),
                Expanded(
                  child: _buildInsightColumn(
                    'Expected Outflow',
                    '$currency${NumberFormat.decimalPattern().format(insights.expectedOutflow.toInt())}',
                    AppColors.darkDanger,
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.grey700.withOpacity(0.5)),
                Expanded(
                  child: _buildInsightColumn(
                    'Net Cash Flow',
                    '${insights.netCashFlow >= 0 ? "+" : ""}$currency${NumberFormat.decimalPattern().format(insights.netCashFlow.toInt())}',
                    insights.netCashFlow >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // --- View Switcher Tabs ---
  Widget _buildViewTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.layer1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: ['Month', 'Week', 'Agenda', 'Timeline', 'Load'].map((view) {
            final isSelected = _selectedView == view;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedView = view),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    view == 'Load' ? 'Obligations' : view,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : AppColors.grey400,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Selected View Switcher ---
  Widget _buildSelectedView(
    MockDatabaseState dbState,
    List<CalendarEvent> allEvents,
    List<CalendarEvent> dayEvents,
    String currency,
  ) {
    switch (_selectedView) {
      case 'Month':
        return _buildMonthView(allEvents, dayEvents, currency);
      case 'Week':
        return _buildWeekView(allEvents, dayEvents, currency);
      case 'Agenda':
        return _buildAgendaView(allEvents, currency);
      case 'Timeline':
        return _buildTimelineView(allEvents, currency);
      case 'Load':
        return _buildLoadAnalysisView(allEvents, currency);
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // VIEW: Month View Layout
  // ==========================================
  Widget _buildMonthView(
    List<CalendarEvent> allEvents,
    List<CalendarEvent> dayEvents,
    String currency,
  ) {
    final days = _buildMonthDays(_selectedMonth);
    final weekdayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Selector Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white),
              onPressed: () => _changeMonth(-1),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              onPressed: () => _changeMonth(1),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Weekday initials
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdayHeaders.map((h) => Expanded(
            child: Center(
              child: Text(
                h,
                style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),

        // Grid of Days
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final isSelected = _selectedDay.year == day.year &&
                _selectedDay.month == day.month &&
                _selectedDay.day == day.day;
            final isCurrentMonth = day.month == _selectedMonth.month;

            // Events on this specific day
            final dayEvs = allEvents.where((e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day).toList();

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.darkPrimary.withOpacity(0.3) 
                      : (isCurrentMonth ? AppColors.layer1 : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.darkPrimary 
                        : (isCurrentMonth ? AppColors.grey700.withOpacity(0.2) : Colors.transparent),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day.day.toString(),
                      style: GoogleFonts.outfit(
                        color: isSelected 
                            ? Colors.white 
                            : (isCurrentMonth ? Colors.white.withOpacity(0.8) : AppColors.grey500),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (dayEvs.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: dayEvs.take(4).map((e) {
                          return Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1.0),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(e.category),
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        // Day Events Listing Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Agenda: ${DateFormat('dd MMMM').format(_selectedDay)}',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            Text(
              '${dayEvents.length} events',
              style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Events List for selected day
        _buildEventsList(dayEvents, currency),
      ],
    );
  }

  // ==========================================
  // VIEW: Week View Layout
  // ==========================================
  Widget _buildWeekView(
    List<CalendarEvent> allEvents,
    List<CalendarEvent> dayEvents,
    String currency,
  ) {
    // Generate the week range containing the selected day
    final firstDayOfWeek = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final List<DateTime> weekDays = List.generate(7, (i) => firstDayOfWeek.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week horizontal scrolling selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Week Range',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.grey500),
            ),
            Text(
              '${DateFormat('dd MMM').format(weekDays.first)} - ${DateFormat('dd MMM yyyy').format(weekDays.last)}',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays.map((day) {
            final isSelected = day.year == _selectedDay.year &&
                day.month == _selectedDay.month &&
                day.day == _selectedDay.day;
            final isToday = day.year == DateTime.now().year &&
                day.month == DateTime.now().month &&
                day.day == DateTime.now().day;

            final dayEvs = allEvents.where((e) =>
                e.date.year == day.year &&
                e.date.month == day.month &&
                e.date.day == day.day).toList();

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.darkPrimary 
                        : (isToday ? AppColors.darkPrimary.withOpacity(0.15) : AppColors.layer1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent 
                          : (isToday ? AppColors.darkPrimary.withOpacity(0.4) : AppColors.grey700.withOpacity(0.2)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('E').format(day).substring(0, 1),
                        style: GoogleFonts.inter(
                          color: isSelected ? Colors.white70 : AppColors.grey500,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        day.day.toString(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dayEvs.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.glow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Agenda: ${DateFormat('EEEE, dd MMMM').format(_selectedDay)}',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            Text(
              '${dayEvents.length} events',
              style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildEventsList(dayEvents, currency),
      ],
    );
  }

  // ==========================================
  // VIEW: Agenda View Layout (Grouped List)
  // ==========================================
  Widget _buildAgendaView(List<CalendarEvent> allEvents, String currency) {
    // Compile future events in sorted order
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final agendaEvents = allEvents.where((e) => !e.date.isBefore(today)).toList();

    if (agendaEvents.isEmpty) {
      return _buildEmptyState('No upcoming events on schedule.');
    }

    // Group events by date string
    final Map<String, List<CalendarEvent>> grouped = {};
    for (final e in agendaEvents) {
      final key = DateFormat('EEEE, dd MMMM yyyy').format(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final dateStr = entry.key;
        final dayEvs = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text(
                dateStr,
                style: GoogleFonts.outfit(
                  color: AppColors.glow,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            ...dayEvs.map((e) => _buildEventItemCard(e, currency)),
          ],
        );
      }).toList(),
    );
  }

  // ==========================================
  // VIEW: Timeline View Layout (Horizontal slider)
  // ==========================================
  Widget _buildTimelineView(List<CalendarEvent> allEvents, String currency) {
    final now = DateTime.now();
    final List<DateTime> nextDays = List.generate(21, (i) => DateTime(now.year, now.month, now.day + i));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            '3-Week Financial Timeline',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: nextDays.length,
            itemBuilder: (context, index) {
              final day = nextDays[index];
              final dayEvs = allEvents.where((e) =>
                  e.date.year == day.year &&
                  e.date.month == day.month &&
                  e.date.day == day.day).toList();

              final isToday = day.year == now.year && day.month == now.month && day.day == now.day;

              return Container(
                width: 260,
                margin: const EdgeInsets.only(right: 16, bottom: 16, top: 4),
                child: GlassCard(
                  borderColor: isToday ? AppColors.darkPrimary.withOpacity(0.6) : null,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM').format(day),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isToday ? AppColors.darkPrimary : AppColors.layer2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isToday ? 'TODAY' : DateFormat('EEEE').format(day).toUpperCase(),
                              style: GoogleFonts.inter(
                                color: isToday ? Colors.white : AppColors.grey500,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: AppColors.grey700.withOpacity(0.4)),
                      const SizedBox(height: 12),
                      if (dayEvs.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              'No obligations scheduled',
                              style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 12),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: dayEvs.length,
                            itemBuilder: (context, idx) {
                              final e = dayEvs[idx];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: InkWell(
                                  onTap: () => _handleEventTap(e),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.layer2.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(e.category),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '$currency${NumberFormat.decimalPattern().format(e.amount.toInt())}',
                                                style: GoogleFonts.outfit(
                                                  color: _getCategoryColor(e.category),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VIEW: Load Analysis Layout (heatmap/aggregations)
  // ==========================================
  Widget _buildLoadAnalysisView(List<CalendarEvent> allEvents, String currency) {
    final busiestDays = CalendarEngine.calculateLoadAnalysis(allEvents);

    if (busiestDays.isEmpty) {
      return _buildEmptyState('No financial obligation load found.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Busiest Obligation Days',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        ...busiestDays.map((day) {
          final isHighLoad = day.totalOutflow >= 10000;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              borderColor: isHighLoad ? AppColors.darkDanger.withOpacity(0.5) : null,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy').format(day.date),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isHighLoad ? AppColors.darkDanger.withOpacity(0.15) : AppColors.layer2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isHighLoad ? AppColors.darkDanger.withOpacity(0.3) : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          '$currency${NumberFormat.decimalPattern().format(day.totalOutflow.toInt())}',
                          style: GoogleFonts.outfit(
                            color: isHighLoad ? AppColors.darkDanger : AppColors.glow,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...day.events.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(e.category),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.title,
                                style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                              ),
                            ),
                            Text(
                              '$currency${NumberFormat.decimalPattern().format(e.amount.toInt())}',
                              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- Sub-widget: Events List ---
  Widget _buildEventsList(List<CalendarEvent> events, String currency) {
    if (events.isEmpty) {
      return _buildEmptyState('No events scheduled for this day.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _buildEventItemCard(events[index], currency);
      },
    );
  }

  Widget _buildEventItemCard(CalendarEvent e, String currency) {
    final categoryColor = _getCategoryColor(e.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        onTap: () => _handleEventTap(e),
        child: Row(
          children: [
            // Left category color stripe
            Container(
              width: 4,
              height: 38,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          e.category,
                          style: GoogleFonts.inter(
                            color: categoryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (e.time != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          e.time!,
                          style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11),
                        ),
                      ],
                      if (e.priority != 'Medium') ...[
                        const SizedBox(width: 8),
                        Text(
                          '${e.priority} Priority',
                          style: GoogleFonts.inter(
                            color: e.priority == 'High' ? AppColors.darkDanger : AppColors.grey500,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$currency${NumberFormat.decimalPattern().format(e.amount.toInt())}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (e.isAutoGenerated)
                  Text(
                    'Auto',
                    style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 9),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub-widget: Empty State ---
  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 40, color: AppColors.grey500.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Redirection & Detailed Operations on Tap
  // ==========================================
  void _handleEventTap(CalendarEvent e) {
    if (e.isAutoGenerated) {
      _showAutoGeneratedDialog(e);
    } else {
      _showEditManualEventSheet(e);
    }
  }

  // REDIRECT AUTO EVENT DIALOG
  void _showAutoGeneratedDialog(CalendarEvent e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer1,
        title: Text(
          'Auto-Generated Event',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This event is automatically generated from your active ${e.sourceType ?? 'records'}. Would you like to view details of the source record?',
          style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _redirectToSource(e);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('View Source', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _redirectToSource(CalendarEvent e) {
    final id = e.sourceId;
    if (id == null) return;

    switch (e.sourceType) {
      case 'sip':
        context.push('/portfolio/investment/${e.sourceId}');
        break;
      case 'receivable':
        context.push('/portfolio/receivable/$id');
        break;
      case 'liability':
        context.push('/portfolio/liability/$id');
        break;
      case 'expected_income':
        context.push('/portfolio/expected/$id');
        break;
      case 'goal':
        context.push('/portfolio/goal/$id');
        break;
      case 'mtf_position':
        context.push('/portfolio/mtf/$id');
        break;
      case 'ipo_pool':
        context.push('/settings/ipo_pool/$id');
        break;
    }
  }

  // ==========================================
  // NOTIFICATION SETTINGS FORM
  // ==========================================
  void _showNotificationSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.layer1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final dbState = ref.watch(mockDatabaseProvider);
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Reminders',
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure reminder push alerts for upcoming calendar obligations.',
                    style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    'Enable Notifications',
                    dbState.notificationsEnabled,
                    (val) {
                      ref.read(mockDatabaseProvider.notifier).updateNotificationsEnabled(val);
                      setSheetState(() {});
                    },
                  ),
                  const Divider(color: AppColors.grey700, height: 24),
                  _buildSwitchTile(
                    'Remind on Due Date',
                    dbState.notificationPrefCalendarOnDue,
                    (val) {
                      ref.read(mockDatabaseProvider.notifier).updateNotificationPref('calendarOnDue', val);
                      setSheetState(() {});
                    },
                    enabled: dbState.notificationsEnabled,
                  ),
                  _buildSwitchTile(
                    'Remind 1 Day Before',
                    dbState.notificationPrefCalendar1Day,
                    (val) {
                      ref.read(mockDatabaseProvider.notifier).updateNotificationPref('calendar1Day', val);
                      setSheetState(() {});
                    },
                    enabled: dbState.notificationsEnabled,
                  ),
                  _buildSwitchTile(
                    'Remind 3 Days Before',
                    dbState.notificationPrefCalendar3Days,
                    (val) {
                      ref.read(mockDatabaseProvider.notifier).updateNotificationPref('calendar3Days', val);
                      setSheetState(() {});
                    },
                    enabled: dbState.notificationsEnabled,
                  ),
                  _buildSwitchTile(
                    'Remind 7 Days Before',
                    dbState.notificationPrefCalendar7Days,
                    (val) {
                      ref.read(mockDatabaseProvider.notifier).updateNotificationPref('calendar7Days', val);
                      setSheetState(() {});
                    },
                    enabled: dbState.notificationsEnabled,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Save Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSwitchTile(String label, bool value, ValueChanged<bool> onChanged, {bool enabled = true}) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: SwitchListTile(
        title: Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: AppColors.darkPrimary,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // ==========================================
  // ADD MANUAL EVENT SHEET
  // ==========================================
  void _showAddEventSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    String category = 'Manual';
    DateTime selectedDate = _selectedDay;
    String? selectedTime;
    String priority = 'Medium';
    bool isRecurring = false;
    String recurrenceInterval = 'monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.layer1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Manual Event',
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title (e.g. Salary, Rent, Bonus)',
                        labelStyle: TextStyle(color: AppColors.grey500),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        labelStyle: TextStyle(color: AppColors.grey500),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: AppColors.layer1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: AppColors.grey500),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Income', child: Text('Income (Green)')),
                        DropdownMenuItem(value: 'Investment', child: Text('Investment (Purple)')),
                        DropdownMenuItem(value: 'Liability', child: Text('Liability (Red)')),
                        DropdownMenuItem(value: 'Receivables', child: Text('Receivables (Blue)')),
                        DropdownMenuItem(value: 'Goals', child: Text('Goals (Gold)')),
                        DropdownMenuItem(value: 'IPO', child: Text('IPO (Orange)')),
                        DropdownMenuItem(value: 'Subscription', child: Text('Subscription (Indigo)')),
                        DropdownMenuItem(value: 'Insurance', child: Text('Insurance (Teal)')),
                        DropdownMenuItem(value: 'Manual', child: Text('Manual (Slate)')),
                      ],
                      onChanged: (val) => setSheetState(() => category = val!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}', style: GoogleFonts.inter(color: Colors.white)),
                        TextButton(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) => Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.darkPrimary,
                                    onPrimary: Colors.white,
                                    surface: AppColors.layer1,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (d != null) {
                              setSheetState(() => selectedDate = d);
                            }
                          },
                          child: const Text('Change Date', style: TextStyle(color: AppColors.glow)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time: ${selectedTime ?? "None"}', style: GoogleFonts.inter(color: Colors.white)),
                        TextButton(
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) => Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.darkPrimary,
                                    onPrimary: Colors.white,
                                    surface: AppColors.layer1,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (t != null) {
                              setSheetState(() => selectedTime = t.format(context));
                            }
                          },
                          child: const Text('Set Time', style: TextStyle(color: AppColors.glow)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: priority,
                      dropdownColor: AppColors.layer1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        labelStyle: TextStyle(color: AppColors.grey500),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (val) => setSheetState(() => priority = val!),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('Recurring Event', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                      value: isRecurring,
                      activeColor: AppColors.darkPrimary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setSheetState(() => isRecurring = val),
                    ),
                    if (isRecurring) ...[
                      DropdownButtonFormField<String>(
                        value: recurrenceInterval,
                        dropdownColor: AppColors.layer1,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Interval', labelStyle: TextStyle(color: AppColors.grey500)),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                        ],
                        onChanged: (val) => setSheetState(() => recurrenceInterval = val!),
                      ),
                    ],
                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(color: AppColors.grey500),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey700)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a title.')),
                            );
                            return;
                          }
                          await ref.read(mockDatabaseProvider.notifier).addCalendarEvent(
                            title: title,
                            amount: amount,
                            category: category,
                            date: selectedDate,
                            time: selectedTime,
                            notes: notesController.text,
                            priority: priority,
                            isRecurring: isRecurring,
                            recurrenceInterval: isRecurring ? recurrenceInterval : null,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('Save Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // EDIT/MANAGE MANUAL EVENT SHEET
  // ==========================================
  void _showEditManualEventSheet(CalendarEvent event) {
    final titleController = TextEditingController(text: event.title);
    final amountController = TextEditingController(text: event.amount.toString());
    final notesController = TextEditingController(text: event.notes ?? '');
    String category = event.category;
    DateTime selectedDate = event.date;
    String? selectedTime = event.time;
    String priority = event.priority;
    bool isRecurring = event.isRecurring;
    String recurrenceInterval = event.recurrenceInterval ?? 'monthly';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.layer1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Manage Event',
                          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy, color: AppColors.glow, size: 20),
                              onPressed: () async {
                                await ref.read(mockDatabaseProvider.notifier).duplicateCalendarEvent(event.id);
                                Navigator.pop(context);
                              },
                              tooltip: 'Duplicate Event',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.darkDanger, size: 20),
                              onPressed: () async {
                                await ref.read(mockDatabaseProvider.notifier).deleteCalendarEventSoft(event.id);
                                Navigator.pop(context);
                              },
                              tooltip: 'Delete Event',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: AppColors.grey500),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        labelStyle: TextStyle(color: AppColors.grey500),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: AppColors.layer1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: AppColors.grey500),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Income', child: Text('Income (Green)')),
                        DropdownMenuItem(value: 'Investment', child: Text('Investment (Purple)')),
                        DropdownMenuItem(value: 'Liability', child: Text('Liability (Red)')),
                        DropdownMenuItem(value: 'Receivables', child: Text('Receivables (Blue)')),
                        DropdownMenuItem(value: 'Goals', child: Text('Goals (Gold)')),
                        DropdownMenuItem(value: 'IPO', child: Text('IPO (Orange)')),
                        DropdownMenuItem(value: 'Subscription', child: Text('Subscription (Indigo)')),
                        DropdownMenuItem(value: 'Insurance', child: Text('Insurance (Teal)')),
                        DropdownMenuItem(value: 'Manual', child: Text('Manual (Slate)')),
                      ],
                      onChanged: (val) => setSheetState(() => category = val!),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}', style: GoogleFonts.inter(color: Colors.white)),
                        TextButton(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              builder: (context, child) => Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.darkPrimary,
                                    onPrimary: Colors.white,
                                    surface: AppColors.layer1,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (d != null) {
                              setSheetState(() => selectedDate = d);
                            }
                          },
                          child: const Text('Change Date', style: TextStyle(color: AppColors.glow)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time: ${selectedTime ?? "None"}', style: GoogleFonts.inter(color: Colors.white)),
                        TextButton(
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (context, child) => Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppColors.darkPrimary,
                                    onPrimary: Colors.white,
                                    surface: AppColors.layer1,
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              ),
                            );
                            if (t != null) {
                              setSheetState(() => selectedTime = t.format(context));
                            }
                          },
                          child: const Text('Set Time', style: TextStyle(color: AppColors.glow)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: priority,
                      dropdownColor: AppColors.layer1,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        labelStyle: TextStyle(color: AppColors.grey500),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Low', child: Text('Low')),
                        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'High', child: Text('High')),
                      ],
                      onChanged: (val) => setSheetState(() => priority = val!),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('Recurring Event', style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
                      value: isRecurring,
                      activeColor: AppColors.darkPrimary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setSheetState(() => isRecurring = val),
                    ),
                    if (isRecurring) ...[
                      DropdownButtonFormField<String>(
                        value: recurrenceInterval,
                        dropdownColor: AppColors.layer1,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Interval', labelStyle: TextStyle(color: AppColors.grey500)),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Daily')),
                          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                          DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                        ],
                        onChanged: (val) => setSheetState(() => recurrenceInterval = val!),
                      ),
                    ],
                    TextField(
                      controller: notesController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        labelStyle: TextStyle(color: AppColors.grey500),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey700)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final amount = double.tryParse(amountController.text) ?? 0.0;
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a title.')),
                            );
                            return;
                          }
                          final updated = event.copyWith(
                            title: title,
                            amount: amount,
                            category: category,
                            date: selectedDate,
                            time: () => selectedTime,
                            notes: () => notesController.text,
                            priority: priority,
                            isRecurring: isRecurring,
                            recurrenceInterval: () => isRecurring ? recurrenceInterval : null,
                          );
                          await ref.read(mockDatabaseProvider.notifier).updateCalendarEvent(updated);
                          Navigator.pop(context);
                        },
                        child: const Text('Update Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
