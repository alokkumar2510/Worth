import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/widgets/calculation_audit_panel.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart';
import '../widgets/adjustment_widgets.dart';
import '../../../../features/recovery/presentation/widgets/recovery_allocation_dialog.dart';
import '../../../../features/recovery/presentation/widgets/recovery_flow_report_widget.dart';
import '../../../../features/recovery/domain/utils/recovery_calculator.dart';
import '../../../../features/recovery/presentation/widgets/payment_reminder_image_generator.dart';

class ReceivableDetailScreen extends ConsumerStatefulWidget {
  final String personId;

  const ReceivableDetailScreen({required this.personId, super.key});

  @override
  ConsumerState<ReceivableDetailScreen> createState() => _ReceivableDetailScreenState();
}

class _ReceivableDetailScreenState extends ConsumerState<ReceivableDetailScreen> with SingleTickerProviderStateMixin {
  final _recoverController = TextEditingController();
  final _activityNotesController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _recoverController.dispose();
    _activityNotesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // --- Collection History log activity helper ---
  Future<void> _logActivity(String type, {String? channel, String? notes, double? amount}) async {
    await ref.read(mockDatabaseProvider.notifier).addReceivableActivity(
          personId: widget.personId,
          activityType: type,
          amount: amount,
          channel: channel,
          notes: notes,
        );
  }

