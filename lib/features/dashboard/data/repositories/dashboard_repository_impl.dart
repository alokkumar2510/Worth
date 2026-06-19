import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/calculation/liability_calculation_service.dart';

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
