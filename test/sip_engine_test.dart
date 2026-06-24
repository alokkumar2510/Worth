import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:worth/core/providers/dependency_provider.dart';
import 'package:worth/core/providers/mock_database.dart';
import 'package:worth/database/database.dart';
import 'package:worth/features/investments/domain/entities/sip.dart' as domain;
import 'package:worth/features/transactions/domain/entities/transaction.dart' as domain_tx;

void main() {
  group('SIP Engine Fix Tests', () {
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

    test('Creating a SIP with a future start date does NOT create transactions immediately', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      // Verify initially there are no transactions or sips
      expect(container.read(mockDatabaseProvider).transactions.isEmpty, isTrue);

      final now = DateTime.now().toUtc();
      final futureStartDate = DateTime(now.year, now.month, now.day + 5);

      // Create a future-dated monthly SIP
      await notifier.addSip(
        investmentId: 'inv_nifty_50',
        amount: 5000.0,
        frequency: 'monthly',
        sipDate: futureStartDate.day,
        startDate: futureStartDate,
        autoCreate: 1,
      );

      final state = container.read(mockDatabaseProvider);

      // 1. Creating a SIP must only create a SIP schedule record
      expect(state.sips.length, equals(1));
      final sip = state.sips.first;
      expect(sip.investmentId, equals('inv_nifty_50'));
      expect(sip.amount, equals(5000.0));

      // 2. Creating a SIP must NOT create an investment transaction
      expect(state.transactions.isEmpty, isTrue);

      // 3. Creating a SIP must NOT deduct money
      // (Since no transactions are created, no bank balance deductions happened)

      // 4. Verify initial nextDueDate is set to the future start date
      expect(sip.nextDueDate, equals(DateTime(futureStartDate.year, futureStartDate.month, futureStartDate.day)));
      expect(sip.lastCompletedInstallment, isNull);
    });

    test('Creating a SIP starting today executes and creates exactly one transaction, and updates nextDueDate', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      final now = DateTime.now().toUtc();
      final todayStartDate = DateTime(now.year, now.month, now.day);

      // Add a bank account to allow buyInvestment to proceed
      await notifier.addAccount('Primary Bank', 'bank', 'Primary Cash', 50000.0);
      // Add investment
      final inv = await notifier.addInvestment('Gold ETF', 'investment', 'GOLD', 'Gold ETF', 100.0);

      // Create a monthly SIP starting today
      await notifier.addSip(
        investmentId: inv.id,
        amount: 2000.0,
        frequency: 'monthly',
        sipDate: todayStartDate.day,
        startDate: todayStartDate,
        autoCreate: 1,
      );

      final state = container.read(mockDatabaseProvider);

      // 1. Should create exactly one investment transaction
      final newTransactions = state.transactions.where((t) => t.type == 'investment_buy').toList();
      expect(newTransactions.length, equals(1));

      final tx = newTransactions.first;
      expect(tx.amount, equals(2000.0));
      expect(tx.sipId, equals(state.sips.first.id));
      expect(tx.executionMonth, equals(todayStartDate.month));
      expect(tx.executionYear, equals(todayStartDate.year));

      // 2. SIP nextDueDate must be updated to the next month
      final sip = state.sips.first;
      expect(sip.lastCompletedInstallment, equals(todayStartDate));
      expect(sip.nextDueDate!.month, equals(todayStartDate.month + 1 == 13 ? 1 : todayStartDate.month + 1));
    });

    test('SIP engine is idempotent across app restarts and background sync retries', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);

      final now = DateTime.now().toUtc();
      final todayStartDate = DateTime(now.year, now.month, now.day);

      await notifier.addAccount('Primary Bank', 'bank', 'Primary Cash', 50000.0);
      final inv = await notifier.addInvestment('Gold ETF', 'investment', 'GOLD', 'Gold ETF', 100.0);

      // Create SIP starting today (this executes it once)
      await notifier.addSip(
        investmentId: inv.id,
        amount: 2000.0,
        frequency: 'monthly',
        sipDate: todayStartDate.day,
        startDate: todayStartDate,
        autoCreate: 1,
      );

      final stateAfterCreation = container.read(mockDatabaseProvider);
      final initialBuyTxs = stateAfterCreation.transactions.where((t) => t.type == 'investment_buy').length;
      expect(initialBuyTxs, equals(1));

      // Let's manually roll back nextDueDate of the SIP to simulate an app restart / retry scenario
      // where the nextDueDate is still today, but the transaction was already created.
      final sip = stateAfterCreation.sips.first;
      final rolledBackSip = sip.copyWith(nextDueDate: Value(todayStartDate));
      await notifier.editSip(rolledBackSip);

      // Trigger runAutoSipProcessing again (simulating app relaunch or background scheduler trigger)
      await notifier.runAutoSipProcessing();

      final stateAfterRestart = container.read(mockDatabaseProvider);
      final finalBuyTxs = stateAfterRestart.transactions.where((t) => t.type == 'investment_buy').length;

      // Verify that NO duplicate transaction was created!
      expect(finalBuyTxs, equals(1));
    });
  });

  group('Database Schema Unique Constraint Tests', () {
    test('Transactions table uniqueKeys constraint prevents duplicate SIP executions for the same month/year', () async {
      final db = AppDatabase(NativeDatabase.memory());

      // Insert first SIP transaction
      final tx1 = TransactionsCompanion.insert(
        id: 'tx_sip_1',
        type: 'investment_buy',
        amount: 5000.0,
        transactionDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        sipId: const Value('sip_123'),
        executionMonth: const Value(6),
        executionYear: const Value(2026),
      );

      await db.into(db.transactions).insert(tx1);

      // Attempt to insert second SIP transaction for the same SIP in the same month/year
      final tx2 = TransactionsCompanion.insert(
        id: 'tx_sip_2',
        type: 'investment_buy',
        amount: 5000.0,
        transactionDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        sipId: const Value('sip_123'),
        executionMonth: const Value(6),
        executionYear: const Value(2026),
      );

      // Verify that this throws a unique constraint violation error
      expect(
        () async => await db.into(db.transactions).insert(tx2),
        throwsA(isA<SqliteException>()),
      );

      await db.close();
    });

    test('Transactions table uniqueKeys constraint allows multiple NULL values for non-SIP transactions', () async {
      final db = AppDatabase(NativeDatabase.memory());

      // Insert first non-SIP transaction (all SIP fields NULL)
      final tx1 = TransactionsCompanion.insert(
        id: 'tx_normal_1',
        type: 'expense',
        amount: 150.0,
        transactionDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await db.into(db.transactions).insert(tx1);

      // Insert second non-SIP transaction (all SIP fields NULL)
      final tx2 = TransactionsCompanion.insert(
        id: 'tx_normal_2',
        type: 'expense',
        amount: 250.0,
        transactionDate: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      // Verify that this does NOT throw any constraint violations and succeeds
      await db.into(db.transactions).insert(tx2);

      final count = await db.select(db.transactions).get();
      expect(count.length, equals(2));

      await db.close();
    });
  });
}
