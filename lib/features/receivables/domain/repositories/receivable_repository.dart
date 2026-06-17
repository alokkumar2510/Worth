import '../entities/receivable.dart';

abstract class ReceivableRepository {
  Stream<List<Receivable>> watchAllReceivables();
  Future<List<Receivable>> getAllReceivables();
  Future<Receivable?> getReceivableById(String id);
  Future<void> createReceivable(Receivable receivable);
  Future<void> updateReceivable(Receivable receivable);
  Future<void> deleteReceivable(String id);
  Future<List<Receivable>> searchReceivables(String query);
}
