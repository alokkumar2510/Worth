import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';

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
    setState(() {
      _isSyncing = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully.')),
        );
      }
    });
  }

  void _handleExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exported backup file: worth_backup.json')),
    );
  }

  void _handleImport() {
    _showConfirmDialog(
      title: 'Import Backup?',
      content: 'Importing worth_backup.json will overwrite all local ledger history, lots, and details. This action cannot be undone.',
      confirmText: 'Import',
      onConfirm: () {
        _handleRecalculate();
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
                    trailingWidget: _isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: AppColors.darkPrimary, strokeWidth: 2),
                          )
                        : null,
                    onTap: _isSyncing ? () {} : _handleSync,
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildActionTile(
                    icon: Icons.upload_file_outlined,
                    title: 'Export Backup',
                    subtitle: 'Generates a JSON file containing all ledger data.',
                    onTap: _handleExport,
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
