
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
import '../calculation/liability_calculation_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// WORTH WEALTH INTELLIGENCE REPORT — Premium Dark-Mode PDF Dossier
// ──────────────────────────────────────────────────────────────────────────────
//
// Design Direction:
//   Morgan Stanley Private Wealth · Goldman Sachs Client Reports
//   BlackRock Investor Reports · Apple Design · Linear
//
// Zero white pages. Zero placeholder text. Zero generic tables.
// Every insight is computed from actual data.
// ──────────────────────────────────────────────────────────────────────────────

extension PdfColorExtension on PdfColor {
  PdfColor withOpacity(double opacity) {
    return PdfColor(red, green, blue, opacity);
  }
}

class PdfExportService {
  // ── Brand Palette ─────────────────────────────────────────────────────────
  static final PdfColor gold = PdfColor.fromHex('#D4AF37');
  static final PdfColor goldDark = PdfColor.fromHex('#B8860B');
  static final PdfColor deepNavy = PdfColor.fromHex('#0A0D1F');
  static final PdfColor cardSurface = PdfColor.fromHex('#111428');
  static final PdfColor cardBorder = PdfColor.fromHex('#1E2140');
  static final PdfColor pageBg = PdfColor.fromHex('#0D1024');
  static final PdfColor textWhite = PdfColor.fromHex('#F0F0F5');
  static final PdfColor textMuted = PdfColor.fromHex('#6B7094');
  static final PdfColor textDim = PdfColor.fromHex('#4A4F6E');
  static final PdfColor greenGrowth = PdfColor.fromHex('#34D399');
  static final PdfColor redDebt = PdfColor.fromHex('#EF4444');
  static final PdfColor blueInfo = PdfColor.fromHex('#38BDF8');
  static final PdfColor purple = PdfColor.fromHex('#A78BFA');
  static final PdfColor amber = PdfColor.fromHex('#FBBF24');

  // ── Main Entry Point ─────────────────────────────────────────────────────
  Future<List<int>> generateReportBytes(MockDatabaseState dbState) async {
    final pdf = pw.Document(
      title: 'Worth Wealth Intelligence Report',
      author: 'Worth Wealth Management',
    );

    // Load premium Google Fonts with fallbacks
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

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/graphics/icons/logo_mark.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);
    final now = DateTime.now();
    final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(now);

    final fonts = _Fonts(title: fontTitle, body: fontBody, bold: fontBold);

    // Pre-compute all data needed across pages
    final reportData = _computeReportData(dbState, now);

    // ── PAGE 1: COVER ───────────────────────────────────────────────────────
    pdf.addPage(_buildCoverPage(fonts, logoImage, format, formattedDateTime, reportData));

    // ── PAGE 2: EXECUTIVE SUMMARY ───────────────────────────────────────────
    pdf.addPage(_buildExecutiveSummary(fonts, format, formattedDateTime, reportData, 2));

    // ── PAGE 3: ASSET ALLOCATION ────────────────────────────────────────────
    pdf.addPage(_buildAssetAllocation(fonts, format, formattedDateTime, reportData, dbState, 3));

    // ── PAGE 4: LIABILITIES ─────────────────────────────────────────────────
    pdf.addPage(_buildLiabilities(fonts, format, formattedDateTime, reportData, dbState, 4));

    // ── PAGE 5: WEALTH EVOLUTION ────────────────────────────────────────────
    pdf.addPage(_buildWealthEvolution(fonts, format, formattedDateTime, reportData, dbState, 5));

    // ── PAGE 6: CASH FLOW & TRANSACTIONS ────────────────────────────────────
    pdf.addPage(_buildCashFlow(fonts, format, formattedDateTime, reportData, dbState, now, 6));

    // ── PAGE 7: SIP PERFORMANCE ─────────────────────────────────────────────
    pdf.addPage(_buildSipPerformance(fonts, format, formattedDateTime, reportData, dbState, now, 7));

    // ── PAGE 8: INVESTMENT HOLDINGS ─────────────────────────────────────────
    pdf.addPage(_buildInvestmentHoldings(fonts, format, formattedDateTime, reportData, dbState, now, 8));

    // ── PAGE 9: IPO POOL (CONDITIONAL) ──────────────────────────────────────
    int nextPage = 9;
    if (dbState.ipoPools.isNotEmpty) {
      pdf.addPage(_buildIpoPool(fonts, format, formattedDateTime, dbState, nextPage));
      nextPage++;
    }

    // ── PAGE 10: INTELLIGENCE OBSERVATIONS ──────────────────────────────────
    pdf.addPage(_buildIntelligenceObservations(fonts, format, formattedDateTime, reportData, dbState, nextPage));

    return pdf.save();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PRE-COMPUTATION
  // ════════════════════════════════════════════════════════════════════════════

