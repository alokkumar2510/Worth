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
import 'package:image/image.dart' as img;

import '../../../../core/constants/app_colors.dart';

enum CardThemeName {
  luxuryBlackGold,
  corporateBlue,
  minimalWhite,
}

enum CardSize {
  post1080x1350,
  story1080x1920,
  banner1200x628,
}

enum ExportFormat {
  png,
  jpg,
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
  CardSize _selectedSize = CardSize.post1080x1350;
  ExportFormat _selectedFormat = ExportFormat.png;
  bool _isExporting = false;

  double get cardWidth {
    switch (_selectedSize) {
      case CardSize.post1080x1350:
        return 1080.0;
      case CardSize.story1080x1920:
        return 1080.0;
      case CardSize.banner1200x628:
        return 1200.0;
    }
  }

  double get cardHeight {
    switch (_selectedSize) {
      case CardSize.post1080x1350:
        return 1350.0;
      case CardSize.story1080x1920:
        return 1920.0;
      case CardSize.banner1200x628:
        return 628.0;
    }
  }

  String get sizeLabel {
    switch (_selectedSize) {
      case CardSize.post1080x1350:
        return 'Post (1080x1350)';
      case CardSize.story1080x1920:
        return 'Story (1080x1920)';
      case CardSize.banner1200x628:
        return 'Banner (1200x628)';
    }
  }

  Future<Uint8List?> _captureImage() async {
    setState(() {
      _isExporting = true;
    });
    // Wait for the UI to settle
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      
      // Capture at pixelRatio 1.0 to get exactly the laid-out size
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) return null;

      if (_selectedFormat == ExportFormat.jpg) {
        // Convert to JPG using image library
        final decodedImage = img.decodePng(pngBytes);
        if (decodedImage == null) return pngBytes;
        final jpgBytes = img.encodeJpg(decodedImage, quality: 90);
        return Uint8List.fromList(jpgBytes);
      }

      return pngBytes;
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
    final bytes = await _captureImage();
    if (bytes == null) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final ext = _selectedFormat == ExportFormat.png ? 'png' : 'jpg';
      final file = File('${tempDir.path}/worth_payment_reminder.$ext');
      await file.writeAsBytes(bytes);
      
