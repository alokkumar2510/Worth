import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  // Standard durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration large = Duration(milliseconds: 400);
  static const Duration page = Duration(milliseconds: 500);

  // Standard curves
  static const Curve easeOut = Cubic(0.16, 1.0, 0.3, 1.0); // easeOutQuart (iOS style deceleration)
  static const Curve easeInOut = Cubic(0.22, 1.0, 0.36, 1.0); // easeInOutQuart
  static const Curve spring = Curves.fastOutSlowIn;
}