  // --- Copy Reminder Action ---
  void _copyToClipboard(String message, String stageLabel) {
    Clipboard.setData(ClipboardData(text: message));
    _logActivity('reminder_sent', channel: 'copy', notes: '$stageLabel copied to clipboard');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$stageLabel copied to clipboard.')),
    );
  }

  // --- Share reminders helper ---
  Future<void> _shareReminder(String message, String channel, Person person, String stageLabel) async {
    Uri url;
    if (channel == 'whatsapp') {
      final rawPhone = person.whatsApp ?? person.phone ?? '';
      final cleanPhone = _cleanPhoneNumber(rawPhone);

      // Print debug log
      print('Selected Contact:');
      print(person.name);
      print('');
      print('WhatsApp Number:');
      print(cleanPhone);

      if (cleanPhone.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No phone number or WhatsApp number found for this contact.')),
          );
        }
        return;
      }

      url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    } else if (channel == 'telegram') {
      url = Uri.parse('https://t.me/share/url?url=&text=${Uri.encodeComponent(message)}');
    } else {
      // SMS
      url = Uri.parse('sms:?body=${Uri.encodeComponent(message)}');
    }

    try {
      if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await _logActivity('reminder_sent', channel: channel, notes: '$stageLabel shared');
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share via $channel: $e')),
        );
      }
    }
  }

  // --- UPI link generator & share ---
  Future<void> _requestUpiPayment(Person person, double outstanding, String upiId, String userName) async {
    final upiLink = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(userName)}&am=$outstanding';
    final shareMsg = 'Hi ${person.name},\n\nOutstanding Amount:\n₹${NumberFormat.decimalPattern().format(outstanding)}\n\nPlease make payment using the link below.\n\n$upiLink\n\nGenerated using Worth.';
    
    final rawPhone = person.whatsApp ?? person.phone ?? '';
    final cleanPhone = _cleanPhoneNumber(rawPhone);

    // Print debug log
    print('Selected Contact:');
    print(person.name);
    print('');
    print('WhatsApp Number:');
    print(cleanPhone);

    if (cleanPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number or WhatsApp number found for this contact.')),
        );
      }
      return;
    }

    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(shareMsg)}');

    try {
      if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await _logActivity('payment_requested', channel: 'upi', notes: 'Payment link requested and shared');
      } else {
        throw 'Could not launch app';
      }
    } catch (e) {
      if (mounted) {
        // Fallback: Copy to clipboard
        Clipboard.setData(ClipboardData(text: shareMsg));
        await _logActivity('payment_requested', channel: 'copy', notes: 'Payment requested (copied to clipboard)');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp. Payment message copied to clipboard instead.')),
        );
      }
    }
  }

  String _cleanPhoneNumber(String phone) {
    // 1. Remove spaces and special characters
    String digits = phone.replaceAll(RegExp(r'\D'), '');
    
    // 2. Remove duplicate country code (starts with 9191 and length is 14)
    if (digits.startsWith('9191') && digits.length == 14) {
      digits = digits.substring(2);
    }
    
    // 3. Prepend 91 if it's exactly 10 digits
    if (digits.length == 10) {
      digits = '91$digits';
    }
    
    return digits;
  }

  Future<void> _shareQrCode(String upiLink) async {
    try {
      final qrValidationResult = QrValidator.validate(
        data: upiLink,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );
        
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/worth_payment_qr.png');
        
        final picData = await painter.toImageData(300);
        if (picData != null) {
          await file.writeAsBytes(picData.buffer.asUint8List());
          await Share.shareXFiles([XFile(file.path)], text: 'Scan this QR code to pay.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share QR: $e')));
      }
    }
  }

  Future<void> _launchUpiApp(String appName, String upiId, String userName, double amount) async {
    final encodedName = Uri.encodeComponent(userName);
    String scheme;
    switch (appName.toLowerCase()) {
      case 'google pay':
        scheme = 'tez://pay?pa=$upiId&pn=$encodedName&am=$amount';
        break;
      case 'phonepe':
        scheme = 'phonepe://pay?pa=$upiId&pn=$encodedName&am=$amount';
        break;
      case 'paytm':
        scheme = 'paytmmp://pay?pa=$upiId&pn=$encodedName&am=$amount';
        break;
      case 'bhim':
      default:
        scheme = 'upi://pay?pa=$upiId&pn=$encodedName&am=$amount';
        break;
    }
    
    final uri = Uri.parse(scheme);
    try {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (success) {
        await _logActivity('payment_requested', channel: appName.toLowerCase(), notes: 'Opened UPI app: $appName');
      } else {
        if (appName.toLowerCase() != 'bhim' && appName.toLowerCase() != 'upi') {
          final fallbackUri = Uri.parse('upi://pay?pa=$upiId&pn=$encodedName&am=$amount');
          final fallbackSuccess = await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          if (fallbackSuccess) {
            await _logActivity('payment_requested', channel: 'upi_fallback', notes: 'Opened generic UPI chooser as fallback for $appName');
            return;
          }
        }
        throw 'Could not launch UPI app';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $appName: $e. Try copying the UPI ID instead.')),
        );
      }
    }
  }

  void _showUpiAppChooser(BuildContext context, Person person, double outstanding, String userUpiName) {
    final upiId = person.upiId!;
    final accountName = person.accountHolderName ?? userUpiName;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.layer1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select UPI App to Pay',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.apps_rounded, color: AppColors.darkPrimary),
              title: const Text('Any UPI App (System Chooser)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                _launchUpiApp('bhim', upiId, accountName, outstanding);
              },
            ),
            const Divider(color: AppColors.glassBorder),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.blue),
              title: const Text('Google Pay', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _launchUpiApp('google pay', upiId, accountName, outstanding);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.purple),
              title: const Text('PhonePe', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _launchUpiApp('phonepe', upiId, accountName, outstanding);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.lightBlue),
              title: const Text('Paytm', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _launchUpiApp('paytm', upiId, accountName, outstanding);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.orange),
              title: const Text('BHIM', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _launchUpiApp('bhim', upiId, accountName, outstanding);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.glassSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.darkPrimary, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRecoverDialog(BuildContext context, String currency, String name, double outstanding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recover from $name', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Outstanding: $currency${NumberFormat.decimalPattern().format(outstanding)}',
              style: const TextStyle(color: AppColors.grey500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _recoverController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Recovery Amount',
                labelStyle: const TextStyle(color: AppColors.grey500),
                prefixText: '$currency ',
                prefixStyle: const TextStyle(color: Colors.white),
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
            onPressed: () async {
              final amount = double.tryParse(_recoverController.text.trim()) ?? 0.0;
              if (amount > 0) {
                Navigator.pop(context);
                final txId = await ref.read(mockDatabaseProvider.notifier).addRecoverTransaction(
                  widget.personId,
                  'acc_primary_bank_uuid',
                  amount,
                  'Recovered debt amount',
                  DateTime.now().toUtc(),
                );
                _recoverController.clear();
                if (context.mounted) {
                  await _showAllocationDialog(context, currency, name, amount, txId);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAllocationDialog(
    BuildContext context,
    String currency,
    String personName,
    double amount,
    String txId,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RecoveryAllocationDialog(
        personId: widget.personId,
        personName: personName,
        totalAmount: amount,
        sourceTransactionId: txId,
        currency: currency,
      ),
    );
  }

  Future<void> _handleSettle(BuildContext context, String currency, String name, double outstanding) async {
    if (outstanding > 0) {
      final txId = await ref.read(mockDatabaseProvider.notifier).addRecoverTransaction(
        widget.personId,
        'acc_primary_bank_uuid',
        outstanding,
        'Full debt settlement',
        DateTime.now().toUtc(),
      );
      if (context.mounted) {
        await _showAllocationDialog(context, currency, name, outstanding, txId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receivable fully settled.')),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, Person person) {
    final nameController = TextEditingController(text: person.name);
    final phoneController = TextEditingController(text: person.phone ?? '');
    final whatsAppController = TextEditingController(text: person.whatsApp ?? '');
    final notesController = TextEditingController(text: person.notes ?? '');
    final upiIdController = TextEditingController(text: person.upiId ?? '');
    final bankNameController = TextEditingController(text: person.bankName ?? '');
    final accountHolderNameController = TextEditingController(text: person.accountHolderName ?? '');
    
    DateTime? selectedBorrowDate = person.borrowDate;
    DateTime? selectedDueDate = person.dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Edit Receivable Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: whatsAppController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'WhatsApp Number', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: upiIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'UPI ID', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Bank Name', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountHolderNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Account Holder Name', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 16),
                
                // Borrow Date Pick
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedBorrowDate == null
                          ? 'Set Borrow Date'
                          : 'Borrowed: ${DateFormat('dd MMM yyyy').format(selectedBorrowDate!)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: AppColors.darkPrimary),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedBorrowDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setStateDialog(() {
                            selectedBorrowDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
                // Due Date Pick
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDueDate == null
                          ? 'Set Due Date'
                          : 'Due Date: ${DateFormat('dd MMM yyyy').format(selectedDueDate!)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    IconButton(
                      icon: const Icon(Icons.event_available, color: AppColors.darkPrimary),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (date != null) {
                          setStateDialog(() {
                            selectedDueDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final whatsApp = whatsAppController.text.trim();
                final upi = upiIdController.text.trim();
                final bank = bankNameController.text.trim();
                final holder = accountHolderNameController.text.trim();
                final notes = notesController.text.trim();

                if (name.isNotEmpty) {
                  ref.read(mockDatabaseProvider.notifier).updatePerson(
                        person.id,
                        name,
                        phone.isNotEmpty ? phone : null,
                        notes.isNotEmpty ? notes : null,
                        whatsApp: whatsApp.isNotEmpty ? whatsApp : null,
                        borrowDate: selectedBorrowDate,
                        dueDate: selectedDueDate,
                        upiId: upi.isNotEmpty ? upi : null,
                        bankName: bank.isNotEmpty ? bank : null,
                        accountHolderName: holder.isNotEmpty ? holder : null,
                      );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receivable details updated.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteReceivable(BuildContext context, Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Receivable?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this receivable? This will hide it from all views and calculations. You can undo this action immediately.',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final notifier = ref.read(mockDatabaseProvider.notifier);
              await notifier.deletePersonSoft(person.id);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Receivable "${person.name}" deleted.'),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: AppColors.darkPrimary,
                    onPressed: () {
                      notifier.restorePerson(person);
                    },
                  ),
                  duration: const Duration(seconds: 5),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Interaction Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _activityNotesController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Interaction Details (e.g. Rahul promised to pay next week)',
            labelStyle: TextStyle(color: AppColors.grey500),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.darkPrimary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              final note = _activityNotesController.text.trim();
              if (note.isNotEmpty) {
                await _logActivity('notes_added', notes: note);
                _activityNotesController.clear();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note added to timeline.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save Note', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final currency = dbState.currency;

    final person = dbState.people.firstWhereOrNull((p) => p.id == widget.personId);

    if (person == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Receivable person not found.', style: TextStyle(color: Colors.white))),
      );
    }

    final outstanding = dbState.getPersonReceivableBalance(person.id);
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    final txs = dbState.transactions
        .where((t) => t.personId == person.id && t.voidedTransactionId == null && (t.type == 'lend_money' || t.type == 'recover_money'))
        .toList();
    final createdStr = DateFormat('dd MMM yyyy').format(person.createdAt.toLocal());

    // Activities list
    final activities = dbState.receivableActivities.where((ReceivableActivity a) => a.personId == person.id).toList();

    // Smart Recovery calculations
    final borrowDate = person.borrowDate ?? person.createdAt;
    final daysPending = RecoveryCalculator.calculateDaysPending(borrowDate);
    final stage = RecoveryCalculator.calculateFollowUpStage(daysPending);
    final stageLabel = RecoveryCalculator.getStageLabel(stage);
    final stageColor = RecoveryCalculator.getStageColor(stage);
    final risk = RecoveryCalculator.calculateRiskLevel(daysPending);
    final prob = RecoveryCalculator.calculateRecoveryProbability(daysPending);

    // Dynamic messages
    final gentleMsg = "Hi ${person.name}, just a friendly reminder regarding the ₹${outstanding.toStringAsFixed(0)} you borrowed. Please settle it whenever convenient.";
    final urgentMsg = "Hi ${person.name}, the outstanding amount of ₹${outstanding.toStringAsFixed(0)} has been pending for $daysPending days. Kindly process the payment.";
    final escalatedMsg = "Hi ${person.name}, the payment of ₹${outstanding.toStringAsFixed(0)} has been pending for $daysPending days. Please prioritize settlement.";
    
    String currentMsg = gentleMsg;
    if (stage == FollowUpStage.urgentReminder) {
      currentMsg = urgentMsg;
    } else if (stage == FollowUpStage.highPriority || stage == FollowUpStage.escalated) {
      currentMsg = escalatedMsg;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.darkSuccess.withOpacity(0.12),
              backgroundImage: person.photoPath != null && File(person.photoPath!).existsSync()
                  ? FileImage(File(person.photoPath!))
                  : null,
              child: person.photoPath == null || !File(person.photoPath!).existsSync()
                  ? const Icon(Icons.person, color: AppColors.darkSuccess, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                person.name,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer1,
            onSelected: (value) async {
              if (value == 'edit') {
                _showEditDialog(context, person);
              } else if (value == 'adjust_amount') {
                _showAdjustAmountDialog(context, ref, person, outstanding);
              } else if (value == 'view_history') {
                showAdjustmentHistorySheet(context, person.id, 'person_receivable', person.name);
              } else if (value == 'delete') {
                _confirmDeleteReceivable(context, person);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Details', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'adjust_amount',
                child: Text('Adjust Amount', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'view_history',
                child: Text('View History', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.darkDanger)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Outstanding amount header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: GlassCard(
                borderColor: AppColors.darkSuccess.withOpacity(0.2),
                child: Column(
                  children: [
                    Text(
                      'OUTSTANDING AMOUNT OWED TO YOU',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      format.format(outstanding),
                      style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.darkSuccess),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildProfileMiniCol('Risk Profile', RecoveryCalculator.getRiskLabel(risk), RecoveryCalculator.getRiskColor(risk)),
                        _buildProfileMiniCol('Probability', RecoveryCalculator.getProbabilityLabel(prob), RecoveryCalculator.getProbabilityColor(prob)),
                        _buildProfileMiniCol('Collection Stage', stageLabel, stageColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Tab bar switcher
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.darkPrimary,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.grey500,
              tabs: const [
                Tab(text: 'Collect'),
                Tab(text: 'Timeline'),
                Tab(text: 'Ledger'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // --- COLLECT TAB ---
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Quick settlements buttons
                        if (outstanding > 0) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showRecoverDialog(context, currency, person.name, outstanding),
                                  icon: const Icon(Icons.keyboard_double_arrow_left, color: Colors.white),
                                  label: const Text('Recover Partial', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleSettle(context, currency, person.name, outstanding),
                                  icon: const Icon(Icons.check, color: AppColors.darkSuccess),
                                  label: const Text('Mark Settled', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    side: const BorderSide(color: AppColors.glassBorder),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Request Payment link section
                        if (person.upiId != null && person.upiId!.isNotEmpty) ...[
                          Text(
                            'UPI PAYMENT COLLECTION',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 12),
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.account_balance_wallet_outlined, color: AppColors.darkPrimary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(person.accountHolderName ?? person.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                          Text('UPI: ${person.upiId} (${person.bankName ?? 'No Bank Specified'})', style: const TextStyle(color: AppColors.grey500, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _requestUpiPayment(
                                    person,
                                    outstanding,
                                    person.upiId!,
                                    person.accountHolderName ?? dbState.userUpiName,
                                  ),
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  label: const Text('Request UPI Payment (WhatsApp)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    _buildUpiActionButton(
                                      icon: Icons.copy_rounded,
                                      label: 'Copy UPI',
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(text: person.upiId!));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('UPI ID copied to clipboard.')),
                                        );
                                      },
                                    ),
                                    _buildUpiActionButton(
                                      icon: Icons.link_rounded,
                                      label: 'Copy Link',
                                      onTap: () {
                                        final upiLink = 'upi://pay?pa=${person.upiId}&pn=${Uri.encodeComponent(person.accountHolderName ?? person.name)}&am=$outstanding';
                                        Clipboard.setData(ClipboardData(text: upiLink));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Payment link copied to clipboard.')),
                                        );
                                      },
                                    ),
                                    _buildUpiActionButton(
                                      icon: Icons.share_rounded,
                                      label: 'Share Link',
                                      onTap: () {
                                        final upiLink = 'upi://pay?pa=${person.upiId}&pn=${Uri.encodeComponent(person.accountHolderName ?? person.name)}&am=$outstanding';
                                        Share.share(upiLink, subject: 'Payment Link');
                                      },
                                    ),
                                    _buildUpiActionButton(
                                      icon: Icons.qr_code_2_rounded,
                                      label: 'Share QR',
                                      onTap: () {
                                        final upiLink = 'upi://pay?pa=${person.upiId}&pn=${Uri.encodeComponent(person.accountHolderName ?? person.name)}&am=$outstanding';
                                        _shareQrCode(upiLink);
                                      },
                                    ),
                                    _buildUpiActionButton(
                                      icon: Icons.open_in_new_rounded,
                                      label: 'Open UPI',
                                      onTap: () => _showUpiAppChooser(context, person, outstanding, dbState.userUpiName),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Reminder messages templates
                        Text(
                          'AUTO GENERATED REMINDERS',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '$stageLabel Message template',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.darkPrimary),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.glassSurface,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  currentMsg,
                                  style: const TextStyle(color: Colors.white, height: 1.4, fontSize: 13),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Colors.white70),
                                    tooltip: 'Copy text',
                                    onPressed: () => _copyToClipboard(currentMsg, stageLabel),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.message_outlined, color: Colors.white70),
                                    tooltip: 'Send SMS',
                                    onPressed: () => _shareReminder(currentMsg, 'sms', person, stageLabel),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send_rounded, color: Colors.white70),
                                    tooltip: 'Send Telegram',
                                    onPressed: () => _shareReminder(currentMsg, 'telegram', person, stageLabel),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _shareReminder(currentMsg, 'whatsapp', person, stageLabel),
                                    icon: const Icon(Icons.share, color: Colors.white, size: 16),
                                    label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Image Card generator section
                        Text(
                          'PAYMENT REMINDER CARD GENERATOR',
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 12),
                        if (dbState.userUpiId.isEmpty) ...[
                          GestureDetector(
                            onTap: () => context.push('/recovery/upi_settings'),
                            child: GlassCard(
                              borderColor: Colors.amber.withOpacity(0.3),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'UPI Collection ID Not Set',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Tap here to set up your UPI ID so debtors can scan the QR code to pay you directly.',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.grey400,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.grey500),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        PaymentReminderImageGenerator(
                          debtorName: person.name,
                          amount: outstanding,
                          borrowDate: borrowDate,
                          daysPending: daysPending,
                          userName: dbState.userUpiName.isNotEmpty ? dbState.userUpiName : 'Worth User',
                          upiId: dbState.userUpiId.isNotEmpty ? dbState.userUpiId : 'payment@worth',
                          currency: currency,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // --- TIMELINE TAB ---
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'COLLECTION ACTIONS LOG',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.5),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showAddNoteDialog,
                              icon: const Icon(Icons.add_comment, size: 14, color: Colors.white),
                              label: const Text('Add Note', style: TextStyle(fontSize: 11, color: Colors.white)),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.layer2, padding: const EdgeInsets.symmetric(horizontal: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (activities.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Text(
                                'No timeline interactions logged yet.',
                                style: TextStyle(color: AppColors.grey500, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: activities.length,
                            itemBuilder: (context, index) {
                              final activity = activities[index];
                              return _buildTimelineCard(activity, currency);
                            },
                          ),
                      ],
                    ),
                  ),

                  // --- LEDGER TAB ---
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Builder(
                          builder: (context) {
                            final double lent = txs
                                .where((t) => t.personId == person.id && t.voidedTransactionId == null && t.type == 'lend_money')
                                .fold(0.0, (sum, t) => sum + t.amount);
                            final double recoveries = txs
                                .where((t) => t.personId == person.id && t.voidedTransactionId == null && t.type == 'recover_money')
                                .fold(0.0, (sum, t) => sum + t.amount);
                            final double adjs = dbState.adjustments
                                .where((a) => a.entityId == person.id && a.entityType == 'person_receivable')
                                .fold(0.0, (sum, a) => sum + a.adjustedAmount);

                            return CalculationAuditPanel(
                              title: 'Verify Receivable Calculation',
                              formula: 'Outstanding Balance = Lent - Recoveries + Adjustments',
                              inputs: {
                                'Total Lent': format.format(lent),
                                'Total Recovered': format.format(recoveries),
                                'Adjustments': format.format(adjs),
                              },
                              output: format.format(outstanding),
                              steps: [
                                'Sum all funds lent to this individual: ${format.format(lent)}.',
                                'Sum all recoveries received from this individual: ${format.format(recoveries)}.',
                                'Sum all adjustments applied to this receivable: ${format.format(adjs)}.',
                                'Calculate outstanding balance: Lent (${format.format(lent)}) - Recoveries (${format.format(recoveries)}) + Adjustments (${format.format(adjs)}) = ${format.format(outstanding)}.',
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        if (person.notes != null) ...[
                          Text(
                            'General Notes',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.grey500),
                          ),
                          const SizedBox(height: 8),
                          GlassCard(
                            child: Text(
                              person.notes!,
                              style: const TextStyle(color: Colors.white, height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        Text(
                          'Ledger Transactions',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 12),

                        if (txs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(child: Text('No ledger history found.', style: TextStyle(color: AppColors.grey500))),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: txs.length,
                            itemBuilder: (context, index) {
                              final tx = txs[index];
                              final isVoided = tx.voidedTransactionId != null || tx.type == 'void';

                              final isRecovery = tx.type == 'recover_money';
                              final color = isRecovery ? AppColors.darkSuccess : AppColors.darkDanger;
                              final prefix = isRecovery ? '-' : '+';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tx.notes ?? tx.type.replaceAll('_', ' ').toUpperCase(),
                                              style: TextStyle(
                                                color: isVoided ? AppColors.grey500 : Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(DateFormat('dd MMM yyyy').format(tx.transactionDate), style: const TextStyle(fontSize: 11, color: AppColors.grey500)),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '$prefix$currency${NumberFormat.decimalPattern().format(tx.amount)}',
                                        style: TextStyle(
                                          color: isVoided ? AppColors.grey500 : color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                        
                        RecoveryFlowReportWidget(
                          personId: widget.personId,
                          dbState: dbState,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMiniCol(String label, String val, Color valColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(color: valColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTimelineCard(ReceivableActivity activity, String currency) {
    String title = '';
    IconData icon = Icons.info_outline;
    Color iconColor = Colors.white70;
    
    switch (activity.activityType) {
      case 'created':
        title = 'Receivable created';
        icon = Icons.add_circle_outline;
        iconColor = AppColors.darkPrimary;
        break;
      case 'reminder_sent':
        title = 'Reminder Shared';
        icon = Icons.notification_important_outlined;
        iconColor = Colors.amber;
        break;
      case 'payment_requested':
        title = 'Payment request sent';
        icon = Icons.link_rounded;
        iconColor = Colors.cyan;
        break;
      case 'payment_received':
        title = 'Payment Received';
        icon = Icons.call_received;
        iconColor = AppColors.darkSuccess;
        break;
      case 'settled':
        title = 'Fully Settled';
        icon = Icons.check_circle_outline;
        iconColor = AppColors.darkSuccess;
        break;
      case 'notes_added':
        title = 'Interaction note logged';
        icon = Icons.comment_outlined;
        iconColor = Colors.white;
        break;
    }

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(activity.createdAt.toLocal());
    final isCashFlow = activity.amount != null && activity.amount! > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                      if (isCashFlow)
                        Text(
                          '+$currency${NumberFormat.decimalPattern().format(activity.amount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkSuccess),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                    Text(
                      activity.notes!,
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      Text(dateStr, style: const TextStyle(color: AppColors.grey500, fontSize: 10)),
                      if (activity.channel != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          'via ${activity.channel!.toUpperCase()}',
                          style: TextStyle(color: AppColors.darkPrimary.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustAmountDialog(BuildContext context, WidgetRef ref, Person person, double currentOutstanding) {
    final controller = TextEditingController(text: currentOutstanding.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust Outstanding Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New Outstanding Amount',
            labelStyle: TextStyle(color: AppColors.grey500),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newAmt = double.tryParse(controller.text.trim());
              if (newAmt == null) return;

              Navigator.pop(context);

              final continueAdj = await showAdjustmentWarningDialog(context);
              if (!continueAdj) return;

              final reason = await showAdjustmentReasonSheet(context);
              if (reason == null) return;

              await ref.read(mockDatabaseProvider.notifier).addAdjustment(
                    entityType: 'person_receivable',
                    entityId: person.id,
                    oldAmount: currentOutstanding,
                    newAmount: newAmt,
                    reason: reason,
                  );

              await _logActivity('notes_added', notes: 'Manually adjusted outstanding balance from $currentOutstanding to $newAmt. Reason: $reason');

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Outstanding amount adjusted successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
