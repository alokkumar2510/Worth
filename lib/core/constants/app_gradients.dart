import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Worth Premium Gradient Library
/// All reusable gradient definitions for the design system
class AppGradients {
  AppGradients._();

  // ─── Primary Violet Gradients ────────────────────────────────────────────────
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B6BFF), Color(0xFF7B3FF2), Color(0xFF5A2DB8)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9B6BFF), Color(0xFF7B3FF2)],
  );

  static const LinearGradient primarySubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x337B3FF2), Color(0x1A5A2DB8)],
  );

  // ─── Orange Accent Gradients ─────────────────────────────────────────────────
  static const LinearGradient orange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF8C5A), Color(0xFFFF6B35), Color(0xFFE04D15)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient orangeSubtle = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FF6B35), Color(0x1AE04D15)],
  );

  // ─── Glass Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient glass = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1EFFFFFF), Color(0x08FFFFFF), Color(0x0AFFFFFF)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient glassBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x2EFFFFFF), Color(0x08FFFFFF), Color(0x187B3FF2), Color(0x04FFFFFF)],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient glassBorderOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x2EFF6B35), Color(0x08FFFFFF), Color(0x14FF6B35), Color(0x04FFFFFF)],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  // ─── Card Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D0B18), Color(0xFF13101F)],
  );

  static const LinearGradient cardHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF13101F), Color(0xFF1A1728), Color(0xFF0D0B18)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardViolet = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1030), Color(0xFF12092A), Color(0xFF0D0B18)],
    stops: [0.0, 0.5, 1.0],
  );

  // ─── Background Mesh Blobs ───────────────────────────────────────────────────
  // Used by WorthBackground painter blobs
  static const Color meshViolet   = Color(0x387B3FF2); // Top-right blob
  static const Color meshOrange   = Color(0x2EFF6B35); // Bottom-left blob
  static const Color meshIndigo   = Color(0x265A2DB8); // Center blob
  static const Color meshLavender = Color(0x1EC084FC); // Bottom-right blob

  // ─── Chart Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient chartFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x4D7B3FF2), Color(0x007B3FF2)],
  );

  static const LinearGradient chartFillOrange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x4DFF6B35), Color(0x00FF6B35)],
  );

  static const LinearGradient chartFillGreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x4D10B981), Color(0x0010B981)],
  );

  // ─── Status Gradients ────────────────────────────────────────────────────────
  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient danger = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  // ─── Shimmer Gradient ────────────────────────────────────────────────────────
  static const LinearGradient shimmer = LinearGradient(
    colors: [Color(0xFF13101F), Color(0xFF1E1835), Color(0xFF13101F)],
    stops: [0.0, 0.5, 1.0],
  );

  // ─── Navigation Bar ──────────────────────────────────────────────────────────
  static const LinearGradient navBar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xE60D0B18), Color(0xF20D0B18)],
  );

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  /// Vertical fade-to-transparent overlay for cards
  static LinearGradient fadeDown({Color? color, double opacity = 0.8}) =>
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, (color ?? AppColors.darkBackground).withOpacity(opacity)],
      );

  static LinearGradient fadeUp({Color? color, double opacity = 0.8}) =>
      LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Colors.transparent, (color ?? AppColors.darkBackground).withOpacity(opacity)],
      );
}
