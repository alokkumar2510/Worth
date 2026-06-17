import '../../../../database/database.dart' as db;
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final db.AppDatabase _database;

  SearchRepositoryImpl(this._database);

  @override
  Future<List<SearchResult>> search({
    required String query,
    List<String>? entityTypes,
    required String sortBy,
    required int limit,
    required int offset,
  }) async {
    final List<SearchResult> results = [];
    final q = query.toLowerCase();

    final targetTypes = entityTypes ??
        ['account', 'transaction', 'asset', 'liability', 'receivable', 'investment', 'goal'];

    // 1. Query Accounts (in-memory filter to avoid Drift generic type inference issues)
    if (targetTypes.contains('account') ||
        targetTypes.contains('asset') ||
        targetTypes.contains('liability')) {
      final accs = await _database.select(_database.accounts).get();
      for (final acc in accs) {
        final matchName = acc.name.toLowerCase().contains(q);
        final matchNotes = (acc.notes ?? '').toLowerCase().contains(q);
        if (!matchName && !matchNotes) continue;
        final isCredit = acc.type == 'credit';
        final resolvedType = isCredit ? 'liability' : 'asset';
        if (targetTypes.contains(resolvedType) || targetTypes.contains('account')) {
          results.add(SearchResult(
            id: acc.id,
            title: acc.name,
            subtitle: 'Account - ${acc.type}',
            type: resolvedType,
            date: acc.createdAt,
            amount: null,
          ));
        }
      }
    }

    // 2. Query Transactions
    if (targetTypes.contains('transaction')) {
      final txs = await _database.select(_database.transactions).get();
      for (final tx in txs) {
        final matchNotes = (tx.notes ?? '').toLowerCase().contains(q);
        final matchCat = (tx.category ?? '').toLowerCase().contains(q);
        if (!matchNotes && !matchCat) continue;
        results.add(SearchResult(
          id: tx.id,
          title: tx.category ?? tx.type,
          subtitle: tx.notes,
          type: 'transaction',
          date: tx.transactionDate,
          amount: tx.amount,
        ));
      }
    }

    // 3. Query Investments
    if (targetTypes.contains('investment') || targetTypes.contains('asset')) {
      final invs = await _database.select(_database.investments).get();
      for (final inv in invs) {
        final matchName = inv.name.toLowerCase().contains(q);
        final matchNotes = (inv.notes ?? '').toLowerCase().contains(q);
        if (!matchName && !matchNotes) continue;
        results.add(SearchResult(
          id: inv.id,
          title: inv.name,
          subtitle: 'Investment - ${inv.type} (${inv.symbol ?? ""})',
          type: 'investment',
          date: inv.createdAt,
          amount: inv.marketValue,
        ));
      }
    }

    // 4. Query Goals
    if (targetTypes.contains('goal')) {
      final goals = await _database.select(_database.goals).get();
      for (final g in goals) {
        final matchName = g.name.toLowerCase().contains(q);
        final matchNotes = (g.notes ?? '').toLowerCase().contains(q);
        if (!matchName && !matchNotes) continue;
        results.add(SearchResult(
          id: g.id,
          title: g.name,
          subtitle: 'Goal - Target: ${g.targetAmount}',
          type: 'goal',
          date: g.createdAt,
          amount: g.targetAmount,
        ));
      }
    }

    // 5. Query People (Receivables)
    if (targetTypes.contains('receivable')) {
      final people = await _database.select(_database.people).get();
      for (final p in people) {
        final matchName = p.name.toLowerCase().contains(q);
        final matchNotes = (p.notes ?? '').toLowerCase().contains(q);
        if (!matchName && !matchNotes) continue;
        results.add(SearchResult(
          id: p.id,
          title: p.name,
          subtitle: 'Person Receivable',
          type: 'receivable',
          date: p.createdAt,
          amount: null,
        ));
      }
    }

    // Sort Combined Results
    if (sortBy == 'date_desc') {
      results.sort((a, b) {
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return b.date!.compareTo(a.date!);
      });
    } else if (sortBy == 'date_asc') {
      results.sort((a, b) {
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        return a.date!.compareTo(b.date!);
      });
    } else if (sortBy == 'name_asc') {
      results.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    // Paginate Results
    if (offset >= results.length) {
      return [];
    }
    final endIdx = (offset + limit) < results.length ? (offset + limit) : results.length;
    return results.sublist(offset, endIdx);
  }
}
