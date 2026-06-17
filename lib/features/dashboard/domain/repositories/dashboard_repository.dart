abstract class DashboardRepository {
  Future<double> getAssetsSum();
  Future<double> getLiabilitiesSum();
  Future<double> getReceivablesSum();
  Future<double> getInvestmentPrincipalSum();
  Future<double> getExpectedIncomeSum();
}
