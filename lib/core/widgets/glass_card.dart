import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_motion.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double blurSigma;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final bool isPrimary; // True = 32px radius, False = 24px radius

  const GlassCard({
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma = 16.0,
    this.borderColor,
    this.gradientColors,
    this.onTap,
    this.isPrimary = false,
    super.key,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _shineController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    // Tactile press compression spring animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: AppMotion.normal,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: AppMotion.easeOut,
        reverseCurve: AppMotion.easeOut,
      ),
    );

    // Continuous premium glass highlight sweep
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Enforce border radius rules: Primary = 32px, Secondary = 24px
    final double radius = widget.borderRadius ?? (widget.isPrimary ? 32.0 : 24.0);

    final defaultBackground = isDark 
        ? AppColors.darkCard.withOpacity(0.55) 
        : Colors.white.withOpacity(0.7);

    final borderGradient = widget.borderColor != null
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.borderColor!,
              widget.borderColor!.withOpacity(0.1),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
                ? [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.03),
                    AppColors.darkPrimary.withOpacity(0.15),
                    Colors.white.withOpacity(0.01),
                  ]
                : [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.02),
                    Colors.black.withOpacity(0.05),
                  ],
            stops: isDark ? const [0.0, 0.4, 0.8, 1.0] : null,
          );

    Widget animatedCard = ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.easeOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -2.0 : 0.0),
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? const Color(0x3F000000).withOpacity(_isHovered ? 0.35 : 0.25) 
                  : const Color(0x0A000000).withOpacity(_isHovered ? 0.06 : 0.04),
              blurRadius: _isHovered ? 40 : 32,
              spreadRadius: _isHovered ? 3 : 2,
              offset: Offset(0, _isHovered ? 14 : 12),
            ),
            if (isDark)
              BoxShadow(
                color: AppColors.darkPrimary.withOpacity(_isHovered ? 0.05 : 0.03),
                blurRadius: _isHovered ? 48 : 40,
                spreadRadius: 1,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Stack(
            children: [
              // 1. Background layer (expanded to full card width)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: widget.gradientColors != null
                        ? LinearGradient(
                            colors: widget.gradientColors!,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: widget.gradientColors == null ? defaultBackground : null,
                  ),
                ),
              ),

              // 2. Blur / BackdropFilter layer
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
                  child: const SizedBox(),
                ),
              ),

              // 3. Premium Noise Overlay Layer
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius),
                    child: CustomPaint(
                      painter: NoisePainter(
                        opacity: isDark ? 0.012 : 0.008,
                        density: 0.12,
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Animated Glass Shine Sweep (conditional)
              if (isDark)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shineController,
                      builder: (context, child) {
                        final value = _shineController.value;
                        final begin = Alignment(
                          -4.0 + (value * 8.0),
                          -4.0 + (value * 8.0),
                        );
                        final end = Alignment(
                          begin.x + 1.2,
                          begin.y + 1.2,
                        );
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(radius),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: begin,
                                end: end,
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.07),
                                  Colors.transparent,
                                ],
                                stops: const [0.3, 0.5, 0.7],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // 5. Border Gradient Layer (Custom Paint)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: BorderGradientPainter(
                      radius: radius,
                      gradient: borderGradient,
                    ),
                  ),
                ),
              ),

              // 6. Content child (non-positioned, determines the card size)
              Container(
                padding: widget.padding ?? const EdgeInsets.all(20.0),
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: widget.onTap,
          child: animatedCard,
        ),
      );
    }

    return animatedCard;
  }
}

class BorderGradientPainter extends CustomPainter {
  final double radius;
  final Gradient gradient;
  final double strokeWidth;

  BorderGradientPainter({
    required this.radius,
    required this.gradient,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(strokeWidth / 2, strokeWidth / 2) & 
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect);
    
    final adjustedRadius = math.max(0.0, radius - strokeWidth / 2);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(adjustedRadius));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant BorderGradientPainter oldDelegate) {
    return oldDelegate.radius != radius || 
           oldDelegate.gradient != gradient || 
           oldDelegate.strokeWidth != strokeWidth;
  }
}


class NoisePainter extends CustomPainter {
  final double opacity;
  final double density;

  const NoisePainter({
    required this.opacity,
    required this.density,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 1.0;

    final List<Offset> points = [];
    
    for (double x = 0; x < size.width; x += 2) {
      for (double y = 0; y < size.height; y += 2) {
        final val = math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
        final randomVal = val - val.floorToDouble();
        if (randomVal < density) {
          points.add(Offset(x, y));
        }
      }
    }
    
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant NoisePainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.density != density;
  }
}
