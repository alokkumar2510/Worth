import 'package:drift/drift.dart';
import '../../../../database/database.dart' as db;
import '../../domain/entities/sip.dart' as domain;
import '../../domain/repositories/sip_repository.dart';

class SipRepositoryImpl implements SipRepository {
  final db.AppDatabase _database;

  SipRepositoryImpl(this._database);

  domain.Sip _toDomain(db.Sip entity) {
    return domain.Sip(
      id: entity.id,
      investmentId: entity.investmentId,
      amount: entity.amount,
      frequency: entity.frequency,
      sipDate: entity.sipDate,
      startDate: entity.startDate,
      endDate: entity.endDate,
      autoCreate: entity.autoCreate,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncStatus: entity.syncStatus,
      importMode: entity.importMode,
      completedInstallmentsOverride: entity.completedInstallmentsOverride,
      worthCreationDate: entity.worthCreationDate,
      firstInstallmentDate: entity.firstInstallmentDate,
      nextDueDate: entity.nextDueDate,
      lastCompletedInstallment: entity.lastCompletedInstallment,
    );
  }

  db.SipsCompanion _toCompanion(domain.Sip entity) {
    return db.SipsCompanion(
      id: Value(entity.id),
      investmentId: Value(entity.investmentId),
      amount: Value(entity.amount),
      frequency: Value(entity.frequency),
      sipDate: Value(entity.sipDate),
      startDate: Value(entity.startDate),
      endDate: Value(entity.endDate),
      autoCreate: Value(entity.autoCreate),
      isActive: Value(entity.isActive),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      syncStatus: Value(entity.syncStatus),
      importMode: Value(entity.importMode),
      completedInstallmentsOverride: Value(entity.completedInstallmentsOverride),
      worthCreationDate: Value(entity.worthCreationDate),
      firstInstallmentDate: Value(entity.firstInstallmentDate),
      nextDueDate: Value(entity.nextDueDate),
      lastCompletedInstallment: Value(entity.lastCompletedInstallment),
    );
  }

  @override
  Stream<List<domain.Sip>> watchAllSips() {
    return _database.select(_database.sips)
        .watch()
        .map((list) => list.map(_toDomain).toList());
  }

  @override
  Future<List<domain.Sip>> getAllSips() async {
    final list = await _database.select(_database.sips).get();
    return list.map(_toDomain).toList();
  }

  @override
  Future<domain.Sip?> getSipById(String id) async {
    final query = _database.select(_database.sips)..where((tbl) => tbl.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? _toDomain(entity) : null;
  }

  @override
  Future<void> createSip(domain.Sip sip) async {
    await _database.into(_database.sips).insert(_toCompanion(sip));
  }

  @override
  Future<void> updateSip(domain.Sip sip) async {
    final dbSip = db.Sip(
      id: sip.id,
      investmentId: sip.investmentId,
      amount: sip.amount,
      frequency: sip.frequency,
      sipDate: sip.sipDate,
      startDate: sip.startDate,
      endDate: sip.endDate,
      autoCreate: sip.autoCreate,
      isActive: sip.isActive,
      createdAt: sip.createdAt,
      updatedAt: sip.updatedAt,
      syncStatus: sip.syncStatus,
      importMode: sip.importMode,
      completedInstallmentsOverride: sip.completedInstallmentsOverride,
      worthCreationDate: sip.worthCreationDate,
      firstInstallmentDate: sip.firstInstallmentDate,
      nextDueDate: sip.nextDueDate,
      lastCompletedInstallment: sip.lastCompletedInstallment,
    );
    await _database.update(_database.sips).replace(dbSip);
  }

  @override
  Future<void> deleteSip(String id) async {
    await (_database.delete(_database.sips)..where((tbl) => tbl.id.equals(id))).go();
  }
}
