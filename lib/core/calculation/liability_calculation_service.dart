import 'package:collection/collection.dart';
import '../../database/database.dart';
import '../providers/mock_database.dart';

class LiabilityCalculationResult {
  final String liabilityId;
  final String name;
  final String type; // credit_card | personal_loan | borrowing | education_loan | manual_liability | mtf_position | other
  final double rawBalance; // Opening balance / principal / borrowed
  final double purchases; // Only for credit card
  final double interest; // Interest accrued
  final double fees; // Only for credit card
  final double adjustments; // Applied balance adjustments
  final double payments; // Repayments / payments
  final double credits; // Refunds / credits (only for credit card)
  final double finalBalance;
  final String formulaUsed;

  LiabilityCalculationResult({
    required this.liabilityId,
    required this.name,
    required this.type,
    required this.rawBalance,
    required this.purchases,
    required this.interest,
    required this.fees,
    required this.adjustments,
    required this.payments,
    required this.credits,
    required this.finalBalance,
    required this.formulaUsed,
  });
}

class LiabilityCalculationService {
  // Centralized calculations using MockDatabaseState as input (used widely across UI and services)

  static LiabilityCalculationResult calculateCreditCard(
    Account acc,
    List<Transaction> allTransactions,
    List<Adjustment> allAdjustments,
  ) {
    final txs = allTransactions.where((t) =>
        (t.fromAccountId == acc.id || t.toAccountId == acc.id) &&
        t.voidedTransactionId == null &&
        t.type != 'void');

    // 1. Opening Balance: borrow_money where credit card is destination
    final double openingBalance = txs
        .where((t) => t.toAccountId == acc.id && t.type == 'borrow_money')
        .fold(0.0, (sum, t) => sum + t.amount);

    // 2. Purchases: spending from the credit card account (fromAccountId == acc.id)
    // Excluding Fee and Interest categories
    final double purchases = txs
        .where((t) =>
            t.fromAccountId == acc.id &&
            t.category != 'Fee' &&
            t.category != 'Fees' &&
            t.category != 'Interest')
        .fold(0.0, (sum, t) => sum + t.amount);

    // 3. Interest: interest_accrued to account OR transactions from account with 'Interest' category
    final double interest = txs
        .where((t) =>
            (t.toAccountId == acc.id && t.type == 'interest_accrued') ||
            (t.fromAccountId == acc.id && t.category == 'Interest'))
        .fold(0.0, (sum, t) => sum + t.amount);

    // 4. Fees: transactions from account with Fee/Fees categories
    final double fees = txs
        .where((t) =>
            t.fromAccountId == acc.id &&
            (t.category == 'Fee' || t.category == 'Fees' || t.category == 'Card Fee'))
        .fold(0.0, (sum, t) => sum + t.amount);

    // 5. Payments: transactions to account, not borrow/interest/refund/credits
    final double payments = txs
        .where((t) =>
            t.toAccountId == acc.id &&
            t.type != 'borrow_money' &&
            t.type != 'interest_accrued' &&
            t.category != 'Credit' &&
            t.category != 'Refund' &&
            t.category != 'Cashback')
        .fold(0.0, (sum, t) => sum + t.amount);

    // 6. Credits: refunds or cashbacks to account
    final double credits = txs
        .where((t) =>
            t.toAccountId == acc.id &&
            (t.category == 'Credit' || t.category == 'Refund' || t.category == 'Cashback'))
        .fold(0.0, (sum, t) => sum + t.amount);

    // 7. Adjustments
    final double adjs = allAdjustments
        .where((a) => a.entityId == acc.id && a.entityType == 'account')
        .fold(0.0, (sum, a) => sum + a.adjustedAmount);

    final double finalBalance = openingBalance + purchases + interest + fees - payments - credits + adjs;

    return LiabilityCalculationResult(
      liabilityId: acc.id,
      name: acc.name,
      type: 'credit_card',
      rawBalance: openingBalance,
      purchases: purchases,
      interest: interest,
      fees: fees,
      adjustments: adjs,
      payments: payments,
      credits: credits,
      finalBalance: finalBalance,
      formulaUsed: 'Outstanding Balance = Opening Balance + Purchases + Interest + Fees - Payments - Credits + Adjustments',
    );
  }

