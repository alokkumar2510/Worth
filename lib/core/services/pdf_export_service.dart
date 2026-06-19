import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';
import '../providers/mock_database.dart';
import '../../database/database.dart';

extension PdfColorExtension on PdfColor {
  PdfColor withOpacity(double opacity) {
    return PdfColor(red, green, blue, opacity);
  }
}

class PdfExportService {
  // Brand color palette definitions
  static final PdfColor gold = PdfColor.fromHex('#D4AF37'); // Primary Accent
  static final PdfColor deepNavy = PdfColor.fromHex('#0E112A'); // Cover BG
  static final PdfColor cardNavy = PdfColor.fromHex('#1B1D38'); // Card BG on Cover
  static final PdfColor lightGray = PdfColor.fromHex('#F4F5F8'); // Page BG
  static final PdfColor textDark = PdfColor.fromHex('#1C1D21'); // Standard Text
  static final PdfColor textLight = PdfColor.fromHex('#FFFFFF');
  static final PdfColor textMuted = PdfColor.fromHex('#7A7D8E');
  static final PdfColor greenGrowth = PdfColor.fromHex('#00E676'); // Positive
  static final PdfColor redLiability = PdfColor.fromHex('#D32F2F'); // Negative

  // Generates the PDF document as bytes
  Future<List<int>> generateReportBytes(MockDatabaseState dbState) async {
    final pdf = pw.Document(
      title: 'Worth Financial Report',
      author: 'Worth Wealth Management',
    );

    // Try to load premium Google Fonts, with standard Helvetica fallbacks for offline usage
    pw.Font fontTitle;
    pw.Font fontBody;
    pw.Font fontBold;

    try {
      fontTitle = await PdfGoogleFonts.outfitMedium();
      fontBody = await PdfGoogleFonts.interRegular();
      fontBold = await PdfGoogleFonts.interBold();
    } catch (_) {
      fontTitle = pw.Font.helvetica();
      fontBody = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    // Try to load the logo image, fallback to vector drawing
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/graphics/icons/logo_mark.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // Fallback: draw circular gold mark manually
    }

    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);
    final now = DateTime.now();
    final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(now);
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    // 1. COVER PAGE
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Container(
            color: deepNavy,
            child: pw.Stack(
              children: [
                // Top accent glow
                pw.Positioned(
                  top: -100,
                  right: -100,
                  child: pw.Container(
                    width: 250,
                    height: 250,
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromRYB(1, 0.8, 0, 0.05),
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                ),
                // Cover Page Content
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 40.0, vertical: 50.0),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header Logo & App Name
                      pw.Row(
                        children: [
                          if (logoImage != null)
                            pw.Image(logoImage, width: 28, height: 28)
                          else
                            pw.Container(
                              width: 28,
                              height: 28,
                              decoration: pw.BoxDecoration(
                                color: gold,
                                shape: pw.BoxShape.circle,
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text('W', style: pw.TextStyle(color: deepNavy, fontWeight: pw.FontWeight.bold, fontSize: 14)),
                            ),
                          pw.SizedBox(width: 10),
                          pw.Text(
                            'WORTH',
                            style: pw.TextStyle(
                              font: fontTitle,
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: textLight,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      pw.Spacer(flex: 2),

                      // Document Title
                      pw.Text(
                        'PRIVATE WEALTH\nINTELLIGENCE REPORT',
                        style: pw.TextStyle(
                          font: fontTitle,
                          fontSize: 36,
                          fontWeight: pw.FontWeight.bold,
                          color: textLight,
                          letterSpacing: -0.5,
                          lineSpacing: 1.1,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Container(
                        width: 80,
                        height: 4,
                        color: gold,
                      ),
                      pw.SizedBox(height: 20),
                      pw.Text(
                        'A comprehensive audit of net worth, asset allocation, debt status, and systematic wealth-building plans.',
                        style: pw.TextStyle(
                          font: fontBody,
                          fontSize: 14,
                          color: textMuted,
                        ),
                      ),
                      pw.Spacer(flex: 2),

                      // Elegant Wealth Summary Card
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(24.0),
                        decoration: pw.BoxDecoration(
                          color: cardNavy,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20.0)),
                          border: pw.Border.all(color: gold.withOpacity(0.3), width: 1.0),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('NET WORTH', style: pw.TextStyle(font: fontBody, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
                                pw.SizedBox(height: 6),
                                pw.Text(format.format(dbState.netWorth), style: pw.TextStyle(font: fontTitle, fontSize: 24, fontWeight: pw.FontWeight.bold, color: textLight)),
                              ],
                            ),
                            pw.Container(width: 1, height: 40, color: textMuted.withOpacity(0.3)),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('TOTAL ASSETS', style: pw.TextStyle(font: fontBody, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
                                pw.SizedBox(height: 6),
                                pw.Text(format.format(dbState.totalAssets), style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: greenGrowth)),
                              ],
                            ),
                            pw.Container(width: 1, height: 40, color: textMuted.withOpacity(0.3)),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text('TOTAL LIABILITIES', style: pw.TextStyle(font: fontBody, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
                                pw.SizedBox(height: 6),
                                pw.Text(format.format(dbState.totalLiabilities), style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: redLiability)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      pw.Spacer(flex: 3),

                      // Generation Metadata
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('PREPARED FOR', style: pw.TextStyle(font: fontBody, fontSize: 8, color: textMuted, letterSpacing: 1.0)),
                              pw.SizedBox(height: 4),
                              pw.Text('Worth Account Holder', style: pw.TextStyle(font: fontBold, fontSize: 12, color: textLight)),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('DATE GENERATED', style: pw.TextStyle(font: fontBody, fontSize: 8, color: textMuted, letterSpacing: 1.0)),
                              pw.SizedBox(height: 4),
                              pw.Text(formattedDateTime, style: pw.TextStyle(font: fontBold, fontSize: 11, color: textLight)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Footer Builder helper
    pw.Widget buildReportFooter(int pageNum) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20.0),
        padding: const pw.EdgeInsets.only(top: 10.0),
        decoration: pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: textMuted.withOpacity(0.15), width: 0.8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Worth • Personal Wealth Intelligence', style: pw.TextStyle(font: fontBody, fontSize: 8, color: textMuted)),
            pw.Text('CONFIDENTIAL · Generated on $formattedDateTime', style: pw.TextStyle(font: fontBody, fontSize: 7, color: textMuted)),
            pw.Text('Page $pageNum', style: pw.TextStyle(font: fontBold, fontSize: 8, color: textMuted)),
          ],
        ),
      );
    }

    // 2. EXECUTIVE SUMMARY PAGE
    final double assetLiabilityRatio = dbState.totalLiabilities > 0 ? dbState.totalAssets / dbState.totalLiabilities : dbState.totalAssets;
    final int wealthScore = (dbState.netWorth <= 0)
        ? 10
        : ((1.0 - (dbState.totalLiabilities / (dbState.totalAssets > 0 ? dbState.totalAssets : 1.0))) * 80 + 20).clamp(0, 100).toInt();

    String healthStatus = 'STABLE';
    PdfColor healthColor = gold;
    if (wealthScore >= 80) {
      healthStatus = 'OUTSTANDING';
      healthColor = greenGrowth;
    } else if (wealthScore >= 50) {
      healthStatus = 'HEALTHY';
      healthColor = greenGrowth;
    } else if (wealthScore < 30) {
      healthStatus = 'VULNERABLE';
      healthColor = redLiability;
    }

    double totalReceivables = 0.0;
    for (final p in dbState.people) {
      if (p.isArchived == 0) {
        totalReceivables += dbState.getPersonReceivableBalance(p.id);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('EXECUTIVE WEALTH SUMMARY', style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Text('Executive snapshot of current financial positions, leverage ratio, and liquidity indexes.', style: pw.TextStyle(font: fontBody, fontSize: 11, color: textMuted)),
              pw.SizedBox(height: 20),

              // KPI Blocks Grid
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('NET WORTH', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted, letterSpacing: 0.5)),
                          pw.SizedBox(height: 8),
                          pw.Text(format.format(dbState.netWorth), style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: gold)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('TOTAL ASSETS', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted, letterSpacing: 0.5)),
                          pw.SizedBox(height: 8),
                          pw.Text(format.format(dbState.totalAssets), style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: greenGrowth)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('TOTAL LIABILITIES', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted, letterSpacing: 0.5)),
                          pw.SizedBox(height: 8),
                          pw.Text(format.format(dbState.totalLiabilities), style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: redLiability)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Ratio Card & Wealth Score Side-by-Side
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      height: 180,
                      padding: const pw.EdgeInsets.all(20.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('LEVERAGE INDEX', style: pw.TextStyle(font: fontBold, fontSize: 11, color: textDark)),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('${assetLiabilityRatio.toStringAsFixed(2)}x', style: pw.TextStyle(font: fontTitle, fontSize: 32, fontWeight: pw.FontWeight.bold, color: textDark)),
                              pw.Text('Asset-to-Liability Ratio', style: pw.TextStyle(font: fontBody, fontSize: 10, color: textMuted)),
                            ],
                          ),
                          // Ratio progress bar visual
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text('Assets (${((dbState.totalAssets / (dbState.totalAssets + dbState.totalLiabilities)) * 100).toStringAsFixed(0)}%)', style: pw.TextStyle(font: fontBody, fontSize: 9, color: greenGrowth)),
                                  pw.Text('Debt (${((dbState.totalLiabilities / (dbState.totalAssets + dbState.totalLiabilities)) * 100).toStringAsFixed(0)}%)', style: pw.TextStyle(font: fontBody, fontSize: 9, color: redLiability)),
                                ],
                              ),
                              pw.SizedBox(height: 6),
                              pw.Container(
                                height: 6,
                                width: double.infinity,
                                decoration: pw.BoxDecoration(
                                  color: lightGray,
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3.0)),
                                ),
                                child: pw.Row(
                                  children: [
                                    pw.Expanded(
                                      flex: dbState.totalAssets.toInt(),
                                      child: pw.Container(
                                        decoration: pw.BoxDecoration(
                                          color: greenGrowth,
                                          borderRadius: const pw.BorderRadius.horizontal(left: pw.Radius.circular(3.0)),
                                        ),
                                      ),
                                    ),
                                    pw.Expanded(
                                      flex: dbState.totalLiabilities.toInt(),
                                      child: pw.Container(
                                        decoration: pw.BoxDecoration(
                                          color: redLiability,
                                          borderRadius: const pw.BorderRadius.horizontal(right: pw.Radius.circular(3.0)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Container(
                      height: 180,
                      padding: const pw.EdgeInsets.all(20.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('WORTH WEALTH SCORE', style: pw.TextStyle(font: fontBold, fontSize: 11, color: textDark)),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('$wealthScore / 100', style: pw.TextStyle(font: fontTitle, fontSize: 32, fontWeight: pw.FontWeight.bold, color: healthColor)),
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: pw.BoxDecoration(
                                  color: healthColor.withOpacity(0.12),
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8.0)),
                                  border: pw.Border.all(color: healthColor, width: 0.8),
                                ),
                                child: pw.Text(
                                  healthStatus,
                                  style: pw.TextStyle(font: fontBold, fontSize: 9, color: healthColor),
                                ),
                              ),
                            ],
                          ),
                          pw.Text(
                            'Wealth Score evaluates your financial security by measuring your asset holdings against outstanding leverage debt liabilities.',
                            style: pw.TextStyle(font: fontBody, fontSize: 10, color: textMuted, lineSpacing: 1.2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Secondary KPI blocks (Receivables, Expected Incomes, Invested Capital)
              pw.Text('LIQUIDITY & FORECASTS', style: pw.TextStyle(font: fontBold, fontSize: 12, color: textDark, letterSpacing: 0.5)),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(14.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.12)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('RECEIVABLES', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted)),
                          pw.SizedBox(height: 6),
                          pw.Text(format.format(totalReceivables), style: pw.TextStyle(font: fontTitle, fontSize: 16, fontWeight: pw.FontWeight.bold, color: textDark)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(14.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.12)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('EXPECTED INCOME', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted)),
                          pw.SizedBox(height: 6),
                          pw.Text(format.format(dbState.totalExpectedIncome), style: pw.TextStyle(font: fontTitle, fontSize: 16, fontWeight: pw.FontWeight.bold, color: textDark)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(14.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.12)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('INVESTED CAPITAL', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted)),
                          pw.SizedBox(height: 6),
                          pw.Text(format.format(dbState.totalInvestedCapital), style: pw.TextStyle(font: fontTitle, fontSize: 16, fontWeight: pw.FontWeight.bold, color: textDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.Spacer(),
              buildReportFooter(2),
            ],
          );
        },
      ),
    );

    // 3. ASSET ANALYSIS PAGE
    double cashAssets = 0.0;
    double invAssets = 0.0;
    for (final acc in dbState.accounts) {
      if (acc.isArchived == 0 && acc.type != 'credit') {
        cashAssets += dbState.getAccountCashBalance(acc.id);
      }
    }
    for (final i in dbState.investments) {
      if (i.isArchived == 0) {
        invAssets += dbState.getInvestmentInvestedCapital(i.id);
      }
    }

    final double totalAssetsCalculated = cashAssets + invAssets + totalReceivables;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PORTFOLIO ASSETS ALLOCATION', style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Text('Detailed breakdown of holding classes, capitalization value, and share percentages.', style: pw.TextStyle(font: fontBody, fontSize: 11, color: textMuted)),
              pw.SizedBox(height: 24),

              // Asset Breakdown progress bars (visual pie chart representation)
              pw.Container(
                padding: const pw.EdgeInsets.all(20.0),
                decoration: pw.BoxDecoration(
                  color: textLight,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20.0)),
                  border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ALLOCATION BREAKDOWN', style: pw.TextStyle(font: fontBold, fontSize: 11, color: textDark)),
                    pw.SizedBox(height: 16),
                    _buildHorizontalAllocationBar(
                      fontBold: fontBold,
                      label: 'Investments',
                      amount: invAssets,
                      total: totalAssetsCalculated,
                      color: gold,
                      format: format,
                    ),
                    pw.SizedBox(height: 12),
                    _buildHorizontalAllocationBar(
                      fontBold: fontBold,
                      label: 'Cash & Cash Equivalents',
                      amount: cashAssets,
                      total: totalAssetsCalculated,
                      color: greenGrowth,
                      format: format,
                    ),
                    pw.SizedBox(height: 12),
                    _buildHorizontalAllocationBar(
                      fontBold: fontBold,
                      label: 'Receivables & Lends',
                      amount: totalReceivables,
                      total: totalAssetsCalculated,
                      color: PdfColor.fromHex('#29B6F6'),
                      format: format,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Assets Table
              pw.Text('ASSETS BREAKDOWN DETAILS', style: pw.TextStyle(font: fontBold, fontSize: 12, color: textDark, letterSpacing: 0.5)),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: textMuted.withOpacity(0.1), width: 0.8),
                  bottom: pw.BorderSide(color: textMuted.withOpacity(0.15), width: 1.0),
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: textMuted.withOpacity(0.05)),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('ASSET NAME', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('CLASS / TYPE', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('CAPITAL VALUE', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('SHARE %', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                    ],
                  ),
                  ...dbState.investments.where((i) => i.isArchived == 0).map((i) {
                    final val = dbState.getInvestmentInvestedCapital(i.id);
                    final pct = totalAssetsCalculated > 0 ? (val / totalAssetsCalculated) * 100 : 0.0;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(i.name, style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(i.type.replaceAll('_', ' ').toUpperCase(), style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(val), style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('${pct.toStringAsFixed(1)}%', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textDark))),
                      ],
                    );
                  }).toList(),
                  ...dbState.accounts.where((a) => a.isArchived == 0 && a.type != 'credit').map((a) {
                    final val = dbState.getAccountCashBalance(a.id);
                    final pct = totalAssetsCalculated > 0 ? (val / totalAssetsCalculated) * 100 : 0.0;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(a.name, style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('${a.type.toUpperCase()} ACCOUNT', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(val), style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('${pct.toStringAsFixed(1)}%', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textDark))),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              buildReportFooter(3),
            ],
          );
        },
      ),
    );

    // 4. LIABILITY ANALYSIS PAGE
    double creditDues = 0.0;
    double personDues = 0.0;
    for (final acc in dbState.accounts) {
      if (acc.isArchived == 0 && acc.type == 'credit') {
        creditDues += dbState.getAccountLiabilityBalance(acc.id);
      }
    }
    for (final p in dbState.people) {
      if (p.isArchived == 0) {
        personDues += dbState.getPersonLiabilityBalance(p.id);
      }
    }
    double mtfBorrowed = 0.0;
    for (final m in dbState.mtfPositions) {
      if (m.isClosed == 0) {
        mtfBorrowed += m.borrowedCapital;
      }
    }

    final double totalLiabilitiesCalculated = creditDues + personDues + mtfBorrowed;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('DEBT OBLIGATIONS & LIABILITIES', style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Text('Detailed breakdown of outstanding leverage, credit cards, personal loans, and debt-funded assets.', style: pw.TextStyle(font: fontBody, fontSize: 11, color: textMuted)),
              pw.SizedBox(height: 24),

              // Allocation breakdown
              pw.Container(
                padding: const pw.EdgeInsets.all(20.0),
                decoration: pw.BoxDecoration(
                  color: textLight,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20.0)),
                  border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('DEBT COMPOSITION', style: pw.TextStyle(font: fontBold, fontSize: 11, color: textDark)),
                    pw.SizedBox(height: 16),
                    _buildHorizontalAllocationBar(
                      fontBold: fontBold,
                      label: 'Credit Cards',
                      amount: creditDues,
                      total: totalLiabilitiesCalculated,
                      color: redLiability,
                      format: format,
                    ),
                    pw.SizedBox(height: 12),
                    _buildHorizontalAllocationBar(
                      fontBold: fontBold,
                      label: 'Personal Borrowed Loans',
                      amount: personDues,
                      total: totalLiabilitiesCalculated,
                      color: gold,
                      format: format,
                    ),
                    pw.SizedBox(height: 12),
                    _buildHorizontalAllocationBar(
                      fontBold: fontBold,
                      label: 'Margin Trading Facility (MTF)',
                      amount: mtfBorrowed,
                      total: totalLiabilitiesCalculated,
                      color: PdfColor.fromHex('#7E57C2'),
                      format: format,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Debt Table
              pw.Text('LIABILITIES OBLIGATION LIST', style: pw.TextStyle(font: fontBold, fontSize: 12, color: textDark, letterSpacing: 0.5)),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: textMuted.withOpacity(0.1), width: 0.8),
                  bottom: pw.BorderSide(color: textMuted.withOpacity(0.15), width: 1.0),
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: textMuted.withOpacity(0.05)),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('LENDER / CARD', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('LEVERAGE TYPE', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('BALANCE OWED', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('DEBT SHARE %', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                    ],
                  ),
                  ...dbState.accounts.where((a) => a.isArchived == 0 && a.type == 'credit').map((a) {
                    final val = dbState.getAccountLiabilityBalance(a.id);
                    final pct = totalLiabilitiesCalculated > 0 ? (val / totalLiabilitiesCalculated) * 100 : 0.0;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(a.name, style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('CREDIT CARD DUES', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(val), style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('${pct.toStringAsFixed(1)}%', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textDark))),
                      ],
                    );
                  }).toList(),
                  ...dbState.people.where((p) => p.isArchived == 0 && dbState.getPersonLiabilityBalance(p.id) > 0).map((p) {
                    final val = dbState.getPersonLiabilityBalance(p.id);
                    final pct = totalLiabilitiesCalculated > 0 ? (val / totalLiabilitiesCalculated) * 100 : 0.0;
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(p.name, style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('PERSONAL DEBT', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(val), style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('${pct.toStringAsFixed(1)}%', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textDark))),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              buildReportFooter(4),
            ],
          );
        },
      ),
    );

    // 5. PORTFOLIO HISTORY PAGE
    // Get historical snapshots (take up to 6 latest)
    final historicalSnaps = dbState.snapshots.toList()..sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate));
    final displaySnaps = historicalSnaps.length > 6 ? historicalSnaps.sublist(historicalSnaps.length - 6) : historicalSnaps;

    final List<double> values = displaySnaps.map((s) => s.netWorth).toList();
    final List<String> labels = displaySnaps.map((s) => DateFormat('MMM yy').format(s.snapshotDate)).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('WEALTH EVOLUTION & SNAPSHOTS', style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Text('Historical trend timeline analysis showing progressive net worth accumulation.', style: pw.TextStyle(font: fontBody, fontSize: 11, color: textMuted)),
              pw.SizedBox(height: 24),

              // Growth Chart (CustomPaint Line Chart)
              if (values.isNotEmpty) ...[
                pw.Container(
                  height: 200,
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16.0),
                  decoration: pw.BoxDecoration(
                    color: textLight,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20.0)),
                    border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('NET WORTH GROWTH CHART', style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark)),
                      pw.SizedBox(height: 10),
                      pw.Expanded(
                        child: pw.CustomPaint(
                          painter: LineChartPainter(
                            values: values,
                            labels: labels,
                            lineColor: gold,
                            areaColor: gold.withOpacity(0.08),
                          ).paint,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      // Axis Labels row
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: labels.map((l) => pw.Text(l, style: pw.TextStyle(font: fontBody, fontSize: 8, color: textMuted))).toList(),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),
              ],

              // Monthly History Snapshots Table
              pw.Text('HISTORICAL WEALTH SNAPSHOTS', style: pw.TextStyle(font: fontBold, fontSize: 12, color: textDark, letterSpacing: 0.5)),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: textMuted.withOpacity(0.1), width: 0.8),
                  bottom: pw.BorderSide(color: textMuted.withOpacity(0.15), width: 1.0),
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(2.5),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: textMuted.withOpacity(0.05)),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('SNAPSHOT DATE', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('ASSETS TOTAL', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('LIABILITIES TOTAL', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('NET WORTH VALUE', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                    ],
                  ),
                  ...historicalSnaps.reversed.take(8).map((s) {
                    final dateStr = DateFormat('dd MMM yyyy').format(s.snapshotDate);
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(dateStr, style: pw.TextStyle(font: fontBody, fontSize: 10, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(s.assets), style: pw.TextStyle(font: fontBody, fontSize: 9, color: greenGrowth))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(s.liabilities), style: pw.TextStyle(font: fontBody, fontSize: 9, color: redLiability))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(s.netWorth), style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              buildReportFooter(5),
            ],
          );
        },
      ),
    );

    // 6. TRANSACTION ANALYTICS PAGE
    // Get recent transactions (take up to 10 latest)
    final recentTxs = dbState.transactions.where((t) => t.voidedTransactionId == null).toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final displayTxs = recentTxs.take(10).toList();

    // Group expenses and incomes by category
    final currentMonthTxs = dbState.transactions.where((t) =>
        t.voidedTransactionId == null &&
        t.transactionDate.year == now.year &&
        t.transactionDate.month == now.month).toList();

    final expensesByCategory = <String, double>{};
    double totalIncomeThisMonth = 0.0;
    double totalExpenseThisMonth = 0.0;

    for (final t in currentMonthTxs) {
      if (t.type == 'income') {
        totalIncomeThisMonth += t.amount;
      } else if (t.type == 'expense') {
        totalExpenseThisMonth += t.amount;
        final cat = t.category ?? 'Other';
        expensesByCategory[cat] = (expensesByCategory[cat] ?? 0.0) + t.amount;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CASH FLOW & TRANSACTION ANALYTICS', style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Text('Detailed logging of recent transactions, monthly income vs expenditure, and category metrics.', style: pw.TextStyle(font: fontBody, fontSize: 11, color: textMuted)),
              pw.SizedBox(height: 20),

              // Monthly Cash Flow Overview Card
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.12)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('MONTHLY INCOME', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted)),
                          pw.SizedBox(height: 6),
                          pw.Text(format.format(totalIncomeThisMonth), style: pw.TextStyle(font: fontTitle, fontSize: 18, fontWeight: pw.FontWeight.bold, color: greenGrowth)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.12)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('MONTHLY EXPENSES', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted)),
                          pw.SizedBox(height: 6),
                          pw.Text(format.format(totalExpenseThisMonth), style: pw.TextStyle(font: fontTitle, fontSize: 18, fontWeight: pw.FontWeight.bold, color: redLiability)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(16.0),
                      decoration: pw.BoxDecoration(
                        color: textLight,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16.0)),
                        border: pw.Border.all(color: textMuted.withOpacity(0.12)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('SURPLUS / CASHFLOW', style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted)),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            format.format(totalIncomeThisMonth - totalExpenseThisMonth),
                            style: pw.TextStyle(
                              font: fontTitle,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: (totalIncomeThisMonth - totalExpenseThisMonth) >= 0 ? greenGrowth : redLiability,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Transaction Logs Table
              pw.Text('RECENT TRANSACTION ACTIVITY LOGS', style: pw.TextStyle(font: fontBold, fontSize: 12, color: textDark, letterSpacing: 0.5)),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: pw.BorderSide(color: textMuted.withOpacity(0.1), width: 0.8),
                  bottom: pw.BorderSide(color: textMuted.withOpacity(0.15), width: 1.0),
                ),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1.2),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FlexColumnWidth(1.8),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: textMuted.withOpacity(0.05)),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('DATE', style: pw.TextStyle(font: fontBold, fontSize: 8, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('NOTES / DESCRIPTION', style: pw.TextStyle(font: fontBold, fontSize: 8, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('EVENT TYPE', style: pw.TextStyle(font: fontBold, fontSize: 8, color: textDark))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text('AMOUNT', style: pw.TextStyle(font: fontBold, fontSize: 8, color: textDark))),
                    ],
                  ),
                  ...displayTxs.map((t) {
                    final dateStr = DateFormat('dd MMM').format(t.transactionDate);
                    final isNegative = ['expense', 'lend_money', 'repay_money', 'investment_buy'].contains(t.type);
                    final color = isNegative ? redLiability : greenGrowth;
                    final prefix = isNegative ? '-' : '+';
                    
                    return pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(dateStr, style: pw.TextStyle(font: fontBody, fontSize: 9, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(t.notes ?? t.type.replaceAll('_', ' ').toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark), maxLines: 1)),
                        pw.Padding(padding: const pw.EdgeInsets.all(8.0), child: pw.Text(t.type.replaceAll('_', ' ').toUpperCase(), style: pw.TextStyle(font: fontBody, fontSize: 8, color: textMuted))),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            '$prefix${format.format(t.amount)}',
                            style: pw.TextStyle(font: fontBold, fontSize: 9, color: color),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.Spacer(),
              buildReportFooter(6),
            ],
          );
        },
      ),
    );

    // 7. IPO POOL MANAGER REPORT (Conditional)
    if (dbState.ipoPools.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            final pool = dbState.ipoPools.first;
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('IPO POOL ALLOCATION REPORT', style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark)),
                pw.SizedBox(height: 6),
                pw.Text('IPO Application settlement status, contributor allocation, and capital percentages.', style: pw.TextStyle(font: fontBody, fontSize: 11, color: textMuted)),
                pw.SizedBox(height: 24),

                // IPO Pool Summary info
                pw.Container(
                  padding: const pw.EdgeInsets.all(20.0),
                  decoration: pw.BoxDecoration(
                    color: textLight,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20.0)),
                    border: pw.Border.all(color: textMuted.withOpacity(0.15)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(pool.name.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 14, color: gold)),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Estimated Listing Date', style: pw.TextStyle(font: fontBody, fontSize: 10, color: textMuted)),
                          pw.Text(DateFormat('dd MMM yyyy').format(pool.createdAt), style: pw.TextStyle(font: fontBold, fontSize: 11, color: textDark)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Applied Capital', style: pw.TextStyle(font: fontBody, fontSize: 10, color: textMuted)),
                          pw.Text(format.format(pool.totalPoolAmount), style: pw.TextStyle(font: fontBold, fontSize: 11, color: textDark)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Settlement Status', style: pw.TextStyle(font: fontBody, fontSize: 10, color: textMuted)),
                          pw.Text(pool.status.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 11, color: pool.status == 'allotted' ? greenGrowth : gold)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // Contributors Table
                pw.Text('CONTRIBUTOR SHARES & CAPITAL', style: pw.TextStyle(font: fontBold, fontSize: 12, color: textDark, letterSpacing: 0.5)),
                pw.SizedBox(height: 12),
                pw.Table(
                  border: pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: textMuted.withOpacity(0.1), width: 0.8),
                    bottom: pw.BorderSide(color: textMuted.withOpacity(0.15), width: 1.0),
                  ),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(3),
                    1: pw.FlexColumnWidth(2),
                    2: pw.FlexColumnWidth(2),
                    3: pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: textMuted.withOpacity(0.05)),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('CONTRIBUTOR', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('CAPITAL INJECTED', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('REFUNDED AMOUNT', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                        pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('OWNERSHIP %', style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark))),
                      ],
                    ),
                    ...pool.contributors.map((c) {
                      final double ownershipPercent = (pool.totalGroupContribution > 0
                          ? (c.contribution / pool.totalGroupContribution)
                          : 0.0) * 100;
                      return pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(c.name, style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                          pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(c.contribution), style: pw.TextStyle(font: fontBody, fontSize: 9, color: textDark))),
                          pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text(format.format(c.amountReceived), style: pw.TextStyle(font: fontBody, fontSize: 9, color: textMuted))),
                          pw.Padding(padding: const pw.EdgeInsets.all(10.0), child: pw.Text('${ownershipPercent.toStringAsFixed(1)}%', style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark))),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.Spacer(),
                buildReportFooter(7),
              ],
            );
          },
        ),
      );
    }

    // 8. FINANCIAL INSIGHTS & OBSERVATIONS PAGE
    final int pageNum = dbState.ipoPools.isNotEmpty ? 8 : 7;
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FINANCIAL INTELLIGENCE OBSERVATIONS', style: pw.TextStyle(font: fontTitle, fontSize: 20, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Text('Automated portfolio observations, risk indicators, and asset growth highlights.', style: pw.TextStyle(font: fontBody, fontSize: 11, color: textMuted)),
              pw.SizedBox(height: 24),

              // Insights Cards
              _buildInsightCard(
                fontBold: fontBold,
                fontBody: fontBody,
                title: 'PORTFOLIO GROWTH SUMMARY',
                content: 'Your net worth stands at ${format.format(dbState.netWorth)}. Capital assets total ${format.format(dbState.totalAssets)} against outstanding liabilities of ${format.format(dbState.totalLiabilities)}.',
                color: gold,
                iconType: 'growth',
              ),
              pw.SizedBox(height: 16),
              
              // Debt Risk Insight
              if (dbState.debtFundedAssets > 0)
                _buildInsightCard(
                  fontBold: fontBold,
                  fontBody: fontBody,
                  title: 'LEVERAGE & DEBT FUNDING EXPOSURE',
                  content: 'Your portfolio contains ${format.format(dbState.debtFundedAssets)} of debt-funded assets. This represents ${((dbState.debtFundedAssets / dbState.totalAssets) * 100).toStringAsFixed(0)}% of your total assets. Maintain a high asset-to-liability ratio to safeguard against market volatility.',
                  color: redLiability,
                  iconType: 'risk',
                )
              else
                _buildInsightCard(
                  fontBold: fontBold,
                  fontBody: fontBody,
                  title: 'LEVERAGE & DEBT FUNDING EXPOSURE',
                  content: 'Your asset portfolio is 100% self-funded with zero debt liabilities. You have exceptional liquidity and financial stability.',
                  color: greenGrowth,
                  iconType: 'safety',
                ),
              pw.SizedBox(height: 16),

              // SIP Consistency Insight
              _buildInsightCard(
                fontBold: fontBold,
                fontBody: fontBody,
                title: 'SYSTEMATIC WEALTH CREATION',
                content: 'Systematic Investment Plans (SIP) and expected income inflows form the backbone of your wealth engine. Ensure your cash buffers in bank accounts match upcoming SIP schedules.',
                color: PdfColor.fromHex('#29B6F6'),
                iconType: 'recommendation',
              ),

              pw.Spacer(),
              buildReportFooter(pageNum),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Helper to build allocation progress bar rows
  static pw.Widget _buildHorizontalAllocationBar({
    required pw.Font fontBold,
    required String label,
    required double amount,
    required double total,
    required PdfColor color,
    required NumberFormat format,
  }) {
    final double pct = total > 0 ? (amount / total) : 0.0;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark)),
            pw.Text('${format.format(amount)} (${(pct * 100).toStringAsFixed(1)}%)', style: pw.TextStyle(font: fontBold, fontSize: 10, color: textDark)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          height: 6,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: lightGray,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3.0)),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                width: pct * 480.0, // Scale to match available width roughly
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3.0)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper to build insight rows
  static pw.Widget _buildInsightCard({
    required pw.Font fontBold,
    required pw.Font fontBody,
    required String title,
    required String content,
    required PdfColor color,
    required String iconType,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16.0),
      decoration: pw.BoxDecoration(
        color: textLight,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16.0)),
        border: pw.Border.all(color: textMuted.withOpacity(0.12)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 8,
            height: 48,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4.0)),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(font: fontBold, fontSize: 9, color: color, letterSpacing: 0.5)),
                pw.SizedBox(height: 6),
                pw.Text(content, style: pw.TextStyle(font: fontBody, fontSize: 10, color: textDark, lineSpacing: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Storage & Export Helper on Android Scoped Storage / local storage
  Future<String> savePdfToDownloads(List<int> pdfBytes, {bool forcePrivateDirectory = false}) async {
    final timestamp = DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now());
    final fileName = 'Worth_Report_$timestamp.pdf';

    if (Platform.isAndroid && !forcePrivateDirectory) {
      // Scoped Storage: Direct write to public Download/Worth folder
      final downloadsDir = Directory('/storage/emulated/0/Download/Worth');
      try {
        // Request storage permission for Android 12 or below
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        // Request manage external storage permission for Android 11+
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
          filePath = '${downloadsDir.path}/Worth_Report_${timestamp}_$counter.pdf';
          file = File(filePath);
          counter++;
        }

        await file.writeAsBytes(pdfBytes);
        return file.path;
      } catch (e) {
        throw FileSystemException(
          'Failed to save report to public Downloads directory. '
          'Please grant storage access or save to private folder.\n\nDetails: $e',
          downloadsDir.path,
        );
      }
    } else {
      // Non-Android platforms or forced private app storage fallback
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
      
      int counter = 1;
      while (await file.exists()) {
        filePath = '${backupWorthDir.path}/Worth_Report_${timestamp}_$counter.pdf';
        file = File(filePath);
        counter++;
      }
      
      await file.writeAsBytes(pdfBytes);
      return file.path;
    }
  }
}

