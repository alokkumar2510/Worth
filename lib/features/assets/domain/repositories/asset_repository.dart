import '../entities/asset.dart';

abstract class AssetRepository {
  Stream<List<Asset>> watchAllAssets();
  Future<List<Asset>> getAllAssets();
  Future<Asset?> getAssetById(String id);
  Future<void> createAsset(Asset asset);
  Future<void> updateAsset(Asset asset);
  Future<void> deleteAsset(String id);
  Future<List<Asset>> searchAssets(String query);
}
