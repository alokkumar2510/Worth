import '../entities/investment.dart';
import '../entities/investment_lot.dart';

abstract class InvestmentRepository {
  Stream<List<Investment>> watchAllInvestments();
  Future<List<Investment>> getAllInvestments();
  Future<Investment?> getInvestmentById(String id);
  Future<void> createInvestment(Investment investment);
  Future<void> updateInvestment(Investment investment);
  Future<void> deleteInvestment(String id);
  Future<List<Investment>> searchInvestments(String query);
  Future<void> updateMarketValue(String id, double marketValue);
  
  // Lot operations
  Future<List<InvestmentLot>> getOpenLots(String investmentId);
  Future<void> createLot(InvestmentLot lot);
  Future<void> updateLot(InvestmentLot lot);
  Future<List<InvestmentLot>> getLotsForInvestment(String investmentId);
}
