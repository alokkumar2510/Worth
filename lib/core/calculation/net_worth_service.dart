import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import '../../database/database.dart';
import 'liability_calculation_service.dart';

class NetWorthService {
  final AppDatabase _db;

  NetWorthService(this._db);

  // Helper to parse debt portion from mixed/debt funding
  double _getDebtPortion(String? fundingSource, String? fundingDetails, double assetValue) {
    if (fundingSource == 'liability_borrowed') {
      return assetValue;
    }
    if (fundingSource == 'mixed_sources') {
      if (fundingDetails != null && fundingDetails.isNotEmpty) {
        try {
          final decoded = jsonDecode(fundingDetails);
          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('debt_pct')) {
              final pct = (decoded['debt_pct'] as num).toDouble();
              return assetValue * (pct / 100.0);
            }
            if (decoded.containsKey('debt_ratio')) {
              final ratio = (decoded['debt_ratio'] as num).toDouble();
              return assetValue * ratio;
            }
            if (decoded.containsKey('debt_amount')) {
              final debtAmt = (decoded['debt_amount'] as num).toDouble();
              if (decoded.containsKey('total_amount')) {
                final totalAmt = (decoded['total_amount'] as num).toDouble();
                if (totalAmt > 0) {
                  return assetValue * (debtAmt / totalAmt);
                }
              }
              return debtAmt.clamp(0.0, assetValue);
            }
          }
        } catch (e) {
          // ignore
        }

        final lowercase = fundingDetails.toLowerCase();
        final regexPct = RegExp(r'(\d+)\s*%\s*debt');
        final matchPct = regexPct.firstMatch(lowercase);
        if (matchPct != null) {
          final pct = double.tryParse(matchPct.group(1) ?? '0') ?? 0.0;
          return assetValue * (pct / 100.0);
        }
        final regexAmt = RegExp(r'debt\s*[:=]\s*(\d+)');
        final matchAmt = regexAmt.firstMatch(lowercase);
        if (matchAmt != null) {
          final amt = double.tryParse(matchAmt.group(1) ?? '0') ?? 0.0;
          return amt.clamp(0.0, assetValue);
        }
      }
      return assetValue * 0.5; // default fallback
    }
    return 0.0;
  }

  // Computes the current Net Worth, Assets, and Liabilities from caches
  Future<NetWorthData> calculateNetWorth() async {
    // 1. Fetch account balances and join with accounts to check the type
    final accountBalances = await (_db.select(_db.accountBalanceCaches).join([
      innerJoin(_db.accounts, _db.accounts.id.equalsExp(_db.accountBalanceCaches.accountId)),
    ])).get();

    double cashAssets = 0.0;
    double creditLiabilities = 0.0;
    double debtFundedAssets = 0.0;

    final Map<String, double> breakdown = {
      'existing_cash': 0.0,
      'salary_income': 0.0,
      'business_income': 0.0,
      'receivable_collected': 0.0,
      'liability_borrowed': 0.0,
      'mixed_sources': 0.0,
    };

    for (final row in accountBalances) {
      final cache = row.readTable(_db.accountBalanceCaches);
      final account = row.readTable(_db.accounts);

      if (account.type == 'credit') {
        creditLiabilities += cache.liabilityBalance;
      } else {
        final bal = cache.cashBalance;
        cashAssets += bal;
        final source = account.fundingSource ?? 'existing_cash';
        breakdown[source] = (breakdown[source] ?? 0.0) + bal;
        debtFundedAssets += _getDebtPortion(source, account.fundingDetails, bal);
      }
    }

    // 2. Fetch person balances (outstanding receivables and liabilities)
    final personBalances = await _db.select(_db.personBalanceCaches).get();
    double receivables = 0.0;
    double personLiabilities = 0.0;
    final lendTxs = await (_db.select(_db.transactions)..where((tbl) => tbl.type.equals('lend_money'))).get();

    for (final cache in personBalances) {
      receivables += cache.receivableBalance;
      personLiabilities += cache.liabilityBalance;

      final bal = cache.receivableBalance;
      if (bal > 0) {
        final tx = lendTxs.firstWhereOrNull((t) => t.personId == cache.personId);
        final source = tx?.fundingSource ?? 'existing_cash';
        breakdown[source] = (breakdown[source] ?? 0.0) + bal;
        debtFundedAssets += _getDebtPortion(source, tx?.fundingDetails, bal);
      }
    }

    // 3. Fetch investment balances (invested capital)
    final investmentBalances = await _db.select(_db.investmentBalanceCaches).get();
    final investments = await (_db.select(_db.investments)..where((tbl) => tbl.isArchived.equals(0))).get();
    double investedCapital = 0.0;

    for (final cache in investmentBalances) {
      final bal = cache.investedCapital;
      investedCapital += bal;

      final inv = investments.firstWhereOrNull((i) => i.id == cache.investmentId);
      final source = inv?.fundingSource ?? 'existing_cash';
      breakdown[source] = (breakdown[source] ?? 0.0) + bal;
      debtFundedAssets += _getDebtPortion(source, inv?.fundingDetails, bal);
    }

    // Fetch active MTF positions
    final activeMtfs = await (_db.select(_db.mtfPositions)
          ..where((tbl) => tbl.isClosed.equals(0) & tbl.deletedAt.isNull()))
        .get();
    
    // Fetch transactions to compute interest / repayments if any
    final rawTxs = await _db.select(_db.transactions).get();
    
    double mtfLiabilities = 0.0;
    for (final pos in activeMtfs) {
      mtfLiabilities += LiabilityCalculationService.calculateMtfPosition(pos, rawTxs, DateTime.now()).finalBalance;
    }

    final double totalAssets = cashAssets + receivables + investedCapital;
    final double totalLiabilities = personLiabilities + creditLiabilities + mtfLiabilities;
    final double netWorth = totalAssets - totalLiabilities;

    return NetWorthData(
      assets: totalAssets,
      liabilities: totalLiabilities,
      netWorth: netWorth,
      investedCapital: investedCapital,
      debtFundedAssets: debtFundedAssets,
      selfFundedAssets: totalAssets - debtFundedAssets,
      fundingSourceBreakdown: breakdown,
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
  final double debtFundedAssets;
  final double selfFundedAssets;
  final Map<String, double> fundingSourceBreakdown;

  NetWorthData({
    required this.assets,
    required this.liabilities,
    required this.netWorth,
    required this.investedCapital,
    required this.debtFundedAssets,
    required this.selfFundedAssets,
    required this.fundingSourceBreakdown,
  });
}