  _ReportData _computeReportData(MockDatabaseState dbState, DateTime now) {
    // Asset breakdown
    double cashAssets = 0.0;
    double invAssets = 0.0;
    double totalReceivables = 0.0;

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
    for (final p in dbState.people) {
      if (p.isArchived == 0) {
        totalReceivables += dbState.getPersonReceivableBalance(p.id);
      }
    }

    final totalAssetsComputed = cashAssets + invAssets + totalReceivables;

    // Liability breakdown
    double creditDues = 0.0;
    double personDues = 0.0;
    double mtfBorrowed = 0.0;

    for (final acc in dbState.accounts) {
      if (acc.isArchived == 0 && acc.type == 'credit') {
        creditDues += LiabilityCalculationService.calculateCreditCard(acc, dbState.transactions, dbState.adjustments).finalBalance;
      }
    }
    for (final p in dbState.people) {
      if (p.isArchived == 0) {
        final bal = LiabilityCalculationService.calculatePeerLiability(p, dbState.transactions, dbState.adjustments).finalBalance;
        if (bal > 0) personDues += bal;
      }
    }
    for (final m in dbState.mtfPositions) {
      if (m.isClosed == 0 && m.deletedAt == null) {
        mtfBorrowed += LiabilityCalculationService.calculateMtfPosition(m, dbState.transactions, DateTime.now()).finalBalance;
      }
    }

    final totalLiabilitiesComputed = creditDues + personDues + mtfBorrowed;

    // Wealth metrics
    final double assetLiabilityRatio = totalLiabilitiesComputed > 0 ? dbState.totalAssets / totalLiabilitiesComputed : dbState.totalAssets;
    final int wealthScore = (dbState.netWorth <= 0)
        ? 10
        : ((1.0 - (totalLiabilitiesComputed / (dbState.totalAssets > 0 ? dbState.totalAssets : 1.0))) * 80 + 20).clamp(0, 100).toInt();

    // Monthly cash flow
    final currentMonthTxs = dbState.transactions.where((t) =>
        t.voidedTransactionId == null &&
        t.transactionDate.year == now.year &&
        t.transactionDate.month == now.month).toList();

    double totalIncomeThisMonth = 0.0;
    double totalExpenseThisMonth = 0.0;
    final expensesByCategory = <String, double>{};

    for (final t in currentMonthTxs) {
      if (t.type == 'income') {
        totalIncomeThisMonth += t.amount;
      } else if (t.type == 'expense') {
        totalExpenseThisMonth += t.amount;
        final cat = t.category ?? 'Other';
        expensesByCategory[cat] = (expensesByCategory[cat] ?? 0.0) + t.amount;
      }
    }

    // Snapshots
    final historicalSnaps = dbState.snapshots.toList()..sort((a, b) => a.snapshotDate.compareTo(b.snapshotDate));

    // SIP data
    double sipInvestedCapital = 0.0;
    double sipCurrentValuation = 0.0;
    int totalSipPastOccurrences = 0;
    int completedSipOccurrences = 0;
    final List<Map<String, dynamic>> sipDetails = [];

    for (final sip in dbState.sips) {
      final investment = dbState.investments.firstWhereOrNull((i) => i.id == sip.investmentId);
      if (investment == null) continue;

      final sipTxs = dbState.transactions.where((t) =>
          t.type == 'investment_buy' &&
          t.investmentId == sip.investmentId &&
          t.notes != null &&
          t.notes!.contains('SIP ID: ${sip.id}') &&
          t.voidedTransactionId == null).toList();

      final double investedAmt = sipTxs.fold(0.0, (sum, t) => sum + t.amount);
      final double unitsBought = sipTxs.fold(0.0, (sum, t) => sum + (t.units ?? 0.0));
      final double currentValue = unitsBought * (investment.marketValue ?? 1.0);

      sipInvestedCapital += investedAmt;
      sipCurrentValuation += currentValue;

      final occurrences = _getSipOccurrences(sip, dbState.transactions, now);
      int sipComplete = 0;
      int sipTotal = 0;
      for (final occ in occurrences) {
        sipTotal++;
        totalSipPastOccurrences++;
        if (occ.isCompleted) {
          sipComplete++;
          completedSipOccurrences++;
        }
      }

      sipDetails.add({
        'name': investment.name,
        'amount': sip.amount,
        'frequency': sip.frequency,
        'invested': investedAmt,
        'currentValue': currentValue,
        'growth': currentValue - investedAmt,
        'completed': sipComplete,
        'total': sipTotal,
      });
    }

    final double sipGrowth = sipCurrentValuation - sipInvestedCapital;
    final double sipConsistencyRate = totalSipPastOccurrences > 0
        ? (completedSipOccurrences / totalSipPastOccurrences) * 100.0
        : 100.0;

    return _ReportData(
      cashAssets: cashAssets,
      invAssets: invAssets,
      totalReceivables: totalReceivables,
      totalAssetsComputed: totalAssetsComputed,
      creditDues: creditDues,
      personDues: personDues,
      mtfBorrowed: mtfBorrowed,
      totalLiabilitiesComputed: totalLiabilitiesComputed,
      assetLiabilityRatio: assetLiabilityRatio,
      wealthScore: wealthScore,
      totalIncomeThisMonth: totalIncomeThisMonth,
      totalExpenseThisMonth: totalExpenseThisMonth,
      expensesByCategory: expensesByCategory,
      historicalSnaps: historicalSnaps,
      sipInvestedCapital: sipInvestedCapital,
      sipCurrentValuation: sipCurrentValuation,
      sipGrowth: sipGrowth,
      sipConsistencyRate: sipConsistencyRate,
      sipDetails: sipDetails,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 1: COVER PAGE
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildCoverPage(_Fonts fonts, pw.MemoryImage? logoImage, NumberFormat format, String dateTime, _ReportData data) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: deepNavy,
          child: pw.Stack(
            children: [
              // Decorative gold glow circle (top-right)
              pw.Positioned(
                top: -80,
                right: -80,
                child: pw.Container(
                  width: 280,
                  height: 280,
                  decoration: pw.BoxDecoration(
                    color: gold.withOpacity(0.03),
                    shape: pw.BoxShape.circle,
                  ),
                ),
              ),
              // Secondary glow (bottom-left)
              pw.Positioned(
                bottom: -120,
                left: -120,
                child: pw.Container(
                  width: 320,
                  height: 320,
                  decoration: pw.BoxDecoration(
                    color: gold.withOpacity(0.02),
                    shape: pw.BoxShape.circle,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 44, vertical: 50),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header: Logo + Branding
                    pw.Row(
                      children: [
                        if (logoImage != null)
                          pw.Image(logoImage, width: 30, height: 30)
                        else
                          pw.Container(
                            width: 30,
                            height: 30,
                            decoration: pw.BoxDecoration(
                              color: gold,
                              shape: pw.BoxShape.circle,
                            ),
                            alignment: pw.Alignment.center,
                            child: pw.Text('W', style: pw.TextStyle(font: fonts.bold, color: deepNavy, fontSize: 15, fontWeight: pw.FontWeight.bold)),
                          ),
                        pw.SizedBox(width: 12),
                        pw.Text('WORTH', style: pw.TextStyle(font: fonts.title, fontSize: 18, color: textWhite, letterSpacing: 3.0)),
                      ],
                    ),

                    pw.Spacer(flex: 3),

                    // Document Title
                    pw.Text(
                      'WEALTH',
                      style: pw.TextStyle(font: fonts.title, fontSize: 52, fontWeight: pw.FontWeight.bold, color: textWhite, letterSpacing: 2.0),
                    ),
                    pw.Text(
                      'INTELLIGENCE',
                      style: pw.TextStyle(font: fonts.title, fontSize: 52, fontWeight: pw.FontWeight.bold, color: gold, letterSpacing: 2.0),
                    ),
                    pw.Text(
                      'REPORT',
                      style: pw.TextStyle(font: fonts.title, fontSize: 52, fontWeight: pw.FontWeight.bold, color: textWhite, letterSpacing: 2.0),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Container(width: 80, height: 4, color: gold),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'A comprehensive audit of net worth, asset allocation,\ndebt status, and systematic wealth-building plans.',
                      style: pw.TextStyle(font: fonts.body, fontSize: 13, color: textMuted, lineSpacing: 1.4),
                    ),

                    pw.Spacer(flex: 2),

                    // Wealth Summary Card
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(28),
                      decoration: pw.BoxDecoration(
                        color: cardSurface,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                        border: pw.Border.all(color: gold.withOpacity(0.2), width: 1),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCoverKPI(fonts, 'NET WORTH', format.format(data.totalAssetsComputed - data.totalLiabilitiesComputed), textWhite),
                          pw.Container(width: 1, height: 50, color: textDim.withOpacity(0.3)),
                          _buildCoverKPI(fonts, 'TOTAL ASSETS', format.format(data.totalAssetsComputed), greenGrowth),
                          pw.Container(width: 1, height: 50, color: textDim.withOpacity(0.3)),
                          _buildCoverKPI(fonts, 'TOTAL LIABILITIES', format.format(data.totalLiabilitiesComputed), redDebt),
                        ],
                      ),
                    ),

                    pw.Spacer(flex: 3),

                    // Footer metadata
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('PREPARED FOR', style: pw.TextStyle(font: fonts.body, fontSize: 8, color: textDim, letterSpacing: 1.5)),
                            pw.SizedBox(height: 4),
                            pw.Text('Worth Account Holder', style: pw.TextStyle(font: fonts.bold, fontSize: 12, color: textWhite)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('DATE GENERATED', style: pw.TextStyle(font: fonts.body, fontSize: 8, color: textDim, letterSpacing: 1.5)),
                            pw.SizedBox(height: 4),
                            pw.Text(dateTime, style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: textWhite)),
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
    );
  }

  pw.Widget _buildCoverKPI(_Fonts fonts, String label, String value, PdfColor valueColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(font: fonts.body, fontSize: 9, color: textMuted, letterSpacing: 1.0)),
        pw.SizedBox(height: 8),
        pw.Text(value, style: pw.TextStyle(font: fonts.title, fontSize: 22, fontWeight: pw.FontWeight.bold, color: valueColor)),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 2: EXECUTIVE WEALTH SUMMARY
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildExecutiveSummary(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, int pageNum) {
    String healthStatus = 'STABLE';
    PdfColor healthColor = gold;
    if (data.wealthScore >= 80) {
      healthStatus = 'OUTSTANDING';
      healthColor = greenGrowth;
    } else if (data.wealthScore >= 50) {
      healthStatus = 'HEALTHY';
      healthColor = greenGrowth;
    } else if (data.wealthScore < 30) {
      healthStatus = 'VULNERABLE';
      healthColor = redDebt;
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'EXECUTIVE WEALTH SUMMARY', 'High-level snapshot of current financial positions, leverage ratio, and liquidity indexes.'),
              pw.SizedBox(height: 24),

              // KPI Row
              pw.Row(
                children: [
                  _buildKpiCard(fonts, 'NET WORTH', format.format(data.totalAssetsComputed - data.totalLiabilitiesComputed), gold),
                  pw.SizedBox(width: 12),
                  _buildKpiCard(fonts, 'TOTAL ASSETS', format.format(data.totalAssetsComputed), greenGrowth),
                  pw.SizedBox(width: 12),
                  _buildKpiCard(fonts, 'TOTAL LIABILITIES', format.format(data.totalLiabilitiesComputed), redDebt),
                ],
              ),
              pw.SizedBox(height: 20),

              // Leverage Index + Wealth Score side-by-side
              pw.Row(
                children: [
                  pw.Expanded(
                    child: _buildDarkCard(
                      height: 190,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('LEVERAGE INDEX', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 0.5)),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('${data.assetLiabilityRatio.toStringAsFixed(2)}x', style: pw.TextStyle(font: fonts.title, fontSize: 34, fontWeight: pw.FontWeight.bold, color: textWhite)),
                              pw.SizedBox(height: 2),
                              pw.Text('Asset-to-Liability Ratio', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: textMuted)),
                            ],
                          ),
                          // Progress bar
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    'Assets (${data.totalAssetsComputed > 0 ? ((data.totalAssetsComputed / (data.totalAssetsComputed + data.totalLiabilitiesComputed)) * 100).toStringAsFixed(0) : '100'}%)',
                                    style: pw.TextStyle(font: fonts.body, fontSize: 8, color: greenGrowth),
                                  ),
                                  pw.Text(
                                    'Debt (${data.totalLiabilitiesComputed > 0 ? ((data.totalLiabilitiesComputed / (data.totalAssetsComputed + data.totalLiabilitiesComputed)) * 100).toStringAsFixed(0) : '0'}%)',
                                    style: pw.TextStyle(font: fonts.body, fontSize: 8, color: redDebt),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 6),
                              pw.Container(
                                height: 6,
                                width: double.infinity,
                                decoration: pw.BoxDecoration(
                                  color: cardBorder,
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                                ),
                                child: pw.Row(
                                  children: [
                                    pw.Expanded(
                                      flex: (data.totalAssetsComputed > 0 ? data.totalAssetsComputed : 1).toInt(),
                                      child: pw.Container(
                                        decoration: pw.BoxDecoration(
                                          color: greenGrowth,
                                          borderRadius: const pw.BorderRadius.horizontal(left: pw.Radius.circular(3)),
                                        ),
                                      ),
                                    ),
                                    if (data.totalLiabilitiesComputed > 0)
                                      pw.Expanded(
                                        flex: data.totalLiabilitiesComputed.toInt(),
                                        child: pw.Container(
                                          decoration: pw.BoxDecoration(
                                            color: redDebt,
                                            borderRadius: const pw.BorderRadius.horizontal(right: pw.Radius.circular(3)),
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
                  pw.SizedBox(width: 14),
                  pw.Expanded(
                    child: _buildDarkCard(
                      height: 190,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('WORTH WEALTH SCORE', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 0.5)),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text('${data.wealthScore}', style: pw.TextStyle(font: fonts.title, fontSize: 48, fontWeight: pw.FontWeight.bold, color: healthColor)),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text('/ 100', style: pw.TextStyle(font: fonts.body, fontSize: 14, color: textMuted)),
                                  pw.SizedBox(height: 4),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: pw.BoxDecoration(
                                      color: healthColor.withOpacity(0.12),
                                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                                      border: pw.Border.all(color: healthColor.withOpacity(0.3), width: 0.8),
                                    ),
                                    child: pw.Text(healthStatus, style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: healthColor, letterSpacing: 0.5)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          pw.Text(
                            'Measures financial security by evaluating asset holdings against outstanding leverage debt liabilities.',
                            style: pw.TextStyle(font: fonts.body, fontSize: 9, color: textMuted, lineSpacing: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Liquidity & Forecasts
              pw.Text('LIQUIDITY & FORECASTS', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
              pw.SizedBox(height: 12),
              pw.Row(
                children: [
                  _buildKpiCard(fonts, 'RECEIVABLES', format.format(data.totalReceivables), blueInfo),
                  pw.SizedBox(width: 12),
                  _buildKpiCard(fonts, 'EXPECTED INCOME', format.format(data.totalIncomeThisMonth), amber),
                  pw.SizedBox(width: 12),
                  _buildKpiCard(fonts, 'INVESTED CAPITAL', format.format(data.invAssets), gold),
                ],
              ),

              pw.Spacer(),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 3: PORTFOLIO ASSET ALLOCATION
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildAssetAllocation(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, int pageNum) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'PORTFOLIO ASSET ALLOCATION', 'Detailed breakdown of holding classes, capitalization value, and share percentages.'),
              pw.SizedBox(height: 24),

              // Allocation Bars
              _buildDarkCard(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ALLOCATION BREAKDOWN', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textWhite, letterSpacing: 0.5)),
                    pw.SizedBox(height: 18),
                    _buildAllocationBar(fonts, 'Investments', data.invAssets, data.totalAssetsComputed, gold, format),
                    pw.SizedBox(height: 14),
                    _buildAllocationBar(fonts, 'Cash & Cash Equivalents', data.cashAssets, data.totalAssetsComputed, greenGrowth, format),
                    pw.SizedBox(height: 14),
                    _buildAllocationBar(fonts, 'Receivables & Lends', data.totalReceivables, data.totalAssetsComputed, blueInfo, format),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Assets Table
              pw.Text('ASSETS REGISTER', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
              pw.SizedBox(height: 12),
              _buildDarkTable(
                fonts: fonts,
                headers: ['ASSET NAME', 'CLASS / TYPE', 'CAPITAL VALUE', 'SHARE %'],
                rows: [
                  ...dbState.investments.where((i) => i.isArchived == 0).map((i) {
                    final val = dbState.getInvestmentInvestedCapital(i.id);
                    final pct = data.totalAssetsComputed > 0 ? (val / data.totalAssetsComputed) * 100 : 0.0;
                    return [i.name, i.type.replaceAll('_', ' ').toUpperCase(), format.format(val), '${pct.toStringAsFixed(1)}%'];
                  }),
                  ...dbState.accounts.where((a) => a.isArchived == 0 && a.type != 'credit').map((a) {
                    final val = dbState.getAccountCashBalance(a.id);
                    final pct = data.totalAssetsComputed > 0 ? (val / data.totalAssetsComputed) * 100 : 0.0;
                    return [a.name, '${a.type.toUpperCase()} ACCOUNT', format.format(val), '${pct.toStringAsFixed(1)}%'];
                  }),
                ],
              ),

              pw.Spacer(),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 4: DEBT OBLIGATIONS & LIABILITIES
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildLiabilities(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, int pageNum) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'DEBT OBLIGATIONS & LIABILITIES', 'Outstanding leverage, credit cards, personal loans, and debt-funded asset exposure.'),
              pw.SizedBox(height: 24),

              // Debt Composition
              _buildDarkCard(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('DEBT COMPOSITION', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textWhite, letterSpacing: 0.5)),
                    pw.SizedBox(height: 18),
                    _buildAllocationBar(fonts, 'Credit Cards', data.creditDues, data.totalLiabilitiesComputed, redDebt, format),
                    pw.SizedBox(height: 14),
                    _buildAllocationBar(fonts, 'Personal & Peer Loans', data.personDues, data.totalLiabilitiesComputed, amber, format),
                    pw.SizedBox(height: 14),
                    _buildAllocationBar(fonts, 'Margin Trading Facility (MTF)', data.mtfBorrowed, data.totalLiabilitiesComputed, purple, format),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Liabilities Table
              pw.Text('LIABILITIES REGISTER', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
              pw.SizedBox(height: 12),
              _buildDarkTable(
                fonts: fonts,
                headers: ['LENDER / CARD', 'LEVERAGE TYPE', 'BALANCE OWED', 'DEBT SHARE %'],
                rows: [
                  ...dbState.accounts.where((a) => a.isArchived == 0 && a.type == 'credit').map((a) {
                    final val = LiabilityCalculationService.calculateCreditCard(a, dbState.transactions, dbState.adjustments).finalBalance;
                    final pct = data.totalLiabilitiesComputed > 0 ? (val / data.totalLiabilitiesComputed) * 100 : 0.0;
                    return [a.name, 'CREDIT CARD', format.format(val), '${pct.toStringAsFixed(1)}%'];
                  }),
                  ...dbState.people.where((p) {
                    if (p.isArchived != 0) return false;
                    final val = LiabilityCalculationService.calculatePeerLiability(p, dbState.transactions, dbState.adjustments).finalBalance;
                    return val > 0;
                  }).map((p) {
                    final val = LiabilityCalculationService.calculatePeerLiability(p, dbState.transactions, dbState.adjustments).finalBalance;
                    final pct = data.totalLiabilitiesComputed > 0 ? (val / data.totalLiabilitiesComputed) * 100 : 0.0;
                    String label = 'PERSONAL LOAN';
                    if (p.type == 'borrowing') {
                      label = 'BORROWING';
                    } else if (p.type == 'education_loan') {
                      label = 'EDUCATION LOAN';
                    } else if (p.type == 'manual_liability') {
                      label = 'MANUAL LIABILITY';
                    }
                    return [p.name, label, format.format(val), '${pct.toStringAsFixed(1)}%'];
                  }),
                  ...dbState.mtfPositions.where((m) => m.isClosed == 0 && m.deletedAt == null).map((m) {
                    final val = LiabilityCalculationService.calculateMtfPosition(m, dbState.transactions, DateTime.now()).finalBalance;
                    final pct = data.totalLiabilitiesComputed > 0 ? (val / data.totalLiabilitiesComputed) * 100 : 0.0;
                    return [m.instrument, 'MTF POSITION', format.format(val), '${pct.toStringAsFixed(1)}%'];
                  }),
                ],
              ),

              pw.Spacer(),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 5: WEALTH EVOLUTION & SNAPSHOTS
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildWealthEvolution(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, int pageNum) {
    final displaySnaps = data.historicalSnaps.length > 8 ? data.historicalSnaps.sublist(data.historicalSnaps.length - 8) : data.historicalSnaps;
    final List<double> values = displaySnaps.map((s) => s.netWorth).toList();
    final List<String> labels = displaySnaps.map((s) => DateFormat('MMM yy').format(s.snapshotDate)).toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'WEALTH EVOLUTION & SNAPSHOTS', 'Historical trend timeline showing progressive net worth accumulation.'),
              pw.SizedBox(height: 24),

              // Line Chart
              if (values.isNotEmpty) ...[
                _buildDarkCard(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('NET WORTH GROWTH CURVE', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textWhite, letterSpacing: 0.5)),
                      pw.SizedBox(height: 14),
                      pw.SizedBox(
                        height: 160,
                        child: pw.CustomPaint(
                          painter: LineChartPainter(
                            values: values,
                            labels: labels,
                            lineColor: gold,
                            areaColor: gold.withOpacity(0.06),
                            gridColor: cardBorder,
                            dotColor: gold,
                          ).paint,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: labels.map((l) => pw.Text(l, style: pw.TextStyle(font: fonts.body, fontSize: 7, color: textDim))).toList(),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Snapshots Table
              pw.Text('HISTORICAL WEALTH SNAPSHOTS', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
              pw.SizedBox(height: 12),
              _buildDarkTable(
                fonts: fonts,
                headers: ['SNAPSHOT DATE', 'ASSETS TOTAL', 'LIABILITIES', 'NET WORTH'],
                rows: data.historicalSnaps.reversed.take(10).map((s) {
                  return [
                    DateFormat('dd MMM yyyy').format(s.snapshotDate),
                    format.format(s.assets),
                    format.format(s.liabilities),
                    format.format(s.netWorth),
                  ];
                }).toList(),
              ),

              pw.Spacer(),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 6: CASH FLOW & TRANSACTION ANALYTICS
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildCashFlow(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, DateTime now, int pageNum) {
    final surplus = data.totalIncomeThisMonth - data.totalExpenseThisMonth;

    // Recent transactions
    final recentTxs = dbState.transactions.where((t) => t.voidedTransactionId == null).toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final displayTxs = recentTxs.take(12).toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'CASH FLOW & TRANSACTION ANALYTICS', 'Monthly income vs expenditure, category metrics, and recent activity logs.'),
              pw.SizedBox(height: 24),

              // Monthly Cash Flow KPIs
              pw.Row(
                children: [
                  _buildKpiCard(fonts, 'MONTHLY INCOME', format.format(data.totalIncomeThisMonth), greenGrowth),
                  pw.SizedBox(width: 12),
                  _buildKpiCard(fonts, 'MONTHLY EXPENSES', format.format(data.totalExpenseThisMonth), redDebt),
                  pw.SizedBox(width: 12),
                  _buildKpiCard(fonts, 'NET SURPLUS', format.format(surplus), surplus >= 0 ? greenGrowth : redDebt),
                ],
              ),
              pw.SizedBox(height: 20),

              // Expense Category Breakdown
              if (data.expensesByCategory.isNotEmpty) ...[
                _buildDarkCard(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('EXPENSE CATEGORY BREAKDOWN', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textWhite, letterSpacing: 0.5)),
                      pw.SizedBox(height: 14),
                      ..._buildExpenseCategoryBars(fonts, data, format),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Transaction Log
              pw.Text('RECENT TRANSACTION ACTIVITY', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
              pw.SizedBox(height: 12),
              _buildDarkTable(
                fonts: fonts,
                headers: ['DATE', 'DESCRIPTION', 'TYPE', 'AMOUNT'],
                rows: displayTxs.map((t) {
                  final dateStr = DateFormat('dd MMM').format(t.transactionDate);
                  final isNegative = ['expense', 'lend_money', 'repay_money', 'investment_buy'].contains(t.type);
                  final prefix = isNegative ? '-' : '+';
                  return [
                    dateStr,
                    t.notes ?? t.type.replaceAll('_', ' ').toUpperCase(),
                    t.type.replaceAll('_', ' ').toUpperCase(),
                    '$prefix${format.format(t.amount)}',
                  ];
                }).toList(),
              ),

              pw.Spacer(),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 7: SIP PERFORMANCE TRACKER
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildSipPerformance(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, DateTime now, int pageNum) {
    String consistencyLabel = 'CONSISTENT';
    PdfColor consistencyColor = greenGrowth;
    if (data.sipConsistencyRate < 50) {
      consistencyLabel = 'IRREGULAR';
      consistencyColor = redDebt;
    } else if (data.sipConsistencyRate < 80) {
      consistencyLabel = 'MODERATE';
      consistencyColor = amber;
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'SIP PERFORMANCE TRACKER', 'Systematic Investment Plan execution, consistency, and performance analysis.'),
              pw.SizedBox(height: 24),

              // SIP KPIs
              pw.Row(
                children: [
                  _buildKpiCard(fonts, 'SIP INVESTED', format.format(data.sipInvestedCapital), gold),
                  pw.SizedBox(width: 12),
                  _buildKpiCard(fonts, 'CURRENT VALUE', format.format(data.sipCurrentValuation), greenGrowth),
                  pw.SizedBox(width: 12),
                  _buildKpiCard(fonts, 'GROWTH (P&L)', '${data.sipGrowth >= 0 ? '+' : ''}${format.format(data.sipGrowth)}', data.sipGrowth >= 0 ? greenGrowth : redDebt),
                ],
              ),
              pw.SizedBox(height: 16),

              // Consistency Badge
              _buildDarkCard(
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SIP CONSISTENCY RATE', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 0.5)),
                        pw.SizedBox(height: 8),
                        pw.Text('${data.sipConsistencyRate.toStringAsFixed(0)}%', style: pw.TextStyle(font: fonts.title, fontSize: 28, fontWeight: pw.FontWeight.bold, color: consistencyColor)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: consistencyColor.withOpacity(0.12),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                        border: pw.Border.all(color: consistencyColor.withOpacity(0.3)),
                      ),
                      child: pw.Text(consistencyLabel, style: pw.TextStyle(font: fonts.bold, fontSize: 9, color: consistencyColor, letterSpacing: 0.5)),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // SIP Details Table
              if (data.sipDetails.isNotEmpty) ...[
                pw.Text('INDIVIDUAL SIP BREAKDOWN', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
                pw.SizedBox(height: 12),
                _buildDarkTable(
                  fonts: fonts,
                  headers: ['SIP NAME', 'INVESTED', 'CURRENT VALUE', 'RETURN'],
                  rows: data.sipDetails.map((sip) {
                    final growth = (sip['growth'] as double?) ?? 0.0;
                    final invested = (sip['invested'] as double?) ?? 0.0;
                    final returnPct = invested > 0 ? (growth / invested) * 100 : 0.0;
                    return [
                      (sip['name'] as String?) ?? 'Unknown',
                      format.format(invested),
                      format.format((sip['currentValue'] as double?) ?? 0.0),
                      '${growth >= 0 ? '+' : ''}${returnPct.toStringAsFixed(1)}%',
                    ];
                  }).toList(),
                ),
              ] else
                _buildDarkCard(
                  child: pw.Center(
                    child: pw.Text('No active SIP plans found. Set up SIPs to track systematic wealth building.', style: pw.TextStyle(font: fonts.body, fontSize: 11, color: textMuted)),
                  ),
                ),

              pw.Spacer(),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 8: INVESTMENT HOLDING ANALYSIS
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildInvestmentHoldings(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, DateTime now, int pageNum) {
    final activeInvestments = dbState.investments.where((i) => i.isArchived == 0).toList();
    double totalHoldingDays = 0.0;
    final List<Map<String, dynamic>> holdingData = [];

    for (final inv in activeInvestments) {
      final purchaseDateTime = inv.purchaseDate ?? inv.createdAt;
      final days = now.difference(purchaseDateTime).inDays;
      final holdDays = days >= 0 ? days : 0;
      totalHoldingDays += holdDays;
      holdingData.add({
        'name': inv.name,
        'days': holdDays,
        'purchaseDate': purchaseDateTime,
        'value': dbState.getInvestmentInvestedCapital(inv.id),
      });
    }

    final double avgHolding = activeInvestments.isNotEmpty ? totalHoldingDays / activeInvestments.length : 0.0;

    // Sort by holding days descending
    holdingData.sort((a, b) => (b['days'] as int).compareTo(a['days'] as int));

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'INVESTMENT HOLDING ANALYSIS', 'Portfolio age distribution, holding periods, and capital aging metrics.'),
              pw.SizedBox(height: 24),

              // Average Holding Period
              _buildDarkCard(
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('AVERAGE HOLDING PERIOD', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 0.5)),
                        pw.SizedBox(height: 8),
                        pw.Text('${avgHolding.toStringAsFixed(0)} Days', style: pw.TextStyle(font: fonts.title, fontSize: 28, fontWeight: pw.FontWeight.bold, color: gold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('ACTIVE POSITIONS', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: textMuted, letterSpacing: 0.5)),
                        pw.SizedBox(height: 6),
                        pw.Text('${activeInvestments.length}', style: pw.TextStyle(font: fonts.title, fontSize: 24, fontWeight: pw.FontWeight.bold, color: textWhite)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Holding Table
              if (holdingData.isNotEmpty) ...[
                pw.Text('POSITION-WISE HOLDING PERIODS', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
                pw.SizedBox(height: 12),
                _buildDarkTable(
                  fonts: fonts,
                  headers: ['INVESTMENT', 'PURCHASE DATE', 'CAPITAL VALUE', 'HOLDING PERIOD'],
                  rows: holdingData.take(15).map((hd) {
                    final purchaseDate = hd['purchaseDate'] as DateTime;
                    return [
                      hd['name'] as String,
                      DateFormat('dd MMM yyyy').format(purchaseDate),
                      format.format(hd['value'] as double),
                      '${hd['days']} Days',
                    ];
                  }).toList(),
                ),
              ] else
                _buildDarkCard(
                  child: pw.Center(
                    child: pw.Text('No active investments found.', style: pw.TextStyle(font: fonts.body, fontSize: 11, color: textMuted)),
                  ),
                ),

              pw.Spacer(),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 9: IPO POOL REPORT (CONDITIONAL)
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildIpoPool(_Fonts fonts, NumberFormat format, String dateTime, MockDatabaseState dbState, int pageNum) {
    final pool = dbState.ipoPools.first;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'IPO POOL ALLOCATION REPORT', 'Application settlement status, contributor allocation, and capital ownership.'),
              pw.SizedBox(height: 24),

              // Pool Summary
              _buildDarkCard(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(pool.name.toUpperCase(), style: pw.TextStyle(font: fonts.bold, fontSize: 14, color: gold, letterSpacing: 0.5)),
                    pw.SizedBox(height: 16),
                    _buildKeyValueRow(fonts, 'Estimated Listing Date', DateFormat('dd MMM yyyy').format(pool.createdAt)),
                    pw.SizedBox(height: 8),
                    _buildKeyValueRow(fonts, 'Total Applied Capital', format.format(pool.totalPoolAmount)),
                    pw.SizedBox(height: 8),
                    _buildKeyValueRow(fonts, 'Settlement Status', pool.status.toUpperCase(), valueColor: pool.status == 'allotted' ? greenGrowth : amber),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Contributors Table
              pw.Text('CONTRIBUTOR CAPITAL & OWNERSHIP', style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: textMuted, letterSpacing: 1.0)),
              pw.SizedBox(height: 12),
              _buildDarkTable(
                fonts: fonts,
                headers: ['CONTRIBUTOR', 'CAPITAL INJECTED', 'REFUNDED', 'OWNERSHIP %'],
                rows: pool.contributors.map((c) {
                  final ownership = (pool.totalGroupContribution > 0 ? (c.contribution / pool.totalGroupContribution) : 0.0) * 100;
                  return [c.name, format.format(c.contribution), format.format(c.amountReceived), '${ownership.toStringAsFixed(1)}%'];
                }).toList(),
              ),

              pw.Spacer(),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 10: FINANCIAL INTELLIGENCE OBSERVATIONS
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildIntelligenceObservations(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, int pageNum) {
    // Compute data-driven insights
    final netWorth = data.totalAssetsComputed - data.totalLiabilitiesComputed;
    final surplus = data.totalIncomeThisMonth - data.totalExpenseThisMonth;
    final savingsRate = data.totalIncomeThisMonth > 0 ? (surplus / data.totalIncomeThisMonth * 100) : 0.0;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'FINANCIAL INTELLIGENCE', 'Data-driven portfolio observations, risk indicators, and strategic highlights.'),
              pw.SizedBox(height: 24),

              // Insight 1: Portfolio Growth Summary
              _buildInsightCard(
                fonts: fonts,
                title: 'PORTFOLIO GROWTH SUMMARY',
                content: 'Net worth stands at ${format.format(netWorth)}. Capital assets total ${format.format(data.totalAssetsComputed)} against outstanding liabilities of ${format.format(data.totalLiabilitiesComputed)}. Your Wealth Score of ${data.wealthScore}/100 places your financial position in the ${data.wealthScore >= 80 ? 'outstanding' : data.wealthScore >= 50 ? 'healthy' : data.wealthScore >= 30 ? 'stable' : 'vulnerable'} zone.',
                color: gold,
              ),
              pw.SizedBox(height: 14),

              // Insight 2: Leverage Exposure
              if (dbState.debtFundedAssets > 0)
                _buildInsightCard(
                  fonts: fonts,
                  title: 'LEVERAGE & DEBT FUNDING EXPOSURE',
                  content: 'Portfolio contains ${format.format(dbState.debtFundedAssets)} of debt-funded assets, representing ${((dbState.debtFundedAssets / (data.totalAssetsComputed > 0 ? data.totalAssetsComputed : 1)) * 100).toStringAsFixed(1)}% of total assets. Maintain a high asset-to-liability ratio (currently ${data.assetLiabilityRatio.toStringAsFixed(2)}x) to safeguard against market volatility.',
                  color: redDebt,
                )
              else
                _buildInsightCard(
                  fonts: fonts,
                  title: 'LEVERAGE & DEBT FUNDING EXPOSURE',
                  content: 'Asset portfolio is 100% self-funded with zero debt-funded positions. Exceptional liquidity and financial stability with an asset-to-liability ratio of ${data.assetLiabilityRatio.toStringAsFixed(2)}x.',
                  color: greenGrowth,
                ),
              pw.SizedBox(height: 14),

              // Insight 3: SIP Consistency
              _buildInsightCard(
                fonts: fonts,
                title: 'SYSTEMATIC WEALTH CREATION',
                content: data.sipDetails.isNotEmpty
                    ? 'SIP portfolio has ${data.sipDetails.length} active plans with a consistency rate of ${data.sipConsistencyRate.toStringAsFixed(0)}%. Total SIP invested capital: ${format.format(data.sipInvestedCapital)}, current valuation: ${format.format(data.sipCurrentValuation)} (${data.sipGrowth >= 0 ? '+' : ''}${format.format(data.sipGrowth)} growth).'
                    : 'No active SIP plans detected. Systematic investment plans are the backbone of disciplined wealth creation. Consider initiating monthly SIPs to compound returns over time.',
                color: blueInfo,
              ),
              pw.SizedBox(height: 14),

              // Insight 4: Cash Flow Health
              _buildInsightCard(
                fonts: fonts,
                title: 'CASH FLOW HEALTH',
                content: data.totalIncomeThisMonth > 0
                    ? 'Monthly income of ${format.format(data.totalIncomeThisMonth)} against expenses of ${format.format(data.totalExpenseThisMonth)} yields a ${surplus >= 0 ? 'surplus' : 'deficit'} of ${format.format(surplus.abs())} (savings rate: ${savingsRate.toStringAsFixed(1)}%). ${savingsRate >= 30 ? 'Excellent savings discipline.' : savingsRate >= 10 ? 'Moderate savings — consider optimizing discretionary spending.' : 'Low savings rate — review expense categories for optimization opportunities.'}'
                    : 'No income recorded this month. Track all income sources to generate comprehensive cash flow intelligence.',
                color: surplus >= 0 ? greenGrowth : amber,
              ),

              pw.Spacer(),

              // End-of-report branding
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: cardBorder, width: 1)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('END OF REPORT', style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: textDim, letterSpacing: 2.0)),
                    pw.SizedBox(height: 4),
                    pw.Text('Generated by Worth — Personal Wealth Intelligence', style: pw.TextStyle(font: fonts.body, fontSize: 8, color: textDim)),
                  ],
                ),
              ),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SHARED UI COMPONENTS
  // ════════════════════════════════════════════════════════════════════════════

  pw.Widget _buildPageHeader(_Fonts fonts, String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: fonts.title, fontSize: 20, fontWeight: pw.FontWeight.bold, color: textWhite, letterSpacing: 0.5)),
        pw.SizedBox(height: 6),
        pw.Text(subtitle, style: pw.TextStyle(font: fonts.body, fontSize: 10, color: textMuted)),
        pw.SizedBox(height: 4),
        pw.Container(width: 60, height: 3, color: gold),
      ],
    );
  }

  pw.Widget _buildPageFooter(_Fonts fonts, String dateTime, int pageNum) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: cardBorder, width: 0.8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Worth Wealth Intelligence', style: pw.TextStyle(font: fonts.body, fontSize: 7, color: textDim)),
          pw.Text('CONFIDENTIAL  |  $dateTime', style: pw.TextStyle(font: fonts.body, fontSize: 7, color: textDim)),
          pw.Text('Page $pageNum', style: pw.TextStyle(font: fonts.bold, fontSize: 7, color: textDim)),
        ],
      ),
    );
  }

  pw.Widget _buildDarkCard({required pw.Widget child, double? height}) {
    return pw.Container(
      height: height,
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: cardSurface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
        border: pw.Border.all(color: cardBorder, width: 0.8),
      ),
      child: child,
    );
  }

  pw.Widget _buildKpiCard(_Fonts fonts, String label, String value, PdfColor valueColor) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: cardSurface,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14)),
          border: pw.Border.all(color: cardBorder, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(font: fonts.body, fontSize: 8, color: textMuted, letterSpacing: 0.5)),
            pw.SizedBox(height: 8),
            pw.Text(value, style: pw.TextStyle(font: fonts.title, fontSize: 17, fontWeight: pw.FontWeight.bold, color: valueColor)),
          ],
        ),
      ),
    );
  }

  List<pw.Widget> _buildExpenseCategoryBars(_Fonts fonts, _ReportData data, NumberFormat format) {
    final sortedEntries = data.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [redDebt, amber, purple, blueInfo, gold, greenGrowth];
    return sortedEntries.take(6).toList().asMap().entries.map((indexed) {
      final e = indexed.value;
      final color = colors[indexed.key % colors.length];
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: _buildAllocationBar(fonts, e.key, e.value, data.totalExpenseThisMonth, color, format),
      );
    }).toList();
  }

  pw.Widget _buildAllocationBar(_Fonts fonts, String label, double amount, double total, PdfColor color, NumberFormat format) {
    final pct = total > 0 ? (amount / total) : 0.0;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(font: fonts.bold, fontSize: 9, color: textWhite)),
            pw.Text('${format.format(amount)} (${(pct * 100).toStringAsFixed(1)}%)', style: pw.TextStyle(font: fonts.bold, fontSize: 9, color: textWhite)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          height: 5,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: cardBorder,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2.5)),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                width: pct * 470,
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInsightCard({required _Fonts fonts, required String title, required String content, required PdfColor color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: cardSurface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14)),
        border: pw.Border.all(color: cardBorder, width: 0.8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 4,
            height: 52,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title, style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: color, letterSpacing: 0.8)),
                pw.SizedBox(height: 6),
                pw.Text(content, style: pw.TextStyle(font: fonts.body, fontSize: 9, color: textWhite, lineSpacing: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildKeyValueRow(_Fonts fonts, String key, String value, {PdfColor? valueColor}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(key, style: pw.TextStyle(font: fonts.body, fontSize: 10, color: textMuted)),
        pw.Text(value, style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: valueColor ?? textWhite)),
      ],
    );
  }

