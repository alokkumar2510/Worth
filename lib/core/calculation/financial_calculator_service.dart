import 'package:drift/drift.dart';
import '../../database/database.dart';

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
    // 1. Credit Card Accounts
    final ccQuery = _db.select(_db.accounts).join([
      innerJoin(
        _db.accountBalanceCaches,
        _databaseAccountMatch,
      ),
    ])..where(_db.accounts.type.equals('credit') & _db.accounts.isArchived.equals(0));

    final ccRows = await ccQuery.get();
    double ccTotal = 0.0;
    for (final row in ccRows) {
      final cache = row.readTable(_db.accountBalanceCaches);
      ccTotal += cache.liabilityBalance;
    }

    // 2. Personal Debt (Liability towards people)
    final debtQuery = _db.select(_db.people).join([
      innerJoin(
        _db.personBalanceCaches,
        _db.personBalanceCaches.personId.equalsExp(_db.people.id),
      ),
    ])..where(_db.people.isArchived.equals(0));

    final debtRows = await debtQuery.get();
    double debtTotal = 0.0;
    for (final row in debtRows) {
      final cache = row.readTable(_db.personBalanceCaches);
      debtTotal += cache.liabilityBalance;
    }

    // 3. MTF Borrowed Capital
    final mtfQuery = _db.select(_db.mtfPositions)..where((tbl) => tbl.isClosed.equals(0));
    final mtfRows = await mtfQuery.get();
    double mtfTotal = 0.0;
    for (final row in mtfRows) {
      mtfTotal += row.borrowedCapital;
    }

    return ccTotal + debtTotal + mtfTotal;
  }

  // Sum of all outstanding loans/receivables owed to us by other people
  Future<double> calculateReceivables() async {
    final query = _db.select(_db.people).join([
      innerJoin(
        _db.personBalanceCaches,
        _db.personBalanceCaches.personId.equalsExp(_db.people.id),
      ),
    ])..where(_db.people.isArchived.equals(0));

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
