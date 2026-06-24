import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../database/database.dart' as db;
import 'balance_cache_service.dart';
import 'fifo_lot_service.dart';
import '../services/search_index_service.dart';
import '../services/sync_service.dart';

class TransactionProcessor {
  final db.AppDatabase _db;
  final BalanceCacheService _cacheService;
  final FifoLotService _fifoLotService;
  final SearchIndexService _searchIndexService;
  final SyncService? _syncService;
  final _uuid = const Uuid();

  TransactionProcessor(
    this._db,
    this._cacheService,
    this._fifoLotService,
    this._searchIndexService, [
    this._syncService,
  ]);

  // Processes transaction insertions and updates lot configurations & balance caches
  Future<void> processTransaction(db.TransactionsCompanion companion) async {
    if (companion.transactionUuid.present && companion.transactionUuid.value != null) {
      final existing = await (_db.select(_db.transactions)
        ..where((tbl) => tbl.transactionUuid.equals(companion.transactionUuid.value!)))
        .getSingleOrNull();
      if (existing != null) {
        return;
      }
    }

    final txId = companion.id.value;
    final type = companion.type.value;
    final amount = companion.amount.value;

    String? detectedOwnership;
    if (companion.fromAccountId.present && companion.fromAccountId.value != null) {
      final account = await (_db.select(_db.accounts)..where((tbl) => tbl.id.equals(companion.fromAccountId.value!))).getSingleOrNull();
      if (account != null) {
        detectedOwnership = account.ownershipType;
      }
    } else if (companion.toAccountId.present && companion.toAccountId.value != null) {
      final account = await (_db.select(_db.accounts)..where((tbl) => tbl.id.equals(companion.toAccountId.value!))).getSingleOrNull();
      if (account != null) {
        detectedOwnership = account.ownershipType;
      }
    }
    detectedOwnership ??= 'PERSONAL';

    var finalCompanion = companion;

    if (type == 'investment_buy') {
      finalCompanion = finalCompanion.copyWith(
        fundSource: Value(detectedOwnership),
        ownershipType: Value(detectedOwnership),
        sourceAccount: companion.fromAccountId,
      );
      await (_db.update(_db.investments)..where((tbl) => tbl.id.equals(companion.investmentId.value!))).write(
        db.InvestmentsCompanion(
          fundSource: Value(detectedOwnership),
          ownershipType: Value(detectedOwnership),
          sourceAccount: companion.fromAccountId,
        ),
      );
    } else if (type == 'borrow_money' || type == 'repay_money') {
      finalCompanion = finalCompanion.copyWith(
        fundSource: const Value('BORROWED'),
        ownershipType: const Value('BORROWED'),
        liabilityType: const Value('BORROWED_CAPITAL'),
      );
    } else if (type == 'lend_money' || type == 'recover_money') {
      finalCompanion = finalCompanion.copyWith(
        fundSource: const Value('PERSONAL'),
        ownershipType: const Value('PERSONAL'),
      );
    }

    await _db.into(_db.transactions).insert(finalCompanion);
    if (_syncService != null) {
      await _syncService!.queueOperation(
        entityType: 'transaction',
        entityId: txId,
        operation: 'upsert',
      );
    }

    // 2. Handle special Investment types
    if (type == 'investment_buy') {
      final double unitsVal = companion.units.value ?? 0.0;
      final double priceVal = companion.pricePerUnit.value ?? 0.0;
      final lotId = _uuid.v4();
      await _db.into(_db.investmentLots).insert(db.InvestmentLotsCompanion(
            id: Value(lotId),
            investmentId: Value(companion.investmentId.value!),
            buyTransactionId: Value(txId),
            unitsPurchased: Value(unitsVal),
            unitsRemaining: Value(unitsVal),
            costPerUnit: Value(priceVal),
            purchaseDate: companion.transactionDate,
            createdAt: Value(DateTime.now().toUtc()),
            updatedAt: Value(DateTime.now().toUtc()),
            fundingSource: companion.fundingSource,
            fundingLiabilityId: companion.fundingLiabilityId,
            fundingDetails: companion.fundingDetails,
          ));
      if (_syncService != null) {
        await _syncService!.queueOperation(
          entityType: 'investment_lot',
          entityId: lotId,
          operation: 'upsert',
        );
      }
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
        if (_syncService != null) {
          await _syncService!.queueOperation(
            entityType: 'investment_lot',
            entityId: lot.id,
            operation: 'upsert',
          );
        }
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
    if (_syncService != null) {
      await _syncService!.queueOperation(
        entityType: 'transaction',
        entityId: originalTxId,
        operation: 'upsert',
      );
    }

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
    if (_syncService != null) {
      await _syncService!.queueOperation(
        entityType: 'transaction',
        entityId: voidTxId,
        operation: 'upsert',
      );
    }

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

    // Search and recursively void linked transactions (e.g. borrow transactions)
    final linkedTxs = await (_db.select(_db.transactions)
      ..where((tbl) => tbl.id.like('$originalTxId%')))
      .get();
    for (final linkedTx in linkedTxs) {
      if (linkedTx.id.startsWith('${originalTxId}_') && linkedTx.type != 'void' && linkedTx.voidedTransactionId == null) {
        await processVoid(linkedTx.id);
      }
    }
  }
}