  pw.Widget _buildDarkTable({required _Fonts fonts, required List<String> headers, required List<List<String>> rows}) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: cardBorder, width: 0.5),
        bottom: pw.BorderSide(color: cardBorder, width: 0.8),
      ),
      columnWidths: {
        for (int i = 0; i < headers.length; i++)
          i: i == 0 ? const pw.FlexColumnWidth(3) : const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: cardSurface),
          children: headers.map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(9),
            child: pw.Text(h, style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: textMuted, letterSpacing: 0.3)),
          )).toList(),
        ),
        ...rows.map((row) => pw.TableRow(
          children: row.asMap().entries.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.all(9),
            child: pw.Text(
              e.value,
              style: pw.TextStyle(
                font: e.key == 0 ? fonts.bold : fonts.body,
                fontSize: 9,
                color: textWhite,
              ),
              maxLines: 1,
            ),
          )).toList(),
        )),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SIP OCCURRENCE HELPER
  // ════════════════════════════════════════════════════════════════════════════

  List<_SipOccurrence> _getSipOccurrences(Sip sip, List<Transaction> transactions, DateTime today) {
    final List<_SipOccurrence> list = [];
    DateTime current = DateTime(sip.startDate.year, sip.startDate.month, sip.startDate.day);
    final end = sip.endDate != null && sip.endDate!.isBefore(today)
        ? DateTime(sip.endDate!.year, sip.endDate!.month, sip.endDate!.day)
        : today;

    if (current.isAfter(end)) return list;

    final creationDate = sip.worthCreationDate ?? sip.createdAt;
    final creationMidnight = DateTime(creationDate.year, creationDate.month, creationDate.day);

    int loops = 0;
    while ((current.isBefore(end) || current.isAtSameMomentAs(end)) && loops < 500) {
      loops++;
      bool matches = false;
      if (sip.frequency == 'weekly') {
        if (current.weekday == sip.sipDate) matches = true;
      } else if (sip.frequency == 'monthly') {
        final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
        final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
        if (current.day == targetDay) matches = true;
      } else if (sip.frequency == 'quarterly') {
        final monthDiff = (current.year - sip.startDate.year) * 12 + (current.month - sip.startDate.month);
        if (monthDiff % 3 == 0) {
          final daysInMonth = DateTime(current.year, current.month + 1, 0).day;
          final targetDay = sip.sipDate > daysInMonth ? daysInMonth : sip.sipDate;
          if (current.day == targetDay) matches = true;
        }
      }

      if (matches) {
        final isCompleted = transactions.any((t) =>
            t.type == 'investment_buy' &&
            t.investmentId == sip.investmentId &&
            t.notes != null &&
            t.notes!.contains('SIP ID: ${sip.id}') &&
            t.transactionDate.year == current.year &&
            t.transactionDate.month == current.month &&
            t.transactionDate.day == current.day &&
            t.voidedTransactionId == null);

        final isAfterOrCreate = current.isAfter(creationMidnight) || current.isAtSameMomentAs(creationMidnight);
        if (isCompleted || isAfterOrCreate) {
          list.add(_SipOccurrence(date: current, isCompleted: isCompleted));
        }
      }
      current = current.add(const Duration(days: 1));
    }
    return list;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // STORAGE & EXPORT
  // ════════════════════════════════════════════════════════════════════════════

  Future<String> savePdfToDownloads(List<int> pdfBytes, {bool forcePrivateDirectory = false}) async {
    final timestamp = DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now());
    final fileName = 'Worth_Report_$timestamp.pdf';

    if (Platform.isAndroid && !forcePrivateDirectory) {
      final downloadsDir = Directory('/storage/emulated/0/Download/Worth');
      try {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        final manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          await Permission.manageExternalStorage.request();
        }

        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }

        String filePath = '${downloadsDir.path}/$fileName';
        File file = File(filePath);

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

// ══════════════════════════════════════════════════════════════════════════════
// INTERNAL DATA MODELS
// ══════════════════════════════════════════════════════════════════════════════

class _Fonts {
  final pw.Font title;
  final pw.Font body;
  final pw.Font bold;
  _Fonts({required this.title, required this.body, required this.bold});
}

class _ReportData {
  final double cashAssets;
  final double invAssets;
  final double totalReceivables;
  final double totalAssetsComputed;
  final double creditDues;
  final double personDues;
  final double mtfBorrowed;
  final double totalLiabilitiesComputed;
  final double assetLiabilityRatio;
  final int wealthScore;
  final double totalIncomeThisMonth;
  final double totalExpenseThisMonth;
  final Map<String, double> expensesByCategory;
  final List<Snapshot> historicalSnaps;
  final double sipInvestedCapital;
  final double sipCurrentValuation;
  final double sipGrowth;
  final double sipConsistencyRate;
  final List<Map<String, dynamic>> sipDetails;

  _ReportData({
    required this.cashAssets,
    required this.invAssets,
    required this.totalReceivables,
    required this.totalAssetsComputed,
    required this.creditDues,
    required this.personDues,
    required this.mtfBorrowed,
    required this.totalLiabilitiesComputed,
    required this.assetLiabilityRatio,
    required this.wealthScore,
    required this.totalIncomeThisMonth,
    required this.totalExpenseThisMonth,
    required this.expensesByCategory,
    required this.historicalSnaps,
    required this.sipInvestedCapital,
    required this.sipCurrentValuation,
    required this.sipGrowth,
    required this.sipConsistencyRate,
    required this.sipDetails,
  });
}

class _SipOccurrence {
  final DateTime date;
  final bool isCompleted;
  _SipOccurrence({required this.date, required this.isCompleted});
}

// ══════════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTER: LINE CHART
// ══════════════════════════════════════════════════════════════════════════════

class LineChartPainter {
  final List<double> values;
  final List<String> labels;
  final PdfColor lineColor;
  final PdfColor areaColor;
  final PdfColor gridColor;
  final PdfColor dotColor;

  LineChartPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.areaColor,
    required this.gridColor,
    required this.dotColor,
  });

  void paint(PdfGraphics canvas, PdfPoint size) {
    if (values.isEmpty) return;

    final double width = size.x;
    final double height = size.y;
    const double padding = 10.0;

    final double maxVal = values.reduce((a, b) => a > b ? a : b);
    final double minVal = values.reduce((a, b) => a < b ? a : b);
    final double diff = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    // Draw horizontal grid lines
    canvas.setStrokeColor(gridColor);
    canvas.setLineWidth(0.3);
    for (int i = 0; i <= 4; i++) {
      final double y = padding + (height - 2 * padding) * (i / 4.0);
      canvas.drawLine(padding, y, width - padding, y);
    }
    canvas.strokePath();

    // Plot line
    final int count = values.length;
    final double stepX = (width - 2 * padding) / (count > 1 ? count - 1 : 1);

    canvas.setStrokeColor(lineColor);
    canvas.setLineWidth(2.0);

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

    // Draw dots
    canvas.setFillColor(dotColor);
    for (int i = 0; i < count; i++) {
      final double val = values[i];
      final double pct = (val - minVal) / diff;
      final double x = padding + i * stepX;
      final double y = padding + pct * (height - 2 * padding);

      canvas.drawEllipse(x, y, 2.5, 2.5);
      canvas.fillPath();
    }
  }
}
