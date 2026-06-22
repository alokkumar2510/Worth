import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class WorthBackground extends StatefulWidget {
  final Widget child;
  const WorthBackground({required this.child, super.key});

  @override
  State<WorthBackground> createState() => _WorthBackgroundState();
}

class _WorthBackgroundState extends State<WorthBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = List.generate(25, (index) => Particle.random());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
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
        // Deep space black base
        Positioned.fill(
          child: Container(color: AppColors.darkBackground),
        ),

        // Dynamic background elements with RepaintBoundary (isolated animation layer)
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // Update particles position on animation tick
                for (var p in _particles) {
                  p.update();
                }

                return Stack(
                  children: [
                    // Dynamic Mesh Gradients (Blobs moving slowly)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: MeshGradientPainter(
                          progress: _controller.value,
                          primaryColor: AppColors.darkPrimary,
                          glowColor: AppColors.glow,
                        ),
                      ),
                    ),

                    // Floating Star Particles (Tactile depth)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ParticlesPainter(particles: _particles),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Frost glass noise texture overlay
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: FrostNoisePainter(),
              ),
            ),
          ),
        ),

        // Main Content child with separate RepaintBoundary to prevent content repainting on background ticks
        Positioned.fill(
          child: RepaintBoundary(
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double speedY;
  double speedX;
  double size;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.opacity,
  });

  factory Particle.random() {
    final rand = math.Random();
    return Particle(
      x: rand.nextDouble(),
      y: rand.nextDouble(),
      speedY: -(rand.nextDouble() * 0.0006 + 0.0002),
      speedX: (rand.nextDouble() - 0.5) * 0.0002,
      size: rand.nextDouble() * 2.0 + 1.0,
      opacity: rand.nextDouble() * 0.25 + 0.1,
    );
  }

  void update() {
    y += speedY;
    x += speedX;
    if (y < 0) {
      y = 1.0;
      x = math.Random().nextDouble();
    }
    if (x < 0 || x > 1.0) {
      x = x < 0 ? 1.0 : 0.0;
    }
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  ParticlesPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var p in particles) {
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MeshGradientPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color glowColor;

  MeshGradientPainter({
    required this.progress,
    required this.primaryColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double rad = progress * 2.0 * math.pi;

    // Blob 1: Accent Purple (Top-Right movement)
    final blob1x = size.width * (0.7 + 0.15 * math.sin(rad));
    final blob1y = size.height * (0.2 + 0.1 * math.cos(rad));
    final blob1Radius = size.width * 0.75;

    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.18),
          primaryColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(blob1x, blob1y), radius: blob1Radius));
    canvas.drawCircle(Offset(blob1x, blob1y), blob1Radius, paint1);

    // Blob 2: Lavender Glow (Bottom-Left movement)
    final blob2x = size.width * (0.2 + 0.12 * math.cos(rad + math.pi));
    final blob2y = size.height * (0.75 + 0.15 * math.sin(rad + math.pi));
    final blob2Radius = size.width * 0.8;

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withOpacity(0.12),
          glowColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(blob2x, blob2y), radius: blob2Radius));
    canvas.drawCircle(Offset(blob2x, blob2y), blob2Radius, paint2);

    // Blob 3: Ambient Highlight (Center Top)
    final blob3x = size.width * (0.45 + 0.08 * math.sin(rad * 1.5));
    final blob3y = size.height * (-0.1 + 0.08 * math.cos(rad * 1.5));
    final blob3Radius = size.width * 0.55;

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.14),
          primaryColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(blob3x, blob3y), radius: blob3Radius));
    canvas.drawCircle(Offset(blob3x, blob3y), blob3Radius, paint3);
  }

  @override
  bool shouldRepaint(covariant MeshGradientPainter oldDelegate) => true;
}

class FrostNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 1.0;

    final List<Offset> points = [];
    final rand = math.Random(42); // Deterministic noise seed

    for (int i = 0; i < 3000; i++) {
      points.add(Offset(
        rand.nextDouble() * size.width,
        rand.nextDouble() * size.height,
      ));
    }

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant FrostNoisePainter oldDelegate) => false;
}
