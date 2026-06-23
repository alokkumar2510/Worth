import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Worth Premium Typography System
/// Outfit: Display / Headings  |  Inter: Body  |  JetBrains Mono: Numbers
class AppTypography {
  AppTypography._();

  // ─── Display ────────────────────────────────────────────────────────────────
  static TextStyle display({Color? color}) => GoogleFonts.outfit(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.0,
        height: 1.0,
        color: color ?? const Color(0xFFF8FAFC),
      );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.05,
        color: color ?? const Color(0xFFF8FAFC),
      );

  // ─── Headings ───────────────────────────────────────────────────────────────
  static TextStyle h1({Color? color}) => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.15,
        color: color ?? const Color(0xFFF8FAFC),
      );

  static TextStyle h2({Color? color}) => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: color ?? const Color(0xFFF8FAFC),
      );

  static TextStyle h3({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: color ?? const Color(0xFFF8FAFC),
      );

  static TextStyle h4({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.3,
        color: color ?? const Color(0xFFF8FAFC),
      );

  // ─── Body ───────────────────────────────────────────────────────────────────
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.6,
        color: color ?? const Color(0xFFF8FAFC),
      );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.5,
        color: color ?? const Color(0xFF94A3B8),
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
        color: color ?? const Color(0xFF64748B),
      );

  // ─── Labels ─────────────────────────────────────────────────────────────────
  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        height: 1.2,
        color: color ?? const Color(0xFF64748B),
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 1.2,
        color: color ?? const Color(0xFF64748B),
      );

  // ─── Monospace (Financial Values) ───────────────────────────────────────────
  static TextStyle monoHero({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.0,
        height: 1.0,
        color: color ?? const Color(0xFFF8FAFC),
      );

  static TextStyle monoLarge({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.0,
        height: 1.0,
        color: color ?? const Color(0xFFF8FAFC),
      );

  static TextStyle mono({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.5,
        height: 1.2,
        color: color ?? const Color(0xFFF8FAFC),
      );

  static TextStyle monoSmall({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
        height: 1.2,
        color: color ?? const Color(0xFF94A3B8),
      );

  // ─── Button ─────────────────────────────────────────────────────────────────
  static TextStyle button({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        height: 1.2,
        color: color ?? Colors.white,
      );

  static TextStyle buttonSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        height: 1.2,
        color: color ?? Colors.white,
      );
}
