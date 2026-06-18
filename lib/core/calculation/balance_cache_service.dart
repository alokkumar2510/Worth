import 'package:drift/drift.dart';
import '../../database/database.dart';

class BalanceCacheService {
  final AppDatabase _db;

  BalanceCacheService(this._db);

  // Apply a single transaction delta to the cache tables
  Future<void> applyTransaction(Transaction tx, {bool isVoidReversal = false}) async {
    final now = DateTime.now().toUtc();
    final double multiplier = isVoidReversal ? -1.0 : 1.0;
    final double amount = tx.amount * multiplier;

    // 1. Handle Account Balance Cache Updates
    if (tx.fromAccountId != null) {
      // Outflow from fromAccount
      await _applyOutflow(tx.fromAccountId!, amount, tx.type, tx.id, now);
    }
    if (tx.toAccountId != null) {
      // Inflow to toAccount
      await _applyInflow(tx.toAccountId!, amount, tx.type, tx.id, now);
    }

    // 2. Handle Person Balance Cache Updates
    if (tx.personId != null) {
      switch (tx.type) {
        case 'borrow_money':
          await _updatePersonCache(tx.personId!, 0.0, amount, tx.id, now);
          break;
        case 'repay_money':
          await _updatePersonCache(tx.personId!, 0.0, -amount, tx.id, now);
          break;
        case 'lend_money':
          await _updatePersonCache(tx.personId!, amount, 0.0, tx.id, now);
          break;
        case 'recover_money':
          await _updatePersonCache(tx.personId!, -amount, 0.0, tx.id, now);
          break;
        case 'interest_accrued':
          // Accrued interest increases either receivable or liability depending on current status
          final current = await _getPersonCache(tx.personId!);
          if (current.receivableBalance > 0) {
            await _updatePersonCache(tx.personId!, amount, 0.0, tx.id, now);
          } else if (current.liabilityBalance > 0) {
            await _updatePersonCache(tx.personId!, 0.0, amount, tx.id, now);
          } else {
            // Default to receivable if no active balances
            await _updatePersonCache(tx.personId!, amount, 0.0, tx.id, now);
          }
          break;
      }
    }

    // 3. Handle Investment Balance Cache Updates
    if (tx.investmentId != null) {
      if (tx.type == 'investment_buy') {
        // Buy increases invested capital by the purchase transaction amount
        // Note: units_purchased is fetched from the investment lot that was created
        final lot = await (_db.select(_db.investmentLots)..where((tbl) => tbl.buyTransactionId.equals(tx.id))).getSingleOrNull();
        final double units = lot?.unitsPurchased ?? 0.0;
        await _updateInvestmentCache(tx.investmentId!, amount, units * multiplier, tx.id, now);
      } else if (tx.type == 'investment_sell') {
        // Sell decreases invested capital by the cost basis of the consumed lots
        final consumptions = await (_db.select(_db.investmentLotConsumptions)..where((tbl) => tbl.sellTransactionId.equals(tx.id))).get();
        double totalCostBasis = 0.0;
        double totalUnits = 0.0;
        for (final c in consumptions) {
          totalCostBasis += c.costBasis;
          totalUnits += c.unitsConsumed;
        }
        // Sell decreases capital and units
        await _updateInvestmentCache(tx.investmentId!, -totalCostBasis * multiplier, -totalUnits * multiplier, tx.id, now);
      }
    }
  }

