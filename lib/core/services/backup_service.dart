import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import '../../database/database.dart' as db;
import 'export_service.dart';
import 'import_service.dart';
import 'encryption_service.dart';
import 'notification_service.dart';

class BackupInfo {
  final DateTime? lastBackupDate;
  final DateTime nextBackupDate;
  final int backupCount;
  final int storageUsedBytes;

  BackupInfo({
    this.lastBackupDate,
    required this.nextBackupDate,
    required this.backupCount,
    required this.storageUsedBytes,
  });
}

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
  final db.AppDatabase _db;
  final ExportService _exportService;
  final ImportService _importService;
  final EncryptionService _encryptionService;
  final NotificationService _notificationService;

  BackupService(
    this._db,
    this._exportService,
    this._importService,
    this._encryptionService,
    this._notificationService,
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

  Future<String?> _getSetting(String key) async {
    final row = await (_db.select(_db.settings)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _saveSetting(String key, String value) async {
    await _db.into(_db.settings).insertOnConflictUpdate(db.Setting(key: key, value: value));
  }

  Future<void> runBackupForDate(DateTime date) async {
    final Map<String, dynamic> backupMap = await _exportService.exportToMap();
    final jsonString = jsonEncode(backupMap);

    final dateStr = DateFormat('yyyy_MM_dd').format(date);
    final fileName = 'worth_backup_$dateStr.json';

    final Directory appDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDir.path}/$fileName';
    final file = File(filePath);

    await file.writeAsString(jsonString);
    await _pruneOldBackups(appDir);
  }

  Future<void> _pruneOldBackups(Directory directory) async {
    final List<File> backupFiles = [];
    if (await directory.exists()) {
      await for (final entity in directory.list()) {
        if (entity is File) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (name.startsWith('worth_backup_') && name.endsWith('.json')) {
            backupFiles.add(entity);
          }
        }
      }
    }

    backupFiles.sort((a, b) {
      final nameA = a.path.split(Platform.pathSeparator).last;
      final nameB = b.path.split(Platform.pathSeparator).last;
      return nameA.compareTo(nameB);
    });

    if (backupFiles.length > 30) {
      final filesToDelete = backupFiles.sublist(0, backupFiles.length - 30);
      for (final file in filesToDelete) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
  }

  Future<void> checkAndRunBackup() async {
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final lastDate = await _getSetting('last_backup_date');
    final lastStatus = await _getSetting('last_backup_status');

    if (lastDate == todayStr && lastStatus == 'success') {
      return;
    }

    bool shouldAttempt = false;
    String targetStatus = 'failed';

    if (now.hour == 0 && now.minute >= 0 && now.minute < 15) {
      if (lastDate != todayStr || (lastStatus != 'failed_00_00' && lastStatus != 'failed_00_15' && lastStatus != 'failed_00_30' && lastStatus != 'failed')) {
        shouldAttempt = true;
        targetStatus = 'failed_00_00';
      }
    } else if (now.hour == 0 && now.minute >= 15 && now.minute < 30) {
      if (lastDate == todayStr && lastStatus == 'failed_00_00') {
        shouldAttempt = true;
        targetStatus = 'failed_00_15';
      }
    } else if (now.hour == 0 && now.minute >= 30) {
      if (lastDate == todayStr && lastStatus == 'failed_00_15') {
        shouldAttempt = true;
        targetStatus = 'failed_00_30';
      }
    } else if (now.hour == 1 && now.minute >= 0 && now.minute < 15) {
      if (lastDate == todayStr && lastStatus == 'failed_00_30') {
        shouldAttempt = true;
        targetStatus = 'failed_01_00';
      }
    } else {
      if (lastDate != todayStr) {
        shouldAttempt = true;
        targetStatus = 'failed';
      }
    }

    if (!shouldAttempt) return;

    try {
      await runBackupForDate(now);
      await _saveSetting('last_backup_date', todayStr);
      await _saveSetting('last_backup_status', 'success');

      await _notificationService.scheduleSystemNotification(
        id: 7001,
        title: 'Backup Completed',
        body: 'Daily backup completed successfully. Your data is safe.',
        scheduledDateTime: DateTime.now().add(const Duration(seconds: 5)),
        type: 'backup',
        channelId: kChannelSystem,
      );
    } catch (e) {
      print('[BackupService] Auto backup attempt failed: $e');
      if (targetStatus == 'failed_01_00') {
        await _saveSetting('last_backup_date', todayStr);
        await _saveSetting('last_backup_status', 'failed');
        await _notificationService.scheduleSystemNotification(
          id: 7002,
          title: 'Backup Failed',
          body: 'Auto-backup failed after retries. Check Backup & Restore in Settings.',
          scheduledDateTime: DateTime.now().add(const Duration(seconds: 5)),
          type: 'backup',
          channelId: kChannelSystem,
        );
      } else {
        await _saveSetting('last_backup_date', todayStr);
        await _saveSetting('last_backup_status', targetStatus);
      }
    }
  }

  Future<void> triggerManualBackup() async {
    await runBackupForDate(DateTime.now());
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _saveSetting('last_backup_date', todayStr);
    await _saveSetting('last_backup_status', 'success');
    await _notificationService.scheduleSystemNotification(
      id: 7003,
      title: 'Backup Completed',
      body: 'Manual backup completed. Your data is safe.',
      scheduledDateTime: DateTime.now().add(const Duration(seconds: 5)),
      type: 'backup',
      channelId: kChannelSystem,
    );
  }

  Future<BackupInfo> getBackupInfo() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(appDir.path);
    final List<File> files = [];
    int totalSize = 0;
    DateTime? lastBackup;

    if (await backupDir.exists()) {
      await for (final entity in backupDir.list()) {
        if (entity is File) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (name.startsWith('worth_backup_') && name.endsWith('.json')) {
            files.add(entity);
            totalSize += await entity.length();

            try {
              final datePart = name.replaceFirst('worth_backup_', '').replaceFirst('.json', '');
              final normalizedDate = datePart.replaceAll('_', '-');
              final parsedDate = DateTime.parse(normalizedDate);
              if (lastBackup == null || parsedDate.isAfter(lastBackup)) {
                lastBackup = parsedDate;
              }
            } catch (_) {}
          }
        }
      }
    }

    final now = DateTime.now();
    final nextBackup = DateTime(now.year, now.month, now.day + 1, 0, 0);

    return BackupInfo(
      lastBackupDate: lastBackup,
      nextBackupDate: nextBackup,
      backupCount: files.length,
      storageUsedBytes: totalSize,
    );
  }

  Future<List<File>> getBackupFileList() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(appDir.path);
    final List<File> files = [];

    if (await backupDir.exists()) {
      await for (final entity in backupDir.list()) {
        if (entity is File) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (name.startsWith('worth_backup_') && name.endsWith('.json')) {
            files.add(entity);
          }
        }
      }
    }

    files.sort((a, b) {
      final nameA = a.path.split(Platform.pathSeparator).last;
      final nameB = b.path.split(Platform.pathSeparator).last;
      return nameB.compareTo(nameA); // Newest first
    });

    return files;
  }

  Future<void> deleteBackupFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteAllBackups() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(appDir.path);
    if (await backupDir.exists()) {
      await for (final entity in backupDir.list()) {
        if (entity is File) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (name.startsWith('worth_backup_') && name.endsWith('.json')) {
            try {
              await entity.delete();
            } catch (_) {}
          }
        }
      }
    }
  }
}
