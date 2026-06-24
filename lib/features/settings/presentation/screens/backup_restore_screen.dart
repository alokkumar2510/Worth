import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tactile_button.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/services/backup_service.dart';
import '../../../auth/providers/auth_providers.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  BackupInfo? _backupInfo;
  List<File> _backupFiles = [];
  bool _isLoading = true;
  bool _isActionInProgress = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadBackupData());
  }

  Future<void> _loadBackupData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final service = ref.read(realBackupServiceProvider);
      final info = await service.getBackupInfo();
      final files = await service.getBackupFileList();
      setState(() {
        _backupInfo = info;
        _backupFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load backup metadata: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  Future<void> _handleBackupNow() async {
    setState(() {
      _isActionInProgress = true;
    });
    try {
      final service = ref.read(realBackupServiceProvider);
      await service.triggerManualBackup();
      await _loadBackupData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily backup completed successfully.'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionInProgress = false;
        });
      }
    }
  }

  Future<void> _handleDeleteAllBackups() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text(
          'Delete All Backups?',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently delete all daily backup files stored locally. Are you sure you want to continue?',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isActionInProgress = true;
    });

    try {
      final service = ref.read(realBackupServiceProvider);
      await service.deleteAllBackups();
      await _loadBackupData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All local backup files deleted successfully.'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deletion failed: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionInProgress = false;
        });
      }
    }
  }

  Future<void> _handleRestoreBackup(File file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text(
          'Restore Local Backup?',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Restoring a backup will overwrite current local data. This action is irreversible. Do you want to proceed?',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Restore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isActionInProgress = true;
    });

    try {
      ref.read(isRestoringProvider.notifier).state = true;
      final service = ref.read(realBackupServiceProvider);
      await service.restoreBackupFromFile(file.path, '');
      
      // Reload state and rebuild caches
      await ref.read(mockDatabaseProvider.notifier).loadStateFromDatabase();
      ref.read(mockDatabaseProvider.notifier).recalculateBalances();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local data successfully restored from backup.'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    } finally {
      ref.read(isRestoringProvider.notifier).state = false;
      if (mounted) {
        setState(() {
          _isActionInProgress = false;
        });
      }
    }
  }

  Future<void> _handleExportBackup(File file) async {
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Worth Local Backup JSON File');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteSingleBackup(File file) async {
    setState(() {
      _isActionInProgress = true;
    });
    try {
      final service = ref.read(realBackupServiceProvider);
      await service.deleteBackupFile(file.path);
      await _loadBackupData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup file deleted successfully.'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActionInProgress = false;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double dBytes = bytes.toDouble();
    while (dBytes >= 1024 && i < suffixes.length - 1) {
      dBytes /= 1024;
      i++;
    }
    return '${dBytes.toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleTextColor = isDark ? Colors.white : AppColors.lightText;
    final bodyTextColor = isDark ? AppColors.grey400 : AppColors.lightSecondaryText;
    final cardBorderColor = isDark ? AppColors.glassBorder : AppColors.lightBorder;

    final lastBackupText = _backupInfo?.lastBackupDate != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(_backupInfo!.lastBackupDate!)
        : 'None';
    final nextBackupText = _backupInfo != null
        ? DateFormat('yyyy-MM-dd HH:mm').format(_backupInfo!.nextBackupDate)
        : 'None';
    final backupCountText = _backupInfo?.backupCount.toString() ?? '0';
    final storageUsedText = _formatBytes(_backupInfo?.storageUsedBytes ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Backup & Restore',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: titleTextColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: titleTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.darkPrimary))
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Metadata Panel
                        Text(
                          'SYSTEM METADATA',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.grey500 : AppColors.lightSecondaryText,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            children: [
                              _buildMetadataRow('Last Backup Date', lastBackupText, isDark),
                              Divider(color: cardBorderColor, height: 24),
                              _buildMetadataRow('Next Backup Date', nextBackupText, isDark),
                              Divider(color: cardBorderColor, height: 24),
                              _buildMetadataRow('Backup Count', backupCountText, isDark),
                              Divider(color: cardBorderColor, height: 24),
                              _buildMetadataRow('Storage Used', storageUsedText, isDark),
                              Divider(color: cardBorderColor, height: 24),
                              _buildMetadataRow('Storage Location', 'Android App Documents', isDark),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Action Controls
                        Row(
                          children: [
                            Expanded(
                              child: TactileButton(
                                onTap: _isActionInProgress ? null : _handleBackupNow,
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.darkPrimary,
                                        AppColors.darkPrimary.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    'Backup Now',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TactileButton(
                                onTap: (_isActionInProgress || _backupFiles.isEmpty)
                                    ? null
                                    : _handleDeleteAllBackups,
                                child: Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.darkDanger.withOpacity(0.5)),
                                    color: isDark ? Colors.transparent : Colors.white,
                                  ),
                                  child: Text(
                                    'Delete All',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkDanger,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // 3. Backup Files List
                        Text(
                          'AVAILABLE BACKUPS (MAX 30 DAYS)',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.grey500 : AppColors.lightSecondaryText,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_backupFiles.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.backup_table_outlined, size: 48, color: isDark ? AppColors.grey500 : AppColors.grey400),
                                const SizedBox(height: 16),
                                Text(
                                  'No local backup files found',
                                  style: GoogleFonts.inter(color: bodyTextColor, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _backupFiles.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final file = _backupFiles[index];
                              final filename = file.path.split(Platform.pathSeparator).last;
                              
                              // Extract human readable date from worth_backup_YYYY_MM_DD.json
                              String displayDate = filename;
                              try {
                                final dateStr = filename.replaceFirst('worth_backup_', '').replaceFirst('.json', '');
                                final dateParts = dateStr.split('_');
                                if (dateParts.length == 3) {
                                  final year = int.parse(dateParts[0]);
                                  final month = int.parse(dateParts[1]);
                                  final day = int.parse(dateParts[2]);
                                  displayDate = DateFormat('MMMM dd, yyyy').format(DateTime(year, month, day));
                                }
                              } catch (_) {}

                              final fileStat = file.statSync();
                              final fileSize = _formatBytes(fileStat.size);

                              return Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.layer2 : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: cardBorderColor),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.layer2 : AppColors.lightBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.description_outlined, color: AppColors.darkPrimary, size: 24),
                                  ),
                                  title: Text(
                                    displayDate,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: titleTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    fileSize,
                                    style: GoogleFonts.inter(
                                      color: bodyTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.share_outlined, size: 20),
                                        tooltip: 'Export Backup',
                                        onPressed: _isActionInProgress ? null : () => _handleExportBackup(file),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.settings_backup_restore_rounded, size: 20),
                                        tooltip: 'Restore Backup',
                                        onPressed: _isActionInProgress ? null : () => _handleRestoreBackup(file),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.darkDanger),
                                        tooltip: 'Delete File',
                                        onPressed: _isActionInProgress ? null : () => _handleDeleteSingleBackup(file),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  if (_isActionInProgress)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.darkPrimary),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? AppColors.grey500 : AppColors.lightSecondaryText,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightText,
          ),
        ),
      ],
    );
  }
}
