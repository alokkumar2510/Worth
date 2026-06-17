import '../../../../core/calculation/chart_data_generator.dart';
import '../../../../core/services/snapshot_service.dart';

class ReportService {
  final SnapshotService _snapshotService;
  final ChartDataGenerator _chartDataGenerator;

  ReportService(this._snapshotService, this._chartDataGenerator);

  // Checks and logs missing monthly snapshot backfills
  Future<void> generateMissingSnapshots() async {
    await _snapshotService.triggerLazySnapshots();
  }

  // Net Worth Trend Series
  Future<List<MapEntry<DateTime, double>>> getNetWorthTrend() async {
    await generateMissingSnapshots(); // Backfill before loading trend to make sure it's up-to-date
    return _chartDataGenerator.getNetWorthTrend();
  }

  // Monthly Growth Rate delta
  Future<List<MapEntry<DateTime, double>>> getMonthlyGrowth() async {
    return _chartDataGenerator.getMonthlyGrowth();
  }

  // Asset allocation breakdown
  Future<Map<String, double>> getAssetAllocation() async {
    return _chartDataGenerator.getAssetAllocation();
  }

  // Liability breakdown
  Future<Map<String, double>> getLiabilityAllocation() async {
    return _chartDataGenerator.getLiabilityAllocation();
  }

  // Investment allocations grouped by type
  Future<Map<String, double>> getInvestmentAllocation() async {
    return _chartDataGenerator.getInvestmentAllocation();
  }

  // Monthly income vs expense
  Future<List<IncomeVsExpenseData>> getIncomeVsExpense() async {
    return _chartDataGenerator.getIncomeVsExpense();
  }
}
