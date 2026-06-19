import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worth/core/providers/dependency_provider.dart';
import 'package:worth/core/providers/mock_database.dart';

void main() {
  group('Financial Funding & Debt Alignment Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          mockModeProvider.overrideWith((ref) => true),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Creating manual investment/receivable/liability does not modify cash/bank balances', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // 1. Create a bank account with 50,000
      final bank = await notifier.addAccount(
        'Main Primary Bank',
        'bank',
        'Primary storage of funds',
        50000.0,
      );

      var state = container.read(mockDatabaseProvider);
      expect(state.getAccountCashBalance(bank.id), equals(50000.0));

      // 2. Manually add an investment by passing `null` bank account ID
      final inv = await notifier.addInvestment(
        'Gold ETF Manual',
        'etf',
        'GOLDBEES',
        'Manual Gold asset',
        20000.0,
        fundingSource: 'existing_cash',
      );
      await notifier.buyInvestment(
        inv.id,
        null,
        1.0,
        20000.0,
        'Opening Buy',
        DateTime.now(),
        fundingSource: 'existing_cash',
      );

      // Verify bank cash balance remains unchanged
      state = container.read(mockDatabaseProvider);
      expect(state.getAccountCashBalance(bank.id), equals(50000.0));
      expect(state.getInvestmentInvestedCapital(inv.id), equals(20000.0));

      // 3. Manually add a Receivable (Lend money) passing `null` bank account ID
      final friend = await notifier.addPerson('John Doe', null, 'Friend');
      await notifier.addLendTransaction(friend.id, null, 5000.0, 'Manual lend', DateTime.now());

      // Verify bank cash balance remains unchanged
      state = container.read(mockDatabaseProvider);
      expect(state.getAccountCashBalance(bank.id), equals(50000.0));
      expect(state.getPersonReceivableBalance(friend.id), equals(5000.0));

      // 4. Manually add a Liability (Borrow money) passing `null` bank account ID
      final creditor = await notifier.addPerson('Creditor Bank', null, 'Creditor');
      await notifier.addBorrowTransaction(creditor.id, null, 10000.0, 'Manual borrow', DateTime.now());

      // Verify bank cash balance remains unchanged
      state = container.read(mockDatabaseProvider);
      expect(state.getAccountCashBalance(bank.id), equals(50000.0));
      expect(state.getPersonLiabilityBalance(creditor.id), equals(10000.0));
    });

    test('Linking investment to a borrowed money liability calculates Net Worth correctly without inflating it', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // 1. Create a personal creditor
      final creditor = await notifier.addPerson('Lender Bob', null, 'Creditor');

      // 2. Borrow 10,000 from creditor (Liability = 10,000)
      // Since it is manual and doesn't deposit to a cash account, we pass `null` to bank account ID
      await notifier.addBorrowTransaction(creditor.id, null, 10000.0, 'Borrowed to invest', DateTime.now());

      var state = container.read(mockDatabaseProvider);
      expect(state.getPersonLiabilityBalance(creditor.id), equals(10000.0));
      expect(state.totalAssets, equals(0.0));
      expect(state.totalLiabilities, equals(10000.0));
      expect(state.netWorth, equals(-10000.0));

      // 3. Buy an investment of 10,000 funded by this liability
      final inv = await notifier.addInvestment(
        'Stock Funded by bob',
        'stock',
        'AAPL',
        'AAPL Stock',
        10000.0,
        fundingSource: 'liability_borrowed',
        fundingLiabilityId: 'person_${creditor.id}',
      );
      await notifier.buyInvestment(
        inv.id,
        null,
        1.0,
        10000.0,
        'Opening Buy',
        DateTime.now(),
        fundingSource: 'liability_borrowed',
        fundingLiabilityId: 'person_${creditor.id}',
      );

      state = container.read(mockDatabaseProvider);
      
      // Verify assets, liabilities and Net Worth
      // Asset (Invested Capital) = 10,000. Liability = 10,000.
      expect(state.getInvestmentInvestedCapital(inv.id), equals(10000.0));
      expect(state.totalAssets, equals(10000.0));
      expect(state.totalLiabilities, equals(10000.0));
      // Net Worth = 10k - 10k = 0. No inflation!
      expect(state.netWorth, equals(0.0));

      // Verify debt-funded vs self-funded metrics
      expect(state.debtFundedAssets, equals(10000.0));
      expect(state.selfFundedAssets, equals(0.0));
      expect(state.fundingSourceBreakdown['liability_borrowed'], equals(10000.0));
    });

    test('Mixed funding sources parses percentage correctly', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // Create an investment funded 40% by debt (mixed sources)
      final inv = await notifier.addInvestment(
        'Mixed Asset',
        'mutual_fund',
        'MIXED',
        'Mixed source MF',
        25000.0,
        fundingSource: 'mixed_sources',
        fundingDetails: '{"debt_pct": 40}',
      );
      await notifier.buyInvestment(
        inv.id,
        null,
        1.0,
        25000.0,
        'Opening Buy',
        DateTime.now(),
        fundingSource: 'mixed_sources',
        fundingDetails: '{"debt_pct": 40}',
      );

      final state = container.read(mockDatabaseProvider);

      expect(state.getInvestmentInvestedCapital(inv.id), equals(25000.0));
      // 40% of 25,000 = 10,000 is debt-funded
      expect(state.debtFundedAssets, equals(10000.0));
      // 60% of 25,000 = 15,000 is self-funded
      expect(state.selfFundedAssets, equals(15000.0));
      expect(state.fundingSourceBreakdown['mixed_sources'], equals(25000.0));
    });
  });
}
