
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';
import '../providers/mock_database.dart';
import '../../database/database.dart';
import '../calculation/liability_calculation_service.dart';

// ──────────────────────────────────────────────────────────────────────────────
// WORTH — PRIVATE WEALTH STATEMENT
// ──────────────────────────────────────────────────────────────────────────────
//
// Design Direction:
//   Light editorial aesthetic. Morgan Stanley · Apple · Notion.
//   Off-white pages, charcoal typography, single gold accent.
//   Generous white space. Strong typographic hierarchy.
//   No gradients. No glassmorphism. No dark backgrounds.
//
// Font Strategy:
//   Embedded Noto Sans TTF for guaranteed ₹ symbol rendering.
//   Loaded via rootBundle — zero runtime downloads.
//
// ──────────────────────────────────────────────────────────────────────────────

class PdfExportService {
  // ── Editorial Palette ────────────────────────────────────────────────────
  static final PdfColor pageBg       = PdfColor.fromHex('#FAFAFA');
  static final PdfColor white        = PdfColor.fromHex('#FFFFFF');
  static final PdfColor charcoal     = PdfColor.fromHex('#0A0A0A');
  static final PdfColor slate800     = PdfColor.fromHex('#1E293B');
  static final PdfColor slate600     = PdfColor.fromHex('#475569');
  static final PdfColor slate400     = PdfColor.fromHex('#94A3B8');
  static final PdfColor slate200     = PdfColor.fromHex('#E2E8F0');
  static final PdfColor slate100     = PdfColor.fromHex('#F1F5F9');
  static final PdfColor gold         = PdfColor.fromHex('#D4AF37');
  static final PdfColor goldDark     = PdfColor.fromHex('#B8860B');
  static final PdfColor positive     = PdfColor.fromHex('#16A34A');
  static final PdfColor negative     = PdfColor.fromHex('#DC2626');
  static final PdfColor info         = PdfColor.fromHex('#2563EB');