  // Replays the entire transaction log from scratch and rebuilds all cache tables
  Future<void> rebuildCache() async {
    await _db.transaction(() async {
      // 1. Clear caches
      await _db.delete(_db.accountBalanceCaches).go();
      await _db.delete(_db.personBalanceCaches).go();
      await _db.delete(_db.investmentBalanceCaches).go();

      // 2. Clear remaining units on all investment lots back to their units_purchased
      // In a real rebuild, we need to reset unitsRemaining before replaying sales
      final allLots = await _db.select(_db.investmentLots).get();
      for (final lot in allLots) {
        await _db.update(_db.investmentLots).replace(
              lot.copyWith(unitsRemaining: lot.unitsPurchased),
            );
      }
      // 3. Fetch all active, non-voided transactions ordered by date
      final activeTx = await (_db.select(_db.transactions)
            ..where((tbl) => tbl.type.equals('void').not() & tbl.voidedTransactionId.isNull())
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.transactionDate, mode: OrderingMode.asc)]))
          .get();
      for (final tx in activeTx) {
        await applyTransaction(tx);
      }
    });
  }

  // Helper methods for Account Caches
  Future<void> _applyInflow(String accountId, double amount, String txType, String txId, DateTime now) async {
    final account = await (_db.select(_db.accounts)..where((tbl) => tbl.id.equals(accountId))).getSingleOrNull();
    final isCredit = account?.type == 'credit';
    if (isCredit) {
      if (txType == 'borrow_money' || txType == 'interest_accrued') {
        await _updateAccountCache(accountId, 0.0, amount, txId, now);
      } else {
        await _updateAccountCache(accountId, 0.0, -amount, txId, now);
      }
    } else {
      await _updateAccountCache(accountId, amount, 0.0, txId, now);
    }
  }

  Future<void> _applyOutflow(String accountId, double amount, String txType, String txId, DateTime now) async {
    final account = await (_db.select(_db.accounts)..where((tbl) => tbl.id.equals(accountId))).getSingleOrNull();
    final isCredit = account?.type == 'credit';
    if (isCredit) {
      await _updateAccountCache(accountId, 0.0, amount, txId, now);
    } else {
      await _updateAccountCache(accountId, -amount, 0.0, txId, now);
    }
  }

  Future<void> _updateAccountCache(String accountId, double cashDelta, double liabilityDelta, String txId, DateTime now) async {
    final existing = await (_db.select(_db.accountBalanceCaches)..where((tbl) => tbl.accountId.equals(accountId))).getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.accountBalanceCaches).insert(AccountBalanceCachesCompanion(
            accountId: Value(accountId),
            cashBalance: Value(cashDelta),
            liabilityBalance: Value(liabilityDelta),
            lastTransactionId: Value(txId),
            updatedAt: Value(now),
          ));
    } else {
      await _db.update(_db.accountBalanceCaches).replace(existing.copyWith(
            cashBalance: existing.cashBalance + cashDelta,
            liabilityBalance: existing.liabilityBalance + liabilityDelta,
            lastTransactionId: Value(txId),
            updatedAt: now,
          ));
    }
  }

  // Helper methods for Person Caches
  Future<PersonBalanceCacheData> _getPersonCache(String personId) async {
    final existing = await (_db.select(_db.personBalanceCaches)..where((tbl) => tbl.personId.equals(personId))).getSingleOrNull();
    if (existing != null) return existing;
    return PersonBalanceCacheData(
      personId: personId,
      receivableBalance: 0.0,
      liabilityBalance: 0.0,
      updatedAt: DateTime.now().toUtc(),
    );
  }

  Future<void> _updatePersonCache(String personId, double receivableDelta, double liabilityDelta, String txId, DateTime now) async {
    final existing = await (_db.select(_db.personBalanceCaches)..where((tbl) => tbl.personId.equals(personId))).getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.personBalanceCaches).insert(PersonBalanceCachesCompanion(
            personId: Value(personId),
            receivableBalance: Value(receivableDelta),
            liabilityBalance: Value(liabilityDelta),
            lastTransactionId: Value(txId),
            updatedAt: Value(now),
          ));
    } else {
      await _db.update(_db.personBalanceCaches).replace(existing.copyWith(
            receivableBalance: existing.receivableBalance + receivableDelta,
            liabilityBalance: existing.liabilityBalance + liabilityDelta,
            lastTransactionId: Value(txId),
            updatedAt: now,
          ));
    }
  }

  // Helper methods for Investment Caches
  Future<void> _updateInvestmentCache(String investmentId, double capitalDelta, double unitsDelta, String txId, DateTime now) async {
    final existing = await (_db.select(_db.investmentBalanceCaches)..where((tbl) => tbl.investmentId.equals(investmentId))).getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.investmentBalanceCaches).insert(InvestmentBalanceCachesCompanion(
            investmentId: Value(investmentId),
            investedCapital: Value(capitalDelta),
            unitsHeld: Value(unitsDelta),
            lastTransactionId: Value(txId),
            updatedAt: Value(now),
          ));
    } else {
      await _db.update(_db.investmentBalanceCaches).replace(existing.copyWith(
            investedCapital: existing.investedCapital + capitalDelta,
            unitsHeld: existing.unitsHeld + unitsDelta,
            lastTransactionId: Value(txId),
            updatedAt: now,
          ));
    }
  }
}
