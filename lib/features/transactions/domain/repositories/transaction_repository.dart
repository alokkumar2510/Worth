import '../entities/transaction.dart';

abstract class TransactionRepository {
  Stream<List<Transaction>> watchAllTransactions();
  Future<List<Transaction>> getAllTransactions();
  Future<Transaction?> getTransactionById(String id);
  Future<void> createTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  
  // Clean Architecture requirements: Pagination, Filtering, Search
  Future<List<Transaction>> getTransactionsPaginated(int limit, DateTime? lastDate, String? lastId);
  Future<List<Transaction>> filterTransactions(String? type, String? category);
  Future<List<Transaction>> searchTransactions(String query);
  
  // Void transaction
  Future<void> voidTransaction(String originalTransactionId);
}