  static LiabilityCalculationResult calculatePeerLiability(
    Person person,
    List<Transaction> allTransactions,
    List<Adjustment> allAdjustments,
  ) {
    final txs = allTransactions.where((t) =>
        t.personId == person.id &&
        t.voidedTransactionId == null &&
        t.type != 'void');

    // 1. Principal: borrow_money transactions
    final double principal = txs
        .where((t) => t.type == 'borrow_money')
        .fold(0.0, (sum, t) => sum + t.amount);

    // 2. Interest Accrued: interest_accrued transactions
    final double interest = txs
        .where((t) => t.type == 'interest_accrued')
        .fold(0.0, (sum, t) => sum + t.amount);

    // 3. Payments Made: repay_money transactions
    final double payments = txs
        .where((t) => t.type == 'repay_money')
        .fold(0.0, (sum, t) => sum + t.amount);

    // 4. Adjustments
    final double adjs = allAdjustments
        .where((a) => a.entityId == person.id && a.entityType == 'person_liability')
        .fold(0.0, (sum, a) => sum + a.adjustedAmount);

    final double finalBalance = principal + interest - payments + adjs;

    // Determine type: personal_loan | borrowing | education_loan | manual_liability
    final String type = person.type;

    String formula = 'Outstanding Balance = Principal + Accrued Interest - Payments Made + Adjustments';

    return LiabilityCalculationResult(
      liabilityId: person.id,
      name: person.name,
      type: type,
      rawBalance: principal,
      purchases: 0.0,
      interest: interest,
      fees: 0.0,
      adjustments: adjs,
      payments: payments,
      credits: 0.0,
      finalBalance: finalBalance,
      formulaUsed: formula,
    );
  }

  static LiabilityCalculationResult calculateMtfPosition(
    MtfPosition pos,
    List<Transaction> allTransactions,
    DateTime today,
  ) {
    if (pos.isClosed == 1) {
      return LiabilityCalculationResult(
        liabilityId: pos.id,
        name: pos.instrument,
        type: 'mtf_position',
        rawBalance: pos.borrowedCapital,
        purchases: 0.0,
        interest: 0.0,
        fees: 0.0,
        adjustments: 0.0,
        payments: pos.borrowedCapital,
        credits: 0.0,
        finalBalance: 0.0,
        formulaUsed: 'Outstanding MTF = Borrowed Amount + Accrued Interest - Repayments (Closed: Balance = 0)',
      );
    }

    final double borrowedAmount = pos.borrowedCapital;

    // Calculate holding days and accrued interest till today
    final DateTime endDate = today;
    final int daysHeld = endDate.difference(DateTime(pos.interestStartDate.year, pos.interestStartDate.month, pos.interestStartDate.day)).inDays;
    final double dailyInterest = borrowedAmount * (pos.interestRate / 100) / 365;
    final double accruedInterest = dailyInterest * daysHeld;

    // Repayments: repay_money transactions associated with the MTF position's investmentId
    final double repayments = allTransactions
        .where((t) =>
            t.investmentId == pos.investmentId &&
            t.type == 'repay_money' &&
            t.voidedTransactionId == null)
        .fold(0.0, (sum, t) => sum + t.amount);

    final double finalBalance = (borrowedAmount + accruedInterest - repayments).clamp(0.0, double.infinity);

    return LiabilityCalculationResult(
      liabilityId: pos.id,
      name: pos.instrument,
      type: 'mtf_position',
      rawBalance: borrowedAmount,
      purchases: 0.0,
      interest: accruedInterest,
      fees: 0.0,
      adjustments: 0.0,
      payments: repayments,
      credits: 0.0,
      finalBalance: finalBalance,
      formulaUsed: 'Outstanding MTF = Borrowed Amount + Accrued Interest - Repayments',
    );
  }

