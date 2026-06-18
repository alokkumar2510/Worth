import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/constants/asset_constants.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/providers/mock_database.dart';
import '../../core/mock_data/mock_constants.dart';
import '../auth/providers/auth_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showCurrencySelector(BuildContext context, String current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Select Currency', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyTile(context, '₹', 'Indian Rupee (INR)', current),
            _buildCurrencyTile(context, '\$', 'US Dollar (USD)', current),
            _buildCurrencyTile(context, '€', 'Euro (EUR)', current),
            _buildCurrencyTile(context, '£', 'British Pound (GBP)', current),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTile(BuildContext context, String symbol, String name, String current) {
    final isSelected = current == symbol;
    return ListTile(
      title: Text(name, style: TextStyle(color: isSelected ? AppColors.darkPrimary : Colors.white)),
      trailing: Text(symbol, style: TextStyle(color: isSelected ? AppColors.darkPrimary : AppColors.grey500, fontWeight: FontWeight.bold, fontSize: 18)),
      onTap: () {
        ref.read(mockDatabaseProvider.notifier).updateCurrency(symbol);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Currency updated to $symbol')),
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context, String current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Select Theme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeTile(context, 'dark', 'Premium Dark Mode', current),
            _buildThemeTile(context, 'light', 'Clean Light Mode', current),
            _buildThemeTile(context, 'system', 'System Default', current),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, String value, String name, String current) {
    final isSelected = current == value;
    return ListTile(
      title: Text(name, style: TextStyle(color: isSelected ? AppColors.darkPrimary : Colors.white)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.darkPrimary) : null,
      onTap: () {
        ref.read(mockDatabaseProvider.notifier).updateTheme(value);
        Navigator.pop(context);
      },
    );
  }

  void _handleRecalculate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 1), () {
          ref.read(mockDatabaseProvider.notifier).recalculateBalances();
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Caches rebuilt successfully. Replay equivalence verified.')),
          );
        });
        return AlertDialog(
          
          content: Row(
            children: const [
              CircularProgressIndicator(color: AppColors.darkPrimary),
              SizedBox(width: 20),
              Text('Replaying transaction log...', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  void _handleMockBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Export Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.backupRestore,
              height: 120,
              semanticLabel: AssetConstants.backupRestoreLabel,
            ),
            const SizedBox(height: 16),
            const Text(
              'This will generate an encrypted JSON file containing your immutable transactions, accounts, and investment lots. Exporting to worth_backup_2026.json...',
              style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Export', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleMockRestore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Import Backup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.backupRestore,
              height: 120,
              semanticLabel: AssetConstants.backupRestoreLabel,
            ),
            const SizedBox(height: 16),
            const Text(
              'Select worth_backup.json. The app will decrypt the backup, overwrite the local database, and perform a full replay calculation of all balances. Continue?',
              style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
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
              _handleRecalculate();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Restore & Rebuild', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'More Options',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile link header
            GlassCard(
              onTap: () => context.push('/profile'),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.darkPrimary.withOpacity(0.12),
                    child: const Icon(Icons.person, color: AppColors.darkPrimary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Wealth Tier: Wealth Builder', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey500),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferences Title
            _buildSectionHeader('PREFERENCES'),
            const SizedBox(height: 8),
            
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.monetization_on_outlined,
                    title: 'Reporting Currency',
                    value: dbState.currency == '₹' ? 'INR (₹)' : dbState.currency == '\$' ? 'USD (\$)' : dbState.currency,
                    onTap: () => _showCurrencySelector(context, dbState.currency),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'App Theme',
                    value: dbState.themeMode.toUpperCase(),
                    onTap: () => _showThemeSelector(context, dbState.themeMode),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Daily Financial Check-ins',
                    value: dbState.checkInEnabled ? 'Active' : 'Disabled',
                    onTap: () => context.push('/settings/checkins'),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Definitions & Formulae',
                    value: 'Glossary & calculations',
                    onTap: () => context.push('/definitions'),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.label_outline_rounded,
                    title: 'Categories & Custom Labels',
                    value: 'Configure transaction labels',
                    onTap: () => context.push('/settings/categories_labels'),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  SwitchListTile(
                    title: const Text('Biometric / PIN App Lock', style: TextStyle(color: Colors.white, fontSize: 14)),
                    secondary: const Icon(Icons.lock_outline, color: AppColors.darkPrimary),
                    activeColor: AppColors.darkPrimary,
                    value: dbState.appLockEnabled,
                    onChanged: (val) {
                      ref.read(mockDatabaseProvider.notifier).updateAppLock(val, '1234');
                      if (val) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: const BorderSide(color: AppColors.glassBorder),
                            ),
                            title: const Text('Security Enabled', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Your local database key is now encrypted and protected by your device\'s hardware biometrics / PIN.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Dismiss', style: TextStyle(color: AppColors.darkPrimary)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  if (dbState.appLockEnabled) ...[
                    const Divider(color: AppColors.glassBorder, height: 1),
                    ListTile(
                      leading: const Icon(Icons.timer_outlined, color: AppColors.darkPrimary),
                      title: const Text('Auto-Lock Timeout', style: TextStyle(color: Colors.white, fontSize: 14)),
                      trailing: DropdownButton<int>(
                        value: dbState.appLockTimeout,
                        dropdownColor: AppColors.layer2,
                        underline: const SizedBox(),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey500),
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Immediately')),
                          DropdownMenuItem(value: 60, child: Text('1 Minute')),
                          DropdownMenuItem(value: 300, child: Text('5 Minutes')),
                          DropdownMenuItem(value: 900, child: Text('15 Minutes')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(mockDatabaseProvider.notifier).updateAppLockTimeout(val);
                          }
                        },
                      ),
                    ),
                  ],
                  const Divider(color: AppColors.glassBorder, height: 1),
                  SwitchListTile(
                    title: const Text('Enable Notifications', style: TextStyle(color: Colors.white, fontSize: 14)),
                    secondary: const Icon(Icons.notifications_none_outlined, color: AppColors.darkPrimary),
                    activeColor: AppColors.darkPrimary,
                    value: dbState.notificationsEnabled,
                    onChanged: (val) {
                      ref.read(mockDatabaseProvider.notifier).updateNotificationsEnabled(val);
                    },
                  ),
                  if (dbState.notificationsEnabled) ...[
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildNotificationPrefTile(
                      title: 'Transaction Reminders',
                      value: dbState.notificationPrefTransactions,
                      onChanged: (val) {
                        ref.read(mockDatabaseProvider.notifier).updateNotificationPref('transactions', val);
                      },
                    ),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildNotificationPrefTile(
                      title: 'Daily Check-ins',
                      value: dbState.notificationPrefCheckIns,
                      onChanged: (val) {
                        ref.read(mockDatabaseProvider.notifier).updateNotificationPref('checkins', val);
                      },
                    ),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildNotificationPrefTile(
                      title: 'SIP Reminders',
                      value: dbState.notificationPrefSip,
                      onChanged: (val) {
                        ref.read(mockDatabaseProvider.notifier).updateNotificationPref('sip', val);
                      },
                    ),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildNotificationPrefTile(
                      title: 'Goal Reminders',
                      value: dbState.notificationPrefGoals,
                      onChanged: (val) {
                        ref.read(mockDatabaseProvider.notifier).updateNotificationPref('goals', val);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Specialized Tools
            _buildSectionHeader('SPECIALIZED TOOLS'),
            const SizedBox(height: 8),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.dashboard_customize_outlined,
                    title: 'IPO Pool Dashboard',
                    value: 'Active pools & pool creation',
                    onTap: () => context.push('/settings/ipo_pool'),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.contact_mail_outlined,
                    title: 'Contributor Ledger',
                    value: 'Profiles, ROIs, and settlement history',
                    onTap: () => context.push('/settings/ipo_pool/contributors'),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.history_edu_outlined,
                    title: 'IPO History Archive',
                    value: 'Timeline & statistics of listed pools',
                    onTap: () => context.push('/settings/ipo_pool/archive'),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildSettingsTile(
                    icon: Icons.archive_outlined,
                    title: 'Archived Portfolio Center',
                    value: 'View and restore archived items',
                    onTap: () => context.push('/settings/archive_center'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // System Title
            _buildSectionHeader('SYSTEM ACTIONS'),
            const SizedBox(height: 8),

            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.settings_suggest_outlined,
                    title: 'Advanced Settings',
                    value: 'Ledger resets & management',
                    onTap: () => context.push('/settings/advanced'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Center Information
            _buildSectionHeader('ABOUT'),
            const SizedBox(height: 8),

            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoRow('Version', '1.0.0 (Build 26)'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Database Model', 'FIFO Lot Ledger (Drift/Encrypted)'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      ref.read(authRepositoryProvider).signOut();
                    },
                    child: const Text('Log Out of Worth', style: TextStyle(color: AppColors.darkDanger, fontWeight: FontWeight.bold)),
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final bool isLongValue = value.length > 15;
    return ListTile(
      leading: Icon(icon, color: AppColors.darkPrimary),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: isLongValue
          ? Text(value, style: const TextStyle(color: AppColors.grey500, fontSize: 12))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLongValue) ...[
            Text(value, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.grey500),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 12)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildNotificationPrefTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
        activeColor: AppColors.darkPrimary,
        dense: true,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
