import '../entities/liability.dart';

abstract class LiabilityRepository {
  Stream<List<Liability>> watchAllLiabilities();
  Future<List<Liability>> getAllLiabilities();
  Future<Liability?> getLiabilityById(String id);
  Future<void> createLiability(Liability liability);
  Future<void> updateLiability(Liability liability);
  Future<void> deleteLiability(String id);
  Future<List<Liability>> searchLiabilities(String query);
}
