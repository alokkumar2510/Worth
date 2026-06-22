import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
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

// ---------------------------------------------------------------------------
// Theme data class — single source of truth for all color tokens per theme
// ---------------------------------------------------------------------------
class _CardTheme {
  final Color background;
  final Color backgroundSecondary;
  final Color accent;
  final Color accentGlow;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color surfaceGlass;
  final Color borderGlass;
  final Color successColor;
  final Color warningColor;
  final Color dangerColor;
  final Color gridLineColor;
  final Color qrBorderColor;
  final Color statusPillBg;
  final Color statusPillText;
  final bool isDark;

  const _CardTheme({
    required this.background,
    required this.backgroundSecondary,
    required this.accent,
    required this.accentGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.surfaceGlass,
    required this.borderGlass,
    required this.successColor,
    required this.warningColor,
    required this.dangerColor,
    required this.gridLineColor,
    required this.qrBorderColor,
    required this.statusPillBg,
    required this.statusPillText,
    required this.isDark,
  });

  static const luxuryBlackGold = _CardTheme(
    background: Color(0xFF0A0A0A),
    backgroundSecondary: Color(0xFF111111),
    accent: Color(0xFFD4AF37),
    accentGlow: Color(0x33D4AF37),
    textPrimary: Color(0xFFF8F8F8),
    textSecondary: Color(0xB3FFFFFF),
    textMuted: Color(0x4DFFFFFF),
    surfaceGlass: Color(0x14FFFFFF),
    borderGlass: Color(0x1FFFFFFF),
    successColor: Color(0xFF22C55E),
    warningColor: Color(0xFFF59E0B),
    dangerColor: Color(0xFFEF4444),
    gridLineColor: Color(0x08D4AF37),
    qrBorderColor: Color(0xFFD4AF37),
    statusPillBg: Color(0x33F59E0B),
    statusPillText: Color(0xFFF59E0B),
    isDark: true,
  );

  static const corporateBlue = _CardTheme(
    background: Color(0xFF0F172A),
    backgroundSecondary: Color(0xFF1E293B),
    accent: Color(0xFF3B82F6),
    accentGlow: Color(0x333B82F6),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF475569),
    surfaceGlass: Color(0x14FFFFFF),
    borderGlass: Color(0x1F94A3B8),
    successColor: Color(0xFF22C55E),
    warningColor: Color(0xFFF59E0B),
    dangerColor: Color(0xFFEF4444),
    gridLineColor: Color(0x083B82F6),
    qrBorderColor: Color(0xFF3B82F6),
    statusPillBg: Color(0x333B82F6),
    statusPillText: Color(0xFF60A5FA),
    isDark: true,
  );

  static const minimalWhite = _CardTheme(
    background: Color(0xFFFAFAFA),
    backgroundSecondary: Color(0xFFFFFFFF),
    accent: Color(0xFF0F172A),
    accentGlow: Color(0x1A0F172A),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textMuted: Color(0xFF94A3B8),
    surfaceGlass: Color(0x0A000000),
    borderGlass: Color(0x14000000),
    successColor: Color(0xFF16A34A),
    warningColor: Color(0xFFB45309),
    dangerColor: Color(0xFFDC2626),
    gridLineColor: Color(0x05000000),
    qrBorderColor: Color(0xFF0F172A),
    statusPillBg: Color(0x1A0F172A),
    statusPillText: Color(0xFF475569),
    isDark: false,
  );
}

// ---------------------------------------------------------------------------
// Custom background painter — grid, floating rupees, ambient glow
// ---------------------------------------------------------------------------
class _PremiumCardBackgroundPainter extends CustomPainter {
  final _CardTheme theme;

