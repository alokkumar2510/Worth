import 'dart:convert';
import 'export_service.dart';
import 'import_service.dart';
import 'encryption_service.dart';

class BackupService {
  final ExportService _exportService;
  final ImportService _importService;
  final EncryptionService _encryptionService;

  BackupService(
    this._exportService,
    this._importService,
    this._encryptionService,
  );

  // Encrypts and exports the database payload as an encrypted JSON backup string
  Future<String> exportBackup(String passphrase) async {
    final Map<String, dynamic> backupMap = await _exportService.exportToMap();
    final jsonString = jsonEncode(backupMap);
    return _encryptionService.encrypt(jsonString, passphrase);
  }

  // Decrypts and restores the database using ImportService
  Future<void> restoreBackup(String encryptedJson, String passphrase) async {
    final jsonString = _encryptionService.decrypt(encryptedJson, passphrase);
    await _importService.importFromJsonString(jsonString);
  }
}
