import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final db.AppDatabase _db;

  DashboardRepositoryImpl(this._db);

  @override
  Future<double> getAssetsSum() async {
    final query = _db.select(_db.accounts).join([
      innerJoin(
        _db.accountBalanceCaches,
        _db.accountBalanceCaches.accountId.equalsExp(_db.accounts.id),
      ),
    ])..where(_db.accounts.type.isNotValue('credit') & _db.accounts.isArchived.equals(0));

    final rows = await query.get();
    double total = 0.0;
    for (final row in rows) {
      final cache = row.readTable(_db.accountBalanceCaches);
      total += cache.cashBalance;
    }
    return total;
  }

  @override
  Future<double> getLiabilitiesSum() async {
    // 1. Credit Card Accounts
    final ccQuery = _db.select(_db.accounts).join([
      innerJoin(
        _db.accountBalanceCaches,
        _db.accountBalanceCaches.accountId.equalsExp(_db.accounts.id),
      ),
    ])..where(_db.accounts.type.equals('credit') & _db.accounts.isArchived.equals(0));

    final ccRows = await ccQuery.get();
    double ccTotal = 0.0;
    for (final row in ccRows) {
      final cache = row.readTable(_db.accountBalanceCaches);
      ccTotal += cache.liabilityBalance;
    }

    // 2. Personal Debt
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

    return ccTotal + debtTotal;
  }

  @override
  Future<double> getReceivablesSum() async {
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

  @override
  Future<double> getInvestmentPrincipalSum() async {
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

  @override
  Future<double> getExpectedIncomeSum() async {
    final query = _db.select(_db.expectedIncomes)..where((tbl) => (tbl as db.$ExpectedIncomesTable).status.equals('pending'));
    final list = await query.get();
    double total = 0.0;
    for (final item in list) {
      total += item.amount;
    }
    return total;
  }
}
