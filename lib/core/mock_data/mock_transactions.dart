import '../../database/database.dart';

class MockTransactionAndLots {
  final List<Transaction> transactions;
  final List<InvestmentLot> investmentLots;
  final List<InvestmentLotConsumption> consumptions;

  MockTransactionAndLots({
    required this.transactions,
    required this.investmentLots,
    required this.consumptions,
  });
}

MockTransactionAndLots getMockTransactionsAndLots(DateTime now) {
  return MockTransactionAndLots(
    transactions: [],
    investmentLots: [],
    consumptions: [],
  );
}
