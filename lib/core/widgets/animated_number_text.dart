import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_motion.dart';

class AnimatedNumberText extends StatelessWidget {
  final double value;
  final String currency;
  final int decimalDigits;
  final TextStyle style;
  final Color? color;

  const AnimatedNumberText({
    required this.value,
    required this.currency,
    this.decimalDigits = 0,
    required this.style,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: AppMotion.large,
      curve: AppMotion.easeOut,
      builder: (context, val, child) {
        final format = NumberFormat.currency(
          locale: 'en_IN',
          symbol: currency,
          decimalDigits: decimalDigits,
        );
        return Text(
          format.format(val),
          style: style.copyWith(color: color ?? style.color),
        );
      },
    );
  }
}
