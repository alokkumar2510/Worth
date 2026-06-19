import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:worth/core/providers/dependency_provider.dart';
import 'package:worth/core/providers/mock_database.dart';

void main() {
  group('Portfolio History Archive Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Override mock mode to true so it runs in memory/mock state
          mockModeProvider.overrideWith((ref) => true),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Adding an Account creates a portfolio history log entry and updates snapshots', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);
      
      // Initially, history might have seeding, but let's check count
      final initialLength = container.read(mockDatabaseProvider).portfolioHistory.length;

      // Add a bank account
      final account = await notifier.addAccount(
        'Test Premium Bank',
        'bank',
        'Unit test account',
        50000.0,
      );

      final state = container.read(mockDatabaseProvider);

      // Verify account is in state
      expect(state.accounts.any((a) => a.id == account.id), isTrue);

      // Verify a history entry was created
      expect(state.portfolioHistory.length, greaterThan(initialLength));
      final latestLog = state.portfolioHistory.first;
      expect(latestLog.entityType, equals('Asset'));
      expect(latestLog.entityTitle, equals('Test Premium Bank'));
      expect(latestLog.action, equals('Added Asset'));

      // Verify that snapshots exist and contain the updated Net Worth
      expect(state.portfolioSnapshots.isNotEmpty, isTrue);
      final latestSnap = state.portfolioSnapshots.first;
      expect(latestSnap.assets, greaterThanOrEqualTo(50000.0));
      expect(latestSnap.netWorth, greaterThanOrEqualTo(50000.0));
    });

    test('Adding an Investment creates a history log entry', () {
      final notifier = container.read(mockDatabaseProvider.notifier);
      final initialLength = container.read(mockDatabaseProvider).portfolioHistory.length;

      // Add a mock investment
      final inv = notifier.addInvestment(
        'NIFTYBEES TEST',
        'mutual_fund',
        'NIFTYBEES',
        'Index ETF',
        10000.0,
      );

      final state = container.read(mockDatabaseProvider);

      expect(state.investments.any((i) => i.id == inv.id), isTrue);
      expect(state.portfolioHistory.length, greaterThan(initialLength));
      
      final latestLog = state.portfolioHistory.first;
      expect(latestLog.entityType, equals('Investment'));
      expect(latestLog.entityTitle, equals('NIFTYBEES TEST'));
      expect(latestLog.action, equals('Added Investment'));
    });

    test('Time Machine successfully reconstructs portfolio balances on past date', () async {
      final notifier = container.read(mockDatabaseProvider.notifier);
      final today = DateTime.now();
      final targetDate = today.subtract(const Duration(days: 10));

      // Reconstruct before adding new accounts with recent dates
      final initialRecon = container.read(mockDatabaseProvider).reconstructPortfolioOnDate(targetDate);
      final initialAssets = initialRecon.totalAssets;

      // Add an account created today
      await notifier.addAccount(
        'Today Bank',
        'bank',
        'Created today',
        100000.0,
      );

      // Reconstruct again on targetDate (10 days ago)
      final pastRecon = container.read(mockDatabaseProvider).reconstructPortfolioOnDate(targetDate);
      
      // The newly added account (created today) should NOT exist in the past state
      expect(pastRecon.accounts.any((a) => a.name == 'Today Bank'), isFalse);
      expect(pastRecon.totalAssets, equals(initialAssets));

      // Reconstruct on today's date
      final todayRecon = container.read(mockDatabaseProvider).reconstructPortfolioOnDate(today.add(const Duration(hours: 1)));
      expect(todayRecon.accounts.any((a) => a.name == 'Today Bank'), isTrue);
      expect(todayRecon.totalAssets, greaterThan(initialAssets));
    });
  });
}
