import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../providers/mock_database.dart';
import 'liability_calculation_service.dart';

class FinancialCalculatorService {
  final AppDatabase _db;

  FinancialCalculatorService(this._db);

  // NET WORTH = Assets + Receivables + Investment Principal - Liabilities
  Future<double> calculateNetWorth() async {
    final assets = await calculateAssets();
    final receivables = await calculateReceivables();
    final principal = await calculateInvestmentPrincipal();
    final liabilities = await calculateLiabilities();
    return assets + receivables + principal - liabilities;
  }

  // Sum of all active cash, bank, and wallet account balances
  Future<double> calculateAssets() async {
    final query = _db.select(_db.accounts).join([
      innerJoin(
        _db.accountBalanceCaches,
        _databaseAccountMatch,
      ),
    ])..where(_db.accounts.type.equals('credit').not() & _db.accounts.isArchived.equals(0));

    final rows = await query.get();
    double total = 0.0;
    for (final row in rows) {
      final cache = row.readTable(_db.accountBalanceCaches);
      total += cache.cashBalance;
    }
    return total;
  }

  // Sum of all outstanding credit card balances, debt owed to other people, and MTF borrowed capital
  Future<double> calculateLiabilities() async {
    final rawAccounts = await _db.select(_db.accounts).get();
    final rawPeople = await _db.select(_db.people).get();
    final rawTransactions = await _db.select(_db.transactions).get();
    final rawAdjustments = await _db.select(_db.adjustments).get();
    final rawMtf = await _db.select(_db.mtfPositions).get();

    final state = MockDatabaseState(
      accounts: rawAccounts.where((x) => x.deletedAt == null).toList(),
      people: rawPeople.where((x) => x.deletedAt == null).toList(),
      transactions: rawTransactions.where((x) => x.deletedAt == null).toList(),
      adjustments: rawAdjustments.toList(),
      mtfPositions: rawMtf.where((x) => x.deletedAt == null).toList(),
      investments: const [],
      investmentLots: const [],
      investmentLotConsumptions: const [],
      expectedIncomes: const [],
      goals: const [],
      snapshots: const [],
      ipoPools: const [],
      sips: const [],
      categories: const [],
      customLabels: const [],
      portfolioHistory: const [],
      portfolioSnapshots: const [],
      recoveryAllocations: const [],
      recoveryDestinations: const [],
      currency: '₹',
    );

    return LiabilityCalculationService.calculateTotalLiabilities(state);
  }

  // Sum of all outstanding loans/receivables owed to us by other people
  Future<double> calculateReceivables() async {
    final query = _db.select(_db.people).join([
      innerJoin(
        _db.personBalanceCaches,
        _db.personBalanceCaches.personId.equalsExp(_db.people.id),
      ),
    ])..where(_db.people.isArchived.equals(0) & (_db.people.ownershipType.equals('PERSONAL') | _db.people.ownershipType.isNull()));

    final rows = await query.get();
    double total = 0.0;
    for (final row in rows) {
      final cache = row.readTable(_db.personBalanceCaches);
      total += cache.receivableBalance;
    }
    return total;
  }

  // Sum of all pending expected income items (Salary, Dividends, etc.)
  // Note: Expected Income should NOT affect Net Worth.
  Future<double> calculateExpectedIncome() async {
    final query = _db.select(_db.expectedIncomes)..where((tbl) => tbl.status.equals('pending'));
    final list = await query.get();
    double total = 0.0;
    for (final item in list) {
      total += item.amount;
    }
    return total;
  }

  // Sum of all invested capital (principal) across all active investments
  Future<double> calculateInvestmentPrincipal() async {
    final query = _db.select(_db.investments).join([
      innerJoin(
        _db.investmentBalanceCaches,
        _db.investmentBalanceCaches.investmentId.equalsExp(_db.investments.id),
      ),
    ])..where(_db.investments.isArchived.equals(0));

    final rows = await query.get();
    double total = 0.0;
    for (final row in rows) {
      final cache = row.readTable(_db.investmentBalanceCaches);
      total += cache.investedCapital;
    }
    return total;
  }

  // Sum of all realized capital gains from lot consumptions
  Future<double> calculateRealizedGain() async {
    final query = _db.select(_db.investmentLotConsumptions);
    final list = await query.get();
    double total = 0.0;
    for (final item in list) {
      total += item.realizedGainLoss;
    }
    return total;
  }

  // Sum of (market value - invested capital) across active investments
  // Note: Unrealized gains should NOT affect Net Worth until realized.
  Future<double> calculateUnrealizedGain() async {
    final query = _db.select(_db.investments).join([
      innerJoin(
        _db.investmentBalanceCaches,
        _db.investmentBalanceCaches.investmentId.equalsExp(_db.investments.id),
      ),
    ])..where(_db.investments.isArchived.equals(0));

    final rows = await query.get();
    double totalUnrealized = 0.0;
    for (final row in rows) {
      final inv = row.readTable(_db.investments);
      final cache = row.readTable(_db.investmentBalanceCaches);
      
      final mValue = inv.marketValue ?? 0.0;
      final currentMarketValue = mValue * cache.unitsHeld;
      final gain = currentMarketValue - cache.investedCapital;
      totalUnrealized += gain;
    }
    return totalUnrealized;
  }

  // Private helper to match account balance caches
  Expression<bool> get _databaseAccountMatch =>
      _db.accountBalanceCaches.accountId.equalsExp(_db.accounts.id);
}
