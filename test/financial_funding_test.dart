import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worth/core/providers/dependency_provider.dart';
import 'package:worth/core/providers/mock_database.dart';
import 'package:worth/core/providers/app_providers.dart';
import 'package:worth/database/database.dart' as db;
import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

    test('Adding MTF position funded via liability_borrowed (borrowed money) tracks bank cash and liability correctly', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // 1. Setup primary bank account with some cash
      final bank = await notifier.addAccount(
        'Main Primary Bank',
        'bank',
        'Primary storage of funds',
        50000.0,
      );

      // 2. Setup lender Bob
      final creditor = await notifier.addPerson('Lender Bob', null, 'Creditor');

      // 3. Add MTF position with ownCapital funded by Lender Bob
      await notifier.addMtfPosition(
        broker: 'Groww',
        instrument: 'Nifty ETF',
        units: 100.0,
        averagePrice: 100.0,
        ownCapital: 4000.0,
        borrowedCapital: 6000.0,
        interestRate: 10.0,
        openingDate: DateTime.now(),
        interestStartDate: DateTime.now(),
        fundingSource: 'liability_borrowed',
        fundingLiabilityId: 'person_${creditor.id}',
        type: 'etf',
      );

      final state = container.read(mockDatabaseProvider);

      // Verify asset and transaction attributes:
      // The total cost is 10,000 (100 units * 100 price).
      // Broker borrowed capital = 6,000. Own capital = 4,000.
      // 4,000 ownCapital is funded by Bob.
      
      // The bank account cash balance:
      // Initial = 50,000.
      // - 10,000 (ETF buy)
      // + 6,000 (broker borrow)
      // + 4,000 (ownCapital borrow from Bob)
      // Net bank balance = 50,000!
      expect(state.getAccountCashBalance(bank.id), equals(50000.0));

      // Creditor Bob's liability balance = 4,000 (own capital funded by Bob)
      expect(state.getPersonLiabilityBalance(creditor.id), equals(4000.0));

      // Total liabilities = 6,000 (broker) + 4,000 (Bob) = 10,000
      expect(state.totalLiabilities, equals(10000.0));

      print('personalBankBalance: ${state.personalBankBalance}');
      print('borrowedCashBalance: ${state.borrowedCashBalance}');
      print('personalInvestments: ${state.personalInvestments}');
      print('borrowedInvestments: ${state.borrowedInvestments}');
      print('mtfInvestments: ${state.mtfInvestments}');
      expect(state.totalAssets, equals(60000.0));

      // Net Worth = 60,000 - 10,000 = 50,000 (equal to original bank balance)
      expect(state.netWorth, equals(50000.0));
      
      // Funding metrics
      expect(state.debtFundedAssets, equals(10000.0)); // both broker and bob are debt-funded
    });
  });

  group('Real SQLite Database Mode Validation Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          mockModeProvider.overrideWith((ref) => false),
          realDatabaseProvider.overrideWith((ref) => db.AppDatabase(NativeDatabase.memory())),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Adding mutual fund manually with null fromAccountId succeeds in real mode and creates purchase lot', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // Create investment metadata
      final inv = await notifier.addInvestment(
        'Nippon India Mutual Fund',
        'mutual_fund',
        'NIPPON',
        'Manual Mutual Fund',
        150.0,
      );

      // Perform the buy transaction with null fromAccountId (simulate manual creation)
      await notifier.buyInvestment(
        inv.id,
        null,
        10.0,
        150.0,
        'Opening Buy Lot',
        DateTime.now(),
      );

      // Manually force loading the state from DB to sync with the provider
      await notifier.loadStateFromDatabase();

      // Fetch the updated database state
      final state = container.read(mockDatabaseProvider);

      // Verify that units and invested capital are calculated correctly
      expect(state.getInvestmentUnitsHeld(inv.id), equals(10.0));
      expect(state.getInvestmentInvestedCapital(inv.id), equals(1500.0));
      expect(state.getInvestmentMarketValue(inv.id), equals(1500.0));
    });

    test('Adding lender-funded investment in real mode succeeds and computes correct investment value', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // Create a person as creditor
      final creditor = await notifier.addPerson('Lender Bob', null, 'Creditor');

      // Create investment metadata funded by the creditor liability
      final inv = await notifier.addInvestment(
        'Stock Funded by bob',
        'stock',
        'AAPL',
        'AAPL Stock',
        10000.0,
        fundingSource: 'liability_borrowed',
        fundingLiabilityId: 'person_${creditor.id}',
      );

      // Buy investment funded by the creditor liability
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

      await notifier.loadStateFromDatabase();
      final state = container.read(mockDatabaseProvider);

      // Verify that units and invested capital are calculated correctly
      expect(state.getInvestmentUnitsHeld(inv.id), equals(1.0));
      expect(state.getInvestmentInvestedCapital(inv.id), equals(10000.0));
      expect(state.getInvestmentMarketValue(inv.id), equals(10000.0));
    });

    test('Adding credit-card funded investment in real mode succeeds and computes correct investment value', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // Create a credit card account
      final card = await notifier.addAccount('Gold Visa Card', 'credit', 'Opening limit', 50000.0);

      // Create investment metadata funded by the credit card
      final inv = await notifier.addInvestment(
        'Stock Funded by card',
        'stock',
        'MSFT',
        'MSFT Stock',
        5000.0,
        fundingSource: 'liability_borrowed',
        fundingLiabilityId: 'acc_${card.id}',
      );

      // Buy investment funded by the credit card
      await notifier.buyInvestment(
        inv.id,
        null,
        1.0,
        5000.0,
        'Opening Buy',
        DateTime.now(),
        fundingSource: 'liability_borrowed',
        fundingLiabilityId: 'acc_${card.id}',
      );

      await notifier.loadStateFromDatabase();
      final state = container.read(mockDatabaseProvider);

      // Verify that units and invested capital are calculated correctly
      expect(state.getInvestmentUnitsHeld(inv.id), equals(1.0));
      expect(state.getInvestmentInvestedCapital(inv.id), equals(5000.0));
      expect(state.getInvestmentMarketValue(inv.id), equals(5000.0));
    });

    group('P0 Bug Fixes Verification Tests', () {
      test('SIP stateful date cycle scheduling prevents double charging', () async {
        final notifier = container.read(mockDatabaseProvider.notifier);

        // Create a bank account
        await notifier.addAccount('Main primary bank', 'bank', 'Primary storage of funds', 50000.0);

        // Create an investment instrument
        final inv = await notifier.addInvestment('Gold BeEs', 'etf', 'GOLDBEES', 'Gold ETF', 10.0);

        // Create a SIP starting on 10 June 2026, with SIP Day 25, monthly frequency
        final startDate = DateTime(2026, 6, 10);
        await notifier.addSip(
          investmentId: inv.id,
          amount: 2000.0,
          frequency: 'monthly',
          sipDate: 25,
          startDate: startDate,
          autoCreate: 1,
          importMode: 'paid',
        );

        await Future.delayed(const Duration(milliseconds: 100));
        await notifier.loadStateFromDatabase();
        final state = container.read(mockDatabaseProvider);
        expect(state.sips.length, equals(1));
        final sip = state.sips.first;

        // Verify stateful columns
        expect(sip.firstInstallmentDate, equals(DateTime(2026, 6, 10)));
        expect(sip.lastCompletedInstallment, equals(DateTime(2026, 6, 10)));
        expect(sip.nextDueDate, equals(DateTime(2026, 7, 25))); // 25 July 2026, not 25 June 2026!

        // Verify that exactly one transaction was created (on 10 June 2026)
        final sipTxs = state.transactions.where((t) => t.notes != null && t.notes!.contains('SIP ID: ${sip.id}')).toList();
        expect(sipTxs.length, equals(1));
        expect(sipTxs.first.transactionDate, equals(DateTime(2026, 6, 10)));
      });

      test('Borrowed money peer lending automatically creates single borrow transaction and voids recursively', () async {
        final notifier = container.read(mockDatabaseProvider.notifier);

        // Create peer lender Sohan
        final sohan = await notifier.addPerson('Sohan', null, 'Creditor');

        // Create investment NIFTYBEES
        final inv = await notifier.addInvestment('NIFTYBEES', 'etf', 'NIFTYBEES', 'Nifty ETF', 10.0);

        // Buy investment funded by Sohan
        await notifier.buyInvestment(
          inv.id,
          null,
          1000.0,
          10.0,
          'Buy NIFTYBEES funded by Sohan',
          DateTime(2026, 6, 10),
          fundingSource: 'liability_borrowed',
          fundingLiabilityId: 'person_${sohan.id}',
        );

        final state = container.read(mockDatabaseProvider);

        // Verify buy transaction was created
        final buyTx = state.transactions.firstWhere((t) => t.type == 'investment_buy' && t.investmentId == inv.id);
        expect(buyTx.amount, equals(10000.0));

        // Verify borrow transaction was automatically created with stable ID
        final borrowTx = state.transactions.firstWhere((t) => t.type == 'borrow_money' && t.personId == 'person_${sohan.id}');
        expect(borrowTx.amount, equals(10000.0));
        expect(borrowTx.id, equals('${buyTx.id}_borrow'));

        // Verify there is no duplicate borrow transaction
        final borrowTxs = state.transactions.where((t) => t.type == 'borrow_money' && t.personId == 'person_${sohan.id}').toList();
        expect(borrowTxs.length, equals(1));

        // Void the buy transaction
        await notifier.voidTransaction(buyTx.id);

        final voidedState = container.read(mockDatabaseProvider);
        final voidedBuyTx = voidedState.transactions.firstWhere((t) => t.id == buyTx.id);
        final voidedBorrowTx = voidedState.transactions.firstWhere((t) => t.id == borrowTx.id);

        // Both transactions must be voided recursively
        expect(voidedBuyTx.voidedTransactionId, isNotNull);
        expect(voidedBorrowTx.voidedTransactionId, isNotNull);
      });
    });
  });
}
