import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/investment.dart' as domain;
import '../../domain/entities/investment_lot.dart' as domain_lot;
import '../../domain/repositories/investment_repository.dart';

class InvestmentRepositoryImpl implements InvestmentRepository {
  final db.AppDatabase _database;

  InvestmentRepositoryImpl(this._database);

  domain.Investment _toDomain(db.Investment entity) {
    return domain.Investment(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      symbol: entity.symbol,
      marketValue: entity.marketValue,
      marketValueUpdatedAt: entity.marketValueUpdatedAt,
      isArchived: entity.isArchived,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
    );
  }

  db.InvestmentsCompanion _toCompanion(domain.Investment entity) {
    return db.InvestmentsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type),
      symbol: Value(entity.symbol),
      marketValue: Value(entity.marketValue),
      marketValueUpdatedAt: Value(entity.marketValueUpdatedAt),
      isArchived: Value(entity.isArchived),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncStatus: Value(entity.syncStatus),
    );
  }

  domain_lot.InvestmentLot _lotToDomain(db.InvestmentLot lot) {
    return domain_lot.InvestmentLot(
      id: lot.id,
      investmentId: lot.investmentId,
      buyTransactionId: lot.buyTransactionId,
      unitsPurchased: lot.unitsPurchased,
      unitsRemaining: lot.unitsRemaining,
      costPerUnit: lot.costPerUnit,
      purchaseDate: lot.purchaseDate,
      createdAt: lot.createdAt,
      updatedAt: lot.updatedAt,
      syncStatus: lot.syncStatus,
    );
  }

  db.InvestmentLotsCompanion _lotToCompanion(domain_lot.InvestmentLot lot) {
    return db.InvestmentLotsCompanion(
      id: Value(lot.id),
      investmentId: Value(lot.investmentId),
      buyTransactionId: Value(lot.buyTransactionId),
      unitsPurchased: Value(lot.unitsPurchased),
      unitsRemaining: Value(lot.unitsRemaining),
      costPerUnit: Value(lot.costPerUnit),
      purchaseDate: Value(lot.purchaseDate),
      createdAt: Value(lot.createdAt),
      updatedAt: Value(lot.updatedAt),
      syncStatus: Value(lot.syncStatus),
    );
  }

  @override
  Stream<List<domain.Investment>> watchAllInvestments() {
    return _database.select(_database.investments)
        .watch()
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<domain.Investment>> getAllInvestments() async {
    final list = await _database.select(_database.investments).get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<domain.Investment?> getInvestmentById(String id) async {
    final query = _database.select(_database.investments)..where((tbl) => tbl.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> createInvestment(domain.Investment investment) async {
    await _database.into(_database.investments).insert(_toCompanion(investment));
  }

  @override
  Future<void> updateInvestment(domain.Investment investment) async {
    final dbInvestment = db.Investment(
      id: investment.id,
      name: investment.name,
      type: investment.type,
      symbol: investment.symbol,
      marketValue: investment.marketValue,
      marketValueUpdatedAt: investment.marketValueUpdatedAt,
      isArchived: investment.isArchived,
      notes: investment.notes,
      createdAt: investment.createdAt,
      updatedAt: investment.updatedAt,
      syncStatus: investment.syncStatus,
    );
    await _database.update(_database.investments).replace(dbInvestment);
  }

  @override
  Future<void> deleteInvestment(String id) async {
    final inv = await getInvestmentById(id);
    if (inv != null) {
      await updateInvestment(inv.copyWith(
        isArchived: 1,
        updatedAt: DateTime.now().toUtc(),
      ));
    }
  }

  @override
  Future<List<domain.Investment>> searchInvestments(String query) async {
    final searchPattern = '%$query%';
    final search = _database.select(_database.investments)
      ..where((tbl) => tbl.name.like(searchPattern) | tbl.notes.like(searchPattern));
    final list = await search.get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<void> updateMarketValue(String id, double marketValue) async {
    final query = _database.update(_database.investments)..where((tbl) => tbl.id.equals(id));
    await query.write(db.InvestmentsCompanion(
      marketValue: Value(marketValue),
      marketValueUpdatedAt: Value(DateTime.now().toUtc()),
      updatedAt: Value(DateTime.now().toUtc()),
    ));
  }

  @override
  Future<List<domain_lot.InvestmentLot>> getOpenLots(String investmentId) async {
    final query = _database.select(_database.investmentLots)
      ..where((tbl) => tbl.investmentId.equals(investmentId) & tbl.unitsRemaining.isBiggerThanValue(0))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.purchaseDate, mode: OrderingMode.asc)]);
    final list = await query.get();
    return list.map(_lotToDomain).toList();
  }

  @override
  Future<void> createLot(domain_lot.InvestmentLot lot) async {
    await _database.into(_database.investmentLots).insert(_lotToCompanion(lot));
  }

  @override
  Future<void> updateLot(domain_lot.InvestmentLot lot) async {
    final dbLot = db.InvestmentLot(
      id: lot.id,
      investmentId: lot.investmentId,
      buyTransactionId: lot.buyTransactionId,
      unitsPurchased: lot.unitsPurchased,
      unitsRemaining: lot.unitsRemaining,
      costPerUnit: lot.costPerUnit,
      purchaseDate: lot.purchaseDate,
      createdAt: lot.createdAt,
      updatedAt: lot.updatedAt,
      syncStatus: lot.syncStatus,
    );
    await _database.update(_database.investmentLots).replace(dbLot);
  }

  @override
  Future<List<domain_lot.InvestmentLot>> getLotsForInvestment(String investmentId) async {
    final query = _database.select(_database.investmentLots)
      ..where((tbl) => tbl.investmentId.equals(investmentId))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.purchaseDate, mode: OrderingMode.asc)]);
    final list = await query.get();
    return list.map(_lotToDomain).toList();
  }
}