      final outstandingFmt = '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}';
      final shareMsg = 'Hi ${widget.debtorName}, here is a payment reminder for the outstanding amount of $outstandingFmt.';
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareMsg,
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
    final bytes = await _captureImage();
    if (bytes == null) return;
    try {
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final ext = _selectedFormat == ExportFormat.png ? 'png' : 'jpg';
      final fileName = 'worth_payment_reminder_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final file = File('${downloadsDir!.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved successfully to:\n${file.path}'),
            backgroundColor: AppColors.darkSuccess,
          ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Theme Selector
        Text(
          'THEME',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.grey500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildThemeTab(CardThemeName.luxuryBlackGold, 'Luxury Gold'),
            _buildThemeTab(CardThemeName.corporateBlue, 'Corporate Blue'),
            _buildThemeTab(CardThemeName.minimalWhite, 'Minimal White'),
          ],
        ),
        const SizedBox(height: 16),

        // Size & Format Selectors
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RATIO & SIZE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.layer2 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.glassBorder : Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<CardSize>(
                        value: _selectedSize,
                        dropdownColor: isDark ? AppColors.layer1 : Colors.white,
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        isExpanded: true,
                        items: CardSize.values.map((size) {
                          String label = '';
                          switch (size) {
                            case CardSize.post1080x1350:
                              label = 'Post 4:5 (1080x1350)';
                              break;
                            case CardSize.story1080x1920:
                              label = 'Story 9:16 (1080x1920)';
                              break;
                            case CardSize.banner1200x628:
                              label = 'Banner 1.91:1 (1200x628)';
                              break;
                          }
                          return DropdownMenuItem(value: size, child: Text(label));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedSize = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPORT FORMAT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.layer2 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.glassBorder : Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ExportFormat>(
                        value: _selectedFormat,
                        dropdownColor: isDark ? AppColors.layer1 : Colors.white,
                        style: GoogleFonts.inter(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        isExpanded: true,
                        items: ExportFormat.values.map((fmt) {
                          return DropdownMenuItem(
                            value: fmt,
                            child: Text(fmt == ExportFormat.png ? 'PNG Image' : 'JPG Image'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedFormat = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Repaint Boundary wrapping the Card View (Scaled down for screen layout)
        Center(
          child: Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.glassBorder : Colors.grey[300]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: _buildCardDesign(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Actions Row
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _saveImage,
                icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                label: Text(
                  'Save ${stateFormatName()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.layer2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _shareImage,
                icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Share Reminder Image',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String stateFormatName() {
    return _selectedFormat == ExportFormat.png ? 'PNG' : 'JPG';
  }

  Widget _buildThemeTab(CardThemeName theme, String label) {
    final isSelected = _selectedTheme == theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTheme = theme;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.darkPrimary.withOpacity(0.15)
                  : (isDark ? AppColors.layer2.withOpacity(0.5) : Colors.grey[100]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.darkPrimary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.darkPrimary : AppColors.grey500,
              ),
            ),
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
    final amountText = '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}';
    final borrowDateStr = DateFormat('dd MMM yyyy').format(widget.borrowDate);
    final daysPendingStr = '${widget.daysPending} Days';

    final isLandscape = _selectedSize == CardSize.banner1200x628;

    Widget leftSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WORTH',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFD4AF37),
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PAYMENT REMINDER',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outstanding Amount',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white38,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amountText,
              style: GoogleFonts.outfit(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFD4AF37),
                letterSpacing: -1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLuxuryInfo('Borrower', widget.debtorName),
            _buildLuxuryInfo('Borrow Date', borrowDateStr),
            _buildLuxuryInfo('Days Pending', daysPendingStr, valueColor: const Color(0xFFEF4444)),
            _buildLuxuryInfo('UPI ID', widget.upiId),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Generated using Worth',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white24,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    Widget rightSection = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'PAY NOW',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFD4AF37),
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: QrImageView(
            data: upiUri,
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Scan & Pay',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border.all(color: const Color(0xFFD4AF37), width: 4),
      ),
      child: isLandscape
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: leftSection),
                const SizedBox(width: 40),
                rightSection,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: leftSection),
                const SizedBox(height: 40),
                rightSection,
              ],
            ),
    );
  }

  Widget _buildLuxuryInfo(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white30,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CORPORATE BLUE CARD DESIGN ---
  Widget _buildCorporateBlueCard() {
    final upiUri = 'upi://pay?pa=${widget.upiId}&pn=${Uri.encodeComponent(widget.userName)}&am=${widget.amount}';
    final amountText = '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}';
    final borrowDateStr = DateFormat('dd MMM yyyy').format(widget.borrowDate);
    final daysPendingStr = '${widget.daysPending} Days';

    final isLandscape = _selectedSize == CardSize.banner1200x628;

    Widget leftSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WORTH',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PAYMENT REMINDER',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3B82F6),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outstanding Amount',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amountText,
              style: GoogleFonts.inter(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCorporateInfo('Borrower', widget.debtorName),
            _buildCorporateInfo('Borrow Date', borrowDateStr),
            _buildCorporateInfo('Days Pending', daysPendingStr, valueColor: const Color(0xFFF59E0B)),
            _buildCorporateInfo('UPI ID', widget.upiId),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Generated using Worth',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF475569),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    Widget rightSection = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'PAY NOW',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3B82F6),
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF3B82F6), width: 2),
          ),
          child: QrImageView(
            data: upiUri,
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Scan & Pay',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF1E293B), width: 4),
      ),
      child: isLandscape
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: leftSection),
                const SizedBox(width: 40),
                rightSection,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: leftSection),
                const SizedBox(height: 40),
                rightSection,
              ],
            ),
    );
  }

  Widget _buildCorporateInfo(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? const Color(0xFFF1F5F9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MINIMAL WHITE CARD DESIGN ---
  Widget _buildMinimalWhiteCard() {
    final upiUri = 'upi://pay?pa=${widget.upiId}&pn=${Uri.encodeComponent(widget.userName)}&am=${widget.amount}';
    final amountText = '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}';
    final borrowDateStr = DateFormat('dd MMM yyyy').format(widget.borrowDate);
    final daysPendingStr = '${widget.daysPending} Days';

    final isLandscape = _selectedSize == CardSize.banner1200x628;

    Widget leftSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WORTH',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'PAYMENT REMINDER',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black54,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outstanding Amount',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              amountText,
              style: GoogleFonts.inter(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMinimalInfo('Borrower', widget.debtorName),
            _buildMinimalInfo('Borrow Date', borrowDateStr),
            _buildMinimalInfo('Days Pending', daysPendingStr, valueColor: Colors.red[800]),
            _buildMinimalInfo('UPI ID', widget.upiId),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Generated using Worth',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.black26,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    Widget rightSection = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'PAY NOW',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: QrImageView(
            data: upiUri,
            version: QrVersions.auto,
            size: 200.0,
            gapless: false,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Scan & Pay',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12, width: 4),
      ),
      child: isLandscape
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: leftSection),
                const SizedBox(width: 40),
                rightSection,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: leftSection),
                const SizedBox(height: 40),
                rightSection,
              ],
            ),
    );
  }

  Widget _buildMinimalInfo(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black38,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