// Custom CustomPainter implementations for graphics rendering on PdfPage

class LineChartPainter {
  final List<double> values;
  final List<String> labels;
  final PdfColor lineColor;
  final PdfColor areaColor;

  LineChartPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.areaColor,
  });

  void paint(PdfGraphics canvas, PdfPoint size) {
    if (values.isEmpty) return;

    final double width = size.x;
    final double height = size.y;
    final double padding = 10.0;

    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double diff = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // Draw horizontal grid lines
    canvas.setStrokeColor(PdfColor.fromHex('#E4E6EB'));
    canvas.setLineWidth(0.5);
    for (int i = 0; i <= 3; i++) {
      final double y = padding + (height - 2 * padding) * (i / 3.0);
      canvas.drawLine(padding, y, width - padding, y);
    }
    canvas.strokePath();

    // Plot line
    final int count = values.length;
    final double stepX = (width - 2 * padding) / (count > 1 ? count - 1 : 1);

    canvas.setStrokeColor(lineColor);
    canvas.setLineWidth(1.5);

    for (int i = 0; i < count; i++) {
      final double val = values[i];
      final double pct = (val - minVal) / diff;
      final double x = padding + i * stepX;
      final double y = padding + pct * (height - 2 * padding);

      if (i == 0) {
        canvas.moveTo(x, y);
      } else {
        canvas.lineTo(x, y);
      }
    }
    canvas.strokePath();

    // Fill area below line
    canvas.setFillColor(areaColor);
    for (int i = 0; i < count; i++) {
      final double val = values[i];
      final double pct = (val - minVal) / diff;
      final double x = padding + i * stepX;
      final double y = padding + pct * (height - 2 * padding);

      if (i == 0) {
        canvas.moveTo(x, padding);
        canvas.lineTo(x, y);
      } else {
        canvas.lineTo(x, y);
      }

      if (i == count - 1) {
        canvas.lineTo(x, padding);
      }
    }
    canvas.closePath();
    canvas.fillPath();

    // Draw points
    canvas.setFillColor(lineColor);
    for (int i = 0; i < count; i++) {
      final double val = values[i];
      final double pct = (val - minVal) / diff;
      final double x = padding + i * stepX;
      final double y = padding + pct * (height - 2 * padding);

      canvas.drawEllipse(x, y, 2.0, 2.0);
      canvas.fillPath();
    }
  }
}
