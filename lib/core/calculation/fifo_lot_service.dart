import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../database/database.dart';

class FifoLotService {
  final AppDatabase _db;
  final _uuid = const Uuid();

  FifoLotService(this._db);

  // Computes and prepares the database updates for consuming lots under FIFO
  Future<FifoSalePlan> prepareSalePlan({
    required String investmentId,
    required double unitsToSell,
    required double totalProceeds,
    required String sellTransactionId,
  }) async {
    // 1. Fetch open lots ordered by purchase date (FIFO)
    final openLots = await (_db.select(_db.investmentLots)
          ..where((tbl) => tbl.investmentId.equals(investmentId) & tbl.unitsRemaining.isBiggerThanValue(0))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.purchaseDate, mode: OrderingMode.asc)]))
        .get();

    double remainingUnitsNeeded = unitsToSell;
    double totalCostBasis = 0.0;
    
    final List<InvestmentLot> updatedLots = [];
    final List<InvestmentLotConsumptionsCompanion> consumptions = [];

    for (final lot in openLots) {
      if (remainingUnitsNeeded <= 0) break;

      final double unitsInLot = lot.unitsRemaining;
      final double unitsConsumed = unitsInLot >= remainingUnitsNeeded ? remainingUnitsNeeded : unitsInLot;
      
      remainingUnitsNeeded -= unitsConsumed;

      final double costBasis = unitsConsumed * lot.costPerUnit;
      totalCostBasis += costBasis;

      // Allocate proceeds proportionally to the units consumed
      final double proceedsAllocated = totalProceeds * (unitsConsumed / unitsToSell);
      final double realizedGainLoss = proceedsAllocated - costBasis;

      // Update the lot's units remaining
      updatedLots.add(lot.copyWith(
        unitsRemaining: lot.unitsRemaining - unitsConsumed,
        updatedAt: DateTime.now().toUtc(),
      ));

      // Build consumption companion
      consumptions.add(InvestmentLotConsumptionsCompanion(
        id: Value(_uuid.v4()),
        sellTransactionId: Value(sellTransactionId),
        lotId: Value(lot.id),
        unitsConsumed: Value(unitsConsumed),
        costBasis: Value(costBasis),
        proceedsAllocated: Value(proceedsAllocated),
        realizedGainLoss: Value(realizedGainLoss),
        createdAt: Value(DateTime.now().toUtc()),
      ));
    }

    if (remainingUnitsNeeded > 0) {
      throw Exception('Insufficient investment units available to complete the sale. Needed: $unitsToSell, missing: $remainingUnitsNeeded');
    }

    final double totalRealizedGainLoss = totalProceeds - totalCostBasis;

    return FifoSalePlan(
      updatedLots: updatedLots,
      consumptions: consumptions,
      totalCostBasis: totalCostBasis,
      realizedGainLoss: totalRealizedGainLoss,
    );
  }
}

class FifoSalePlan {
  final List<InvestmentLot> updatedLots;
  final List<InvestmentLotConsumptionsCompanion> consumptions;
  final double totalCostBasis;
  final double realizedGainLoss;

  FifoSalePlan({
    required this.updatedLots,
    required this.consumptions,
    required this.totalCostBasis,
    required this.realizedGainLoss,
  });
}
