import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';

/// Premium animated background: 4-blob mesh gradients + floating particles
class WorthBackground extends StatefulWidget {
  final Widget child;
  const WorthBackground({required this.child, super.key});

  @override
  State<WorthBackground> createState() => _WorthBackgroundState();
}

class _WorthBackgroundState extends State<WorthBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles =
      List.generate(40, (i) => Particle.random(i));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep obsidian base
        Positioned.fill(child: Container(color: AppColors.darkBackground)),

        // Animated mesh blobs + particles (isolated paint boundary)
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                for (final p in _particles) {
                  p.update();
                }
                return CustomPaint(
                  painter: _BackgroundPainter(
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),
        ),

        // Static noise overlay (no repaint needed)
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _FrostPainter()),
            ),
          ),
        ),

        // Content
        Positioned.fill(
          child: RepaintBoundary(child: widget.child),
        ),
      ],
    );
  }
}

// ─── Background Painter ────────────────────────────────────────────────────────
class _BackgroundPainter extends CustomPainter {
  final double progress;
  _BackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rad = progress * 2.0 * math.pi;

    // ── Blob 1: Electric Violet — Top Right (slow drift)
    _drawBlob(
      canvas, size,
      cx: 0.75 + 0.12 * math.sin(rad * 0.7),
      cy: 0.15 + 0.08 * math.cos(rad * 0.7),
      radius: 0.65,
      color: AppGradients.meshViolet,
    );

    // ── Blob 2: Vivid Orange — Bottom Left (opposing drift)
    _drawBlob(
      canvas, size,
      cx: 0.18 + 0.10 * math.cos(rad * 0.5 + math.pi),
      cy: 0.78 + 0.12 * math.sin(rad * 0.5 + math.pi),
      radius: 0.60,
      color: AppGradients.meshOrange,
    );

    // ── Blob 3: Deep Indigo — Center (very slow)
    _drawBlob(
      canvas, size,
      cx: 0.48 + 0.06 * math.sin(rad * 0.3 + 1.0),
      cy: 0.45 + 0.05 * math.cos(rad * 0.3 + 1.0),
      radius: 0.72,
      color: AppGradients.meshIndigo,
    );

    // ── Blob 4: Lavender — Bottom Right (medium drift)
    _drawBlob(
      canvas, size,
      cx: 0.82 + 0.08 * math.cos(rad * 0.6 + 2.0),
      cy: 0.80 + 0.10 * math.sin(rad * 0.6 + 2.0),
      radius: 0.50,
      color: AppGradients.meshLavender,
    );
  }

  void _drawBlob(Canvas canvas, Size size,
      {required double cx, required double cy,
      required double radius, required Color color}) {
    final center = Offset(cx * size.width, cy * size.height);
    final r = radius * size.width;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) =>
      old.progress != progress;
}

// ─── Frost Noise Overlay ──────────────────────────────────────────────────────
class _FrostPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.012)
      ..strokeWidth = 1.0;
    final rand = math.Random(99);
    final pts = <Offset>[];
    for (int i = 0; i < 2500; i++) {
      pts.add(Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height));
    }
    canvas.drawPoints(PointMode.points, pts, paint);
  }

  @override
  bool shouldRepaint(covariant _FrostPainter _) => false;
}

// ─── Particle ─────────────────────────────────────────────────────────────────
class Particle {
  double x, y, speedY, speedX, size, opacity;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.opacity,
    required this.color,
  });

  factory Particle.random(int seed) {
    final rand = math.Random(seed * 37 + 13);
    final isOrange = rand.nextBool();
    return Particle(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      speedY: -(rand.nextDouble() * 0.0005 + 0.0001),
      speedX: (rand.nextDouble() - 0.5) * 0.00015,
      size: rand.nextDouble() * 2.2 + 0.8,
      opacity: rand.nextDouble() * 0.3 + 0.08,
      color: isOrange ? AppColors.orange : AppColors.darkPrimary,
    );
  }

  void update() {
    y += speedY;
    x += speedX;
    if (y < 0) { y = 1.0; x = math.Random().nextDouble(); }
    if (x < 0 || x > 1.0) { x = x < 0 ? 1.0 : 0.0; }
  }
}
