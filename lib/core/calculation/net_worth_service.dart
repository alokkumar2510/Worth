import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:collection/collection.dart';
import '../../database/database.dart';
import 'liability_calculation_service.dart';
import '../providers/mock_database.dart';

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
    final rawAccounts = await _db.select(_db.accounts).get();
    final rawPeople = await _db.select(_db.people).get();
    final rawTransactions = await _db.select(_db.transactions).get();
    final rawAdjustments = await _db.select(_db.adjustments).get();
    final rawMtf = await _db.select(_db.mtfPositions).get();
    final rawInvestments = await _db.select(_db.investments).get();
    final rawLots = await _db.select(_db.investmentLots).get();

    final state = MockDatabaseState(
      accounts: rawAccounts.where((x) => x.deletedAt == null).toList(),
      people: rawPeople.where((x) => x.deletedAt == null).toList(),
      transactions: rawTransactions.where((x) => x.deletedAt == null).toList(),
      adjustments: rawAdjustments.toList(),
      mtfPositions: rawMtf.where((x) => x.deletedAt == null).toList(),
      investments: rawInvestments.where((x) => x.deletedAt == null).toList(),
      investmentLots: rawLots.toList(),
    );

    final double personalBank = state.accounts
        .where((a) => a.isArchived == 0 && a.type != 'credit' && (a.ownershipType == 'PERSONAL' || a.ownershipType == null))
        .fold(0.0, (sum, a) => sum + state.getAccountCashBalance(a.id));

    final double borrowedCash = state.accounts
        .where((a) => a.isArchived == 0 && a.type != 'credit' && a.ownershipType == 'BORROWED')
        .fold(0.0, (sum, a) => sum + state.getAccountCashBalance(a.id));

    final double personalReceivables = state.people
        .where((p) => p.isArchived == 0 && (p.ownershipType == 'PERSONAL' || p.ownershipType == null))
        .fold(0.0, (sum, p) => sum + state.getPersonReceivableBalance(p.id));

    final double personalInv = state.investments
        .where((i) => i.isArchived == 0 && (i.fundSource == 'PERSONAL' || i.fundSource == null))
        .fold(0.0, (sum, i) => sum + state.getInvestmentInvestedCapital(i.id));

    final double borrowedInv = state.investments
        .where((i) => i.isArchived == 0 && i.fundSource == 'BORROWED')
        .fold(0.0, (sum, i) => sum + state.getInvestmentInvestedCapital(i.id));

    final double mtfInv = state.investments
        .where((i) => i.isArchived == 0 && i.fundSource == 'MTF')
        .fold(0.0, (sum, i) => sum + state.getInvestmentInvestedCapital(i.id));

    final double totalAssets = personalBank + borrowedCash + personalReceivables + personalInv + borrowedInv + mtfInv;

    final double borrowedCapitalLiability = LiabilityCalculationService.calculateBorrowedCapitalLiability(state);
    final double mtfLiability = LiabilityCalculationService.calculateMtfLiability(state);
    final double creditCardLiability = LiabilityCalculationService.calculateCreditCardLiability(state);
    final double totalLiabilities = borrowedCapitalLiability + mtfLiability + creditCardLiability;
    final double netWorth = totalAssets - totalLiabilities;

    final double debtFunded = borrowedCash + borrowedInv + mtfInv;
    final double selfFunded = personalBank + personalReceivables + personalInv;

    final Map<String, double> breakdown = {
      'PERSONAL': selfFunded,
      'BORROWED': borrowedCash + borrowedInv,
      'MTF': mtfInv,
    };

    return NetWorthData(
      personalBankBalance: personalBank,
      borrowedCashBalance: borrowedCash,
      personalReceivables: personalReceivables,
      personalInvestments: personalInv,
      borrowedInvestments: borrowedInv,
      mtfInvestments: mtfInv,
      assets: totalAssets,
      borrowedCapitalLiability: borrowedCapitalLiability,
      mtfLiability: mtfLiability,
      creditCardLiability: creditCardLiability,
      liabilities: totalLiabilities,
      netWorth: netWorth,
      investedCapital: personalInv + borrowedInv + mtfInv,
      debtFundedAssets: debtFunded,
      selfFundedAssets: selfFunded,
      fundingSourceBreakdown: breakdown,
    );
  }

  // Reactive stream of Net Worth changes by watching the cache tables
  Stream<NetWorthData> watchNetWorth() {
    final accountStream = _db.select(_db.accountBalanceCaches).watch();
    return accountStream.asyncMap((_) async => calculateNetWorth());
  }
}

class NetWorthData {
  final double personalBankBalance;
  final double borrowedCashBalance;
  final double personalReceivables;
  final double personalInvestments;
  final double borrowedInvestments;
  final double mtfInvestments;
  final double assets;

  final double borrowedCapitalLiability;
  final double mtfLiability;
  final double creditCardLiability;
  final double liabilities;

  final double netWorth;
  final double investedCapital;
  final double debtFundedAssets;
  final double selfFundedAssets;
  final Map<String, double> fundingSourceBreakdown;

  NetWorthData({
    required this.personalBankBalance,
    required this.borrowedCashBalance,
    required this.personalReceivables,
    required this.personalInvestments,
    required this.borrowedInvestments,
    required this.mtfInvestments,
    required this.assets,
    required this.borrowedCapitalLiability,
    required this.mtfLiability,
    required this.creditCardLiability,
    required this.liabilities,
    required this.netWorth,
    required this.investedCapital,
    required this.debtFundedAssets,
    required this.selfFundedAssets,
    required this.fundingSourceBreakdown,
  });
}
