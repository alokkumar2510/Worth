import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:archive/archive.dart';
import 'export_service.dart';
import 'import_service.dart';
import 'encryption_service.dart';

class BackupExportResult {
  final String filePath;
  final String fileName;
  final int fileSizeInBytes;
  final DateTime exportTime;
  final List<int> bytes;

  BackupExportResult({
    required this.filePath,
    required this.fileName,
    required this.fileSizeInBytes,
    required this.exportTime,
    required this.bytes,
  });
}

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

  // --- New Premium Export and Save to Downloads folder ---
  // --- New Premium Export and Save to Downloads folder ---
  Future<BackupExportResult> exportBackupToDownloads({
    required String passphrase,
    required bool compressZip,
    required bool encryptPayload,
    bool forcePrivateDirectory = false,
  }) async {
    // 1. Get raw backup map
    final Map<String, dynamic> backupMap = await _exportService.exportToMap();
    final jsonString = jsonEncode(backupMap);
    
    // 2. Encrypt if specified
    String finalPayload = jsonString;
    if (encryptPayload) {
      finalPayload = _encryptionService.encrypt(jsonString, passphrase);
    }
    
    // 3. Format name and path
    final timestamp = DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now());
    final extension = compressZip ? 'zip' : 'json';
    final fileName = 'Worth_Backup_$timestamp.$extension';
    
    List<int> fileBytes;
    if (compressZip) {
      // Create ZIP archive
      final archive = Archive();
      final innerFileName = 'Worth_Backup_$timestamp.json';
      final archiveFile = ArchiveFile(
        innerFileName,
        finalPayload.length,
        utf8.encode(finalPayload),
      );
      archive.addFile(archiveFile);
      fileBytes = ZipEncoder().encode(archive)!;
    } else {
      fileBytes = utf8.encode(finalPayload);
    }

    String savedPath = '';

    if (Platform.isAndroid && !forcePrivateDirectory) {
      // Scoped Storage: Direct write to public Download/Worth folder
      final downloadsDir = Directory('/storage/emulated/0/Download/Worth');
      try {
        // Request storage permission for Android 12 or below
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        // Request manage external storage for Android 11+
        final manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          await Permission.manageExternalStorage.request();
        }

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
        
        String filePath = '${downloadsDir.path}/$fileName';
        File file = File(filePath);
        
        // Handle duplicate names
        int counter = 1;
        while (await file.exists()) {
          filePath = '${downloadsDir.path}/Worth_Backup_${timestamp}_$counter.$extension';
          file = File(filePath);
          counter++;
        }

        await file.writeAsBytes(fileBytes);
        savedPath = file.path;
      } catch (e) {
        throw FileSystemException(
          'Failed to write to public Downloads directory. '
          'Please grant storage access or save to private folder.\n\nDetails: $e',
          downloadsDir.path,
        );
      }
    } else {
      // Non-Android platforms or forced private app storage
      final Directory? appDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      
      if (appDir == null) {
        throw Exception('Could not access storage directory.');
      }
      
      final backupWorthDir = Directory('${appDir.path}/Worth');
      if (!await backupWorthDir.exists()) {
        await backupWorthDir.create(recursive: true);
      }
      
      String filePath = '${backupWorthDir.path}/$fileName';
      File file = File(filePath);
      
      // Handle duplicate names
      int counter = 1;
      while (await file.exists()) {
        filePath = '${backupWorthDir.path}/Worth_Backup_${timestamp}_$counter.$extension';
        file = File(filePath);
        counter++;
      }
      
      await file.writeAsBytes(fileBytes);
      savedPath = file.path;
    }

    final fileSize = await File(savedPath).length();
    return BackupExportResult(
      filePath: savedPath,
      fileName: fileName,
      fileSizeInBytes: fileSize,
      exportTime: DateTime.now(),
      bytes: fileBytes,
    );
  }

  // --- New Premium Restore from File ---
  Future<void> restoreBackupFromFile(String filePath, String passphrase) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found at: $filePath');
    }

    final fileBytes = await file.readAsBytes();
    String jsonString = '';

    if (filePath.endsWith('.zip')) {
      final archive = ZipDecoder().decodeBytes(fileBytes);
      final archiveFile = archive.files.firstOrNull;
      if (archiveFile == null) {
        throw Exception('ZIP archive is empty');
      }
      jsonString = utf8.decode(archiveFile.content as List<int>);
    } else {
      jsonString = utf8.decode(fileBytes);
    }

    // Try decrypting. If it fails, check if it's raw JSON or throw
    String decryptedString = '';
    try {
      decryptedString = _encryptionService.decrypt(jsonString, passphrase);
    } catch (_) {
      // If decryption fails, check if the string is valid raw JSON
      try {
        jsonDecode(jsonString);
        decryptedString = jsonString; // Valid raw JSON
      } catch (e) {
        throw Exception('File decryption failed. Please verify your passphrase.');
      }
    }

    await _importService.importFromJsonString(decryptedString);
  }
}
