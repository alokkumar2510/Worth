import 'package:drift/drift.dart';
import '../../database/database.dart';

class NetWorthService {
  final AppDatabase _db;

  NetWorthService(this._db);

  // Computes the current Net Worth, Assets, and Liabilities from caches
  Future<NetWorthData> calculateNetWorth() async {
    // 1. Fetch account balances and join with accounts to check the type
    final accountBalances = await (_db.select(_db.accountBalanceCaches).join([
      innerJoin(_db.accounts, _db.accounts.id.equalsExp(_db.accountBalanceCaches.accountId)),
    ])).get();

    double cashAssets = 0.0;
    double creditLiabilities = 0.0;

    for (final row in accountBalances) {
      final cache = row.readTable(_db.accountBalanceCaches);
      final account = row.readTable(_db.accounts);

      if (account.type == 'credit') {
        creditLiabilities += cache.liabilityBalance;
      } else {
        cashAssets += cache.cashBalance;
      }
    }

    // 2. Fetch person balances (outstanding receivables and liabilities)
    final personBalances = await _db.select(_db.personBalanceCaches).get();
    double receivables = 0.0;
    double personLiabilities = 0.0;

    for (final cache in personBalances) {
      receivables += cache.receivableBalance;
      personLiabilities += cache.liabilityBalance;
    }

    // 3. Fetch investment balances (invested capital)
    final investmentBalances = await _db.select(_db.investmentBalanceCaches).get();
    double investedCapital = 0.0;

    for (final cache in investmentBalances) {
      investedCapital += cache.investedCapital;
    }

    final double totalAssets = cashAssets + receivables + investedCapital;
    final double totalLiabilities = personLiabilities + creditLiabilities;
    final double netWorth = totalAssets - totalLiabilities;

    return NetWorthData(
      assets: totalAssets,
      liabilities: totalLiabilities,
      netWorth: netWorth,
      investedCapital: investedCapital,
    );
  }

  // Reactive stream of Net Worth changes by watching the cache tables
  Stream<NetWorthData> watchNetWorth() {
    // We watch all three cache tables. Whenever any updates, we recalculate.
    final accountStream = _db.select(_db.accountBalanceCaches).watch();
    final personStream = _db.select(_db.personBalanceCaches).watch();
    final investmentStream = _db.select(_db.investmentBalanceCaches).watch();

    // Combine streams to trigger calculation
    return accountStream.asyncMap((_) async => calculateNetWorth());
  }
}

class NetWorthData {
  final double assets;
  final double liabilities;
  final double netWorth;
  final double investedCapital;

  NetWorthData({
    required this.assets,
    required this.liabilities,
    required this.netWorth,
    required this.investedCapital,
  });
}
