import '../entities/expected_income.dart';

abstract class ExpectedIncomeRepository {
  Stream<List<ExpectedIncome>> watchPendingIncome();
  Future<List<ExpectedIncome>> getPendingIncome();
  Future<void> saveExpectedIncome(ExpectedIncome income);
  Future<void> markAsReceived(String id, String toAccountId);
  Future<void> markAsExpired(String id);
}
