import 'package:drift/drift.dart';
import '../database.dart';

class TransactionRepository {
  final AppDatabase _db;
  TransactionRepository(this._db);

  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  // Keyset Pagination for transaction feed
  Future<List<Transaction>> getTransactionsPaginated({
    required int limit,
    DateTime? lastDate,
    String? lastId,
  }) {
    final query = _db.select(_db.transactions)
      ..orderBy([
        (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    if (lastDate != null && lastId != null) {
      query.where((t) {
        // Keyset logic: Date is strictly before lastDate, OR
        // Date is equal to lastDate but ID is lexicographically smaller than lastId (stable tie-breaker)
        return t.transactionDate.isSmallerThanValue(lastDate) |
            (t.transactionDate.equals(lastDate) & t.id.isSmallerThanValue(lastId));
      });
    }

    return query.get();
  }

  Future<Transaction?> getTransactionById(String id) {
    return (_db.select(_db.transactions)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertTransaction(TransactionsCompanion companion) {
    return _db.into(_db.transactions).insert(companion);
  }

  Future<void> updateTransaction(Transaction transaction) {
    return _db.update(_db.transactions).replace(transaction);
  }
}
