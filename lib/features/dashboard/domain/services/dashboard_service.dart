import '../entities/dashboard_data.dart';
import '../repositories/dashboard_repository.dart';

class DashboardService {
  final DashboardRepository _repository;

  DashboardService(this._repository);

  Future<DashboardData> getDashboardData() async {
    final assets = await _repository.getAssetsSum();
    final liabilities = await _repository.getLiabilitiesSum();
    final receivables = await _repository.getReceivablesSum();
    final investmentPrincipal = await _repository.getInvestmentPrincipalSum();
    final expectedIncome = await _repository.getExpectedIncomeSum();

    // Business rule: NET WORTH = Assets + Receivables + Investment Principal - Liabilities
    final netWorth = assets + receivables + investmentPrincipal - liabilities;

    return DashboardData(
      netWorth: netWorth,
      assets: assets,
      liabilities: liabilities,
      receivables: receivables,
      investmentPrincipal: investmentPrincipal,
      expectedIncome: expectedIncome,
    );
  }
}