  // Unified method to compute a single liability details from MockDatabaseState
  static LiabilityCalculationResult? calculateSingleLiability(
    MockDatabaseState state,
    String rawId, [
    DateTime? today,
  ]) {
    final targetToday = today ?? DateTime.now();

    // Check prefix
    if (rawId.startsWith('acc_')) {
      final cleanId = rawId.substring(4);
      final acc = state.accounts.firstWhereOrNull((a) => a.id == cleanId);
      if (acc != null) {
        return calculateCreditCard(acc, state.transactions, state.adjustments);
      }
    } else if (rawId.startsWith('person_')) {
      final cleanId = rawId.substring(7);
      final person = state.people.firstWhereOrNull((p) => p.id == cleanId);
      if (person != null) {
        return calculatePeerLiability(person, state.transactions, state.adjustments);
      }
    } else {
      // Try clean IDs
      final acc = state.accounts.firstWhereOrNull((a) => a.id == rawId);
      if (acc != null && acc.type == 'credit') {
        return calculateCreditCard(acc, state.transactions, state.adjustments);
      }

      final person = state.people.firstWhereOrNull((p) => p.id == rawId);
      if (person != null) {
        return calculatePeerLiability(person, state.transactions, state.adjustments);
      }

      final mtf = state.mtfPositions.firstWhereOrNull((m) => m.id == rawId);
      if (mtf != null) {
        return calculateMtfPosition(mtf, state.transactions, targetToday);
      }
    }

    return null;
  }
  static double calculateCreditCardLiability(MockDatabaseState state) {
    double total = 0.0;
    final ccCards = state.accounts.where((a) => a.isArchived == 0 && (a.type == 'credit' || a.liabilityType == 'CREDIT_CARD'));
    for (final cc in ccCards) {
      total += calculateCreditCard(cc, state.transactions, state.adjustments).finalBalance;
    }
    return total;
  }

  static double calculateBorrowedCapitalLiability(MockDatabaseState state) {
    double total = 0.0;
    final peers = state.people.where((p) => p.isArchived == 0 && p.type != 'broker' && (p.ownershipType == 'BORROWED' || p.liabilityType == 'BORROWED_CAPITAL' || p.type == 'borrowing'));
    for (final p in peers) {
      final bal = calculatePeerLiability(p, state.transactions, state.adjustments).finalBalance;
      if (bal > 0) {
        total += bal;
      }
    }
    return total;
  }

  static double calculateMtfLiability(MockDatabaseState state, [DateTime? today]) {
    final targetToday = today ?? DateTime.now();
    double total = 0.0;
    final mtfs = state.mtfPositions.where((m) => m.isClosed == 0 && m.deletedAt == null);
    for (final mtf in mtfs) {
      total += calculateMtfPosition(mtf, state.transactions, targetToday).finalBalance;
    }
    return total;
  }

  // Sum of all active liability balances in the system
  static double calculateTotalLiabilities(MockDatabaseState state, [DateTime? today]) {
    final targetToday = today ?? DateTime.now();
    return calculateCreditCardLiability(state) +
        calculateBorrowedCapitalLiability(state) +
        calculateMtfLiability(state, targetToday);
  }

  // Centralized Net Worth = Total Assets - Total Liabilities
  static double calculateNetWorth(MockDatabaseState state, [DateTime? today]) {
    final targetToday = today ?? DateTime.now();

    final double personalBank = state.accounts
        .where((a) => a.isArchived == 0 && a.type != 'credit' && (a.ownershipType == 'PERSONAL' || a.ownershipType == null))
        .fold(0.0, (sum, a) => sum + state.getAccountCashBalance(a.id));

    final double borrowedCash = state.accounts
        .where((a) => a.isArchived == 0 && a.type != 'credit' && a.ownershipType == 'BORROWED')
        .fold(0.0, (sum, a) => sum + state.getAccountCashBalance(a.id));

    final double receivables = state.people
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

    final double totalAssets = personalBank + borrowedCash + receivables + personalInv + borrowedInv + mtfInv;
    final double totalLiabilities = calculateTotalLiabilities(state, targetToday);

    return totalAssets - totalLiabilities;
  }
}
