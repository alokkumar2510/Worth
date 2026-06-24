import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Premium Space Black / Obsidian Color System
  static const Color darkBackground = Color(0xFF050507); // Deepest obsidian black
  static const Color layer1 = Color(0xFF0B0B0F);         // Deep charcoal obsidian panel
  static const Color layer2 = Color(0xFF111118);         // Grouped element container
  
  static const Color glassSurface = Color(0x0FFFFFFF);   // Frosted white glass (6% opacity)
  static const Color glassBorder = Color(0x14FFFFFF);    // Frosted white border highlight (8% opacity)
  
  static const Color darkCard = Color(0xFF0B0B0F);       // Matches layer 1
  static const Color darkCardBorder = Color(0x14FFFFFF);  // Matches glassBorder

  static const Color darkText = Color(0xFFF8FAFC);       // Soft white
  static const Color grey500 = Color(0xFF64748B);        // Mid-grey secondary text
  static const Color grey400 = Color(0xFF94A3B8);        // Muted grey text
  static const Color grey700 = Color(0xFF334155);        // Slate grey border/divider
  
  // Glowing Accents
  static const Color darkPrimary = Color(0xFF7C4DFF);    // Vibrant amethyst violet
  static const Color darkSecondary = Color(0xFFB39DDB);  // Soft accent lavender
  static const Color glow = Color(0xFFA78BFA);           // Amethyst glow highlight
  static const Color accentGlow = Color(0x1A7C4DFF);     // Soft translucent primary glow
  static const Color shadowColor = Color(0x7F000000);    // Deep tactile drop shadow
  
  // Status Colors
  static const Color darkSuccess = Color(0xFF22C55E);    // Emerald success
  static const Color darkWarning = Color(0xFFF59E0B);    // Amber warning
  static const Color darkDanger = Color(0xFFEF4444);     // Coral danger

  // Fallbacks for compatibility with light mode code paths
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightSuccess = Color(0xFF16A34A);
  static const Color lightWarning = Color(0xFFB45309);
  static const Color lightDanger = Color(0xFFDC2626);
  static const Color lightPrimary = Color(0xFF7C4DFF);
  static const Color lightSecondary = Color(0xFF673AB7);
  static const Color lightSecondaryText = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFE2E8F0);
}