  // ── Main Entry Point ─────────────────────────────────────────────────────
  Future<List<int>> generateReportBytes(MockDatabaseState dbState) async {
    final pdf = pw.Document(
      title: 'Worth — Private Wealth Statement',
      author: 'Worth Wealth Management',
    );

    // Load embedded Noto Sans font — guaranteed ₹ support
    pw.Font fontRegular;
    pw.Font fontBold;

    try {
      final regularData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      fontRegular = pw.Font.ttf(regularData);
      fontBold = pw.Font.ttf(regularData); // Variable font — same file, bold simulated via TextStyle
    } catch (_) {
      // Absolute last resort fallback — should never happen with bundled assets
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    final fonts = _Fonts(title: fontBold, body: fontRegular, bold: fontBold);

    // Load logo
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/graphics/icons/logo_mark.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {}

    final currency = dbState.currency;
    final formatCompact = NumberFormat.currency(locale: 'en_IN', symbol: currency, decimalDigits: 0);
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy').format(now);
    final formattedDateTime = DateFormat('dd MMM yyyy, hh:mm a').format(now);

    // Pre-compute all data
    final reportData = _computeReportData(dbState, now);

    // ── BUILD PAGES ──────────────────────────────────────────────────────
    pdf.addPage(_buildCoverPage(fonts, logoImage, formatCompact, formattedDate, reportData));
    pdf.addPage(_buildExecutiveSummary(fonts, formatCompact, formattedDateTime, reportData, 2));
    pdf.addPage(_buildAssetAllocation(fonts, formatCompact, formattedDateTime, reportData, dbState, 3));
    pdf.addPage(_buildLiabilities(fonts, formatCompact, formattedDateTime, reportData, dbState, 4));
    pdf.addPage(_buildWealthEvolution(fonts, formatCompact, formattedDateTime, reportData, dbState, 5));
    pdf.addPage(_buildCashFlow(fonts, formatCompact, formattedDateTime, reportData, dbState, now, 6));
    pdf.addPage(_buildSipPerformance(fonts, formatCompact, formattedDateTime, reportData, dbState, now, 7));
    pdf.addPage(_buildInvestmentHoldings(fonts, formatCompact, formattedDateTime, reportData, dbState, now, 8));

    int nextPage = 9;
    if (dbState.ipoPools.isNotEmpty) {
      pdf.addPage(_buildIpoPool(fonts, formatCompact, formattedDateTime, dbState, nextPage));
      nextPage++;
    }

    pdf.addPage(_buildObservations(fonts, formatCompact, formattedDateTime, reportData, dbState, nextPage));

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
  // PAGE 1: COVER
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildCoverPage(_Fonts fonts, pw.MemoryImage? logoImage, NumberFormat format, String date, _ReportData data) {
    final netWorth = data.totalAssetsComputed - data.totalLiabilitiesComputed;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          width: double.infinity,
          height: double.infinity,
          color: white,
          padding: const pw.EdgeInsets.symmetric(horizontal: 56, vertical: 48),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Top bar: Logo + WORTH wordmark
              pw.Row(
                children: [
                  if (logoImage != null)
                    pw.Image(logoImage, width: 28, height: 28)
                  else
                    pw.Container(
                      width: 28,
                      height: 28,
                      decoration: pw.BoxDecoration(
                        color: charcoal,
                        shape: pw.BoxShape.circle,
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text('W', style: pw.TextStyle(font: fonts.bold, color: white, fontSize: 13)),
                    ),
                  pw.SizedBox(width: 10),
                  pw.Text('WORTH', style: pw.TextStyle(font: fonts.bold, fontSize: 16, color: charcoal, letterSpacing: 4.0)),
                ],
              ),

              pw.Spacer(flex: 4),

              // Main title block
              pw.Text(
                'Private',
                style: pw.TextStyle(font: fonts.body, fontSize: 44, color: slate400),
              ),
              pw.Text(
                'Wealth Statement',
                style: pw.TextStyle(font: fonts.bold, fontSize: 44, color: charcoal),
              ),

              pw.SizedBox(height: 20),

              // Gold rule
              pw.Container(width: 64, height: 3, color: gold),

              pw.SizedBox(height: 24),

              // Tagline
              pw.Text(
                'Your Complete Financial Reality',
                style: pw.TextStyle(font: fonts.body, fontSize: 12, color: slate400, letterSpacing: 0.5),
              ),

              pw.Spacer(flex: 2),

              // Net Worth — hero number
              pw.Text(
                'NET WORTH',
                style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: slate400, letterSpacing: 2.0),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                format.format(netWorth),
                style: pw.TextStyle(font: fonts.bold, fontSize: 52, color: charcoal),
              ),
              pw.SizedBox(height: 4),
              pw.Container(width: 200, height: 1.5, color: gold),

              pw.Spacer(flex: 3),

              // Footer metadata
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(top: 16),
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: slate200, width: 0.8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PREPARED FOR', style: pw.TextStyle(font: fonts.body, fontSize: 7, color: slate400, letterSpacing: 1.5)),
                        pw.SizedBox(height: 3),
                        pw.Text('Account Holder', style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: charcoal)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('DATE', style: pw.TextStyle(font: fonts.body, fontSize: 7, color: slate400, letterSpacing: 1.5)),
                        pw.SizedBox(height: 3),
                        pw.Text(date, style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: charcoal)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('CLASSIFICATION', style: pw.TextStyle(font: fonts.body, fontSize: 7, color: slate400, letterSpacing: 1.5)),
                        pw.SizedBox(height: 3),
                        pw.Text('CONFIDENTIAL', style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: gold)),
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

  // ════════════════════════════════════════════════════════════════════════════
  // PAGE 2: EXECUTIVE SUMMARY
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildExecutiveSummary(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, int pageNum) {
    final netWorth = data.totalAssetsComputed - data.totalLiabilitiesComputed;
    String healthStatus = 'STABLE';
    PdfColor healthColor = gold;
    if (data.wealthScore >= 80) {
      healthStatus = 'OUTSTANDING';
      healthColor = positive;
    } else if (data.wealthScore >= 50) {
      healthStatus = 'HEALTHY';
      healthColor = positive;
    } else if (data.wealthScore < 30) {
      healthStatus = 'VULNERABLE';
      healthColor = negative;
    }

    final surplus = data.totalIncomeThisMonth - data.totalExpenseThisMonth;
    final savingsRate = data.totalIncomeThisMonth > 0 ? (surplus / data.totalIncomeThisMonth * 100) : 0.0;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'Executive Summary'),

              pw.SizedBox(height: 32),

              // Three primary metrics
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildLargeMetric(fonts, 'Net Worth', format.format(netWorth), charcoal),
                  pw.SizedBox(width: 32),
                  _buildLargeMetric(fonts, 'Total Assets', format.format(data.totalAssetsComputed), positive),
                  pw.SizedBox(width: 32),
                  _buildLargeMetric(fonts, 'Total Liabilities', format.format(data.totalLiabilitiesComputed), negative),
                ],
              ),

