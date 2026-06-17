import '../entities/sip.dart';

abstract class SipRepository {
  Stream<List<Sip>> watchAllSips();
  Future<List<Sip>> getAllSips();
  Future<Sip?> getSipById(String id);
  Future<void> createSip(Sip sip);
  Future<void> updateSip(Sip sip);
  Future<void> deleteSip(String id);
}
