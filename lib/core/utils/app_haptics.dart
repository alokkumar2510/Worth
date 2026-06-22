import 'package:flutter/services.dart';

class AppHaptics {
  AppHaptics._();

  // Subtle impact for tab selection or card clicks
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  // Medium impact for successful confirmations (e.g. backup complete, sync)
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  // Heavy alert for warning actions or destructive resets
  static Future<void> alert() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}
