import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';

enum CardThemeName {
  luxuryBlackGold,
  corporateBlue,
  minimalWhite,
}

class PaymentReminderImageGenerator extends StatefulWidget {
  final String debtorName;
  final double amount;
  final DateTime borrowDate;
  final int daysPending;
  final String userName;
  final String upiId;
  final String currency;

  const PaymentReminderImageGenerator({
    required this.debtorName,
    required this.amount,
    required this.borrowDate,
    required this.daysPending,
    required this.userName,
    required this.upiId,
    required this.currency,
    super.key,
  });

  @override
  State<PaymentReminderImageGenerator> createState() => _PaymentReminderImageGeneratorState();
}

class _PaymentReminderImageGeneratorState extends State<PaymentReminderImageGenerator> {
  final GlobalKey _boundaryKey = GlobalKey();
  CardThemeName _selectedTheme = CardThemeName.luxuryBlackGold;
  bool _isExporting = false;

  Future<Uint8List?> _capturePng() async {
    setState(() {
      _isExporting = true;
    });
    // Wait for the UI to settle
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('[IMAGE GENERATOR] Capture failed: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _shareImage() async {
    final bytes = await _capturePng();
    if (bytes == null) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/worth_payment_reminder.png');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Hi ${widget.debtorName}, here is the payment details for the outstanding amount of ${widget.currency}${widget.amount.toStringAsFixed(0)}.',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  Future<void> _saveImage() async {
    final bytes = await _capturePng();
    if (bytes == null) return;
    try {
      // Get the standard documents/downloads folder
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final fileName = 'worth_payment_reminder_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${downloadsDir!.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved successfully to:\n${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Theme Selector Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildThemeTab(CardThemeName.luxuryBlackGold, 'Luxury Gold'),
            _buildThemeTab(CardThemeName.corporateBlue, 'Corporate Blue'),
            _buildThemeTab(CardThemeName.minimalWhite, 'Minimal White'),
          ],
        ),
        const SizedBox(height: 20),

        // Repaint Boundary wrapping the Card View
        Center(
          child: RepaintBoundary(
            key: _boundaryKey,
            child: _buildCardDesign(),
          ),
        ),
        const SizedBox(height: 20),

        // Actions Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _saveImage,
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: const Text('Save Card', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.layer2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _shareImage,
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                label: const Text('Share Card', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeTab(CardThemeName theme, String label) {
    final isSelected = _selectedTheme == theme;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTheme = theme;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkPrimary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.darkPrimary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.darkPrimary : AppColors.grey500,
          ),
        ),
      ),
    );
  }

  Widget _buildCardDesign() {
    switch (_selectedTheme) {
      case CardThemeName.luxuryBlackGold:
        return _buildLuxuryBlackGoldCard();
      case CardThemeName.corporateBlue:
        return _buildCorporateBlueCard();
      case CardThemeName.minimalWhite:
        return _buildMinimalWhiteCard();
    }
  }

  // --- LUXURY BLACK GOLD CARD DESIGN ---
  Widget _buildLuxuryBlackGoldCard() {
    final upiUri = 'upi://pay?pa=${widget.upiId}&pn=${Uri.encodeComponent(widget.userName)}&am=${widget.amount}';
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F), // Sleek black
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37), width: 2), // Golden border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WORTH',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFD4AF37),
                  letterSpacing: 2,
                ),
              ),
              Text(
                'WEALTH STATEMENT',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'OUTSTANDING DEBT ALERTER',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white30,
              letterSpacing: 1.0,
            ),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFD4AF37),
            ),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x33D4AF37), height: 1),
          const SizedBox(height: 12),
          _buildInfoRow('Debtor', widget.debtorName, Colors.white, Colors.white70),
          _buildInfoRow('Lent Date', DateFormat('dd MMM yyyy').format(widget.borrowDate), Colors.white, Colors.white70),
          _buildInfoRow('Days Pending', '${widget.daysPending} Days', Colors.white, const Color(0xFFEF4444)),
          _buildInfoRow('Requested By', widget.userName, Colors.white, Colors.white70),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: QrImageView(
                data: upiUri,
                version: QrVersions.auto,
                size: 110.0,
                gapless: false,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'UPI ID: ${widget.upiId}',
            style: GoogleFonts.inter(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w500),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Scan to settle using any UPI app · Generated ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
            style: GoogleFonts.inter(fontSize: 7, color: Colors.white24),
            textAlign: ui.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- CORPORATE BLUE CARD DESIGN ---
  Widget _buildCorporateBlueCard() {
    final upiUri = 'upi://pay?pa=${widget.upiId}&pn=${Uri.encodeComponent(widget.userName)}&am=${widget.amount}';
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate/Navy blue
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WORTH',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'PAYMENT REQUEST',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3B82F6),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'OUTSTANDING BALANCE',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white60,
              letterSpacing: 1.0,
            ),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x22FFFFFF), height: 1),
          const SizedBox(height: 12),
          _buildInfoRow('Debtor', widget.debtorName, Colors.white, Colors.white70),
          _buildInfoRow('Borrow Date', DateFormat('dd MMM yyyy').format(widget.borrowDate), Colors.white, Colors.white70),
          _buildInfoRow('Days Pending', '${widget.daysPending} Days', Colors.white, const Color(0xFFF59E0B)),
          _buildInfoRow('Recipient', widget.userName, Colors.white, Colors.white70),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6), width: 1.0),
              ),
              child: QrImageView(
                data: upiUri,
                version: QrVersions.auto,
                size: 110.0,
                gapless: false,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'UPI: ${widget.upiId}',
            style: GoogleFonts.inter(fontSize: 9, color: Colors.white38),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Scan to pay via BHIM, GPay, PhonePe, Paytm · Generated using Worth.',
            style: GoogleFonts.inter(fontSize: 7, color: Colors.white24),
            textAlign: ui.TextAlign.center,
          ),
        ],
      ),
    );
  }

  // --- MINIMAL WHITE CARD DESIGN ---
  Widget _buildMinimalWhiteCard() {
    final upiUri = 'upi://pay?pa=${widget.upiId}&pn=${Uri.encodeComponent(widget.userName)}&am=${widget.amount}';
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WORTH',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'MEMO',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'AMOUNT PENDING',
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
              letterSpacing: 1.0,
            ),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),
          _buildInfoRow('Debtor', widget.debtorName, Colors.black, Colors.black87),
          _buildInfoRow('Lent Date', DateFormat('dd MMM yyyy').format(widget.borrowDate), Colors.black, Colors.black87),
          _buildInfoRow('Pending', '${widget.daysPending} Days', Colors.black, Colors.redAccent),
          _buildInfoRow('User', widget.userName, Colors.black, Colors.black87),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              ),
              child: QrImageView(
                data: upiUri,
                version: QrVersions.auto,
                size: 110.0,
                gapless: false,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'UPI: ${widget.upiId}',
            style: GoogleFonts.inter(fontSize: 9, color: Colors.black45),
            textAlign: ui.TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Scan to settle balance · Generated ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
            style: GoogleFonts.inter(fontSize: 7, color: Colors.black26),
            textAlign: ui.TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color labelColor, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: labelColor.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
