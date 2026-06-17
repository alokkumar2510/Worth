import '../entities/account.dart';

abstract class AccountRepository {
  Stream<List<Account>> watchAllAccounts();
  Future<List<Account>> getAllAccounts();
  Future<Account?> getAccountById(String id);
  Future<void> createAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
  Future<List<Account>> searchAccounts(String query);
}
