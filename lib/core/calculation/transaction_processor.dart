import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../database/database.dart' as db;
import 'balance_cache_service.dart';
import 'fifo_lot_service.dart';
import '../services/search_index_service.dart';

class TransactionProcessor {
  final db.AppDatabase _db;
  final BalanceCacheService _cacheService;
  final FifoLotService _fifoLotService;
  final SearchIndexService _searchIndexService;
  final _uuid = const Uuid();

  TransactionProcessor(
    this._db,
    this._cacheService,
    this._fifoLotService,
    this._searchIndexService,
  );

  // Processes transaction insertions and updates lot configurations & balance caches
  Future<void> processTransaction(db.TransactionsCompanion companion) async {
    final txId = companion.id.value;
    final type = companion.type.value;
    final amount = companion.amount.value;

    // 1. Insert transaction record
    await _db.into(_db.transactions).insert(companion);

    // 2. Handle special Investment types
    if (type == 'investment_buy') {
      final double unitsVal = companion.units.value ?? 0.0;
      final double priceVal = companion.pricePerUnit.value ?? 0.0;
      await _db.into(_db.investmentLots).insert(db.InvestmentLotsCompanion(
            id: Value(_uuid.v4()),
            investmentId: Value(companion.investmentId.value!),
            buyTransactionId: Value(txId),
            unitsPurchased: Value(unitsVal),
            unitsRemaining: Value(unitsVal),
            costPerUnit: Value(priceVal),
            purchaseDate: companion.transactionDate,
            createdAt: Value(DateTime.now().toUtc()),
            updatedAt: Value(DateTime.now().toUtc()),
          ));
    } else if (type == 'investment_sell') {
      final double unitsSold = companion.units.value ?? 0.0;
      final plan = await _fifoLotService.prepareSalePlan(
        investmentId: companion.investmentId.value!,
        unitsToSell: unitsSold,
        totalProceeds: amount,
        sellTransactionId: txId,
      );

      for (final lot in plan.updatedLots) {
        await _db.update(_db.investmentLots).replace(lot);
      }

      for (final c in plan.consumptions) {
        await _db.into(_db.investmentLotConsumptions).insert(c);
      }
    }

    // 3. Incrementally update balance caches
    final tx = await (_db.select(_db.transactions)..where((tbl) => tbl.id.equals(txId))).getSingle();
    await _cacheService.applyTransaction(tx);

    // 4. Update the Search Index
    if (tx.notes != null && tx.notes!.trim().isNotEmpty) {
      await _searchIndexService.updateEntityIndex(
        entityType: 'transaction',
        entityId: tx.id,
        searchableText: tx.notes!,
      );
    }

    // 5. Insert Audit Log
    await _db.into(_db.auditLogs).insert(db.AuditLogsCompanion(
          id: Value(_uuid.v4()),
          entityType: const Value('transaction'),
          entityId: Value(txId),
          action: const Value('created'),
          createdAt: Value(DateTime.now().toUtc()),
        ));
  }

  // Processes transaction voiding (reversing balances and linking void items)
  Future<void> processVoid(String originalTxId) async {
    final original = await (_db.select(_db.transactions)..where((tbl) => tbl.id.equals(originalTxId))).getSingleOrNull();
    if (original == null) {
      throw Exception('Transaction not found: $originalTxId');
    }
    if (original.type == 'void' || original.voidedTransactionId != null) {
      throw Exception('Transaction is already voided or is a void reversal: $originalTxId');
    }

    final voidTxId = _uuid.v4();
    final now = DateTime.now().toUtc();

    // 1. Link original with void link
    await _db.update(_db.transactions).replace(original.copyWith(
          voidedTransactionId: Value(voidTxId),
          updatedAt: now,
        ));

    // 2. Create void reversal record
    final voidCompanion = db.TransactionsCompanion(
      id: Value(voidTxId),
      type: const Value('void'),
      amount: Value(original.amount),
      fromAccountId: Value(original.fromAccountId),
      toAccountId: Value(original.toAccountId),
      personId: Value(original.personId),
      investmentId: Value(original.investmentId),
      voidedTransactionId: Value(originalTxId),
      notes: Value('Reversal of transaction ${original.id}. Reason: Voided.'),
      transactionDate: Value(now),
      createdAt: Value(now),
      updatedAt: Value(now),
    );
    await _db.into(_db.transactions).insert(voidCompanion);

    // 3. Replay reverse caches
    await _cacheService.applyTransaction(original, isVoidReversal: true);

    // 4. Remove from Search Index
    await _searchIndexService.removeEntityIndex(originalTxId);

    // 5. Insert Audit Log
    await _db.into(_db.auditLogs).insert(db.AuditLogsCompanion(
          id: Value(_uuid.v4()),
          entityType: const Value('transaction'),
          entityId: Value(originalTxId),
          action: const Value('voided'),
          detailsJson: Value('{"void_transaction_id": "$voidTxId"}'),
          createdAt: Value(now),
        ));
  }
}
