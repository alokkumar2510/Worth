import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart';
import '../../../ipo_pool/domain/entities/ipo_pool_models.dart';
import 'package:uuid/uuid.dart';

class ArchiveCenterScreen extends ConsumerWidget {
  const ArchiveCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbState = ref.watch(mockDatabaseProvider);
    final format = NumberFormat.currency(symbol: dbState.currency, decimalDigits: 0);

    // Filter archived items from the mock database state
    // Note: mock_database.dart loads everything, but for active net worth calculations
    // and feeds it filters them out. Here, we fetch directly from raw lists in dbState.
    // Let's verify which items are archived:
    final archivedAccounts = dbState.accounts.where((a) => a.isArchived == 1).toList();
    final archivedInvestments = dbState.investments.where((i) => i.isArchived == 1).toList();
    final archivedGoals = dbState.goals.where((g) => g.isArchived == 1).toList();
    final archivedPeople = dbState.people.where((p) => p.isArchived == 1).toList();
    final archivedIpoPools = dbState.ipoPools.where((p) => p.status == 'Archived').toList();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Archived Portfolio Items',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.darkPrimary,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.darkPrimary,
            tabs: [
              Tab(text: 'Accounts'),
              Tab(text: 'Investments'),
              Tab(text: 'Goals'),
              Tab(text: 'People'),
              Tab(text: 'IPO Pools'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Accounts Tab
              _buildAccountsList(context, ref, archivedAccounts, format),

              // Investments Tab
              _buildInvestmentsList(context, ref, archivedInvestments, format),

              // Goals Tab
              _buildGoalsList(context, ref, archivedGoals, format),

              // People Tab
              _buildPeopleList(context, ref, archivedPeople),

              // IPO Pools Tab
              _buildIpoPoolsList(context, ref, archivedIpoPools),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsList(BuildContext context, WidgetRef ref, List<Account> items, NumberFormat format) {
    if (items.isEmpty) {
      return const Center(child: Text('No archived accounts.', style: TextStyle(color: AppColors.grey500)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isAsset = item.type == 'asset';
        final route = isAsset ? '/portfolio/asset/${item.id}' : '/portfolio/liability/acc_${item.id}';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${item.type.toUpperCase()}',
                        style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(mockDatabaseProvider.notifier).unarchiveAccount(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restored account "${item.name}"')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  child: const Text('Restore', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: AppColors.grey500, size: 16),
                  onPressed: () => context.push(route),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvestmentsList(BuildContext context, WidgetRef ref, List<Investment> items, NumberFormat format) {
    if (items.isEmpty) {
      return const Center(child: Text('No archived investments.', style: TextStyle(color: AppColors.grey500)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${item.type.toUpperCase()} | Value: ${format.format(item.marketValue ?? 0.0)}',
                        style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(mockDatabaseProvider.notifier).unarchiveInvestment(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restored investment "${item.name}"')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  child: const Text('Restore', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: AppColors.grey500, size: 16),
                  onPressed: () => context.push('/portfolio/investment/${item.id}'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalsList(BuildContext context, WidgetRef ref, List<Goal> items, NumberFormat format) {
    if (items.isEmpty) {
      return const Center(child: Text('No archived goals.', style: TextStyle(color: AppColors.grey500)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        'Target: ${format.format(item.targetAmount)} | Date: ${item.deadline != null ? DateFormat('dd MMM yyyy').format(item.deadline!) : 'No deadline'}',
                        style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(mockDatabaseProvider.notifier).unarchiveGoal(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restored goal "${item.name}"')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  child: const Text('Restore', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: AppColors.grey500, size: 16),
                  onPressed: () => context.push('/portfolio/goal/${item.id}'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeopleList(BuildContext context, WidgetRef ref, List<Person> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No archived people.', style: TextStyle(color: AppColors.grey500)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        'Debtor/Creditor Profile',
                        style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(mockDatabaseProvider.notifier).unarchivePerson(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restored person "${item.name}"')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  child: const Text('Restore', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: AppColors.grey500, size: 16),
                  onPressed: () => context.push('/portfolio/receivable/${item.id}'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIpoPoolsList(BuildContext context, WidgetRef ref, List<IpoPool> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No archived IPO Pools.', style: TextStyle(color: AppColors.grey500)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        'Company: ${item.companyName} | Status: ARCHIVED',
                        style: const TextStyle(color: AppColors.grey500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final restored = item.copyWith(
                      status: 'Closed',
                      activities: [
                        ...item.activities,
                        PoolActivity(
                          id: Uuid().v4(),
                          type: 'Update',
                          description: 'Unarchived/Restored pool status to Closed',
                          timestamp: DateTime.now(),
                          userId: 'User',
                        ),
                      ],
                    );
                    await ref.read(mockDatabaseProvider.notifier).updateIpoPool(restored);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Restored IPO pool "${item.name}"')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  child: const Text('Restore', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: AppColors.grey500, size: 16),
                  onPressed: () => context.push('/settings/ipo_pool/${item.id}'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
