import 'package:flutter/material.dart';

/// Worth Premium Design System — Color Palette
/// Deep luxury fintech: obsidian base + electric violet + vivid orange
class AppColors {
  AppColors._();

  // ─── Background Layers ─────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF06050C); // Deep obsidian void
  static const Color layer1         = Color(0xFF0D0B18); // Primary card surface
  static const Color layer2         = Color(0xFF13101F); // Grouped containers
  static const Color layer3         = Color(0xFF1A1728); // Elevated modals

  // ─── Glass Surfaces ────────────────────────────────────────────────────────
  static const Color glassSurface   = Color(0x0AFFFFFF); // 4% white frost
  static const Color glassBorder    = Color(0x14FFFFFF); // 8% white border
  static const Color glassHighlight = Color(0x1AFFFFFF); // 10% top sheen
  static const Color darkCard       = Color(0xFF0D0B18); // Alias layer1
  static const Color darkCardBorder = Color(0x14FFFFFF); // Alias glassBorder

  // ─── Primary — Electric Violet ─────────────────────────────────────────────
  static const Color darkPrimary      = Color(0xFF7B3FF2); // Electric violet
  static const Color primaryLight     = Color(0xFF9B6BFF); // Lighter violet
  static const Color primaryDark      = Color(0xFF5A2DB8); // Deep violet
  static const Color glow             = Color(0xFFC084FC); // Soft lavender glow
  static const Color accentGlow       = Color(0x267B3FF2); // 15% violet overlay
  static const Color primaryGlass     = Color(0x1A7B3FF2); // 10% violet glass
  static const Color darkSecondary    = Color(0xFFC084FC); // Lavender accent

  // ─── Secondary — Vivid Orange ──────────────────────────────────────────────
  static const Color orange           = Color(0xFFFF6B35); // Primary orange CTA
  static const Color orangeLight      = Color(0xFFFF8C5A); // Soft orange
  static const Color orangeDark       = Color(0xFFE04D15); // Deep orange
  static const Color orangeGlow       = Color(0x26FF6B35); // 15% orange overlay
  static const Color orangeGlass      = Color(0x1AFF6B35); // 10% orange glass

  // ─── Typography ────────────────────────────────────────────────────────────
  static const Color darkText  = Color(0xFFF8FAFC); // Near-white primary text
  static const Color grey400   = Color(0xFF94A3B8); // Muted secondary text
  static const Color grey500   = Color(0xFF64748B); // Placeholder/hint text
  static const Color grey600   = Color(0xFF475569); // Disabled text
  static const Color grey700   = Color(0xFF334155); // Subtle dividers
  static const Color grey800   = Color(0xFF1E293B); // Very subtle borders

  // ─── Status ────────────────────────────────────────────────────────────────
  static const Color darkSuccess  = Color(0xFF10B981); // Emerald green
  static const Color darkWarning  = Color(0xFFF59E0B); // Amber
  static const Color darkDanger   = Color(0xFFEF4444); // Coral red
  static const Color successGlass = Color(0x1A10B981);
  static const Color dangerGlass  = Color(0x1AEF4444);
  static const Color warningGlass = Color(0x1AF59E0B);

  // ─── Shadows / Depth ───────────────────────────────────────────────────────
  static const Color shadowColor      = Color(0x99000000);
  static const Color violetShadow     = Color(0x407B3FF2);
  static const Color orangeShadow     = Color(0x40FF6B35);
  static const Color deepShadow       = Color(0xBF000000);

  // ─── Light Mode Fallbacks ──────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard       = Color(0xFFFFFFFF);
  static const Color lightText       = Color(0xFF0F172A);
  static const Color lightSuccess    = Color(0xFF16A34A);
  static const Color lightWarning    = Color(0xFFB45309);
  static const Color lightDanger     = Color(0xFFDC2626);
  static const Color lightPrimary    = Color(0xFF7B3FF2);
  static const Color lightSecondary  = Color(0xFF5A2DB8);
}
