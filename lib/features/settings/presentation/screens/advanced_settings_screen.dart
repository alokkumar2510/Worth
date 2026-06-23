import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/dependency_provider.dart';
import '../../../sync/presentation/providers/sync_status_provider.dart';
import '../../../../core/services/backup_service.dart';
import '../widgets/backup_success_sheet.dart';
import '../widgets/backup_failure_sheet.dart';
import 'package:permission_handler/permission_handler.dart';

class AdvancedSettingsScreen extends ConsumerStatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  ConsumerState<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends ConsumerState<AdvancedSettingsScreen> {
  bool _isSyncing = false;

  void _showConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          content,
          style: const TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.darkDanger : AppColors.darkPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _handleRecalculate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 800), () {
          ref.read(mockDatabaseProvider.notifier).recalculateBalances();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Balances recalculated and cache rebuilt successfully.')),
          );
        });
        return AlertDialog(
          
          content: Row(
            children: const [
              CircularProgressIndicator(color: AppColors.darkPrimary),
              SizedBox(width: 20),
              Text('Recalculating balances...', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  void _handleSync() {
    ref.read(syncStatusProvider.notifier).forceSync();
  }

  void _handleExportOptions() {
    bool compressZip = true;
    bool encryptPayload = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final goldAccent = const Color(0xFFD4AF37);
          return AlertDialog(
            backgroundColor: const Color(0xFF111118),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: goldAccent.withOpacity(0.2), width: 1),
            ),
            title: Text(
              'Export Backup Options',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ZIP format toggle
                SwitchListTile(
                  title: Text('Compress as ZIP', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('Creates a compressed .zip archive containing the JSON payload.', style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11)),
                  value: compressZip,
                  activeColor: goldAccent,
                  onChanged: (val) => setDialogState(() => compressZip = val),
                ),
                const Divider(color: Colors.white10, height: 16),
                // Encryption toggle
                SwitchListTile(
                  title: Text('Encrypt Backup', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text('Protects database payload with AES passphrase encryption.', style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11)),
                  value: encryptPayload,
                  activeColor: goldAccent,
                  onChanged: (val) => setDialogState(() => encryptPayload = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _runExport(compressZip: compressZip, encryptPayload: encryptPayload);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Export', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _runExport({
    required bool compressZip,
    required bool encryptPayload,
    bool forcePrivateDirectory = false,
  }) async {
    try {
      final backupService = ref.read(realBackupServiceProvider);
      final passphrase = ref.read(databasePassphraseProvider);

      // Show progress overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: Color(0xFF0B0B0F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFFD4AF37)),
              SizedBox(width: 20),
              Text('Compiling Backup Payload...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );

      final result = await backupService.exportBackupToDownloads(
        passphrase: passphrase,
        compressZip: compressZip,
        encryptPayload: encryptPayload,
        forcePrivateDirectory: forcePrivateDirectory,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => BackupSuccessSheet(
            filePath: result.filePath,
            fileName: result.fileName,
            fileBytes: result.bytes,
            fileSizeInBytes: result.fileSizeInBytes,
            exportTime: result.exportTime,
            onExportAgain: () => _runExport(
              compressZip: compressZip,
              encryptPayload: encryptPayload,
              forcePrivateDirectory: forcePrivateDirectory,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading if open
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.5),
          builder: (context) => BackupFailureSheet(
            errorMessage: e.toString(),
            onRetry: () => _runExport(
              compressZip: compressZip,
              encryptPayload: encryptPayload,
              forcePrivateDirectory: false,
            ),
            onSavePrivate: () => _runExport(
              compressZip: compressZip,
              encryptPayload: encryptPayload,
              forcePrivateDirectory: true,
            ),
          ),
        );
      }
    }
  }

  void _handleImport() async {
    if (Platform.isAndroid) {
      // Request standard storage permission
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      // Request manage external storage permission for Android 11+
      final manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    }

    final downloadsDir = Directory('/storage/emulated/0/Download/Worth');
    List<File> backupFiles = [];

    // Scan public Downloads/Worth directory
    try {
      if (await downloadsDir.exists()) {
        final list = downloadsDir.listSync();
        backupFiles.addAll(
          list
              .whereType<File>()
              .where((f) => f.path.endsWith('.json') || f.path.endsWith('.zip')),
        );
      }
    } catch (e) {
      // ignore listing issues, we will fallback/combine with private storage
    }

    // Scan private app-specific external storage directory
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final privateDir = Directory('${externalDir.path}/Worth');
        if (await privateDir.exists()) {
          final list = privateDir.listSync();
          backupFiles.addAll(
            list
                .whereType<File>()
                .where((f) => f.path.endsWith('.json') || f.path.endsWith('.zip')),
          );
        }
      }
    } catch (e) {
      // ignore private directory issues
    }

    // Deduplicate backups by file path
    final uniquePaths = <String>{};
    backupFiles = backupFiles.where((file) => uniquePaths.add(file.path)).toList();

    // Sort backups: newest modification date first
    backupFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    if (!mounted) return;

    if (backupFiles.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF111118),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: Text('No Backups Found', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'No backup files (.json or .zip) were found in the public Download/Worth/ or app-private storage folder.\n\nPlease export a backup first or place a backup file in those directories to restore.',
            style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        ),
      );
      return;
    }

    // Show selection dialog
    showDialog(
      context: context,
      builder: (context) {
        final goldAccent = const Color(0xFFD4AF37);
        return AlertDialog(
          backgroundColor: const Color(0xFF111118),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: goldAccent.withOpacity(0.2), width: 1),
          ),
          title: Text(
            'Select Backup to Restore',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backupFiles.length,
              itemBuilder: (context, index) {
                final file = backupFiles[index];
                final name = file.path.split(Platform.pathSeparator).last;
                final modTime = file.lastModifiedSync();
                final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(modTime);
                final size = file.lengthSync();
                final sizeStr = size < 1024
                    ? '$size B'
                    : size < 1024 * 1024
                        ? '${(size / 1024).toStringAsFixed(1)} KB'
                        : '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';

                final isPrivate = !file.path.contains('/Download/Worth');

                return ListTile(
                  leading: Icon(
                    file.path.endsWith('.zip') ? Icons.archive_outlined : Icons.description_outlined,
                    color: goldAccent,
                  ),
                  title: Text(
                    name,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$dateStr • $sizeStr${isPrivate ? " (Private)" : ""}',
                    style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmRestore(file.path);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
          ],
        );
      },
    );
  }

  void _confirmRestore(String filePath) {
    final name = filePath.split(Platform.pathSeparator).last;
    _showConfirmDialog(
      title: 'Import Selected Backup?',
      content: 'Are you sure you want to restore the backup "$name"? This will overwrite all local ledger history, lots, and details. This action cannot be undone.',
      confirmText: 'Import',
      onConfirm: () async {
        try {
          // Show progress dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AlertDialog(
              backgroundColor: Color(0xFF0B0B0F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              content: Row(
                children: [
                  CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  SizedBox(width: 20),
                  Text('Restoring Database Ledger...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          );

          final backupService = ref.read(realBackupServiceProvider);
          final passphrase = ref.read(databasePassphraseProvider);

          await backupService.restoreBackupFromFile(filePath, passphrase);

          // Rebuild caches and reload database state
          await ref.read(mockDatabaseProvider.notifier).loadStateFromDatabase();
          ref.read(mockDatabaseProvider.notifier).recalculateBalances();

          // Close loading dialog
          if (mounted) Navigator.pop(context);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Backup imported and database restored successfully.')),
            );
          }
        } catch (e) {
          if (mounted) Navigator.pop(context); // Close loading if open
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to import backup: $e'),
                backgroundColor: AppColors.darkDanger,
              ),
            );
          }
        }
      },
    );
  }

  void _handleClearCache() {
    _showConfirmDialog(
      title: 'Clear Cache?',
      content: 'This will purge all computed balance cache entries and rebuild them. Rebuild runs instantly on next load. Continue?',
      confirmText: 'Clear',
      onConfirm: () async {
        await ref.read(mockDatabaseProvider.notifier).clearCache();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Balance cache purged & recalculated.')),
          );
        }
      },
    );
  }

  void _handleResetDemoData() {
    _showConfirmDialog(
      title: 'Reset Demo Data?',
      content: 'This will reset the application to its original mock demo state. All custom transactions, accounts, and investments will be deleted. This action cannot be undone.',
      confirmText: 'Reset Demo',
      isDestructive: true,
      onConfirm: () async {
        await ref.read(mockDatabaseProvider.notifier).resetDemoData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demo data has been reset to default values.')),
          );
        }
      },
    );
  }

  void _handleClearAllTransactions() {
    _showConfirmDialog(
      title: 'Clear All Transactions?',
      content: 'Are you sure? This will permanently delete every transaction, buy lot, and sale consumption log. This action cannot be undone.',
      confirmText: 'Clear All',
      isDestructive: true,
      onConfirm: () async {
        await ref.read(mockDatabaseProvider.notifier).clearAllTransactions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All transactions deleted.')),
          );
        }
      },
    );
  }

  void _handleClearAllInvestments() {
    _showConfirmDialog(
      title: 'Clear All Investments?',
      content: 'Are you sure? This will delete all investments, investment lots, consumptions, and investment-related transactions. This action cannot be undone.',
      confirmText: 'Clear Investments',
      isDestructive: true,
      onConfirm: () async {
        await ref.read(mockDatabaseProvider.notifier).clearAllInvestments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All investments cleared.')),
          );
        }
      },
    );
  }

  void _handleClearAllReceivables() {
    _showConfirmDialog(
      title: 'Clear All Receivables?',
      content: 'Are you sure? This will delete all transactions related to lent or recovered money. This action cannot be undone.',
      confirmText: 'Clear Receivables',
      isDestructive: true,
      onConfirm: () async {
        await ref.read(mockDatabaseProvider.notifier).clearAllReceivables();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All receivables cleared.')),
          );
        }
      },
    );
  }

  void _handleClearAllLiabilities() {
    _showConfirmDialog(
      title: 'Clear All Liabilities?',
      content: 'Are you sure? This will delete all transactions related to borrowed or repaid money. This action cannot be undone.',
      confirmText: 'Clear Liabilities',
      isDestructive: true,
      onConfirm: () async {
        await ref.read(mockDatabaseProvider.notifier).clearAllLiabilities();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All liabilities cleared.')),
          );
        }
      },
    );
  }

  void _handleClearAllGoals() {
    _showConfirmDialog(
      title: 'Clear All Goals?',
      content: 'Are you sure? This will delete all goals and goal milestone records. This action cannot be undone.',
      confirmText: 'Clear Goals',
      isDestructive: true,
      onConfirm: () async {
        await ref.read(mockDatabaseProvider.notifier).clearAllGoals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All goals cleared.')),
          );
        }
      },
    );
  }

  void _handleFactoryReset() {
    _showConfirmDialog(
      title: 'Factory Reset Worth?',
      content: 'WARNING: This will completely wipe all ledger records, accounts, lots, goals, settings, snapshots, and cache from the SQLite database, and log you out. This action cannot be undone.',
      confirmText: 'Factory Reset',
      isDestructive: true,
      onConfirm: () async {
        await ref.read(mockDatabaseProvider.notifier).factoryReset();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application has been factory reset.')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Advanced Management',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader('LEDGER CONTROLS'),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.refresh_rounded,
                    title: 'Recalculate Balances',
                    subtitle: 'Recomputes cash, lots, and balances from the transaction ledger.',
                    onTap: _handleRecalculate,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.sync_rounded,
                    title: 'Sync Now',
                    subtitle: 'Triggers a push/pull sync with the remote cloud replica.',
                    trailingWidget: ref.watch(syncStatusProvider).status == SyncStatusType.syncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: AppColors.darkPrimary, strokeWidth: 2),
                          )
                        : null,
                    onTap: ref.watch(syncStatusProvider).status == SyncStatusType.syncing ? () {} : _handleSync,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.upload_file_outlined,
                    title: 'Export Backup',
                    subtitle: 'Generates a JSON file containing all ledger data.',
                    onTap: _handleExportOptions,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.download_outlined,
                    title: 'Import Backup',
                    subtitle: 'Restores a backup and runs full replay recalculation.',
                    onTap: _handleImport,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.cleaning_services_outlined,
                    title: 'Clear Cache',
                    subtitle: 'Deletes computed balance cache tables without affecting ledger.',
                    onTap: _handleClearCache,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('DANGER ZONE (IMMUTABLE RESET)'),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.restore_rounded,
                    title: 'Reset Demo Data',
                    subtitle: 'Restores default sample bank, investments, and goals.',
                    textColor: AppColors.darkWarning,
                    onTap: _handleResetDemoData,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Clear All Transactions',
                    subtitle: 'Wipes all transactions, buys, sales, and lots.',
                    textColor: AppColors.darkDanger,
                    onTap: _handleClearAllTransactions,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.trending_down_outlined,
                    title: 'Clear All Investments',
                    subtitle: 'Deletes all investments, buy lots, and sale records.',
                    textColor: AppColors.darkDanger,
                    onTap: _handleClearAllInvestments,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.people_outline,
                    title: 'Clear All Receivables',
                    subtitle: 'Removes all records of lent/recovered money.',
                    textColor: AppColors.darkDanger,
                    onTap: _handleClearAllReceivables,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.money_off_outlined,
                    title: 'Clear All Liabilities',
                    subtitle: 'Removes all records of borrowed/repaid money.',
                    textColor: AppColors.darkDanger,
                    onTap: _handleClearAllLiabilities,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.tour_outlined,
                    title: 'Clear All Goals',
                    subtitle: 'Deletes all financial and asset saving goals.',
                    textColor: AppColors.darkDanger,
                    onTap: _handleClearAllGoals,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.warning_amber_rounded,
                    title: 'Factory Reset Application',
                    subtitle: 'Fully wipes database tables and locks the application.',
                    textColor: AppColors.darkDanger,
                    onTap: _handleFactoryReset,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('DIAGNOSTIC TEST CONTROLS'),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.bug_report_outlined,
                    title: 'Simulate Rendering Crash',
                    subtitle: 'Forces a widget build crash to verify framework error boundary recovery.',
                    textColor: AppColors.darkWarning,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: const Text('Crash Test')),
                            body: Builder(
                              builder: (context) {
                                throw Exception('Simulated UI Rendering Crash');
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.bolt_outlined,
                    title: 'Simulate Asynchronous Crash',
                    subtitle: 'Throws an exception out-of-band in an async task to verify runtime auto-restart.',
                    textColor: AppColors.darkWarning,
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        throw Exception('Simulated Asynchronous Task Exception');
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.grey500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? textColor,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.darkPrimary),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(subtitle, style: const TextStyle(color: AppColors.grey500, fontSize: 12)),
      ),
      trailing: trailingWidget ?? const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.grey500),
      onTap: onTap,
    );
  }
}
