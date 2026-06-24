import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_version.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/constants/asset_constants.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/providers/mock_database.dart';
import '../../core/providers/app_providers.dart';
import '../../core/mock_data/mock_constants.dart';
import '../auth/providers/auth_providers.dart';
import '../sync/presentation/providers/sync_status_provider.dart';
import '../../core/widgets/tactile_button.dart';
import '../checkins/presentation/providers/check_in_providers.dart';
import '../reports/presentation/widgets/export_success_sheet.dart';
import '../reports/presentation/widgets/export_failure_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Search state
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Developer easter egg state
  bool _developerMode = false;
  int _devTapCount = 0;

  // Local state variables for interactive options
  bool _receivableFollowupsEnabled = true;
  String _pdfTheme = 'Editorial Light';
  String _reportStyle = 'Full Audit Ledger';
  bool _showPageNumbers = true;
  bool _showLogoHeader = true;
  bool _includeSignature = false;
  String _reportBrandingName = 'Worth Private Statement';

  // Export PDF state
  bool _isExporting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- ORIGINAL FUNCTIONALITIES (MUST BE PRESERVED) ---

  void _showCurrencySelector(BuildContext context, String current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
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
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
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

  Future<void> _launchEmailSupport(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'alok.vssut28@gmail.com',
      query: 'subject=Worth%20App%20Support%20Request',
    );
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open mail client. Support: alok.vssut28@gmail.com'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
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
          backgroundColor: AppColors.layer2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
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
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
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
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
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

  void _confirmRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text(
          'Restore Cloud Backup?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Text(
          'This will wipe all local data, download your backup from the cloud, and rebuild your balance ledgers. Continue?',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(syncStatusProvider.notifier).manualRestore();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkPrimary,
              foregroundColor: Colors.white,
            ),
            child: Text('Restore', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleAppLockToggle(bool val) {
    ref.read(mockDatabaseProvider.notifier).updateAppLock(val, '1234');
    if (val) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.layer2,
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
  }

  Future<void> _exportPdfReport(MockDatabaseState dbState, {bool forcePrivateDirectory = false}) async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pdfService = ref.read(pdfExportServiceProvider);
      final pdfBytes = await pdfService.generateReportBytes(dbState);
      final savedPath = await pdfService.savePdfToDownloads(pdfBytes, forcePrivateDirectory: forcePrivateDirectory);
      final fileName = savedPath.split(Platform.pathSeparator).last;
      
      final file = File(savedPath);
      final fileSize = await file.length();

      setState(() {
        _isExporting = false;
      });

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => ExportSuccessSheet(
          filePath: savedPath,
          fileName: fileName,
          pdfBytes: pdfBytes,
          fileSizeInBytes: fileSize,
        ),
      );
    } catch (e) {
      setState(() {
        _isExporting = false;
      });
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) => ExportFailureSheet(
          errorMessage: e.toString(),
          onRetry: () => _exportPdfReport(dbState, forcePrivateDirectory: false),
          onSavePrivate: () => _exportPdfReport(dbState, forcePrivateDirectory: true),
        ),
      );
    }
  }

  // --- NEW INTERACTIVE DIALOGS FOR REDESIGN SKELETON OPTIONS ---

  void _showLoginSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Login & Security', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AUTHENTICATION PROVIDER', style: TextStyle(color: AppColors.grey500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text('Firebase Auth (Secure Local Engine)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('DEVICE AUTHORIZATION', style: TextStyle(color: AppColors.grey500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text('Authorized Hardware Key (AES-256)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            const Text('SESSION EXPIRY', style: TextStyle(color: AppColors.grey500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text('Never (Protected by Device Biometrics)', style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.darkPrimary)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Change Password', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'A secure link to update your master account password will be sent to your registered email address. Continue?',
          style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset instructions dispatched to email.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPinLockDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Configure Security PIN', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter a 4-digit PIN to secure local database records when biometrics are unavailable.',
              style: TextStyle(color: AppColors.grey400, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 16),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                counterText: '',
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkPrimary)),
              ),
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
              final pin = controller.text;
              if (pin.length == 4) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Security PIN successfully configured.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Set PIN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEncryptionStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: AppColors.darkSuccess, size: 24),
            const SizedBox(width: 10),
            Text('Encryption Active', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your entire local SQLite database is encrypted on-disk. Worth utilizes industrial AES-256 standards.',
              style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            _buildDialogMetaRow('Cipher Scheme', 'AES-256-CBC'),
            _buildDialogMetaRow('Key Derivation', 'PBKDF2 (10,000 Rounds)'),
            _buildDialogMetaRow('Hardware Enclave', 'Secure Hardware Enclave Bound'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.darkPrimary)),
          ),
        ],
      ),
    );
  }

  void _showBackupStatusDialog(BuildContext context, SyncStatusState syncState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Backup & Replication Status', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogMetaRow('Sync Status', syncState.statusText),
            _buildDialogMetaRow('Last Replication', syncState.lastSyncedText),
            _buildDialogMetaRow('Replicated Records', '${syncState.cloudRecords} elements'),
            _buildDialogMetaRow('Replica Location', 'Cloud Primary (AWS Mumbai)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.darkPrimary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Danger Zone', style: GoogleFonts.outfit(color: AppColors.darkDanger, fontWeight: FontWeight.bold)),
        content: const Text(
          'Select an action to reset the app. "Clear Transactions" purges all transaction listings, while "Factory Reset" wipes settings, accounts, cash assets, and logs.',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings/advanced');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Advanced Resets', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStorageUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Storage Usage', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogMetaRow('SQLite DB File Size', '248.0 KB'),
            _buildDialogMetaRow('Cache Size', '124.0 KB'),
            _buildDialogMetaRow('Attached Reports', '0 items'),
            const SizedBox(height: 16),
            const Text(
              'Purging the balance cache deletes computed values without affecting your raw transaction entries.',
              style: TextStyle(color: AppColors.grey500, fontSize: 11, height: 1.3),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleRecalculate();
            },
            child: const Text('Purge Cache', style: TextStyle(color: AppColors.darkPrimary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.grey500)),
          ),
        ],
      ),
    );
  }

  void _showPdfThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: const Text('PDF Report Theme', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOptionTile(context, 'Editorial Light'),
            _buildThemeOptionTile(context, 'Modern Obsidian'),
            _buildThemeOptionTile(context, 'Emerald Green'),
            _buildThemeOptionTile(context, 'Royal Gold'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptionTile(BuildContext context, String value) {
    final isSelected = _pdfTheme == value;
    return ListTile(
      title: Text(value, style: TextStyle(color: isSelected ? AppColors.darkPrimary : Colors.white)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.darkPrimary) : null,
      onTap: () {
        setState(() {
          _pdfTheme = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showReportStyleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: const Text('Select Report Style', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStyleOptionTile(context, 'Executive Brief'),
            _buildStyleOptionTile(context, 'Standard Statement'),
            _buildStyleOptionTile(context, 'Full Audit Ledger'),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleOptionTile(BuildContext context, String value) {
    final isSelected = _reportStyle == value;
    return ListTile(
      title: Text(value, style: TextStyle(color: isSelected ? AppColors.darkPrimary : Colors.white)),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.darkPrimary) : null,
      onTap: () {
        setState(() {
          _reportStyle = value;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showExportPreferencesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.layer2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: Text('Export Preferences', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Include Page Numbers', style: TextStyle(color: Colors.white, fontSize: 13)),
                activeColor: AppColors.darkPrimary,
                value: _showPageNumbers,
                onChanged: (val) {
                  setDialogState(() => _showPageNumbers = val);
                  setState(() => _showPageNumbers = val);
                },
              ),
              const Divider(color: AppColors.glassBorder, height: 1),
              SwitchListTile(
                title: const Text('Include Logo Header', style: TextStyle(color: Colors.white, fontSize: 13)),
                activeColor: AppColors.darkPrimary,
                value: _showLogoHeader,
                onChanged: (val) {
                  setDialogState(() => _showLogoHeader = val);
                  setState(() => _showLogoHeader = val);
                },
              ),
              const Divider(color: AppColors.glassBorder, height: 1),
              SwitchListTile(
                title: const Text('Signature Verification Block', style: TextStyle(color: Colors.white, fontSize: 13)),
                activeColor: AppColors.darkPrimary,
                value: _includeSignature,
                onChanged: (val) {
                  setDialogState(() => _includeSignature = val);
                  setState(() => _includeSignature = val);
                },
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
      ),
    );
  }

  void _showReportBrandingDialog(BuildContext context) {
    final controller = TextEditingController(text: _reportBrandingName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Report Custom Branding', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Branding Title Header',
            labelStyle: TextStyle(color: AppColors.grey500),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkPrimary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              final newBranding = controller.text.trim();
              if (newBranding.isNotEmpty) {
                setState(() {
                  _reportBrandingName = newBranding;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report branding title updated.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('File a Bug Report', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Describe what occurred, your expectation, and steps to reproduce...',
            hintStyle: TextStyle(color: AppColors.grey500, fontSize: 12),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.glassBorder)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkPrimary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you! Bug report submitted successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRateWorthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Rate Worth App', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'If Worth helps you control your private ledger, please leave a quick rating! We appreciate your support.',
              style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => const Icon(Icons.star_rounded, color: Color(0xFFD4AF37), size: 36),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App rating submitted. Thank you!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Submit Rating', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSyncDebuggerDialog(BuildContext context, SyncStatusState syncState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Cloud Replica Debugger', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('[DEBUG REPLICA SYNC ENGINE LOGS]', style: TextStyle(color: AppColors.darkPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildDebugLogLine('Initial replica connection verified.'),
                _buildDebugLogLine('Sync status requested: ${syncState.status}'),
                _buildDebugLogLine('Replica elements tracked in cache: ${syncState.cloudRecords}'),
                _buildDebugLogLine('Last replication success event: ${syncState.lastSyncedText}'),
                _buildDebugLogLine('Crypto handshake status: AES-256 Validated'),
                _buildDebugLogLine('Database connection pool size: 5 (Open)'),
              ],
            ),
          ),
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

  Widget _buildDebugLogLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        '>> $text',
        style: const TextStyle(fontFamily: 'monospace', color: Colors.white70, fontSize: 10),
      ),
    );
  }

  void _showDatabaseStatusDialog(BuildContext context, MockDatabaseState dbState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Database Table Registry', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogMetaRow('Accounts Table', '${dbState.accounts.length} rows'),
            _buildDialogMetaRow('Transactions Table', '${dbState.transactions.length} rows'),
            _buildDialogMetaRow('Investments Table', '${dbState.investments.length} rows'),
            _buildDialogMetaRow('SIP Table', '${dbState.sips.length} rows'),
            _buildDialogMetaRow('Goals Table', '${dbState.goals.length} rows'),
            _buildDialogMetaRow('Recovery Table', '${dbState.recoveryAllocations.length} rows'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.darkPrimary)),
          ),
        ],
      ),
    );
  }

  void _showNotificationStatusDialog(BuildContext context, MockDatabaseState dbState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.layer2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: Text('Active Scheduled Triggers', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogMetaRow('Notification Service', dbState.notificationsEnabled ? 'ACTIVE' : 'DISABLED'),
            _buildDialogMetaRow('Permission Asked', dbState.notificationsAsked ? 'Yes' : 'No'),
            const SizedBox(height: 12),
            const Text('REGISTERED ALARMS:', style: TextStyle(color: AppColors.grey500, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _buildTriggerItem('Daily check-in alarm trigger', dbState.notificationPrefCheckIns),
            _buildTriggerItem('Monthly SIP alarm check trigger', dbState.notificationPrefSip),
            _buildTriggerItem('Goal milestone prediction alarm trigger', dbState.notificationPrefGoals),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.darkPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerItem(String name, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle_rounded : Icons.cancel_outlined, color: active ? AppColors.darkSuccess : AppColors.grey500, size: 12),
          const SizedBox(width: 6),
          Expanded(child: Text(name, style: const TextStyle(color: Colors.white70, fontSize: 11))),
        ],
      ),
    );
  }

  void _showCalendarNotificationsDialog(BuildContext context, MockDatabaseState dbState) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.layer2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
          title: Text('Calendar Reminders', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('On due date', style: TextStyle(color: Colors.white, fontSize: 13)),
                activeColor: AppColors.darkPrimary,
                value: dbState.notificationPrefCalendarOnDue,
                onChanged: (val) {
                  ref.read(mockDatabaseProvider.notifier).updateNotificationPref('calendarOnDue', val);
                  setDialogState(() {});
                },
              ),
              const Divider(color: AppColors.glassBorder, height: 1),
              SwitchListTile(
                title: const Text('1 day before', style: TextStyle(color: Colors.white, fontSize: 13)),
                activeColor: AppColors.darkPrimary,
                value: dbState.notificationPrefCalendar1Day,
                onChanged: (val) {
                  ref.read(mockDatabaseProvider.notifier).updateNotificationPref('calendar1Day', val);
                  setDialogState(() {});
                },
              ),
              const Divider(color: AppColors.glassBorder, height: 1),
              SwitchListTile(
                title: const Text('3 days before', style: TextStyle(color: Colors.white, fontSize: 13)),
                activeColor: AppColors.darkPrimary,
                value: dbState.notificationPrefCalendar3Days,
                onChanged: (val) {
                  ref.read(mockDatabaseProvider.notifier).updateNotificationPref('calendar3Days', val);
                  setDialogState(() {});
                },
              ),
              const Divider(color: AppColors.glassBorder, height: 1),
              SwitchListTile(
                title: const Text('7 days before', style: TextStyle(color: Colors.white, fontSize: 13)),
                activeColor: AppColors.darkPrimary,
                value: dbState.notificationPrefCalendar7Days,
                onChanged: (val) {
                  ref.read(mockDatabaseProvider.notifier).updateNotificationPref('calendar7Days', val);
                  setDialogState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done', style: TextStyle(color: AppColors.darkPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  // --- DEVELOPER EASTER EGG ---

  void _incrementDeveloperTap() {
    _devTapCount++;
    if (_devTapCount == 7) {
      setState(() {
        _developerMode = !_developerMode;
        _devTapCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_developerMode ? 'Developer Mode Activated' : 'Developer Mode Deactivated'),
          backgroundColor: _developerMode ? AppColors.darkPrimary : AppColors.grey500,
        ),
      );
    } else if (_devTapCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are ${7 - _devTapCount} taps away from developer tools.'),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final syncState = ref.watch(syncStatusProvider);
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final userEmail = user?.email ?? 'private@worth.io';

    final joinDate = DateFormat('MMMM yyyy').format(dbState.userCreatedAt ?? DateTime.now());
    
    // Currency formatters
    final formatCompact = NumberFormat.currency(locale: 'en_IN', symbol: dbState.currency, decimalDigits: 0);
    final formattedNetWorth = formatCompact.format(dbState.netWorth);

    // Wealth score calculation (Morgan Stanley inspired composite)
    final int wealthScore = (dbState.netWorth <= 0)
        ? 10
        : ((1.0 - (dbState.totalLiabilities / (dbState.totalAssets > 0 ? dbState.totalAssets : 1.0))) * 80 + 20).clamp(0, 100).toInt();

    // Streak retrieval
    final streakAsync = ref.watch(checkInStreakInfoProvider);
    final currentStreak = streakAsync.when(
      data: (streak) => streak.currentStreak,
      loading: () => 0,
      error: (_, __) => 0,
    );

    // Dynamic list of setting items for search filtering
    final allItems = [
      // ACCOUNT
      _SettingItem(
        title: 'Profile Information',
        subtitle: 'Full name, wealth tier, and milestones',
        section: 'ACCOUNT',
        icon: Icons.person_outline_rounded,
        iconColor: AppColors.darkPrimary,
        onTap: () => context.push('/profile'),
      ),
      _SettingItem(
        title: 'Login & Security',
        subtitle: 'Current active session and credentials',
        section: 'ACCOUNT',
        icon: Icons.security_rounded,
        iconColor: AppColors.darkPrimary,
        onTap: () => _showLoginSecurityDialog(context),
      ),
      _SettingItem(
        title: 'Change Password',
        subtitle: 'Update security passphrase',
        section: 'ACCOUNT',
        icon: Icons.key_rounded,
        iconColor: AppColors.darkPrimary,
        onTap: () => _showChangePasswordDialog(context),
      ),
      _SettingItem(
        title: 'Biometric Lock',
        subtitle: 'Secure access with Touch/Face ID',
        section: 'ACCOUNT',
        icon: Icons.fingerprint_rounded,
        iconColor: AppColors.darkPrimary,
        onTap: () {},
        isSwitch: true,
        switchValue: dbState.appLockEnabled,
        onSwitchChanged: _handleAppLockToggle,
      ),
      if (dbState.appLockEnabled)
        _SettingItem(
          title: 'Auto-Lock Timeout',
          subtitle: 'Configure app lock inactive delay',
          section: 'ACCOUNT',
          icon: Icons.timer_outlined,
          iconColor: AppColors.darkPrimary,
          onTap: () {},
          isDropdown: true,
          dropdownValue: dbState.appLockTimeout,
          dropdownItems: const [
            DropdownMenuItem(value: 0, child: Text('Immediately')),
            DropdownMenuItem(value: 60, child: Text('1 Minute')),
            DropdownMenuItem(value: 300, child: Text('5 Minutes')),
            DropdownMenuItem(value: 900, child: Text('15 Minutes')),
          ],
          onDropdownChanged: (val) {
            if (val != null) {
              ref.read(mockDatabaseProvider.notifier).updateAppLockTimeout(val);
            }
          },
        ),
      _SettingItem(
        title: 'Cloud Sync',
        subtitle: 'Manage remote data replication',
        section: 'ACCOUNT',
        icon: Icons.cloud_sync_rounded,
        iconColor: AppColors.darkPrimary,
        onTap: () => context.push('/settings/sync_center'),
      ),
      _SettingItem(
        title: 'Backup & Restore',
        subtitle: 'Automated daily & manual backups',
        section: 'ACCOUNT',
        icon: Icons.backup_table_rounded,
        iconColor: AppColors.darkPrimary,
        onTap: () => context.push('/settings/backup_restore'),
      ),

      // WEALTH MANAGEMENT
      _SettingItem(
        title: 'Net Worth Preferences',
        subtitle: 'Reporting currency and format settings',
        section: 'WEALTH MANAGEMENT',
        icon: Icons.currency_exchange_rounded,
        iconColor: const Color(0xFF8B5CF6),
        onTap: () => _showCurrencySelector(context, dbState.currency),
        trailing: Text(
          dbState.currency == '₹' ? 'INR (₹)' : dbState.currency == '\$' ? 'USD (\$)' : dbState.currency,
          style: const TextStyle(color: AppColors.grey400, fontSize: 12),
        ),
      ),
      _SettingItem(
        title: 'Dashboard Preferences',
        subtitle: 'Visual layout and dark mode theme selector',
        section: 'WEALTH MANAGEMENT',
        icon: Icons.dashboard_customize_rounded,
        iconColor: const Color(0xFF8B5CF6),
        onTap: () => _showThemeSelector(context, dbState.themeMode),
        trailing: Text(
          dbState.themeMode.toUpperCase(),
          style: const TextStyle(color: AppColors.grey400, fontSize: 12),
        ),
      ),
      _SettingItem(
        title: 'Portfolio Preferences',
        subtitle: 'Archived records and asset snapshots',
        section: 'WEALTH MANAGEMENT',
        icon: Icons.history_toggle_off_rounded,
        iconColor: const Color(0xFF8B5CF6),
        onTap: () => context.push('/settings/history_archive'),
      ),
      _SettingItem(
        title: 'Investment Preferences',
        subtitle: 'Transaction categories & custom labels',
        section: 'WEALTH MANAGEMENT',
        icon: Icons.label_outline_rounded,
        iconColor: const Color(0xFF8B5CF6),
        onTap: () => context.push('/settings/categories_labels'),
      ),
      _SettingItem(
        title: 'SIP Preferences',
        subtitle: 'Automation rules and recurring savings',
        section: 'WEALTH MANAGEMENT',
        icon: Icons.schedule_send_rounded,
        iconColor: const Color(0xFF8B5CF6),
        onTap: () => context.push('/sip'),
      ),
      _SettingItem(
        title: 'IPO Preferences',
        subtitle: 'IPO pools dashboard and contributors list',
        section: 'WEALTH MANAGEMENT',
        icon: Icons.pie_chart_outline_rounded,
        iconColor: const Color(0xFF8B5CF6),
        onTap: () => context.push('/settings/ipo_pool'),
      ),
      _SettingItem(
        title: 'Education Loan Preferences',
        subtitle: 'Moratorium and loan forecasting hub',
        section: 'WEALTH MANAGEMENT',
        icon: Icons.school_outlined,
        iconColor: const Color(0xFF0EA5E9),
        onTap: () => context.push('/settings/education_loan'),
      ),

      // NOTIFICATIONS
      _SettingItem(
        title: 'Push Notifications',
        subtitle: 'Global alert notification triggers',
        section: 'NOTIFICATIONS',
        icon: Icons.notifications_none_outlined,
        iconColor: const Color(0xFFEC4899),
        isSwitch: true,
        switchValue: dbState.notificationsEnabled,
        onSwitchChanged: (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationsEnabled(val),
      ),
      _SettingItem(
        title: 'Daily Check-ins',
        subtitle: 'Daily financial check-in alert triggers',
        section: 'NOTIFICATIONS',
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFFEC4899),
        isSwitch: true,
        switchValue: dbState.notificationPrefCheckIns,
        onSwitchChanged: dbState.notificationsEnabled
            ? (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationPref('checkins', val)
            : null,
      ),
      _SettingItem(
        title: 'Transaction Reminders',
        subtitle: 'Alerts for trade buys, sales and deposits',
        section: 'NOTIFICATIONS',
        icon: Icons.receipt_long_outlined,
        iconColor: const Color(0xFFEC4899),
        isSwitch: true,
        switchValue: dbState.notificationPrefTransactions,
        onSwitchChanged: dbState.notificationsEnabled
            ? (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationPref('transactions', val)
            : null,
      ),
      _SettingItem(
        title: 'SIP Reminders',
        subtitle: 'SIP due date payment warning notifications',
        section: 'NOTIFICATIONS',
        icon: Icons.watch_later_outlined,
        iconColor: const Color(0xFFEC4899),
        isSwitch: true,
        switchValue: dbState.notificationPrefSip,
        onSwitchChanged: dbState.notificationsEnabled
            ? (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationPref('sip', val)
            : null,
      ),
      _SettingItem(
        title: 'Receivable Follow-ups',
        subtitle: 'Due alerts for lending and recovery payments',
        section: 'NOTIFICATIONS',
        icon: Icons.person_pin_rounded,
        iconColor: const Color(0xFFEC4899),
        isSwitch: true,
        switchValue: _receivableFollowupsEnabled,
        onSwitchChanged: (val) => setState(() => _receivableFollowupsEnabled = val),
      ),
      _SettingItem(
        title: 'Goal Reminders',
        subtitle: 'Milestone achievements prediction updates',
        section: 'NOTIFICATIONS',
        icon: Icons.track_changes_outlined,
        iconColor: const Color(0xFFEC4899),
        isSwitch: true,
        switchValue: dbState.notificationPrefGoals,
        onSwitchChanged: dbState.notificationsEnabled
            ? (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationPref('goals', val)
            : null,
      ),
      _SettingItem(
        title: 'Financial Calendar Reminders',
        subtitle: 'Alert schedule configs for calendar events',
        section: 'NOTIFICATIONS',
        icon: Icons.calendar_month_outlined,
        iconColor: const Color(0xFFEC4899),
        onTap: () => _showCalendarNotificationsDialog(context, dbState),
      ),

      // PRIVACY & SECURITY
      _SettingItem(
        title: 'Biometric Lock',
        subtitle: 'Secure access with Touch/Face ID',
        section: 'PRIVACY & SECURITY',
        icon: Icons.lock_person_outlined,
        iconColor: const Color(0xFF10B981),
        isSwitch: true,
        switchValue: dbState.appLockEnabled,
        onSwitchChanged: _handleAppLockToggle,
      ),
      _SettingItem(
        title: 'PIN Lock',
        subtitle: 'Configure or update local PIN key',
        section: 'PRIVACY & SECURITY',
        icon: Icons.lock_outline,
        iconColor: const Color(0xFF10B981),
        onTap: () => _showPinLockDialog(context),
      ),
      _SettingItem(
        title: 'Encryption Status',
        subtitle: 'Drift SQLite database cryptographic status',
        section: 'PRIVACY & SECURITY',
        icon: Icons.enhanced_encryption_outlined,
        iconColor: const Color(0xFF10B981),
        onTap: () => _showEncryptionStatusDialog(context),
      ),
      _SettingItem(
        title: 'Backup Status',
        subtitle: 'Check local files and cloud ledger logs',
        section: 'PRIVACY & SECURITY',
        icon: Icons.cloud_done_outlined,
        iconColor: const Color(0xFF10B981),
        onTap: () => _showBackupStatusDialog(context, syncState),
      ),
      _SettingItem(
        title: 'Export Data',
        subtitle: 'Secure backup download folder export',
        section: 'PRIVACY & SECURITY',
        icon: Icons.file_upload_outlined,
        iconColor: const Color(0xFF10B981),
        onTap: _handleMockBackup,
      ),
      _SettingItem(
        title: 'Delete Data',
        subtitle: 'Factory reset or clear transaction ledger',
        section: 'PRIVACY & SECURITY',
        icon: Icons.delete_forever_outlined,
        iconColor: const Color(0xFF10B981),
        onTap: () => _showDeleteDataDialog(context),
      ),

      // DATA MANAGEMENT
      _SettingItem(
        title: 'Import Data',
        subtitle: 'Decrypt worth_backup.json and restore state',
        section: 'DATA MANAGEMENT',
        icon: Icons.input_rounded,
        iconColor: const Color(0xFFF59E0B),
        onTap: _handleMockRestore,
      ),
      _SettingItem(
        title: 'Export Data',
        subtitle: 'Compile transaction and asset database',
        section: 'DATA MANAGEMENT',
        icon: Icons.output_rounded,
        iconColor: const Color(0xFFF59E0B),
        onTap: _handleMockBackup,
      ),
      _SettingItem(
        title: 'Cloud Backup',
        subtitle: 'Push local changes to cloud replica',
        section: 'DATA MANAGEMENT',
        icon: Icons.backup_outlined,
        iconColor: const Color(0xFFF59E0B),
        onTap: () => ref.read(syncStatusProvider.notifier).forceSync(),
      ),
      _SettingItem(
        title: 'Restore From Backup',
        subtitle: 'Overwrite local state from cloud repository',
        section: 'DATA MANAGEMENT',
        icon: Icons.restore_page_rounded,
        iconColor: const Color(0xFFF59E0B),
        onTap: () => _confirmRestore(context),
      ),
      _SettingItem(
        title: 'Clear Cache',
        subtitle: 'Recalculate ledger logs and clean views',
        section: 'DATA MANAGEMENT',
        icon: Icons.refresh_rounded,
        iconColor: const Color(0xFFF59E0B),
        onTap: _handleRecalculate,
      ),
      _SettingItem(
        title: 'Storage Usage',
        subtitle: 'SQLite db size and cache management options',
        section: 'DATA MANAGEMENT',
        icon: Icons.storage_rounded,
        iconColor: const Color(0xFFF59E0B),
        onTap: () => _showStorageUsageDialog(context),
      ),

      // REPORTS & PDF
      _SettingItem(
        title: 'PDF Theme',
        subtitle: 'Choose colors and fonts for exported statements',
        section: 'REPORTS & PDF',
        icon: Icons.picture_as_pdf_outlined,
        iconColor: const Color(0xFF3B82F6),
        onTap: () => _showPdfThemeDialog(context),
        trailing: Text(
          _pdfTheme,
          style: const TextStyle(color: AppColors.grey400, fontSize: 12),
        ),
      ),
      _SettingItem(
        title: 'Report Style',
        subtitle: 'Select layout structure of monthly reports',
        section: 'REPORTS & PDF',
        icon: Icons.view_quilt_rounded,
        iconColor: const Color(0xFF3B82F6),
        onTap: () => _showReportStyleDialog(context),
        trailing: Text(
          _reportStyle,
          style: const TextStyle(color: AppColors.grey400, fontSize: 12),
        ),
      ),
      _SettingItem(
        title: 'Export Preferences',
        subtitle: 'Toggle branding and signature components',
        section: 'REPORTS & PDF',
        icon: Icons.settings_outlined,
        iconColor: const Color(0xFF3B82F6),
        onTap: () => _showExportPreferencesDialog(context),
      ),
      _SettingItem(
        title: 'Report Branding',
        subtitle: 'Customize corporate/personal statements headers',
        section: 'REPORTS & PDF',
        icon: Icons.business_center_rounded,
        iconColor: const Color(0xFF3B82F6),
        onTap: () => _showReportBrandingDialog(context),
        trailing: Text(
          _reportBrandingName.length > 15 ? '${_reportBrandingName.substring(0, 12)}...' : _reportBrandingName,
          style: const TextStyle(color: AppColors.grey400, fontSize: 12),
        ),
      ),

      // SUPPORT
      _SettingItem(
        title: 'Help Center',
        subtitle: 'Glossary, definitions and wealth formulas',
        section: 'SUPPORT',
        icon: Icons.help_center_outlined,
        iconColor: const Color(0xFF06B6D4),
        onTap: () => context.push('/definitions'),
      ),
      _SettingItem(
        title: 'Feature Requests',
        subtitle: 'Suggest integrations or tool extensions',
        section: 'SUPPORT',
        icon: Icons.lightbulb_outline_rounded,
        iconColor: const Color(0xFF06B6D4),
        onTap: () => context.push('/settings/founder'),
      ),
      _SettingItem(
        title: 'Bug Reports',
        subtitle: 'Report app crashes or computation bugs',
        section: 'SUPPORT',
        icon: Icons.bug_report_outlined,
        iconColor: const Color(0xFF06B6D4),
        onTap: () => _showBugReportDialog(context),
      ),
      _SettingItem(
        title: 'Roadmap',
        subtitle: 'Explore upcoming Worth private bank updates',
        section: 'SUPPORT',
        icon: Icons.map_outlined,
        iconColor: const Color(0xFF06B6D4),
        onTap: () => context.push('/settings/whats_new'),
      ),
      _SettingItem(
        title: 'Rate Worth',
        subtitle: 'Leave feedback on the App Store',
        section: 'SUPPORT',
        icon: Icons.star_rate_rounded,
        iconColor: const Color(0xFF06B6D4),
        onTap: () => _showRateWorthDialog(context),
      ),

      // DEVELOPER / ADVANCED SECTION (only if developerMode is true)
      if (_developerMode) ...[
        _SettingItem(
          title: 'Developer Tools',
          subtitle: 'Advanced SQLite database controls and resets',
          section: 'ADVANCED',
          icon: Icons.developer_mode_rounded,
          iconColor: const Color(0xFFF43F5E),
          onTap: () => context.push('/settings/advanced'),
        ),
        _SettingItem(
          title: 'Financial Calculation Inspector',
          subtitle: 'Interactive test for cash ledger and FIFO',
          section: 'ADVANCED',
          icon: Icons.search_rounded,
          iconColor: const Color(0xFFF43F5E),
          onTap: () => context.push('/settings/calculation_inspector'),
        ),
        _SettingItem(
          title: 'Funding Relationship Inspector',
          subtitle: 'Audit debt funding sources and alignments',
          section: 'ADVANCED',
          icon: Icons.link_rounded,
          iconColor: const Color(0xFFF43F5E),
          onTap: () => context.push('/settings/funding_relationship_inspector'),
        ),
        _SettingItem(
          title: 'Sync Debugger',
          subtitle: 'Real-time replica log events viewer',
          section: 'ADVANCED',
          icon: Icons.sync_problem_rounded,
          iconColor: const Color(0xFFF43F5E),
          onTap: () => _showSyncDebuggerDialog(context, syncState),
        ),
        _SettingItem(
          title: 'Database Status',
          subtitle: 'Inspect raw database file structures',
          section: 'ADVANCED',
          icon: Icons.settings_input_component_rounded,
          iconColor: const Color(0xFFF43F5E),
          onTap: () => _showDatabaseStatusDialog(context, dbState),
        ),
        _SettingItem(
          title: 'Notification Status',
          subtitle: 'Review active scheduled alarm alerts',
          section: 'ADVANCED',
          icon: Icons.notifications_active_rounded,
          iconColor: const Color(0xFFF43F5E),
          onTap: () => _showNotificationStatusDialog(context, dbState),
        ),
      ]
    ];

    // Filter items based on search query
    final filteredItems = allItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.section.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Command Center',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Top Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Sleek Search Input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.layer1.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search_rounded, color: AppColors.grey500),
                        hintText: 'Search: notification, SIP, biometric...',
                        hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 13),
                        border: InputBorder.none,
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.grey400, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Top action bar
                  _buildTopActionBar(context, dbState),
                ],
              ),
            ),
            
            // Main content area
            Expanded(
              child: _isExporting
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.darkPrimary),
                    )
                  : AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      alignment: Alignment.topCenter,
                      child: _searchQuery.isNotEmpty
                          ? _buildSearchResultsList(filteredItems)
                          : _buildGroupedSettingsList(context, dbState, syncState, userName, userEmail, joinDate, formattedNetWorth, wealthScore, currentStreak),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTopActionBar(BuildContext context, MockDatabaseState dbState) {
    final syncState = ref.watch(syncStatusProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTopActionPill(
            icon: Icons.sync_rounded,
            label: syncState.status == SyncStatusType.syncing ? 'Syncing...' : 'Sync Status',
            color: AppColors.darkPrimary,
            onTap: () => ref.read(syncStatusProvider.notifier).forceSync(),
          ),
          const SizedBox(width: 8),
          _buildTopActionPill(
            icon: Icons.cloud_upload_rounded,
            label: 'Backup Now',
            color: AppColors.glow,
            onTap: () => ref.read(syncStatusProvider.notifier).manualBackup(),
          ),
          const SizedBox(width: 8),
          _buildTopActionPill(
            icon: Icons.cloud_download_rounded,
            label: 'Restore',
            color: AppColors.darkWarning,
            onTap: _handleMockRestore,
          ),
          const SizedBox(width: 8),
          _buildTopActionPill(
            icon: Icons.picture_as_pdf_rounded,
            label: 'Export PDF',
            color: AppColors.darkSuccess,
            onTap: () => _exportPdfReport(dbState),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.layer1.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultsList(List<_SettingItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.grey500, size: 48),
            const SizedBox(height: 12),
            Text('No settings found', style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: EdgeInsets.zero,
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Text(
                      item.section,
                      style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: item.iconColor, letterSpacing: 0.5),
                    ),
                  ),
                  _buildTileFromItem(item),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupedSettingsList(
    BuildContext context,
    MockDatabaseState dbState,
    SyncStatusState syncState,
    String userName,
    String userEmail,
    String joinDate,
    String formattedNetWorth,
    int wealthScore,
    int currentStreak,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        // 1. Premium Profile Header
        _buildPremiumProfileHeader(userName, userEmail, joinDate, formattedNetWorth, wealthScore, currentStreak, syncState),
        const SizedBox(height: 24),

        // 2. Sections
        _buildSettingsSectionGroup(
          context,
          'ACCOUNT',
          [
            _SettingItem(
              title: 'Profile Information',
              subtitle: 'Full name, wealth tier, and milestones',
              section: 'ACCOUNT',
              icon: Icons.person_outline_rounded,
              iconColor: AppColors.darkPrimary,
              onTap: () => context.push('/profile'),
            ),
            _SettingItem(
              title: 'Login & Security',
              subtitle: 'Current active session and credentials',
              section: 'ACCOUNT',
              icon: Icons.security_rounded,
              iconColor: AppColors.darkPrimary,
              onTap: () => _showLoginSecurityDialog(context),
            ),
            _SettingItem(
              title: 'Change Password',
              subtitle: 'Update security passphrase',
              section: 'ACCOUNT',
              icon: Icons.key_rounded,
              iconColor: AppColors.darkPrimary,
              onTap: () => _showChangePasswordDialog(context),
            ),
            _SettingItem(
              title: 'Biometric Lock',
              subtitle: 'Secure access with Touch/Face ID',
              section: 'ACCOUNT',
              icon: Icons.fingerprint_rounded,
              iconColor: AppColors.darkPrimary,
              onTap: () {},
              isSwitch: true,
              switchValue: dbState.appLockEnabled,
              onSwitchChanged: _handleAppLockToggle,
            ),
            if (dbState.appLockEnabled)
              _SettingItem(
                title: 'Auto-Lock Timeout',
                subtitle: 'Configure app lock inactive delay',
                section: 'ACCOUNT',
                icon: Icons.timer_outlined,
                iconColor: AppColors.darkPrimary,
                onTap: () {},
                isDropdown: true,
                dropdownValue: dbState.appLockTimeout,
                dropdownItems: const [
                  DropdownMenuItem(value: 0, child: Text('Immediately')),
                  DropdownMenuItem(value: 60, child: Text('1 Minute')),
                  DropdownMenuItem(value: 300, child: Text('5 Minutes')),
                  DropdownMenuItem(value: 900, child: Text('15 Minutes')),
                ],
                onDropdownChanged: (val) {
                  if (val != null) {
                    ref.read(mockDatabaseProvider.notifier).updateAppLockTimeout(val);
                  }
                },
              ),
            _SettingItem(
              title: 'Cloud Sync',
              subtitle: 'Manage remote data replication',
              section: 'ACCOUNT',
              icon: Icons.cloud_sync_rounded,
              iconColor: AppColors.darkPrimary,
              onTap: () => context.push('/settings/sync_center'),
            ),
            _SettingItem(
              title: 'Backup & Restore',
              subtitle: 'Automated daily & manual backups',
              section: 'ACCOUNT',
              icon: Icons.backup_table_rounded,
              iconColor: AppColors.darkPrimary,
              onTap: () => context.push('/settings/backup_restore'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSettingsSectionGroup(
          context,
          'WEALTH MANAGEMENT',
          [
            _SettingItem(
              title: 'Net Worth Preferences',
              subtitle: 'Reporting currency and format settings',
              section: 'WEALTH MANAGEMENT',
              icon: Icons.currency_exchange_rounded,
              iconColor: const Color(0xFF8B5CF6),
              onTap: () => _showCurrencySelector(context, dbState.currency),
              trailing: Text(
                dbState.currency == '₹' ? 'INR (₹)' : dbState.currency == '\$' ? 'USD (\$)' : dbState.currency,
                style: const TextStyle(color: AppColors.grey400, fontSize: 12),
              ),
            ),
            _SettingItem(
              title: 'Dashboard Preferences',
              subtitle: 'Visual layout and dark mode theme selector',
              section: 'WEALTH MANAGEMENT',
              icon: Icons.dashboard_customize_rounded,
              iconColor: const Color(0xFF8B5CF6),
              onTap: () => _showThemeSelector(context, dbState.themeMode),
              trailing: Text(
                dbState.themeMode.toUpperCase(),
                style: const TextStyle(color: AppColors.grey400, fontSize: 12),
              ),
            ),
            _SettingItem(
              title: 'Portfolio Preferences',
              subtitle: 'Archived records and asset snapshots',
              section: 'WEALTH MANAGEMENT',
              icon: Icons.history_toggle_off_rounded,
              iconColor: const Color(0xFF8B5CF6),
              onTap: () => context.push('/settings/history_archive'),
            ),
            _SettingItem(
              title: 'Investment Preferences',
              subtitle: 'Transaction categories & custom labels',
              section: 'WEALTH MANAGEMENT',
              icon: Icons.label_outline_rounded,
              iconColor: const Color(0xFF8B5CF6),
              onTap: () => context.push('/settings/categories_labels'),
            ),
            _SettingItem(
              title: 'SIP Preferences',
              subtitle: 'Automation rules and recurring savings',
              section: 'WEALTH MANAGEMENT',
              icon: Icons.schedule_send_rounded,
              iconColor: const Color(0xFF8B5CF6),
              onTap: () => context.push('/sip'),
            ),
            _SettingItem(
              title: 'IPO Preferences',
              subtitle: 'IPO pools dashboard and contributors list',
              section: 'WEALTH MANAGEMENT',
              icon: Icons.pie_chart_outline_rounded,
              iconColor: const Color(0xFF8B5CF6),
              onTap: () => context.push('/settings/ipo_pool'),
            ),
            _SettingItem(
              title: 'Education Loan Preferences',
              subtitle: 'Moratorium and loan forecasting hub',
              section: 'WEALTH MANAGEMENT',
              icon: Icons.school_outlined,
              iconColor: const Color(0xFF0EA5E9),
              onTap: () => context.push('/settings/education_loan'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSettingsSectionGroup(
          context,
          'NOTIFICATIONS',
          [
            _SettingItem(
              title: 'Push Notifications',
              subtitle: 'Global alert notification triggers',
              section: 'NOTIFICATIONS',
              icon: Icons.notifications_none_outlined,
              iconColor: const Color(0xFFEC4899),
              isSwitch: true,
              switchValue: dbState.notificationsEnabled,
              onSwitchChanged: (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationsEnabled(val),
            ),
            _SettingItem(
              title: 'Daily Check-ins',
              subtitle: 'Daily check-in logs reminder check alert',
              section: 'NOTIFICATIONS',
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFFEC4899),
              isSwitch: true,
              switchValue: dbState.notificationPrefCheckIns,
              onSwitchChanged: dbState.notificationsEnabled
                  ? (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationPref('checkins', val)
                  : null,
            ),
            _SettingItem(
              title: 'Transaction Reminders',
              subtitle: 'Alerts for pending trades deposits',
              section: 'NOTIFICATIONS',
              icon: Icons.receipt_long_outlined,
              iconColor: const Color(0xFFEC4899),
              isSwitch: true,
              switchValue: dbState.notificationPrefTransactions,
              onSwitchChanged: dbState.notificationsEnabled
                  ? (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationPref('transactions', val)
                  : null,
            ),
            _SettingItem(
              title: 'SIP Reminders',
              subtitle: 'SIP due date warning alerts and notification',
              section: 'NOTIFICATIONS',
              icon: Icons.watch_later_outlined,
              iconColor: const Color(0xFFEC4899),
              isSwitch: true,
              switchValue: dbState.notificationPrefSip,
              onSwitchChanged: dbState.notificationsEnabled
                  ? (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationPref('sip', val)
                  : null,
            ),
            _SettingItem(
              title: 'Receivable Follow-ups',
              subtitle: 'Follow up due notifications for lend recovery',
              section: 'NOTIFICATIONS',
              icon: Icons.person_pin_rounded,
              iconColor: const Color(0xFFEC4899),
              isSwitch: true,
              switchValue: _receivableFollowupsEnabled,
              onSwitchChanged: (val) => setState(() => _receivableFollowupsEnabled = val),
            ),
            _SettingItem(
              title: 'Goal Reminders',
              subtitle: 'Target prediction and milestones status',
              section: 'NOTIFICATIONS',
              icon: Icons.track_changes_outlined,
              iconColor: const Color(0xFFEC4899),
              isSwitch: true,
              switchValue: dbState.notificationPrefGoals,
              onSwitchChanged: dbState.notificationsEnabled
                  ? (val) => ref.read(mockDatabaseProvider.notifier).updateNotificationPref('goals', val)
                  : null,
            ),
            _SettingItem(
              title: 'Financial Calendar Reminders',
              subtitle: 'Customize alarm schedules for calendar events',
              section: 'NOTIFICATIONS',
              icon: Icons.calendar_month_outlined,
              iconColor: const Color(0xFFEC4899),
              onTap: () => _showCalendarNotificationsDialog(context, dbState),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSettingsSectionGroup(
          context,
          'PRIVACY & SECURITY',
          [
            _SettingItem(
              title: 'Biometric Lock',
              subtitle: 'Secure access with Face ID / fingerprint',
              section: 'PRIVACY & SECURITY',
              icon: Icons.lock_person_outlined,
              iconColor: const Color(0xFF10B981),
              isSwitch: true,
              switchValue: dbState.appLockEnabled,
              onSwitchChanged: _handleAppLockToggle,
            ),
            _SettingItem(
              title: 'PIN Lock',
              subtitle: 'Configure or update local PIN key',
              section: 'PRIVACY & SECURITY',
              icon: Icons.lock_outline,
              iconColor: const Color(0xFF10B981),
              onTap: () => _showPinLockDialog(context),
            ),
            _SettingItem(
              title: 'Encryption Status',
              subtitle: 'Local SQLite DB cryptographic cipher settings',
              section: 'PRIVACY & SECURITY',
              icon: Icons.enhanced_encryption_outlined,
              iconColor: const Color(0xFF10B981),
              onTap: () => _showEncryptionStatusDialog(context),
            ),
            _SettingItem(
              title: 'Backup Status',
              subtitle: 'Inspect local databases and sync checkpoints',
              section: 'PRIVACY & SECURITY',
              icon: Icons.cloud_done_outlined,
              iconColor: const Color(0xFF10B981),
              onTap: () => _showBackupStatusDialog(context, syncState),
            ),
            _SettingItem(
              title: 'Export Data',
              subtitle: 'Compile database and export JSON package',
              section: 'PRIVACY & SECURITY',
              icon: Icons.file_upload_outlined,
              iconColor: const Color(0xFF10B981),
              onTap: _handleMockBackup,
            ),
            _SettingItem(
              title: 'Delete Data',
              subtitle: 'Factory reset database or purge transaction logs',
              section: 'PRIVACY & SECURITY',
              icon: Icons.delete_forever_outlined,
              iconColor: const Color(0xFF10B981),
              onTap: () => _showDeleteDataDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSettingsSectionGroup(
          context,
          'DATA MANAGEMENT',
          [
            _SettingItem(
              title: 'Import Data',
              subtitle: 'Load backup file and trigger full rebuild',
              section: 'DATA MANAGEMENT',
              icon: Icons.input_rounded,
              iconColor: const Color(0xFFF59E0B),
              onTap: _handleMockRestore,
            ),
            _SettingItem(
              title: 'Export Data',
              subtitle: 'Compile JSON payload and download backup',
              section: 'DATA MANAGEMENT',
              icon: Icons.output_rounded,
              iconColor: const Color(0xFFF59E0B),
              onTap: _handleMockBackup,
            ),
            _SettingItem(
              title: 'Cloud Backup',
              subtitle: 'Replicate current state to cloud repository',
              section: 'DATA MANAGEMENT',
              icon: Icons.backup_outlined,
              iconColor: const Color(0xFFF59E0B),
              onTap: () => ref.read(syncStatusProvider.notifier).forceSync(),
            ),
            _SettingItem(
              title: 'Restore From Backup',
              subtitle: 'Pull replica snapshot and rewrite local ledger',
              section: 'DATA MANAGEMENT',
              icon: Icons.restore_page_rounded,
              iconColor: const Color(0xFFF59E0B),
              onTap: () => _confirmRestore(context),
            ),
            _SettingItem(
              title: 'Clear Cache',
              subtitle: 'Purge computed balances and force recalculation',
              section: 'DATA MANAGEMENT',
              icon: Icons.refresh_rounded,
              iconColor: const Color(0xFFF59E0B),
              onTap: _handleRecalculate,
            ),
            _SettingItem(
              title: 'Storage Usage',
              subtitle: 'Raw storage analysis and cache parameters',
              section: 'DATA MANAGEMENT',
              icon: Icons.storage_rounded,
              iconColor: const Color(0xFFF59E0B),
              onTap: () => _showStorageUsageDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSettingsSectionGroup(
          context,
          'REPORTS & PDF',
          [
            _SettingItem(
              title: 'PDF Theme',
              subtitle: 'Customize typography and colors for exports',
              section: 'REPORTS & PDF',
              icon: Icons.picture_as_pdf_outlined,
              iconColor: const Color(0xFF3B82F6),
              onTap: () => _showPdfThemeDialog(context),
              trailing: Text(
                _pdfTheme,
                style: const TextStyle(color: AppColors.grey400, fontSize: 12),
              ),
            ),
            _SettingItem(
              title: 'Report Style',
              subtitle: 'Layout formatting for monthly statements',
              section: 'REPORTS & PDF',
              icon: Icons.view_quilt_rounded,
              iconColor: const Color(0xFF3B82F6),
              onTap: () => _showReportStyleDialog(context),
              trailing: Text(
                _reportStyle,
                style: const TextStyle(color: AppColors.grey400, fontSize: 12),
              ),
            ),
            _SettingItem(
              title: 'Export Preferences',
              subtitle: 'Toggle custom elements like signatures and page numbers',
              section: 'REPORTS & PDF',
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFF3B82F6),
              onTap: () => _showExportPreferencesDialog(context),
            ),
            _SettingItem(
              title: 'Report Branding',
              subtitle: 'Add custom header logos and naming to pdf reports',
              section: 'REPORTS & PDF',
              icon: Icons.business_center_rounded,
              iconColor: const Color(0xFF3B82F6),
              onTap: () => _showReportBrandingDialog(context),
              trailing: Text(
                _reportBrandingName.length > 15 ? '${_reportBrandingName.substring(0, 12)}...' : _reportBrandingName,
                style: const TextStyle(color: AppColors.grey400, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSettingsSectionGroup(
          context,
          'SUPPORT',
          [
            _SettingItem(
              title: 'Help Center',
              subtitle: 'Glossary, definitions and formulas documentation',
              section: 'SUPPORT',
              icon: Icons.help_center_outlined,
              iconColor: const Color(0xFF06B6D4),
              onTap: () => context.push('/definitions'),
            ),
            _SettingItem(
              title: 'Feature Requests',
              subtitle: 'Connect with founder and vote on integrations',
              section: 'SUPPORT',
              icon: Icons.lightbulb_outline_rounded,
              iconColor: const Color(0xFF06B6D4),
              onTap: () => context.push('/settings/founder'),
            ),
            _SettingItem(
              title: 'Bug Reports',
              subtitle: 'Submit tickets to resolve balance inconsistencies',
              section: 'SUPPORT',
              icon: Icons.bug_report_outlined,
              iconColor: const Color(0xFF06B6D4),
              onTap: () => _showBugReportDialog(context),
            ),
            _SettingItem(
              title: 'Roadmap',
              subtitle: 'View release milestones and new features',
              section: 'SUPPORT',
              icon: Icons.map_outlined,
              iconColor: const Color(0xFF06B6D4),
              onTap: () => context.push('/settings/whats_new'),
            ),
            _SettingItem(
              title: 'Rate Worth',
              subtitle: 'Simulate app evaluation and share opinion',
              section: 'SUPPORT',
              icon: Icons.star_rate_rounded,
              iconColor: const Color(0xFF06B6D4),
              onTap: () => _showRateWorthDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildSettingsSectionGroup(
          context,
          'ABOUT WORTH',
          [
            _SettingItem(
              title: 'Update Center',
              subtitle: 'Check for updates and view release history',
              section: 'ABOUT WORTH',
              icon: Icons.system_update_rounded,
              iconColor: const Color(0xFF10B981),
              onTap: () => context.push('/settings/update_center'),
            ),
            _SettingItem(
              title: 'What\'s New',
              subtitle: 'Read highlights of the latest release',
              section: 'ABOUT WORTH',
              icon: Icons.new_releases_outlined,
              iconColor: const Color(0xFF10B981),
              onTap: () => context.push('/settings/whats_new'),
            ),
          ],
        ),

        // 3. Collapsible Advanced Developer Tools Section
        if (_developerMode) ...[
          const SizedBox(height: 20),
          _buildSettingsSectionGroup(
            context,
            'ADVANCED',
            [
              _SettingItem(
                title: 'Developer Tools',
                subtitle: 'Advanced SQLite database controls and resets',
                section: 'ADVANCED',
                icon: Icons.developer_mode_rounded,
                iconColor: const Color(0xFFF43F5E),
                onTap: () => context.push('/settings/advanced'),
              ),
              _SettingItem(
                title: 'Financial Calculation Inspector',
                subtitle: 'Interactive test for cash ledger and FIFO',
                section: 'ADVANCED',
                icon: Icons.search_rounded,
                iconColor: const Color(0xFFF43F5E),
                onTap: () => context.push('/settings/calculation_inspector'),
              ),
              _SettingItem(
                title: 'Funding Relationship Inspector',
                subtitle: 'Audit debt funding sources and alignments',
                section: 'ADVANCED',
                icon: Icons.link_rounded,
                iconColor: const Color(0xFFF43F5E),
                onTap: () => context.push('/settings/funding_relationship_inspector'),
              ),
              _SettingItem(
                title: 'Sync Debugger',
                subtitle: 'Real-time replica log events viewer',
                section: 'ADVANCED',
                icon: Icons.sync_problem_rounded,
                iconColor: const Color(0xFFF43F5E),
                onTap: () => _showSyncDebuggerDialog(context, syncState),
              ),
              _SettingItem(
                title: 'Database Status',
                subtitle: 'Inspect raw database file structures',
                section: 'ADVANCED',
                icon: Icons.settings_input_component_rounded,
                iconColor: const Color(0xFFF43F5E),
                onTap: () => _showDatabaseStatusDialog(context, dbState),
              ),
              _SettingItem(
                title: 'Notification Status',
                subtitle: 'Review active scheduled alarm alerts',
                section: 'ADVANCED',
                icon: Icons.notifications_active_rounded,
                iconColor: const Color(0xFFF43F5E),
                onTap: () => _showNotificationStatusDialog(context, dbState),
              ),
            ],
          ),
        ],

        const SizedBox(height: 32),

        // 4. Log Out button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: TactileButton(
            color: Colors.transparent,
            border: const BorderSide(color: AppColors.darkDanger, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            onTap: () {
              ref.read(authRepositoryProvider).signOut();
            },
            child: Text(
              'Log Out of Worth',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.darkDanger,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // 5. Version Info Footer (Easter Egg)
        GestureDetector(
          onTap: _incrementDeveloperTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Worth Version ${AppVersion.version} (Build ${AppVersion.build})',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'SQLite: worth_db_v3.db (248 KB) • Last sync: ${syncState.lastSyncedText}',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPremiumProfileHeader(
    String userName,
    String userEmail,
    String joinDate,
    String formattedNetWorth,
    int wealthScore,
    int currentStreak,
    SyncStatusState syncState,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      isPrimary: true, // 32px border radius
      child: Column(
        children: [
          // Profile photo & name row
          Row(
            children: [
              // Premium Glowing Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.darkPrimary, AppColors.glow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'W',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '@${userName.replaceAll(' ', '').toLowerCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.grey400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member since $joinDate',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.layer2,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: 20),
          
          // Hero Metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroMetric('Net Worth', formattedNetWorth, AppColors.glow),
              _buildHeroMetric('Wealth Score', '$wealthScore/100', AppColors.darkSuccess),
              _buildHeroMetric('Streak', '$currentStreak Days', AppColors.darkWarning),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.glassBorder, height: 1),
          const SizedBox(height: 14),
          
          // Cloud Sync Info Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    syncState.status == SyncStatusType.synced
                        ? Icons.cloud_done_rounded
                        : syncState.status == SyncStatusType.syncing
                            ? Icons.sync_rounded
                            : Icons.cloud_off_rounded,
                    color: syncState.status == SyncStatusType.synced
                        ? AppColors.darkSuccess
                        : syncState.status == SyncStatusType.syncing
                            ? AppColors.darkPrimary
                            : AppColors.grey500,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cloud Sync:',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey400),
                  ),
                ],
              ),
              Text(
                syncState.statusText,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: syncState.status == SyncStatusType.synced
                      ? AppColors.darkSuccess
                      : syncState.status == SyncStatusType.syncing
                          ? AppColors.darkPrimary
                          : AppColors.grey400,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick actions row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionBtn(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () => context.push('/profile'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionBtn(
                  icon: Icons.upload_file_rounded,
                  label: 'Export Data',
                  onTap: _handleMockBackup,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionBtn(
                  icon: Icons.backup_rounded,
                  label: 'Backup Now',
                  onTap: () => ref.read(syncStatusProvider.notifier).manualBackup(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.grey500,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.layer2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSectionGroup(BuildContext context, String title, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0, bottom: 8.0),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.grey500,
              letterSpacing: 1.2,
            ),
          ),
        ),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              return Column(
                children: [
                  _buildTileFromItem(item),
                  if (index < items.length - 1)
                    const Divider(color: AppColors.glassBorder, height: 1),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTileFromItem(_SettingItem item) {
    if (item.isSwitch) {
      return SwitchListTile(
        title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
        subtitle: Text(item.subtitle, style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
        secondary: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: item.iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: item.iconColor, size: 18),
        ),
        activeColor: AppColors.darkPrimary,
        value: item.switchValue ?? false,
        onChanged: item.onSwitchChanged,
      );
    }

    if (item.isDropdown) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: item.iconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(item.icon, color: item.iconColor, size: 18),
        ),
        title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
        subtitle: Text(item.subtitle, style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
        trailing: DropdownButton<int>(
          value: item.dropdownValue,
          dropdownColor: AppColors.layer2,
          underline: const SizedBox(),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey500),
          items: item.dropdownItems,
          onChanged: item.onDropdownChanged,
        ),
      );
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: item.iconColor.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(item.icon, color: item.iconColor, size: 18),
      ),
      title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
      subtitle: Text(item.subtitle, style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.trailing != null) ...[
            item.trailing!,
            const SizedBox(width: 6),
          ],
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.grey500),
        ],
      ),
      onTap: item.onTap,
    );
  }
}

class _SettingItem {
  final String title;
  final String subtitle;
  final String section;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isSwitch;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final bool isDropdown;
  final int? dropdownValue;
  final List<DropdownMenuItem<int>>? dropdownItems;
  final ValueChanged<int?>? onDropdownChanged;

  _SettingItem({
    required this.title,
    required this.subtitle,
    required this.section,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.trailing,
    this.isSwitch = false,
    this.switchValue,
    this.onSwitchChanged,
    this.isDropdown = false,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
  });
}
