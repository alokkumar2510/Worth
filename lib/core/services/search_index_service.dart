import 'package:drift/drift.dart';
import '../../database/database.dart';

class SearchIndexService {
  final AppDatabase _db;

  SearchIndexService(this._db);

  // Inserts or updates an entity's searchable text in the FTS5 virtual table
  Future<void> updateEntityIndex({
    required String entityType,
    required String entityId,
    required String searchableText,
  }) async {
    // Delete existing entry if any
    await removeEntityIndex(entityId);
    
    // Insert new entry
    await _db.customInsert(
      'INSERT INTO search_index (entity_type, entity_id, searchable_text) VALUES (?, ?, ?);',
      variables: [
        Variable<String>(entityType),
        Variable<String>(entityId),
        Variable<String>(searchableText),
      ],
    );
  }

  // Removes an entity from the search index
  Future<void> removeEntityIndex(String entityId) async {
    await _db.customStatement(
      'DELETE FROM search_index WHERE entity_id = ?;',
      [entityId],
    );
  }

  // Performs a search query against FTS5
  Future<List<SearchResultItem>> search(String queryText) async {
    if (queryText.trim().isEmpty) return const [];
    
    // Query search_index using FTS5 MATCH syntax
    final rows = await _db.customSelect(
      'SELECT entity_type, entity_id, searchable_text FROM search_index WHERE searchable_text MATCH ?;',
      variables: [Variable<String>('$queryText*')], // Prefix search support
    ).get();

    return rows.map((row) {
      return SearchResultItem(
        entityType: row.read<String>('entity_type'),
        entityId: row.read<String>('entity_id'),
        matchedText: row.read<String>('searchable_text'),
      );
    }).toList();
  }

  // Rebuilds the entire index from scratch by querying active data tables
  Future<void> rebuildIndex() async {
    await _db.customStatement('DELETE FROM search_index;');

    // Index accounts
    final accounts = await _db.select(_db.accounts).get();
    for (final account in accounts) {
      final text = '${account.name} ${account.notes ?? ""}';
      await updateEntityIndex(entityType: 'account', entityId: account.id, searchableText: text);
    }

    // Index people
    final people = await _db.select(_db.people).get();
    for (final person in people) {
      final text = '${person.name} ${person.notes ?? ""}';
      await updateEntityIndex(entityType: 'person', entityId: person.id, searchableText: text);
    }

    // Index investments
    final investments = await _db.select(_db.investments).get();
    for (final inv in investments) {
      final text = '${inv.name} ${inv.symbol ?? ""} ${inv.notes ?? ""}';
      await updateEntityIndex(entityType: 'investment', entityId: inv.id, searchableText: text);
    }

    // Index goals
    final goals = await _db.select(_db.goals).get();
    for (final goal in goals) {
      final text = '${goal.name} ${goal.notes ?? ""}';
      await updateEntityIndex(entityType: 'goal', entityId: goal.id, searchableText: text);
    }

    // Index transactions (notes field)
    final transactions = await _db.select(_db.transactions).get();
    for (final tx in transactions) {
      if (tx.notes != null && tx.notes!.trim().isNotEmpty) {
        await updateEntityIndex(entityType: 'transaction', entityId: tx.id, searchableText: tx.notes!);
      }
    }
  }
}

class SearchResultItem {
  final String entityType;
  final String entityId;
  final String matchedText;

  SearchResultItem({
    required this.entityType,
    required this.entityId,
    required this.matchedText,
  });
}
