import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'glass_card.dart';

class CalculationAuditPanel extends StatefulWidget {
  final String title;
  final String formula;
  final Map<String, String> inputs;
  final String output;
  final List<String> steps;

  const CalculationAuditPanel({
    Key? key,
    required this.title,
    required this.formula,
    required this.inputs,
    required this.output,
    required this.steps,
  }) : super(key: key);

  @override
  State<CalculationAuditPanel> createState() => _CalculationAuditPanelState();
}

class _CalculationAuditPanelState extends State<CalculationAuditPanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_outlined, color: AppColors.darkPrimary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.grey500,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              const Divider(color: AppColors.glassBorder, height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Formula Section
                    Text(
                      'FORMULA USED',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        widget.formula,
                        style: GoogleFonts.shareTechMono(
                          color: const Color(0xFF00FFCC),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Inputs Section
                    Text(
                      'INPUT VALUES',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...widget.inputs.entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  entry.key,
                                  style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                                ),
                              Text(
                                entry.value,
                                style: GoogleFonts.shareTechMono(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 14),

                    // Output Section
                    Text(
                      'OUTPUT VALUE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Result:',
                          style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                        ),
                        Text(
                          widget.output,
                          style: GoogleFonts.outfit(
                            color: AppColors.darkPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Step-by-Step Breakdown Section
                    Text(
                      'CALCULATION BREAKDOWN',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...widget.steps.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final step = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2, right: 8),
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: AppColors.glassBorder,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$idx',
                                style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                step,
                                style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
