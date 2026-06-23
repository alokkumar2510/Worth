import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_spacing.dart';

/// Reusable premium glass dialog for Worth
/// Replaces plain AlertDialog throughout the app with a cinematic experience
class WorthDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final IconData? titleIcon;
  final Color? accentColor;
  final bool isDangerous;

  const WorthDialog({
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.titleIcon,
    this.accentColor,
    this.isDangerous = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDangerous
        ? AppColors.darkDanger
        : (accentColor ?? AppColors.darkPrimary);
    final accentGrad = isDangerous ? AppGradients.danger : AppGradients.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: AppColors.layer2.withOpacity(0.95),
                borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.15),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.deepShadow,
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Accent top strip + title
                  _DialogHeader(
                    title: title,
                    subtitle: subtitle,
                    titleIcon: titleIcon,
                    accent: accent,
                    accentGrad: accentGrad,
                  ),

                  // ── Body content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: body,
                    ),
                  ),

                  // ── Actions
                  if (actions != null && actions!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      decoration: const BoxDecoration(
                        color: AppColors.layer3,
                        border: Border(
                          top: BorderSide(color: AppColors.glassBorder),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(AppSpacing.radiusHero),
                          bottomRight: Radius.circular(AppSpacing.radiusHero),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions!
                            .map((w) => Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: w,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final Color accent;
  final LinearGradient accentGrad;

  const _DialogHeader({
    required this.title,
    required this.accent,
    required this.accentGrad,
    this.subtitle,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.12), Colors.transparent],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusHero),
          topRight: Radius.circular(AppSpacing.radiusHero),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: Row(
        children: [
          if (titleIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: accentGrad,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(titleIcon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Show a WorthDialog with proper routing
Future<T?> showWorthDialog<T>({
  required BuildContext context,
  required WorthDialog dialog,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.75),
    builder: (_) => dialog,
  );
}
