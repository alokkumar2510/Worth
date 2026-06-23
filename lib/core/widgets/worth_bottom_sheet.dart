import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';


/// Reusable premium bottom sheet for Worth
class WorthBottomSheet extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget body;
  final Widget? footer;
  final IconData? titleIcon;
  final Color? accentColor;
  final bool showHandle;
  final bool isScrollable;

  const WorthBottomSheet({
    required this.body,
    this.title,
    this.subtitle,
    this.footer,
    this.titleIcon,
    this.accentColor,
    this.showHandle = true,
    this.isScrollable = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.darkPrimary;
    final maxH = MediaQuery.of(context).size.height * 0.92;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusXxl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxH),
          decoration: BoxDecoration(
            color: AppColors.layer2.withOpacity(0.97),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXxl),
            ),
            border: const Border(
              top: BorderSide(color: AppColors.glassBorder),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, -8),
              ),
              const BoxShadow(
                color: AppColors.deepShadow,
                blurRadius: 48,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle
              if (showHandle)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

              // ── Header
              if (title != null)
                _SheetHeader(
                  title: title!,
                  subtitle: subtitle,
                  titleIcon: titleIcon,
                  accent: accent,
                ),

              // ── Body
              if (isScrollable)
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      0,
                      AppSpacing.screenPadding,
                      AppSpacing.lg,
                    ),
                    child: body,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    0,
                    AppSpacing.screenPadding,
                    AppSpacing.lg,
                  ),
                  child: body,
                ),

              // ── Footer
              if (footer != null) ...[
                Builder(
                  builder: (ctx) => Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.screenPadding,
                      AppSpacing.sm,
                      AppSpacing.screenPadding,
                      AppSpacing.md + MediaQuery.of(ctx).padding.bottom,
                    ),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                    child: footer!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? titleIcon;
  final Color accent;

  const _SheetHeader({
    required this.title,
    required this.accent,
    this.subtitle,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      child: Row(
        children: [
          if (titleIcon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withOpacity(0.25)),
              ),
              child: Icon(titleIcon, color: accent, size: 18),
            ),
            const SizedBox(width: 14),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
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
        ],
      ),
    );
  }
}

/// Show a WorthBottomSheet with correct settings
Future<T?> showWorthSheet<T>({
  required BuildContext context,
  required WorthBottomSheet sheet,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: sheet,
    ),
  );
}