              pw.SizedBox(height: 28),
              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 28),

              // Wealth Score + Leverage Index row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('WEALTH SCORE', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text('${data.wealthScore}', style: pw.TextStyle(font: fonts.bold, fontSize: 42, color: healthColor)),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 6),
                              child: pw.Text(' / 100', style: pw.TextStyle(font: fonts.body, fontSize: 14, color: slate400)),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: healthColor, width: 0.8),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(healthStatus, style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: healthColor, letterSpacing: 1.0)),
                        ),
                        pw.SizedBox(height: 12),
                        pw.Text(
                          'Composite score measuring financial security based on\nasset strength relative to outstanding obligations.',
                          style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate600, lineSpacing: 1.4),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 32),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('LEVERAGE INDEX', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                        pw.SizedBox(height: 10),
                        pw.Text('${data.assetLiabilityRatio.toStringAsFixed(2)}x', style: pw.TextStyle(font: fonts.bold, fontSize: 42, color: charcoal)),
                        pw.SizedBox(height: 8),
                        pw.Text('Asset-to-Liability Ratio', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate600)),
                        pw.SizedBox(height: 16),

                        // Minimal progress bar
                        _buildMinimalProgressBar(data.totalAssetsComputed, data.totalLiabilitiesComputed),
                        pw.SizedBox(height: 6),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Assets ${data.totalAssetsComputed > 0 ? ((data.totalAssetsComputed / (data.totalAssetsComputed + data.totalLiabilitiesComputed)) * 100).toStringAsFixed(0) : '100'}%',
                              style: pw.TextStyle(font: fonts.body, fontSize: 7, color: slate400),
                            ),
                            pw.Text(
                              'Liabilities ${data.totalLiabilitiesComputed > 0 ? ((data.totalLiabilitiesComputed / (data.totalAssetsComputed + data.totalLiabilitiesComputed)) * 100).toStringAsFixed(0) : '0'}%',
                              style: pw.TextStyle(font: fonts.body, fontSize: 7, color: slate400),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 28),
              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 28),

              // Secondary metrics row
              pw.Text('ADDITIONAL POSITIONS', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
              pw.SizedBox(height: 16),
              pw.Row(
                children: [
                  _buildCompactMetric(fonts, 'Receivables', format.format(data.totalReceivables)),
                  pw.SizedBox(width: 24),
                  _buildCompactMetric(fonts, 'Invested Capital', format.format(data.invAssets)),
                  pw.SizedBox(width: 24),
                  _buildCompactMetric(fonts, 'Cash Holdings', format.format(data.cashAssets)),
                  pw.SizedBox(width: 24),
                  _buildCompactMetric(fonts, 'Savings Rate', '${savingsRate.toStringAsFixed(1)}%'),
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
  // PAGE 3: ASSET ALLOCATION
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildAssetAllocation(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, int pageNum) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'Asset Allocation'),

              pw.SizedBox(height: 28),

              // Allocation breakdown
              pw.Text('PORTFOLIO COMPOSITION', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
              pw.SizedBox(height: 16),

              _buildEditorialBar(fonts, 'Investments', data.invAssets, data.totalAssetsComputed, charcoal, format),
              pw.SizedBox(height: 14),
              _buildEditorialBar(fonts, 'Cash & Cash Equivalents', data.cashAssets, data.totalAssetsComputed, slate600, format),
              pw.SizedBox(height: 14),
              _buildEditorialBar(fonts, 'Receivables & Lends', data.totalReceivables, data.totalAssetsComputed, gold, format),

              pw.SizedBox(height: 28),
              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 24),

              // Asset Register Table
              pw.Text('ASSET REGISTER', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
              pw.SizedBox(height: 14),
              _buildEditorialTable(
                fonts: fonts,
                headers: ['Asset Name', 'Classification', 'Capital Value', 'Share'],
                rows: [
                  ...dbState.investments.where((i) => i.isArchived == 0).map((i) {
                    final val = dbState.getInvestmentInvestedCapital(i.id);
                    final pct = data.totalAssetsComputed > 0 ? (val / data.totalAssetsComputed) * 100 : 0.0;
                    return [i.name, i.type.replaceAll('_', ' '), format.format(val), '${pct.toStringAsFixed(1)}%'];
                  }),
                  ...dbState.accounts.where((a) => a.isArchived == 0 && a.type != 'credit').map((a) {
                    final val = dbState.getAccountCashBalance(a.id);
                    final pct = data.totalAssetsComputed > 0 ? (val / data.totalAssetsComputed) * 100 : 0.0;
                    return [a.name, '${a.type} account', format.format(val), '${pct.toStringAsFixed(1)}%'];
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
  // PAGE 4: LIABILITIES
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildLiabilities(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, int pageNum) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'Debt & Liabilities'),

              pw.SizedBox(height: 28),

              // Debt composition
              pw.Text('DEBT COMPOSITION', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
              pw.SizedBox(height: 16),

              _buildEditorialBar(fonts, 'Credit Cards', data.creditDues, data.totalLiabilitiesComputed, negative, format),
              pw.SizedBox(height: 14),
              _buildEditorialBar(fonts, 'Personal & Peer Loans', data.personDues, data.totalLiabilitiesComputed, charcoal, format),
              pw.SizedBox(height: 14),
              _buildEditorialBar(fonts, 'Margin Trading (MTF)', data.mtfBorrowed, data.totalLiabilitiesComputed, slate600, format),

              pw.SizedBox(height: 28),
              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 24),

              // Liabilities Table
              pw.Text('LIABILITIES REGISTER', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
              pw.SizedBox(height: 14),
              _buildEditorialTable(
                fonts: fonts,
                headers: ['Lender / Card', 'Type', 'Balance Owed', 'Share'],
                rows: [
                  ...dbState.accounts.where((a) => a.isArchived == 0 && a.type == 'credit').map((a) {
                    final val = LiabilityCalculationService.calculateCreditCard(a, dbState.transactions, dbState.adjustments).finalBalance;
                    final pct = data.totalLiabilitiesComputed > 0 ? (val / data.totalLiabilitiesComputed) * 100 : 0.0;
                    return [a.name, 'Credit Card', format.format(val), '${pct.toStringAsFixed(1)}%'];
                  }),
                  ...dbState.people.where((p) {
                    if (p.isArchived != 0) return false;
                    final val = LiabilityCalculationService.calculatePeerLiability(p, dbState.transactions, dbState.adjustments).finalBalance;
                    return val > 0;
                  }).map((p) {
                    final val = LiabilityCalculationService.calculatePeerLiability(p, dbState.transactions, dbState.adjustments).finalBalance;
                    final pct = data.totalLiabilitiesComputed > 0 ? (val / data.totalLiabilitiesComputed) * 100 : 0.0;
                    String label = 'Personal Loan';
                    if (p.type == 'borrowing') {
                      label = 'Borrowing';
                    } else if (p.type == 'education_loan') {
                      label = 'Education Loan';
                    } else if (p.type == 'manual_liability') {
                      label = 'Manual Liability';
                    }
                    return [p.name, label, format.format(val), '${pct.toStringAsFixed(1)}%'];
                  }),
                  ...dbState.mtfPositions.where((m) => m.isClosed == 0 && m.deletedAt == null).map((m) {
                    final val = LiabilityCalculationService.calculateMtfPosition(m, dbState.transactions, DateTime.now()).finalBalance;
                    final pct = data.totalLiabilitiesComputed > 0 ? (val / data.totalLiabilitiesComputed) * 100 : 0.0;
                    return [m.instrument, 'MTF Position', format.format(val), '${pct.toStringAsFixed(1)}%'];
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
  // PAGE 5: WEALTH EVOLUTION
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
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'Wealth Evolution'),

              pw.SizedBox(height: 28),

              // Line Chart
              if (values.isNotEmpty) ...[
                pw.Text('NET WORTH TREND', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                pw.SizedBox(height: 16),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: white,
                    border: pw.Border.all(color: slate200, width: 0.5),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.SizedBox(
                        height: 160,
                        child: pw.CustomPaint(
                          painter: _LightLineChartPainter(
                            values: values,
                            labels: labels,
                            lineColor: gold,
                            areaColor: PdfColor(gold.red, gold.green, gold.blue, 0.08),
                            gridColor: slate200,
                            dotColor: gold,
                          ).paint,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: labels.map((l) => pw.Text(l, style: pw.TextStyle(font: fonts.body, fontSize: 7, color: slate400))).toList(),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),
              ],

              // Snapshots Table
              pw.Text('HISTORICAL SNAPSHOTS', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
              pw.SizedBox(height: 14),
              _buildEditorialTable(
                fonts: fonts,
                headers: ['Date', 'Total Assets', 'Liabilities', 'Net Worth'],
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
  // PAGE 6: CASH FLOW
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildCashFlow(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, DateTime now, int pageNum) {
    final surplus = data.totalIncomeThisMonth - data.totalExpenseThisMonth;

    final recentTxs = dbState.transactions.where((t) => t.voidedTransactionId == null).toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final displayTxs = recentTxs.take(12).toList();

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'Cash Flow & Transactions'),

              pw.SizedBox(height: 28),

              // Cash flow metrics
              pw.Row(
                children: [
                  _buildLargeMetric(fonts, 'Income', format.format(data.totalIncomeThisMonth), positive),
                  pw.SizedBox(width: 32),
                  _buildLargeMetric(fonts, 'Expenses', format.format(data.totalExpenseThisMonth), negative),
                  pw.SizedBox(width: 32),
                  _buildLargeMetric(fonts, 'Net Surplus', format.format(surplus), surplus >= 0 ? positive : negative),
                ],
              ),

              pw.SizedBox(height: 24),

              // Expense category breakdown
              if (data.expensesByCategory.isNotEmpty) ...[
                pw.Container(height: 0.5, color: slate200),
                pw.SizedBox(height: 20),
                pw.Text('EXPENSE CATEGORIES', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                pw.SizedBox(height: 14),
                ..._buildExpenseCategoryBars(fonts, data, format),
                pw.SizedBox(height: 20),
              ],

              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 20),

              // Transaction log
              pw.Text('RECENT ACTIVITY', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
              pw.SizedBox(height: 14),
              _buildEditorialTable(
                fonts: fonts,
                headers: ['Date', 'Description', 'Type', 'Amount'],
                rows: displayTxs.map((t) {
                  final dateStr = DateFormat('dd MMM').format(t.transactionDate);
                  final isNegative = ['expense', 'lend_money', 'repay_money', 'investment_buy'].contains(t.type);
                  final prefix = isNegative ? '-' : '+';
                  return [
                    dateStr,
                    t.notes ?? t.type.replaceAll('_', ' '),
                    t.type.replaceAll('_', ' '),
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
  // PAGE 7: SIP PERFORMANCE
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildSipPerformance(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, DateTime now, int pageNum) {
    String consistencyLabel = 'CONSISTENT';
    PdfColor consistencyColor = positive;
    if (data.sipConsistencyRate < 50) {
      consistencyLabel = 'IRREGULAR';
      consistencyColor = negative;
    } else if (data.sipConsistencyRate < 80) {
      consistencyLabel = 'MODERATE';
      consistencyColor = gold;
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'SIP Performance'),

              pw.SizedBox(height: 28),

              // SIP metrics
              pw.Row(
                children: [
                  _buildLargeMetric(fonts, 'SIP Invested', format.format(data.sipInvestedCapital), charcoal),
                  pw.SizedBox(width: 32),
                  _buildLargeMetric(fonts, 'Current Value', format.format(data.sipCurrentValuation), positive),
                  pw.SizedBox(width: 32),
                  _buildLargeMetric(fonts, 'Growth', '${data.sipGrowth >= 0 ? '+' : ''}${format.format(data.sipGrowth)}', data.sipGrowth >= 0 ? positive : negative),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 24),

              // Consistency
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CONSISTENCY RATE', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                      pw.SizedBox(height: 8),
                      pw.Text('${data.sipConsistencyRate.toStringAsFixed(0)}%', style: pw.TextStyle(font: fonts.bold, fontSize: 28, color: consistencyColor)),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: consistencyColor, width: 0.8),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(consistencyLabel, style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: consistencyColor, letterSpacing: 1.0)),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 24),

              // SIP details table
              if (data.sipDetails.isNotEmpty) ...[
                pw.Text('INDIVIDUAL SIP BREAKDOWN', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                pw.SizedBox(height: 14),
                _buildEditorialTable(
                  fonts: fonts,
                  headers: ['SIP Name', 'Invested', 'Current Value', 'Return'],
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
                pw.Container(
                  padding: const pw.EdgeInsets.all(24),
                  decoration: pw.BoxDecoration(
                    color: white,
                    border: pw.Border.all(color: slate200, width: 0.5),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text(
                    'No active SIP plans. Systematic investment plans are the backbone of disciplined wealth creation.',
                    style: pw.TextStyle(font: fonts.body, fontSize: 10, color: slate400),
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
  // PAGE 8: INVESTMENT HOLDINGS
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
    holdingData.sort((a, b) => (b['days'] as int).compareTo(a['days'] as int));

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'Investment Holdings'),

              pw.SizedBox(height: 28),

              // Holding period metrics
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('AVERAGE HOLDING PERIOD', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                        pw.SizedBox(height: 8),
                        pw.Text('${avgHolding.toStringAsFixed(0)} Days', style: pw.TextStyle(font: fonts.bold, fontSize: 28, color: charcoal)),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ACTIVE POSITIONS', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                        pw.SizedBox(height: 8),
                        pw.Text('${activeInvestments.length}', style: pw.TextStyle(font: fonts.bold, fontSize: 28, color: charcoal)),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 24),

              // Holdings table
              if (holdingData.isNotEmpty) ...[
                pw.Text('POSITION-WISE ANALYSIS', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
                pw.SizedBox(height: 14),
                _buildEditorialTable(
                  fonts: fonts,
                  headers: ['Investment', 'Purchase Date', 'Capital Value', 'Holding'],
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
                pw.Container(
                  padding: const pw.EdgeInsets.all(24),
                  decoration: pw.BoxDecoration(
                    color: white,
                    border: pw.Border.all(color: slate200, width: 0.5),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Text('No active investments found.', style: pw.TextStyle(font: fonts.body, fontSize: 10, color: slate400)),
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
  // PAGE 9: IPO POOL (CONDITIONAL)
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildIpoPool(_Fonts fonts, NumberFormat format, String dateTime, MockDatabaseState dbState, int pageNum) {
    final pool = dbState.ipoPools.first;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'IPO Pool Report'),

              pw.SizedBox(height: 28),

              // Pool details
              pw.Text(pool.name, style: pw.TextStyle(font: fonts.bold, fontSize: 18, color: charcoal)),
              pw.SizedBox(height: 16),

              _buildKeyValueRow(fonts, 'Listing Date', DateFormat('dd MMM yyyy').format(pool.createdAt)),
              pw.SizedBox(height: 8),
              _buildKeyValueRow(fonts, 'Total Applied Capital', format.format(pool.totalPoolAmount)),
              pw.SizedBox(height: 8),
              _buildKeyValueRow(fonts, 'Settlement Status', pool.status.toUpperCase(), valueColor: pool.status == 'allotted' ? positive : gold),

              pw.SizedBox(height: 28),
              pw.Container(height: 0.5, color: slate200),
              pw.SizedBox(height: 24),

              // Contributors table
              pw.Text('CONTRIBUTOR ALLOCATION', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.5)),
              pw.SizedBox(height: 14),
              _buildEditorialTable(
                fonts: fonts,
                headers: ['Contributor', 'Capital Injected', 'Refunded', 'Ownership'],
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
  // PAGE 10: OBSERVATIONS & CLOSING
  // ════════════════════════════════════════════════════════════════════════════

  pw.Page _buildObservations(_Fonts fonts, NumberFormat format, String dateTime, _ReportData data, MockDatabaseState dbState, int pageNum) {
    final netWorth = data.totalAssetsComputed - data.totalLiabilitiesComputed;
    final surplus = data.totalIncomeThisMonth - data.totalExpenseThisMonth;
    final savingsRate = data.totalIncomeThisMonth > 0 ? (surplus / data.totalIncomeThisMonth * 100) : 0.0;

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (context) {
        return pw.Container(
          color: pageBg,
          padding: const pw.EdgeInsets.symmetric(horizontal: 48, vertical: 40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildPageHeader(fonts, 'Observations'),

              pw.SizedBox(height: 28),

              // Insight 1
              _buildInsightBlock(
                fonts: fonts,
                title: 'Portfolio Position',
                content: 'Net worth stands at ${format.format(netWorth)}. Capital assets total ${format.format(data.totalAssetsComputed)} against outstanding liabilities of ${format.format(data.totalLiabilitiesComputed)}. Your Wealth Score of ${data.wealthScore}/100 places your financial position in the ${data.wealthScore >= 80 ? 'outstanding' : data.wealthScore >= 50 ? 'healthy' : data.wealthScore >= 30 ? 'stable' : 'vulnerable'} zone.',
              ),
              pw.SizedBox(height: 20),

              // Insight 2
              if (dbState.debtFundedAssets > 0)
                _buildInsightBlock(
                  fonts: fonts,
                  title: 'Leverage Exposure',
                  content: 'Portfolio contains ${format.format(dbState.debtFundedAssets)} of debt-funded assets, representing ${((dbState.debtFundedAssets / (data.totalAssetsComputed > 0 ? data.totalAssetsComputed : 1)) * 100).toStringAsFixed(1)}% of total assets. Current asset-to-liability ratio stands at ${data.assetLiabilityRatio.toStringAsFixed(2)}x.',
                )
              else
                _buildInsightBlock(
                  fonts: fonts,
                  title: 'Leverage Exposure',
                  content: 'Asset portfolio is entirely self-funded with zero debt-funded positions. Exceptional financial stability with an asset-to-liability ratio of ${data.assetLiabilityRatio.toStringAsFixed(2)}x.',
                ),
              pw.SizedBox(height: 20),

              // Insight 3
              _buildInsightBlock(
                fonts: fonts,
                title: 'Systematic Wealth Creation',
                content: data.sipDetails.isNotEmpty
                    ? '${data.sipDetails.length} active SIP plan${data.sipDetails.length > 1 ? 's' : ''} with a consistency rate of ${data.sipConsistencyRate.toStringAsFixed(0)}%. Total SIP invested capital: ${format.format(data.sipInvestedCapital)}, current valuation: ${format.format(data.sipCurrentValuation)} (${data.sipGrowth >= 0 ? '+' : ''}${format.format(data.sipGrowth)}).'
                    : 'No active SIP plans detected. Systematic investment plans compound returns over time and are recommended for disciplined wealth creation.',
              ),
              pw.SizedBox(height: 20),

              // Insight 4
              _buildInsightBlock(
                fonts: fonts,
                title: 'Cash Flow Health',
                content: data.totalIncomeThisMonth > 0
                    ? 'Monthly income of ${format.format(data.totalIncomeThisMonth)} against expenses of ${format.format(data.totalExpenseThisMonth)} yields a ${surplus >= 0 ? 'surplus' : 'deficit'} of ${format.format(surplus.abs())} (savings rate: ${savingsRate.toStringAsFixed(1)}%). ${savingsRate >= 30 ? 'Excellent savings discipline.' : savingsRate >= 10 ? 'Moderate savings — consider optimizing discretionary spending.' : 'Low savings rate — review expense categories for optimization.'}'
                    : 'No income recorded this month. Track all income sources for comprehensive cash flow intelligence.',
              ),

              pw.Spacer(),

              // End of report
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(top: 20),
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: slate200, width: 0.8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Container(width: 40, height: 2, color: gold),
                    pw.SizedBox(height: 12),
                    pw.Text('END OF REPORT', style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: slate400, letterSpacing: 2.5)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated by Worth — Your Complete Financial Reality',
                      style: pw.TextStyle(font: fonts.body, fontSize: 8, color: slate400),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),
              _buildPageFooter(fonts, dateTime, pageNum),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // SHARED EDITORIAL COMPONENTS
  // ════════════════════════════════════════════════════════════════════════════

  pw.Widget _buildPageHeader(_Fonts fonts, String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('WORTH', style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: slate400, letterSpacing: 3.0)),
            pw.Container(width: 24, height: 1.5, color: gold),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Text(title, style: pw.TextStyle(font: fonts.bold, fontSize: 24, color: charcoal)),
        pw.SizedBox(height: 6),
        pw.Container(width: 48, height: 2, color: gold),
      ],
    );
  }

  pw.Widget _buildPageFooter(_Fonts fonts, String dateTime, int pageNum) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: slate200, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Worth — Private Wealth Statement', style: pw.TextStyle(font: fonts.body, fontSize: 7, color: slate400)),
          pw.Text('Confidential  ·  $dateTime', style: pw.TextStyle(font: fonts.body, fontSize: 7, color: slate400)),
          pw.Text('$pageNum', style: pw.TextStyle(font: fonts.bold, fontSize: 7, color: slate400)),
        ],
      ),
    );
  }

  pw.Widget _buildLargeMetric(_Fonts fonts, String label, String value, PdfColor valueColor) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label.toUpperCase(), style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate400, letterSpacing: 1.0)),
          pw.SizedBox(height: 8),
          pw.Text(value, style: pw.TextStyle(font: fonts.bold, fontSize: 18, color: valueColor)),
        ],
      ),
    );
  }

  pw.Widget _buildCompactMetric(_Fonts fonts, String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(font: fonts.body, fontSize: 8, color: slate400)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(font: fonts.bold, fontSize: 13, color: charcoal)),
        ],
      ),
    );
  }

  pw.Widget _buildMinimalProgressBar(double assets, double liabilities) {
    final total = assets + liabilities;
    final assetPct = total > 0 ? assets / total : 1.0;

    return pw.Container(
      height: 4,
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: slate200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: (assetPct * 100).toInt().clamp(1, 100),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: charcoal,
                borderRadius: const pw.BorderRadius.horizontal(left: pw.Radius.circular(2)),
              ),
            ),
          ),
          if (liabilities > 0)
            pw.Expanded(
              flex: ((1.0 - assetPct) * 100).toInt().clamp(1, 100),
              child: pw.Container(),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildEditorialBar(_Fonts fonts, String label, double amount, double total, PdfColor color, NumberFormat format) {
    final pct = total > 0 ? (amount / total) : 0.0;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: pw.TextStyle(font: fonts.bold, fontSize: 10, color: slate800)),
            pw.Text('${format.format(amount)}  (${(pct * 100).toStringAsFixed(1)}%)', style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate600)),
          ],
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          height: 4,
          width: double.infinity,
          decoration: pw.BoxDecoration(
            color: slate100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                width: (pct * 460).clamp(0, 460),
                decoration: pw.BoxDecoration(
                  color: color,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _buildExpenseCategoryBars(_Fonts fonts, _ReportData data, NumberFormat format) {
    final sortedEntries = data.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(6).map((e) {
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 10),
        child: _buildEditorialBar(fonts, e.key, e.value, data.totalExpenseThisMonth, slate600, format),
      );
    }).toList();
  }

  pw.Widget _buildEditorialTable({required _Fonts fonts, required List<String> headers, required List<List<String>> rows}) {
    return pw.Table(
      border: pw.TableBorder(
        horizontalInside: pw.BorderSide(color: slate200, width: 0.4),
        bottom: pw.BorderSide(color: slate200, width: 0.4),
      ),
      columnWidths: {
        for (int i = 0; i < headers.length; i++)
          i: i == 0 ? const pw.FlexColumnWidth(3) : const pw.FlexColumnWidth(2),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: charcoal, width: 1.0)),
          ),
          children: headers.map((h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: pw.Text(h.toUpperCase(), style: pw.TextStyle(font: fonts.bold, fontSize: 7, color: slate400, letterSpacing: 0.5)),
          )).toList(),
        ),
        // Data rows
        ...rows.map((row) => pw.TableRow(
          children: row.asMap().entries.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 4),
            child: pw.Text(
              e.value,
              style: pw.TextStyle(
                font: e.key == 0 ? fonts.bold : fonts.body,
                fontSize: 9,
                color: e.key == 0 ? slate800 : slate600,
              ),
              maxLines: 1,
            ),
          )).toList(),
        )),
      ],
    );
  }

  pw.Widget _buildInsightBlock({required _Fonts fonts, required String title, required String content}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(width: 3, height: 14, color: gold),
            pw.SizedBox(width: 10),
            pw.Text(title.toUpperCase(), style: pw.TextStyle(font: fonts.bold, fontSize: 9, color: charcoal, letterSpacing: 1.0)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 13),
          child: pw.Text(content, style: pw.TextStyle(font: fonts.body, fontSize: 9, color: slate600, lineSpacing: 1.5)),
        ),
      ],
    );
  }

  pw.Widget _buildKeyValueRow(_Fonts fonts, String key, String value, {PdfColor? valueColor}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(key, style: pw.TextStyle(font: fonts.body, fontSize: 10, color: slate400)),
        pw.Text(value, style: pw.TextStyle(font: fonts.bold, fontSize: 11, color: valueColor ?? charcoal)),
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
    final fileName = 'Worth_Statement_$timestamp.pdf';

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
          filePath = '${downloadsDir.path}/Worth_Statement_${timestamp}_$counter.pdf';
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
        filePath = '${backupWorthDir.path}/Worth_Statement_${timestamp}_$counter.pdf';
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
// LIGHT THEME LINE CHART PAINTER
// ══════════════════════════════════════════════════════════════════════════════

class _LightLineChartPainter {
  final List<double> values;
  final List<String> labels;
  final PdfColor lineColor;
  final PdfColor areaColor;
  final PdfColor gridColor;
  final PdfColor dotColor;

  _LightLineChartPainter({
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
