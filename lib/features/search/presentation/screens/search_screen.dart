import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/constants/asset_constants.dart';

class SearchItem {
  final String id;
  final String type; // 'account' | 'person' | 'investment' | 'transaction' | 'goal'
  final String title;
  final String subtitle;
  final double? amount;
  final String routePath;

  SearchItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.amount,
    required this.routePath,
  });
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    // Build the searchable list
    final List<SearchItem> items = [];

    // Accounts
    for (final acc in dbState.accounts) {
      if (acc.isArchived == 0) {
        final bal = acc.type == 'credit' ? dbState.getAccountLiabilityBalance(acc.id) : dbState.getAccountCashBalance(acc.id);
        items.add(
          SearchItem(
            id: acc.id,
            type: 'account',
            title: acc.name,
            subtitle: acc.type.toUpperCase(),
            amount: bal,
            routePath: acc.type == 'credit' ? '/portfolio/liability/acc_${acc.id}' : '/portfolio/asset/${acc.id}',
          ),
        );
      }
    }

    // People
    for (final p in dbState.people) {
      if (p.isArchived == 0) {
        final rec = dbState.getPersonReceivableBalance(p.id);
        final liab = dbState.getPersonLiabilityBalance(p.id);
        if (rec > 0) {
          items.add(SearchItem(id: p.id, type: 'person', title: p.name, subtitle: 'RECEIVABLE FROM INDIVIDUAL', amount: rec, routePath: '/portfolio/receivable/${p.id}'));
        }
        if (liab > 0) {
          items.add(SearchItem(id: p.id, type: 'person', title: p.name, subtitle: 'LIABILITY OWE TO INDIVIDUAL', amount: liab, routePath: '/portfolio/liability/person_${p.id}'));
        }
      }
    }

    // Investments
    for (final inv in dbState.investments) {
      if (inv.isArchived == 0) {
        final val = dbState.getInvestmentMarketValue(inv.id);
        items.add(
          SearchItem(
            id: inv.id,
            type: 'investment',
            title: inv.name,
            subtitle: '${inv.type.toUpperCase()} · ${inv.symbol ?? ""}',
            amount: val,
            routePath: '/portfolio/investment/${inv.id}',
          ),
        );
      }
    }

    // Goals
    for (final goal in dbState.goals) {
      if (goal.isArchived == 0) {
        items.add(
          SearchItem(
            id: goal.id,
            type: 'goal',
            title: goal.name,
            subtitle: 'PASSIBLE TARGET MILESTONE',
            amount: goal.targetAmount,
            routePath: '/dashboard', // Deep links to dashboard net worth
          ),
        );
      }
    }

    // Transactions
    for (final tx in dbState.transactions) {
      items.add(
        SearchItem(
          id: tx.id,
          type: 'transaction',
          title: tx.notes ?? tx.type.replaceAll('_', ' ').toUpperCase(),
          subtitle: '${DateFormat('dd MMM yyyy').format(tx.transactionDate)} · ${tx.type.replaceAll('_', ' ').toUpperCase()}',
          amount: tx.amount,
          routePath: '/transactions',
        ),
      );
    }

    // Filter by query
    final filtered = items.where((item) {
      final q = _query.toLowerCase();
      if (q.isEmpty) return false; // Show nothing until they type
      return item.title.toLowerCase().contains(q) || item.subtitle.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Database', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input
              TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search accounts, transactions, people...',
                  hintStyle: const TextStyle(color: AppColors.grey500),
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey500),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.grey500),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.glassBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppColors.darkPrimary)),
                  filled: true,
                  fillColor: AppColors.darkCard.withOpacity(0.5),
                ),
                onChanged: (val) {
                  setState(() {
                    _query = val;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Search Results
              Expanded(
                child: _query.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_rounded, size: 64, color: AppColors.grey700),
                            const SizedBox(height: 16),
                            const Text('Type something to search the wealth system.', style: TextStyle(color: AppColors.grey500)),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AssetPaths.noSearchResults,
                                  height: AssetConstants.emptyStateImageHeight,
                                  semanticLabel: AssetConstants.noSearchResultsLabel,
                                ),
                                const SizedBox(height: 16),
                                const Text('No results match your search.', style: TextStyle(color: AppColors.grey500)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              
                              Color typeColor = AppColors.darkPrimary;
                              IconData icon = Icons.info_outline;
                              if (item.type == 'account') {
                                icon = Icons.account_balance_wallet_outlined;
                                typeColor = AppColors.darkPrimary;
                              } else if (item.type == 'person') {
                                icon = Icons.person_outline;
                                typeColor = AppColors.darkSuccess;
                              } else if (item.type == 'investment') {
                                icon = Icons.show_chart;
                                typeColor = AppColors.darkSuccess;
                              } else if (item.type == 'goal') {
                                icon = Icons.track_changes;
                                typeColor = AppColors.darkWarning;
                              } else if (item.type == 'transaction') {
                                icon = Icons.receipt_long_outlined;
                                typeColor = AppColors.grey400;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: GlassCard(
                                  onTap: () {
                                    context.push(item.routePath);
                                  },
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: typeColor.withOpacity(0.1),
                                        child: Icon(icon, color: typeColor, size: 20),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                            const SizedBox(height: 4),
                                            Text(item.subtitle, style: const TextStyle(fontSize: 10, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      if (item.amount != null)
                                        Text(
                                          '$currency${NumberFormat.decimalPattern().format(item.amount)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
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
        ),
      ),
    );
  }
}
