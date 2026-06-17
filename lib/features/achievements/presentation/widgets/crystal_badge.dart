import 'dart:math' as math;
import 'package:flutter/material.dart';

class CrystalBadge extends StatefulWidget {
  final Color color;
  final double progress; // 0.0 to 1.0
  final bool isUnlocked;
  final double size;
  final String category; // 'wealth_building' | 'investment' | 'debt_management' | 'receivables' | 'consistency' | 'goals'

  const CrystalBadge({
    super.key,
    required this.color,
    required this.progress,
    required this.isUnlocked,
    this.size = 100.0,
    required this.category,
  });

  @override
  State<CrystalBadge> createState() => _CrystalBadgeState();
}

class _CrystalBadgeState extends State<CrystalBadge> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    if (widget.isUnlocked) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant CrystalBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isUnlocked && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double pulse = widget.isUnlocked ? (0.92 + 0.08 * _pulseController.value) : 1.0;
        final double glow = widget.isUnlocked ? _pulseController.value : 0.0;

        return Transform.scale(
          scale: pulse,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: widget.isUnlocked
                  ? [
                      BoxShadow(
                        color: widget.color.withOpacity(0.15 + 0.1 * glow),
                        blurRadius: 24.0 + 8.0 * glow,
                        spreadRadius: -4.0,
                      )
                    ]
                  : null,
            ),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CrystalPainter(
                color: widget.color,
                progress: widget.progress,
                isUnlocked: widget.isUnlocked,
                glow: glow,
                category: widget.category,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CrystalPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isUnlocked;
  final double glow;
  final String category;

  _CrystalPainter({
    required this.color,
    required this.progress,
    required this.isUnlocked,
    required this.glow,
    required this.category,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background base wireframe ring
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 2, bgPaint);

    final double width = size.width;
    final double height = size.height;

    // Define vertices for crystal geometries depending on category
    // We will support 3 types of premium geometric crystals:
    // 1. Double Octahedron (Wealth Building, Consistency)
    // 2. Faceted Diamond (Investment, Goals)
    // 3. Hexagonal Bipyramid (Debt Management, Receivables)

    if (category == 'investment' || category == 'goals') {
      _paintFacetedDiamond(canvas, center, width, height);
    } else if (category == 'debt_management' || category == 'receivables') {
      _paintHexagonalBipyramid(canvas, center, width, height);
    } else {
      _paintDoubleOctahedron(canvas, center, width, height);
    }
  }

  void _paintDoubleOctahedron(Canvas canvas, Offset center, double w, double h) {
    // 1. Vertices
    final top = Offset(center.dx, center.dy - h * 0.4);
    final bottom = Offset(center.dx, center.dy + h * 0.4);

    final left = Offset(center.dx - w * 0.3, center.dy);
    final right = Offset(center.dx + w * 0.3, center.dy);
    final front = Offset(center.dx, center.dy + h * 0.1);
    final back = Offset(center.dx, center.dy - h * 0.1);

    // 2. Drawing Facets (Fills)
    final opacity = isUnlocked ? (0.12 + 0.08 * glow) : 0.02 + 0.05 * progress;
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [color.withOpacity(opacity * 1.5), color.withOpacity(opacity * 0.4)],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.3));

    // Draw facets
    _drawTriangle(canvas, top, left, front, fillPaint);
    _drawTriangle(canvas, top, front, right, fillPaint);
    _drawTriangle(canvas, top, right, back, fillPaint);
    _drawTriangle(canvas, top, back, left, fillPaint);

    _drawTriangle(canvas, bottom, left, front, fillPaint);
    _drawTriangle(canvas, bottom, front, right, fillPaint);
    _drawTriangle(canvas, bottom, right, back, fillPaint);
    _drawTriangle(canvas, bottom, back, left, fillPaint);

    // 3. Drawing Wireframe Lines
    final linePaint = Paint()
      ..color = isUnlocked 
          ? Color.alphaBlend(color.withOpacity(0.85 + 0.15 * glow), Colors.transparent)
          : Colors.white.withOpacity(0.1 + 0.3 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isUnlocked ? 1.6 : 1.0;

    // Glowing lines overlay
    Paint? glowPaint;
    if (isUnlocked) {
      glowPaint = Paint()
        ..color = color.withOpacity(0.3 + 0.2 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
    }

    void drawLine(Offset p1, Offset p2) {
      if (glowPaint != null) canvas.drawLine(p1, p2, glowPaint);
      canvas.drawLine(p1, p2, linePaint);
    }

    // Connect top
    drawLine(top, left);
    drawLine(top, front);
    drawLine(top, right);
    drawLine(top, back);

    // Connect bottom
    drawLine(bottom, left);
    drawLine(bottom, front);
    drawLine(bottom, right);
    drawLine(bottom, back);

    // Connect belt
    drawLine(left, front);
    drawLine(front, right);
    drawLine(right, back);
    drawLine(back, left);
    drawLine(left, right); // horizontal axis line
  }

  void _paintFacetedDiamond(Canvas canvas, Offset center, double w, double h) {
    // 1. Vertices
    final topL = Offset(center.dx - w * 0.25, center.dy - h * 0.3);
    final topM = Offset(center.dx, center.dy - h * 0.33);
    final topR = Offset(center.dx + w * 0.25, center.dy - h * 0.3);

    final midL = Offset(center.dx - w * 0.35, center.dy - h * 0.08);
    final midM = Offset(center.dx, center.dy - h * 0.05);
    final midR = Offset(center.dx + w * 0.35, center.dy - h * 0.08);

    final bottom = Offset(center.dx, center.dy + h * 0.38);

    // 2. Fills
    final opacity = isUnlocked ? (0.12 + 0.08 * glow) : 0.02 + 0.05 * progress;
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(opacity * 1.5), color.withOpacity(opacity * 0.3)],
      ).createShader(Rect.fromLTRB(center.dx - w * 0.4, center.dy - h * 0.4, center.dx + w * 0.4, center.dy + h * 0.4));

    // Draw facets
    _drawQuad(canvas, topL, topM, midM, midL, fillPaint);
    _drawQuad(canvas, topM, topR, midR, midM, fillPaint);
    _drawTriangle(canvas, midL, midM, bottom, fillPaint);
    _drawTriangle(canvas, midM, midR, bottom, fillPaint);

    // 3. Lines
    final linePaint = Paint()
      ..color = isUnlocked 
          ? Color.alphaBlend(color.withOpacity(0.85 + 0.15 * glow), Colors.transparent)
          : Colors.white.withOpacity(0.1 + 0.3 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isUnlocked ? 1.5 : 1.0;

    Paint? glowPaint;
    if (isUnlocked) {
      glowPaint = Paint()
        ..color = color.withOpacity(0.3 + 0.2 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    }

    void drawLine(Offset p1, Offset p2) {
      if (glowPaint != null) canvas.drawLine(p1, p2, glowPaint);
      canvas.drawLine(p1, p2, linePaint);
    }

    // Top belt
    drawLine(topL, topM);
    drawLine(topM, topR);
    drawLine(topL, midL);
    drawLine(topM, midM);
    drawLine(topR, midR);

    // Mid belt
    drawLine(midL, midM);
    drawLine(midM, midR);

    // Connect top facets
    drawLine(topL, midM);
    drawLine(topR, midM);

    // Connect bottom
    drawLine(midL, bottom);
    drawLine(midM, bottom);
    drawLine(midR, bottom);
  }

  void _paintHexagonalBipyramid(Canvas canvas, Offset center, double w, double h) {
    // 1. Vertices
    final top = Offset(center.dx, center.dy - h * 0.38);
    final bottom = Offset(center.dx, center.dy + h * 0.38);

    // 6 middle ring points
    final rX = w * 0.33;
    final rY = h * 0.12;

    final p1 = Offset(center.dx + rX, center.dy);
    final p2 = Offset(center.dx + rX * 0.5, center.dy + rY);
    final p3 = Offset(center.dx - rX * 0.5, center.dy + rY);
    final p4 = Offset(center.dx - rX, center.dy);
    final p5 = Offset(center.dx - rX * 0.5, center.dy - rY);
    final p6 = Offset(center.dx + rX * 0.5, center.dy - rY);

    // 2. Fills
    final opacity = isUnlocked ? (0.12 + 0.08 * glow) : 0.02 + 0.05 * progress;
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [color.withOpacity(opacity * 1.5), color.withOpacity(opacity * 0.4)],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.35));

    _drawTriangle(canvas, top, p1, p2, fillPaint);
    _drawTriangle(canvas, top, p2, p3, fillPaint);
    _drawTriangle(canvas, top, p3, p4, fillPaint);
    _drawTriangle(canvas, top, p4, p5, fillPaint);
    _drawTriangle(canvas, top, p5, p6, fillPaint);
    _drawTriangle(canvas, top, p6, p1, fillPaint);

    _drawTriangle(canvas, bottom, p1, p2, fillPaint);
    _drawTriangle(canvas, bottom, p2, p3, fillPaint);
    _drawTriangle(canvas, bottom, p3, p4, fillPaint);
    _drawTriangle(canvas, bottom, p4, p5, fillPaint);
    _drawTriangle(canvas, bottom, p5, p6, fillPaint);
    _drawTriangle(canvas, bottom, p6, p1, fillPaint);

    // 3. Lines
    final linePaint = Paint()
      ..color = isUnlocked 
          ? Color.alphaBlend(color.withOpacity(0.85 + 0.15 * glow), Colors.transparent)
          : Colors.white.withOpacity(0.1 + 0.3 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isUnlocked ? 1.5 : 1.0;

    Paint? glowPaint;
    if (isUnlocked) {
      glowPaint = Paint()
        ..color = color.withOpacity(0.3 + 0.2 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    }

    void drawLine(Offset p1, Offset p2) {
      if (glowPaint != null) canvas.drawLine(p1, p2, glowPaint);
      canvas.drawLine(p1, p2, linePaint);
    }

    // Connect top
    drawLine(top, p1);
    drawLine(top, p2);
    drawLine(top, p3);
    drawLine(top, p4);
    drawLine(top, p5);
    drawLine(top, p6);

    // Connect bottom
    drawLine(bottom, p1);
    drawLine(bottom, p2);
    drawLine(bottom, p3);
    drawLine(bottom, p4);
    drawLine(bottom, p5);
    drawLine(bottom, p6);

    // Connect middle ring
    drawLine(p1, p2);
    drawLine(p2, p3);
    drawLine(p3, p4);
    drawLine(p4, p5);
    drawLine(p5, p6);
    drawLine(p6, p1);
  }

  void _drawTriangle(Canvas canvas, Offset p1, Offset p2, Offset p3, Paint paint) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawQuad(Canvas canvas, Offset p1, Offset p2, Offset p3, Offset p4, Paint paint) {
    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
