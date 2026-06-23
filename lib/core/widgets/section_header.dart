import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';

/// Premium section header with accent dot, label, and optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? accentColor;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.showDivider = false,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.orange;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Accent dot
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 8, top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [accent, accent.withOpacity(0.5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              // Title
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.grey400,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              // Action
              if (actionLabel != null && onAction != null)
                GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.orangeGlass,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.orange.withOpacity(0.25)),
                    ),
                    child: Text(
                      actionLabel!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text(
                subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.grey600,
                  height: 1.4,
                ),
              ),
            ),
          ],

          if (showDivider) ...[
            const SizedBox(height: 10),
            Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.glassBorder, Colors.transparent],
                  stops: [0.0, 0.8],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
