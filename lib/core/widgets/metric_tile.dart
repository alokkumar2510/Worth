import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_spacing.dart';

/// Reusable financial metric tile — large number + label + trend indicator
class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final LinearGradient? accentGradient;
  final String? trend;      // e.g. "+12.4%" or "-3.2%"
  final bool isPositive;    // controls trend color
  final VoidCallback? onTap;
  final bool isCompact;

  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor = AppColors.darkPrimary,
    this.accentGradient,
    this.trend,
    this.isPositive = true,
    this.onTap,
    this.isCompact = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = accentGradient ??
        LinearGradient(colors: [accentColor, accentColor.withOpacity(0.6)]);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isCompact ? 14 : 18),
        decoration: BoxDecoration(
          color: AppColors.layer1,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge + trend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(isCompact ? 8 : 10),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: isCompact ? 16 : 18),
                ),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? AppColors.successGlass
                          : AppColors.dangerGlass,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 10,
                          color: isPositive
                              ? AppColors.darkSuccess
                              : AppColors.darkDanger,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          trend!.replaceAll('+', '').replaceAll('-', ''),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isPositive
                                ? AppColors.darkSuccess
                                : AppColors.darkDanger,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            SizedBox(height: isCompact ? 10 : 14),

            // Value
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: isCompact ? 16 : 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkText,
                letterSpacing: -0.5,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isCompact ? 10 : 11,
                fontWeight: FontWeight.w600,
                color: AppColors.grey500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
