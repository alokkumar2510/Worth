import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/transaction_repository.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../auth/providers/auth_providers.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final db.AppDatabase _database;
  final Ref _ref;
  final _uuid = const Uuid();

  TransactionRepositoryImpl(this._database, this._ref);

  domain.Transaction _toDomain(db.Transaction tx) {
    return domain.Transaction(
      id: tx.id,
      type: tx.type,
      amount: tx.amount,
      category: tx.category,
      fromAccountId: tx.fromAccountId,
      toAccountId: tx.toAccountId,
      personId: tx.personId,
      investmentId: tx.investmentId,
      voidedTransactionId: tx.voidedTransactionId,
      notes: tx.notes,
      pricePerUnit: tx.pricePerUnit,
      units: tx.units,
      transactionDate: tx.transactionDate,
      createdAt: tx.createdAt,
      updatedAt: tx.updatedAt,
      syncStatus: tx.syncStatus,
    );
  }

  db.TransactionsCompanion _toCompanion(domain.Transaction tx) {
    return db.TransactionsCompanion(
      id: Value(tx.id),
      type: Value(tx.type),
      amount: Value(tx.amount),
      category: Value(tx.category),
      fromAccountId: Value(tx.fromAccountId),
      toAccountId: Value(tx.toAccountId),
      personId: Value(tx.personId),
      investmentId: Value(tx.investmentId),
      voidedTransactionId: Value(tx.voidedTransactionId),
      notes: Value(tx.notes),
      pricePerUnit: Value(tx.pricePerUnit),
      units: Value(tx.units),
      transactionDate: Value(tx.transactionDate),
      createdAt: Value(tx.createdAt),
      updatedAt: Value(tx.updatedAt),
      syncStatus: Value(tx.syncStatus),
    );
  }

  @override
  Stream<List<domain.Transaction>> watchAllTransactions() {
    return (_database.select(_database.transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<domain.Transaction>> getAllTransactions() async {
    final list = await (_database.select(_database.transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ]))
        .get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<domain.Transaction?> getTransactionById(String id) async {
    final query = _database.select(_database.transactions)..where((tbl) => tbl.id.equals(id));
    final tx = await query.getSingleOrNull();
    return tx != null ? _toDomain(tx) : null;
  }

  @override
  Future<void> createTransaction(domain.Transaction transaction) async {
    await _database.into(_database.transactions).insert(_toCompanion(transaction));
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'transaction',
      entityId: transaction.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> updateTransaction(domain.Transaction transaction) async {
    final dbTx = db.Transaction(
      id: transaction.id,
      type: transaction.type,
      amount: transaction.amount,
      category: transaction.category,
      fromAccountId: transaction.fromAccountId,
      toAccountId: transaction.toAccountId,
      personId: transaction.personId,
      investmentId: transaction.investmentId,
      voidedTransactionId: transaction.voidedTransactionId,
      notes: transaction.notes,
      pricePerUnit: transaction.pricePerUnit,
      units: transaction.units,
      transactionDate: transaction.transactionDate,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      syncStatus: transaction.syncStatus,
    );
    await _database.update(_database.transactions).replace(dbTx);
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'transaction',
      entityId: transaction.id,
      operation: 'upsert',
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final query = _database.delete(_database.transactions)..where((tbl) => tbl.id.equals(id));
    await query.go();
    await _ref.read(syncServiceProvider).queueOperation(
      entityType: 'transaction',
      entityId: id,
      operation: 'delete',
    );
  }

  @override
  Future<List<domain.Transaction>> getTransactionsPaginated(int limit, DateTime? lastDate, String? lastId) async {
    final query = _database.select(_database.transactions)
      ..orderBy([
        (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    if (lastDate != null && lastId != null) {
      query.where((t) {
        return t.transactionDate.isSmallerThanValue(lastDate) |
            (t.transactionDate.equals(lastDate) & t.id.isSmallerThanValue(lastId));
      });
    }

    final list = await query.get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<List<domain.Transaction>> filterTransactions(String? type, String? category) async {
    final query = _database.select(_database.transactions);
    
    if (type != null) {
      query.where((tbl) => tbl.type.equals(type));
    }
    if (category != null) {
      query.where((tbl) => tbl.category.equals(category));
    }

    query.orderBy([
      (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
    ]);

    final list = await query.get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<List<domain.Transaction>> searchTransactions(String query) async {
    final searchPattern = '%$query%';
    final search = _database.select(_database.transactions)
      ..where((tbl) => tbl.notes.like(searchPattern) | tbl.category.like(searchPattern))
      ..orderBy([
        (t) => OrderingTerm(expression: t.transactionDate, mode: OrderingMode.desc),
      ]);
    final list = await search.get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<void> voidTransaction(String originalTransactionId) async {
    final original = await getTransactionById(originalTransactionId);
    if (original == null) {
      throw Exception('Original transaction not found: $originalTransactionId');
    }
    if (original.type == 'void' || original.voidedTransactionId != null) {
      throw Exception('Transaction is already voided or is a void reversal: $originalTransactionId');
    }

    final voidTxId = _uuid.v4();
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      // 1. Update original transaction with void link
      final updatedOriginal = original.copyWith(
        voidedTransactionId: voidTxId,
        updatedAt: now,
      );
      await updateTransaction(updatedOriginal);

      // 2. Insert the void transaction (mirroring the original)
      final voidTx = domain.Transaction(
        id: voidTxId,
        type: 'void',
        amount: original.amount,
        fromAccountId: original.fromAccountId,
        toAccountId: original.toAccountId,
        personId: original.personId,
        investmentId: original.investmentId,
        voidedTransactionId: original.id,
        notes: 'Reversal of transaction ${original.id}',
        transactionDate: now,
        createdAt: now,
        updatedAt: now,
      );
      await createTransaction(voidTx);
    });
  }
}
