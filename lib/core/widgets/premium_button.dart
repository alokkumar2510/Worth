import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_spacing.dart';

/// Premium gradient-filled button variants for Worth
enum PremiumButtonVariant { primary, orange, glass, ghost, danger }

class PremiumButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const PremiumButton({
    required this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.variant = PremiumButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.fontSize,
    this.padding,
    super.key,
  });

  const PremiumButton.primary({
    required this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.fontSize,
    this.padding,
    super.key,
  }) : variant = PremiumButtonVariant.primary;

  const PremiumButton.orange({
    required this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.fontSize,
    this.padding,
    super.key,
  }) : variant = PremiumButtonVariant.orange;

  const PremiumButton.glass({
    required this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.fontSize,
    this.padding,
    super.key,
  }) : variant = PremiumButtonVariant.glass;

  const PremiumButton.ghost({
    required this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.fontSize,
    this.padding,
    super.key,
  }) : variant = PremiumButtonVariant.ghost;

  const PremiumButton.danger({
    required this.label,
    this.icon,
    this.iconWidget,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.fontSize,
    this.padding,
    super.key,
  }) : variant = PremiumButtonVariant.danger;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) { if (widget.onPressed != null) _ctrl.forward(); }
  void _onTapUp(_)   { _ctrl.reverse(); }
  void _onCancel()   { _ctrl.reverse(); }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.isLoading;
    final h = widget.height ?? 52.0;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onCancel,
      onTap: disabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          opacity: disabled ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: _buildButton(h),
        ),
      ),
    );
  }

  Widget _buildButton(double h) {
    switch (widget.variant) {
      case PremiumButtonVariant.primary:
        return _gradientButton(h, AppGradients.primary, AppColors.violetShadow);
      case PremiumButtonVariant.orange:
        return _gradientButton(h, AppGradients.orange, AppColors.orangeShadow);
      case PremiumButtonVariant.danger:
        return _gradientButton(h, AppGradients.danger, AppColors.darkDanger.withOpacity(0.4));
      case PremiumButtonVariant.glass:
        return _glassButton(h);
      case PremiumButtonVariant.ghost:
        return _ghostButton(h);
    }
  }

  Widget _gradientButton(double h, LinearGradient gradient, Color glowColor) {
    return Container(
      height: h,
      width: widget.isFullWidth ? double.infinity : null,
      padding: widget.padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buttonContent(Colors.white),
    );
  }

  Widget _glassButton(double h) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: h,
          width: widget.isFullWidth ? double.infinity : null,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: AppColors.glassSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: _buttonContent(AppColors.darkPrimary),
        ),
      ),
    );
  }

  Widget _ghostButton(double h) {
    return Container(
      height: h,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: _buttonContent(AppColors.grey400),
    );
  }

  Widget _buttonContent(Color textColor) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: textColor,
          ),
        ),
      );
    }

    final iconWidget = widget.iconWidget ??
        (widget.icon != null ? Icon(widget.icon, size: 18, color: textColor) : null);

    return Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconWidget != null) ...[
          iconWidget,
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.fontSize ?? 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
