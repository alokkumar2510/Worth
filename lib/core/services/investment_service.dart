import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import '../../database/database.dart';
import '../providers/dependency_provider.dart';
import '../providers/mock_database.dart';
import '../providers/app_providers.dart';

class InvestmentService {
  final Ref _ref;
  final _uuid = const Uuid();

  InvestmentService(this._ref);

  AppDatabase get _db => _ref.read(realDatabaseProvider);
  bool get _isMock => _ref.read(mockModeProvider);

  Future<void> buyInvestment({
    required String investmentId,
    String? fromAccountId,
    required double units,
    required double pricePerUnit,
    String? notes,
    required DateTime date,
    String? fundingSource,
    String? fundingLiabilityId,
    String? fundingDetails,
  }) async {
    if (_isMock) {
      await _ref.read(mockDatabaseProvider.notifier).buyInvestment(
        investmentId,
        fromAccountId,
        units,
        pricePerUnit,
        notes,
        date,
        fundingSource: fundingSource,
        fundingLiabilityId: fundingLiabilityId,
        fundingDetails: fundingDetails,
      );
    } else {
      final totalAmount = units * pricePerUnit;
      final companion = TransactionsCompanion(
        id: Value(_uuid.v4()),
        type: const Value('investment_buy'),
        amount: Value(totalAmount),
        fromAccountId: fromAccountId != null && fromAccountId.isNotEmpty ? Value(fromAccountId) : const Value(null),
        investmentId: Value(investmentId),
        pricePerUnit: Value(pricePerUnit),
        units: Value(units),
        notes: Value(notes ?? 'Bought $units units @ $pricePerUnit'),
        transactionDate: Value(date),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
        fundingSource: Value(fundingSource),
        fundingLiabilityId: Value(fundingLiabilityId),
        fundingDetails: Value(fundingDetails),
      );
      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
      final txId = companion.id.value;
      _ref.read(syncServiceProvider).queueOperation(entityType: 'transaction', entityId: txId, operation: 'upsert');
      
      final lots = await _db.select(_db.investmentLots).get();
      final newLot = lots.firstWhereOrNull((l) => l.buyTransactionId == txId);
      if (newLot != null) {
        _ref.read(syncServiceProvider).queueOperation(entityType: 'investment_lot', entityId: newLot.id, operation: 'upsert');
      }
    }
  }

  Future<void> sellInvestment({
    required String investmentId,
    required String toAccountId,
    required double unitsToSell,
    required double salePricePerUnit,
    String? notes,
    required DateTime date,
  }) async {
    if (_isMock) {
      await _ref.read(mockDatabaseProvider.notifier).sellInvestment(
        investmentId,
        toAccountId,
        unitsToSell,
        salePricePerUnit,
        notes,
        date,
      );
    } else {
      final totalProceeds = unitsToSell * salePricePerUnit;
      final companion = TransactionsCompanion(
        id: Value(_uuid.v4()),
        type: const Value('investment_sell'),
        amount: Value(totalProceeds),
        toAccountId: Value(toAccountId),
        investmentId: Value(investmentId),
        pricePerUnit: Value(salePricePerUnit),
        units: Value(unitsToSell),
        notes: Value(notes ?? 'Sold $unitsToSell units @ $salePricePerUnit'),
        transactionDate: Value(date),
        createdAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      );
      await _ref.read(realTransactionServiceProvider).createTransaction(companion);
      final txId = companion.id.value;
      _ref.read(syncServiceProvider).queueOperation(entityType: 'transaction', entityId: txId, operation: 'upsert');
      
      final consumptions = await _db.select(_db.investmentLotConsumptions).get();
      final sellConsumptions = consumptions.where((c) => c.sellTransactionId == txId);
      for (final cons in sellConsumptions) {
        _ref.read(syncServiceProvider).queueOperation(entityType: 'investment_lot', entityId: cons.lotId, operation: 'upsert');
      }
    }
  }

  Future<void> updateMarketValue(String investmentId, double newValue) async {
    if (_isMock) {
      _ref.read(mockDatabaseProvider.notifier).updateInvestmentMarketValue(investmentId, newValue);
    } else {
      final query = _db.update(_db.investments)..where((tbl) => tbl.id.equals(investmentId));
      await query.write(InvestmentsCompanion(
        marketValue: Value(newValue),
        marketValueUpdatedAt: Value(DateTime.now().toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ));
      // Rebuild caches after market price changes
      await _ref.read(realBalanceCacheServiceProvider).rebuildCache();
    }
  }

  Future<double> calculateRealizedProfit(String investmentId) async {
    if (_isMock) {
      final state = _ref.read(mockDatabaseProvider);
      double total = 0.0;
      for (final cons in state.investmentLotConsumptions) {
        final lot = state.investmentLots.firstWhereOrNull((l) => l.id == cons.lotId);
        if (lot != null && lot.investmentId == investmentId) {
          total += cons.realizedGainLoss;
        }
      }
      return total;
    } else {
      final query = _db.select(_db.investmentLotConsumptions).join([
        innerJoin(
          _db.investmentLots,
          _db.investmentLots.id.equalsExp(_db.investmentLotConsumptions.lotId),
        ),
      ])..where(_db.investmentLots.investmentId.equals(investmentId));

      final rows = await query.get();
      double total = 0.0;
      for (final row in rows) {
        final cons = row.readTable(_db.investmentLotConsumptions);
        total += cons.realizedGainLoss;
      }
      return total;
    }
  }

  Future<double> calculateUnrealizedProfit(String investmentId) async {
    if (_isMock) {
      final state = _ref.read(mockDatabaseProvider);
      return state.getInvestmentUnrealizedGain(investmentId);
    } else {
      final inv = await (_db.select(_db.investments)..where((tbl) => tbl.id.equals(investmentId))).getSingleOrNull();
      final cache = await (_db.select(_db.investmentBalanceCaches)..where((tbl) => tbl.investmentId.equals(investmentId))).getSingleOrNull();
      if (inv == null || cache == null) return 0.0;

      final mPrice = inv.marketValue ?? 0.0;
      final currentMV = mPrice * cache.unitsHeld;
      return currentMV - cache.investedCapital;
    }
  }
}