  _PremiumCardBackgroundPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // --- Ambient radial glow from top center ---
    if (theme.isDark) {
      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * 0.5, size.height * 0.15),
          size.width * 0.7,
          [
            theme.accent.withOpacity(0.06),
            theme.accent.withOpacity(0.02),
            Colors.transparent,
          ],
          [0.0, 0.4, 1.0],
        );
      canvas.drawRect(Offset.zero & size, glowPaint);
    }

    // --- Subtle grid pattern ---
    final gridPaint = Paint()
      ..color = theme.gridLineColor
      ..strokeWidth = 1.0;

    const gridSpacing = 80.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // --- Floating rupee symbols ---
    if (theme.isDark) {
      final rng = math.Random(42); // deterministic seed
      final rupeePaint = TextPainter(textDirection: TextDirection.ltr);
      for (int i = 0; i < 12; i++) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height;
        final opacity = 0.02 + rng.nextDouble() * 0.025;
        final fontSize = 28.0 + rng.nextDouble() * 32.0;
        rupeePaint.text = TextSpan(
          text: '₹',
          style: TextStyle(
            fontSize: fontSize,
            color: theme.accent.withOpacity(opacity),
            fontWeight: FontWeight.w300,
          ),
        );
        rupeePaint.layout();
        rupeePaint.paint(canvas, Offset(x, y));
      }
    }

    // --- Corner vignette ---
    if (theme.isDark) {
      final vignettePaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width * 0.5, size.height * 0.5),
          size.width * 0.9,
          [
            Colors.transparent,
            Colors.black.withOpacity(0.35),
          ],
          [0.6, 1.0],
        );
      canvas.drawRect(Offset.zero & size, vignettePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Main widget — preserves original API
// ---------------------------------------------------------------------------
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
  late double _customAmount;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _customAmount = widget.amount;
    _amountController = TextEditingController(text: widget.amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PaymentReminderImageGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _customAmount = widget.amount;
      _amountController.text = widget.amount.toStringAsFixed(0);
    }
  }

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

  _CardTheme get _currentCardTheme {
    switch (_selectedTheme) {
      case CardThemeName.luxuryBlackGold:
        return _CardTheme.luxuryBlackGold;
      case CardThemeName.corporateBlue:
        return _CardTheme.corporateBlue;
      case CardThemeName.minimalWhite:
        return _CardTheme.minimalWhite;
    }
  }

  // -----------------------------------------------------------------------
  // Export infrastructure (unchanged)
  // -----------------------------------------------------------------------
  Future<Uint8List?> _captureImage() async {
    setState(() {
      _isExporting = true;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) return null;

      if (_selectedFormat == ExportFormat.jpg) {
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

      final isPartial = (_customAmount - widget.amount).abs() > 0.01;
      final requestedFmt = '${widget.currency}${NumberFormat.decimalPattern().format(_customAmount)}';
      final outstandingFmt = '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}';
      final shareMsg = isPartial
          ? 'Hi ${widget.debtorName}, here is a payment reminder for the requested amount of $requestedFmt (out of total $outstandingFmt outstanding).'
          : 'Hi ${widget.debtorName}, here is a payment reminder for the outstanding amount of $outstandingFmt.';

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

  // -----------------------------------------------------------------------
  // Build — outer shell with selectors + preview
  // -----------------------------------------------------------------------
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

        // Custom Recovery Amount Input
        Text(
          'RECOVERY AMOUNT',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.grey500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            prefixText: '${widget.currency} ',
            prefixStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
            hintText: 'Enter amount to recover',
            hintStyle: const TextStyle(color: AppColors.grey500),
            filled: true,
            fillColor: isDark ? AppColors.layer2 : Colors.grey[200],
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.glassBorder : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.darkPrimary),
            ),
            helperText: 'Defaults to total outstanding: ${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}',
            helperStyle: const TextStyle(color: AppColors.grey500, fontSize: 11),
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val.trim());
            setState(() {
              _customAmount = (parsed != null && parsed > 0) ? parsed : widget.amount;
            });
          },
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
                              label = 'Post 4:5 (1080×1350)';
                              break;
                            case CardSize.story1080x1920:
                              label = 'Story 9:16 (1080×1920)';
                              break;
                            case CardSize.banner1200x628:
                              label = 'Banner 1.91:1 (1200×628)';
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

        // Preview with RepaintBoundary
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
                  child: _buildPremiumCard(_currentCardTheme),
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
                  'Save ${_selectedFormat == ExportFormat.png ? 'PNG' : 'JPG'}',
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

  // -----------------------------------------------------------------------
  // The premium card — unified builder for all themes
  // -----------------------------------------------------------------------
  Widget _buildPremiumCard(_CardTheme ct) {
    final isLandscape = _selectedSize == CardSize.banner1200x628;
    final isStory = _selectedSize == CardSize.story1080x1920;

    final isPartial = (_customAmount - widget.amount).abs() > 0.01;
    final amountText = '${widget.currency}${NumberFormat.decimalPattern().format(_customAmount)}';
    final borrowDateStr = DateFormat('dd MMM yyyy').format(widget.borrowDate);
    final nowStr = DateFormat('dd MMM yyyy  •  hh:mm a').format(DateTime.now());
    final upiUri = 'upi://pay?pa=${widget.upiId}&pn=${Uri.encodeComponent(widget.userName)}&am=$_customAmount';
    final txId = 'WTH-${widget.borrowDate.millisecondsSinceEpoch.toRadixString(36).toUpperCase().substring(0, 6)}';

    // Urgency level
    String urgencyLabel;
    Color urgencyColor;
    double urgencyFill;
    if (widget.daysPending <= 7) {
      urgencyLabel = 'LOW';
      urgencyColor = ct.successColor;
      urgencyFill = 0.2;
    } else if (widget.daysPending <= 30) {
      urgencyLabel = 'MEDIUM';
      urgencyColor = ct.warningColor;
      urgencyFill = 0.55;
    } else {
      urgencyLabel = 'HIGH';
      urgencyColor = ct.dangerColor;
      urgencyFill = 0.9;
    }

    final scaleFactor = isStory ? 1.15 : 1.0;

    if (isLandscape) {
      return _buildBannerLayout(ct, amountText, borrowDateStr, nowStr, upiUri, txId, urgencyLabel, urgencyColor, urgencyFill);
    }

    return Container(
      color: ct.background,
      child: Stack(
        children: [
          // Background effects
          Positioned.fill(
            child: CustomPaint(
              painter: _PremiumCardBackgroundPainter(theme: ct),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48 * scaleFactor, vertical: 36 * scaleFactor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── SECTION 1: HEADER ──
                _buildHeader(ct, nowStr, scaleFactor),
                SizedBox(height: 28 * scaleFactor),

                // ── SECTION 2: HERO AMOUNT ──
                _buildHeroAmount(ct, amountText, scaleFactor, label: isPartial ? 'REQUESTED AMOUNT' : 'OUTSTANDING BALANCE'),
                SizedBox(height: 24 * scaleFactor),

                // ── SECTION 3: BORROWER PROFILE ──
                _buildBorrowerProfile(ct, borrowDateStr, txId, scaleFactor),
                SizedBox(height: 24 * scaleFactor),

                // ── SECTION 4: QR PAYMENT CARD ──
                _buildQrPaymentCard(ct, upiUri, scaleFactor),
                SizedBox(height: 24 * scaleFactor),

                // ── SECTION 5: INSIGHTS GRID ──
                _buildInsightsGrid(ct, amountText, borrowDateStr, scaleFactor),
                SizedBox(height: 20 * scaleFactor),

                // ── SECTION 6: TIMELINE ──
                _buildTimeline(ct, scaleFactor),
                SizedBox(height: 20 * scaleFactor),

                // ── SECTION 7: URGENCY METER ──
                _buildUrgencyMeter(ct, urgencyLabel, urgencyColor, urgencyFill, scaleFactor),
                SizedBox(height: 20 * scaleFactor),

                // ── SECTION 8: TRUST BADGES ──
                _buildTrustBadges(ct, scaleFactor),
                SizedBox(height: 20 * scaleFactor),

                // ── SECTION 9: PERSONAL MESSAGE ──
                _buildPersonalMessage(ct, amountText, scaleFactor),

                const Spacer(),

                // ── SECTION 10: FOOTER ──
                _buildFooter(ct, scaleFactor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // SECTION 1 — Header
  // =======================================================================
  Widget _buildHeader(_CardTheme ct, String nowStr, double scale) {
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: ct.surfaceGlass,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: ct.borderGlass, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo + subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: ct.isDark
                      ? [ct.accent, ct.accent.withOpacity(0.7)]
                      : [ct.accent, ct.accent],
                ).createShader(bounds),
                child: Text(
                  'WORTH',
                  style: GoogleFonts.outfit(
                    fontSize: 30 * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 5.0,
                  ),
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                'PAYMENT REMINDER',
                style: GoogleFonts.inter(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w700,
                  color: ct.textSecondary,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Date + status pill
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                nowStr,
                style: GoogleFonts.inter(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w500,
                  color: ct.textMuted,
                ),
              ),
              SizedBox(height: 8 * scale),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 6 * scale),
                decoration: BoxDecoration(
                  color: ct.statusPillBg,
                  borderRadius: BorderRadius.circular(20 * scale),
                  border: Border.all(color: ct.statusPillText.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6 * scale,
                      height: 6 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ct.statusPillText,
                        boxShadow: [
                          BoxShadow(color: ct.statusPillText.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
                        ],
                      ),
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      'PENDING PAYMENT',
                      style: GoogleFonts.inter(
                        fontSize: 9 * scale,
                        fontWeight: FontWeight.w800,
                        color: ct.statusPillText,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // SECTION 2 — Hero Amount
  // =======================================================================
  Widget _buildHeroAmount(_CardTheme ct, String amountText, double scale, {required String label}) {
    return Center(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              color: ct.textMuted,
              letterSpacing: 3.0,
            ),
          ),
          SizedBox(height: 8 * scale),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: ct.isDark
                  ? [ct.accent, ct.accent.withOpacity(0.65), ct.accent]
                  : [ct.accent, ct.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              amountText,
              style: GoogleFonts.outfit(
                fontSize: 72 * scale,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -1.5,
                height: 1.1,
              ),
            ),
          ),
          // Glow line beneath amount
          if (ct.isDark)
            Container(
              width: 200 * scale,
              height: 2,
              margin: EdgeInsets.only(top: 6 * scale),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    ct.accent.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =======================================================================
  // SECTION 3 — Borrower Profile
  // =======================================================================
  Widget _buildBorrowerProfile(_CardTheme ct, String borrowDateStr, String txId, double scale) {
    final initial = widget.debtorName.isNotEmpty ? widget.debtorName[0].toUpperCase() : '?';
    final daysPendingColor = widget.daysPending <= 7
        ? ct.successColor
        : (widget.daysPending <= 30 ? ct.warningColor : ct.dangerColor);

    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: ct.surfaceGlass,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: ct.borderGlass, width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [ct.accent.withOpacity(0.3), ct.accent.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: ct.accent.withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.outfit(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.bold,
                  color: ct.accent,
                ),
              ),
            ),
          ),
          SizedBox(width: 14 * scale),
          // Name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.debtorName.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w800,
                    color: ct.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  'Borrower',
                  style: GoogleFonts.inter(
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w500,
                    color: ct.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Details grid
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileDetail(ct, 'Borrow Date', borrowDateStr, ct.textPrimary, scale),
                _buildProfileDetail(ct, 'Days Pending', '${widget.daysPending}', daysPendingColor, scale),
                _buildProfileDetail(ct, 'Txn ID', txId, ct.textPrimary, scale),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetail(_CardTheme ct, String label, String value, Color valueColor, double scale) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 8 * scale, fontWeight: FontWeight.w600, color: ct.textMuted, letterSpacing: 0.5),
        ),
        SizedBox(height: 4 * scale),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 12 * scale, fontWeight: FontWeight.w700, color: valueColor),
        ),
      ],
    );
  }

  // =======================================================================
  // SECTION 4 — QR Payment Card
  // =======================================================================
  Widget _buildQrPaymentCard(_CardTheme ct, String upiUri, double scale) {
    return Container(
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: ct.surfaceGlass,
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: ct.qrBorderColor.withOpacity(0.35), width: 1.5),
        boxShadow: ct.isDark
            ? [
                BoxShadow(color: ct.qrBorderColor.withOpacity(0.12), blurRadius: 24, spreadRadius: 2),
                BoxShadow(color: ct.qrBorderColor.withOpacity(0.06), blurRadius: 48, spreadRadius: 4),
              ]
            : [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, spreadRadius: 2),
              ],
      ),
      child: Row(
        children: [
          // QR Code
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(color: ct.qrBorderColor.withOpacity(0.5), width: 2),
              boxShadow: ct.isDark
                  ? [BoxShadow(color: ct.qrBorderColor.withOpacity(0.15), blurRadius: 12, spreadRadius: 1)]
                  : [],
            ),
            child: QrImageView(
              data: upiUri,
              version: QrVersions.auto,
              size: 140 * scale,
              gapless: false,
            ),
          ),
          SizedBox(width: 24 * scale),
          // Pay info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCAN & PAY INSTANTLY',
                  style: GoogleFonts.inter(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w900,
                    color: ct.accent,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 10 * scale),
                // UPI ID
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: ct.surfaceGlass,
                    borderRadius: BorderRadius.circular(8 * scale),
                    border: Border.all(color: ct.borderGlass, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_outlined, size: 12 * scale, color: ct.textMuted),
                      SizedBox(width: 6 * scale),
                      Flexible(
                        child: Text(
                          widget.upiId,
                          style: GoogleFonts.inter(fontSize: 11 * scale, fontWeight: FontWeight.w600, color: ct.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * scale),
                // Badges
                Row(
                  children: [
                    _buildBadge(ct, Icons.verified_rounded, 'Verified', ct.successColor, scale),
                    SizedBox(width: 10 * scale),
                    _buildBadge(ct, Icons.shield_outlined, 'Secure', ct.accent, scale),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(_CardTheme ct, IconData icon, String label, Color color, double scale) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12 * scale, color: color),
        SizedBox(width: 3 * scale),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 9 * scale, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  // =======================================================================
  // SECTION 5 — Insights Grid (3×2)
  // =======================================================================
  Widget _buildInsightsGrid(_CardTheme ct, String amountText, String borrowDateStr, double scale) {
    final isPartial = (_customAmount - widget.amount).abs() > 0.01;
    final insights = [
      _InsightData(Icons.payments_outlined, isPartial ? 'Requested Amt' : 'Amount Due', amountText, ct.accent),
      _InsightData(Icons.person_outline, 'Borrower', widget.debtorName, ct.textPrimary),
      _InsightData(Icons.schedule_outlined, 'Pending', '${widget.daysPending} Days', widget.daysPending > 30 ? ct.dangerColor : (widget.daysPending > 7 ? ct.warningColor : ct.successColor)),
      isPartial
          ? _InsightData(Icons.account_balance_wallet_outlined, 'Total Balance', '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}', ct.textPrimary)
          : _InsightData(Icons.qr_code_2_rounded, 'Payment Method', 'UPI QR', ct.textPrimary),
      _InsightData(Icons.calendar_today_outlined, 'Created', borrowDateStr, ct.textPrimary),
      _InsightData(Icons.hourglass_top_rounded, 'Status', isPartial ? 'Partial Request' : 'Awaiting Payment', ct.warningColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PAYMENT INSIGHTS',
          style: GoogleFonts.inter(
            fontSize: 9 * scale,
            fontWeight: FontWeight.w800,
            color: ct.textMuted,
            letterSpacing: 2.0,
          ),
        ),
        SizedBox(height: 10 * scale),
        Row(
          children: [
            Expanded(child: _buildInsightCard(ct, insights[0], scale)),
            SizedBox(width: 8 * scale),
            Expanded(child: _buildInsightCard(ct, insights[1], scale)),
            SizedBox(width: 8 * scale),
            Expanded(child: _buildInsightCard(ct, insights[2], scale)),
          ],
        ),
        SizedBox(height: 8 * scale),
        Row(
          children: [
            Expanded(child: _buildInsightCard(ct, insights[3], scale)),
            SizedBox(width: 8 * scale),
            Expanded(child: _buildInsightCard(ct, insights[4], scale)),
            SizedBox(width: 8 * scale),
            Expanded(child: _buildInsightCard(ct, insights[5], scale)),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(_CardTheme ct, _InsightData data, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: ct.surfaceGlass,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: ct.borderGlass, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, size: 14 * scale, color: ct.textMuted),
          SizedBox(height: 6 * scale),
          Text(
            data.label,
            style: GoogleFonts.inter(fontSize: 8 * scale, fontWeight: FontWeight.w600, color: ct.textMuted, letterSpacing: 0.5),
          ),
          SizedBox(height: 2 * scale),
          Text(
            data.value,
            style: GoogleFonts.inter(fontSize: 13 * scale, fontWeight: FontWeight.w700, color: data.valueColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // SECTION 6 — Payment Timeline
  // =======================================================================
  Widget _buildTimeline(_CardTheme ct, double scale) {
    final steps = [
      _TimelineStep('Loan Created', true, ct.successColor),
      _TimelineStep('Reminder Generated', true, ct.successColor),
      _TimelineStep('Payment Pending', false, ct.warningColor),
      _TimelineStep('Settlement Complete', false, ct.textMuted.withOpacity(0.3)),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: ct.surfaceGlass,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: ct.borderGlass, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYMENT TIMELINE',
            style: GoogleFonts.inter(fontSize: 9 * scale, fontWeight: FontWeight.w800, color: ct.textMuted, letterSpacing: 2.0),
          ),
          SizedBox(height: 10 * scale),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Connector line
                final stepIdx = index ~/ 2;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: steps[stepIdx].completed ? ct.successColor.withOpacity(0.5) : ct.textMuted.withOpacity(0.15),
                  ),
                );
              }
              final step = steps[index ~/ 2];
              return _buildTimelineDot(ct, step, scale);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDot(_CardTheme ct, _TimelineStep step, double scale) {
    return Column(
      children: [
        Container(
          width: 18 * scale,
          height: 18 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: step.completed ? step.color : Colors.transparent,
            border: Border.all(color: step.color, width: 2),
            boxShadow: step.completed
                ? [BoxShadow(color: step.color.withOpacity(0.3), blurRadius: 6, spreadRadius: 1)]
                : [],
          ),
          child: step.completed
              ? Icon(Icons.check, size: 10 * scale, color: ct.isDark ? Colors.black : Colors.white)
              : null,
        ),
        SizedBox(height: 4 * scale),
        Text(
          step.label,
          style: GoogleFonts.inter(
            fontSize: 7 * scale,
            fontWeight: FontWeight.w600,
            color: step.completed ? ct.textSecondary : ct.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // =======================================================================
  // SECTION 7 — Urgency Meter
  // =======================================================================
  Widget _buildUrgencyMeter(_CardTheme ct, String label, Color color, double fill, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: ct.surfaceGlass,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: ct.borderGlass, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAYMENT URGENCY',
                style: GoogleFonts.inter(fontSize: 9 * scale, fontWeight: FontWeight.w800, color: ct.textMuted, letterSpacing: 2.0),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 3 * scale),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(color: color.withOpacity(0.4), width: 1),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 9 * scale, fontWeight: FontWeight.w800, color: color, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4 * scale),
            child: SizedBox(
              height: 8 * scale,
              child: Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: ct.textMuted.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4 * scale),
                    ),
                  ),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: fill,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ct.successColor, ct.warningColor, ct.dangerColor],
                        ),
                        borderRadius: BorderRadius.circular(4 * scale),
                        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6 * scale),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LOW', style: GoogleFonts.inter(fontSize: 7 * scale, fontWeight: FontWeight.w700, color: ct.successColor)),
              Text('MEDIUM', style: GoogleFonts.inter(fontSize: 7 * scale, fontWeight: FontWeight.w700, color: ct.warningColor)),
              Text('HIGH', style: GoogleFonts.inter(fontSize: 7 * scale, fontWeight: FontWeight.w700, color: ct.dangerColor)),
            ],
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // SECTION 8 — Trust Badges
  // =======================================================================
  Widget _buildTrustBadges(_CardTheme ct, double scale) {
    final badges = [
      'Generated by Worth',
      'Secure UPI Payment',
      'Instant Settlement',
      'Financial Tracking',
      'QR Verified',
    ];

    return Wrap(
      spacing: 8 * scale,
      runSpacing: 6 * scale,
      children: badges.map((badge) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
          decoration: BoxDecoration(
            color: ct.surfaceGlass,
            borderRadius: BorderRadius.circular(8 * scale),
            border: Border.all(color: ct.borderGlass, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 10 * scale, color: ct.successColor),
              SizedBox(width: 4 * scale),
              Text(
                badge,
                style: GoogleFonts.inter(
                  fontSize: 8 * scale,
                  fontWeight: FontWeight.w600,
                  color: ct.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // =======================================================================
  // SECTION 9 — Personalized Message
  // =======================================================================
  Widget _buildPersonalMessage(_CardTheme ct, String amountText, double scale) {
    final isPartial = (_customAmount - widget.amount).abs() > 0.01;
    final totalFmt = '${widget.currency}${NumberFormat.decimalPattern().format(widget.amount)}';
    final message = isPartial
        ? 'Hi ${widget.debtorName},\nThis is a friendly reminder that a partial payment of $amountText (out of total $totalFmt outstanding) is requested. Scan the QR code to complete payment instantly.'
        : 'Hi ${widget.debtorName},\nThis is a friendly reminder that $amountText is pending. Scan the QR code to complete payment instantly.';

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: ct.surfaceGlass,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: ct.accent.withOpacity(0.15), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, size: 20 * scale, color: ct.accent.withOpacity(0.4)),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 11 * scale,
                fontWeight: FontWeight.w500,
                color: ct.textSecondary,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =======================================================================
  // SECTION 10 — Footer
  // =======================================================================
  Widget _buildFooter(_CardTheme ct, double scale) {
    return Column(
      children: [
        // Separator
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                ct.accent.withOpacity(ct.isDark ? 0.3 : 0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          'Powered by Worth',
          style: GoogleFonts.inter(
            fontSize: 10 * scale,
            fontWeight: FontWeight.w600,
            color: ct.textMuted,
            letterSpacing: 1.0,
          ),
        ),
        SizedBox(height: 3 * scale),
        Text(
          'Track  •  Manage  •  Grow Wealth',
          style: GoogleFonts.inter(
            fontSize: 8 * scale,
            fontWeight: FontWeight.w500,
            color: ct.textMuted.withOpacity(0.6),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  // =======================================================================
  // BANNER LAYOUT — condensed 2-column for 1200×628
  // =======================================================================
  Widget _buildBannerLayout(
    _CardTheme ct,
    String amountText,
    String borrowDateStr,
    String nowStr,
    String upiUri,
    String txId,
    String urgencyLabel,
    Color urgencyColor,
    double urgencyFill,
  ) {
    return Container(
      color: ct.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PremiumCardBackgroundPainter(theme: ct),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(36),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left column — branding + amount + borrower + message
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo row
                      Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: ct.isDark
                                  ? [ct.accent, ct.accent.withOpacity(0.7)]
                                  : [ct.accent, ct.accent],
                            ).createShader(bounds),
                            child: Text(
                              'WORTH',
                              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4.0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'PAYMENT REMINDER',
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: ct.textMuted, letterSpacing: 2.0),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: ct.statusPillBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: ct.statusPillText.withOpacity(0.3)),
                            ),
                            child: Text('PENDING', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: ct.statusPillText, letterSpacing: 1.0)),
                          ),
                        ],
                      ),

                      // Amount + borrower
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((_customAmount - widget.amount).abs() > 0.01 ? 'REQUESTED' : 'OUTSTANDING', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: ct.textMuted, letterSpacing: 2.5)),
                          const SizedBox(height: 4),
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: ct.isDark ? [ct.accent, ct.accent.withOpacity(0.65)] : [ct.accent, ct.accent],
                            ).createShader(bounds),
                            child: Text(amountText, style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1.0)),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [ct.accent.withOpacity(0.3), ct.accent.withOpacity(0.1)]),
                                  border: Border.all(color: ct.accent.withOpacity(0.4)),
                                ),
                                child: Center(child: Text(widget.debtorName.isNotEmpty ? widget.debtorName[0].toUpperCase() : '?', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ct.accent))),
                              ),
                              const SizedBox(width: 8),
                              Text(widget.debtorName.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: ct.textPrimary, letterSpacing: 1.0)),
                              const SizedBox(width: 12),
                              Text('•', style: TextStyle(color: ct.textMuted)),
                              const SizedBox(width: 12),
                              Text(borrowDateStr, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: ct.textSecondary)),
                              const SizedBox(width: 12),
                              Text('•', style: TextStyle(color: ct.textMuted)),
                              const SizedBox(width: 12),
                              Text('${widget.daysPending} days pending', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: widget.daysPending > 30 ? ct.dangerColor : (widget.daysPending > 7 ? ct.warningColor : ct.successColor))),
                            ],
                          ),
                        ],
                      ),

                      // Footer
                      Row(
                        children: [
                          Text('Powered by Worth', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w500, color: ct.textMuted)),
                          const SizedBox(width: 16),
                          ...[
                            'Secure UPI',
                            'QR Verified',
                            'Instant Settlement',
                          ].map((b) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 8, color: ct.successColor),
                                    const SizedBox(width: 3),
                                    Text(b, style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w600, color: ct.textSecondary)),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 28),

                // Right column — QR card
                SizedBox(
                  width: 260,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ct.surfaceGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ct.qrBorderColor.withOpacity(0.3), width: 1.5),
                      boxShadow: ct.isDark
                          ? [BoxShadow(color: ct.qrBorderColor.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)]
                          : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('SCAN & PAY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w900, color: ct.accent, letterSpacing: 2.0)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ct.qrBorderColor.withOpacity(0.4), width: 2),
                          ),
                          child: QrImageView(data: upiUri, version: QrVersions.auto, size: 160, gapless: false),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: ct.surfaceGlass,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ct.borderGlass),
                          ),
                          child: Text(widget.upiId, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: ct.textSecondary), overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_rounded, size: 10, color: ct.successColor),
                            const SizedBox(width: 3),
                            Text('Verified', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: ct.successColor)),
                            const SizedBox(width: 10),
                            Icon(Icons.shield_outlined, size: 10, color: ct.accent),
                            const SizedBox(width: 3),
                            Text('Secure', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: ct.accent)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models for sections
// ---------------------------------------------------------------------------
class _InsightData {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  _InsightData(this.icon, this.label, this.value, this.valueColor);
}

class _TimelineStep {
  final String label;
  final bool completed;
  final Color color;

  _TimelineStep(this.label, this.completed, this.color);
}
