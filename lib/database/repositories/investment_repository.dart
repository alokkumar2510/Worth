import 'package:drift/drift.dart';
import '../database.dart';

class InvestmentRepository {
  final AppDatabase _db;
  InvestmentRepository(this._db);

  Stream<List<Investment>> watchActiveInvestments() {
    return (_db.select(_db.investments)..where((tbl) => tbl.isArchived.equals(0))).watch();
  }

  Future<List<Investment>> getActiveInvestments() {
    return (_db.select(_db.investments)..where((tbl) => tbl.isArchived.equals(0))).get();
  }

  Future<Investment?> getInvestmentById(String id) {
    return (_db.select(_db.investments)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertInvestment(InvestmentsCompanion companion) {
    return _db.into(_db.investments).insert(companion);
  }

  Future<void> updateInvestment(Investment investment) {
    return _db.update(_db.investments).replace(investment);
  }
}

class InvestmentLotRepository {
  final AppDatabase _db;
  InvestmentLotRepository(this._db);

  Future<List<InvestmentLot>> getLotsForInvestment(String investmentId) {
    return (_db.select(_db.investmentLots)
          ..where((tbl) => tbl.investmentId.equals(investmentId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.purchaseDate, mode: OrderingMode.asc)]))
        .get();
  }

  Future<List<InvestmentLot>> getOpenLotsForInvestment(String investmentId) {
    return (_db.select(_db.investmentLots)
          ..where((tbl) => tbl.investmentId.equals(investmentId) & tbl.unitsRemaining.isBiggerThanValue(0))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.purchaseDate, mode: OrderingMode.asc)]))
        .get();
  }

  Future<void> insertLot(InvestmentLotsCompanion companion) {
    return _db.into(_db.investmentLots).insert(companion);
  }

  Future<void> updateLot(InvestmentLot lot) {
    return _db.update(_db.investmentLots).replace(lot);
  }
}

class InvestmentLotConsumptionRepository {
  final AppDatabase _db;
  InvestmentLotConsumptionRepository(this._db);

  Future<List<InvestmentLotConsumption>> getConsumptionsForSell(String sellTransactionId) {
    return (_db.select(_db.investmentLotConsumptions)..where((tbl) => tbl.sellTransactionId.equals(sellTransactionId))).get();
  }

  Future<void> insertConsumption(InvestmentLotConsumptionsCompanion companion) {
    return _db.into(_db.investmentLotConsumptions).insert(companion);
  }
}
