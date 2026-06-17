import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  double _pageOffset = 0.0;
  int _currentPage = 0;

  // Animation controllers for slide visuals
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _chartDrawController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    });

    // Pulse animation (for Slide 4/5)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Float animation (for Slide 2)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Chart draw animation (for Slide 3)
    _chartDrawController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _chartDrawController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void _skipToLast() {
    _pageController.animateToPage(
      4,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
    );
  }

  void _finishSetup() async {
    final notifier = ref.read(mockDatabaseProvider.notifier);
    
    // 1. Create default primary bank account container
    await notifier.addAccount(
      'Primary Bank',
      'bank',
      'Setup automatically during onboarding',
      0.0,
      id: 'acc_primary_bank_uuid',
    );

    // 2. Complete onboarding state transition
    await notifier.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background atmospheric glows (Fintech Obsidian style)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkPrimary.withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.glow.withOpacity(0.06),
                    blurRadius: 100,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Skip Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mini logo mark
                      Row(
                        children: [
                          const Icon(Icons.radar_rounded, color: AppColors.darkPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'WORTH',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      // Skip button (fade out on last page)
                      AnimatedOpacity(
                        opacity: _currentPage == 4 ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: _currentPage == 4,
                          child: TextButton(
                            onPressed: _skipToLast,
                            child: Text(
                              'Skip',
                              style: GoogleFonts.inter(
                                color: AppColors.grey500,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main PageView for Slides
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                      if (page == 2) {
                        _chartDrawController.reset();
                        _chartDrawController.forward();
                      }
                    },
                    children: [
                      _buildSlide(
                        index: 0,
                        title: "Know What You're Worth.",
                        description: "Track your complete financial life in one place.",
                        visual: _buildSlide1Visual(),
                      ),
                      _buildSlide(
                        index: 1,
                        title: "Everything In One Place.",
                        description: "Manage Assets, Investments, Receivables, Liabilities, and Goals effortlessly.",
                        visual: _buildSlide2Visual(),
                      ),
                      _buildSlide(
                        index: 2,
                        title: "Built For Wealth Growth.",
                        description: "Understand how your net worth evolves over time with powerful analytics and reports.",
                        visual: _buildSlide3Visual(),
                      ),
                      _buildSlide(
                        index: 3,
                        title: "Secure & Offline First.",
                        description: "Your data stays on your device and works even without internet.",
                        visual: _buildSlide4Visual(),
                      ),
                      _buildSlide(
                        index: 4,
                        title: "Start Building Your Wealth Journey.",
                        description: "Take control of your financial future with Worth.",
                        visual: _buildSlide5Visual(),
                      ),
                    ],
                  ),
                ),

                // Bottom Controls (Dots & Buttons)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress Indicators
                      Row(
                        children: List.generate(5, (index) {
                          final isSelected = _currentPage == index;
                          return GestureDetector(
                            onTap: () => _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 6,
                              width: isSelected ? 24 : 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        }),
                      ),

                      // Action Button (Next / Get Started transition)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: _currentPage == 4
                            ? TactileButton(
                                key: const ValueKey('get_started_btn'),
                                onTap: _finishSetup,
                                gradient: const LinearGradient(
                                  colors: [AppColors.darkPrimary, AppColors.glow],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                width: 140,
                                child: Text(
                                  'GET STARTED',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              )
                            : TactileButton(
                                key: const ValueKey('next_btn'),
                                onTap: _nextPage,
                                border: const BorderSide(color: AppColors.glassBorder),
                                width: 60,
                                child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Generic Slide Builder
  Widget _buildSlide({
    required int index,
    required String title,
    required String description,
    required Widget visual,
  }) {
    // Parallax scrolling translation factor
    final offsetMultiplier = (index - _pageOffset);
    final textParallax = offsetMultiplier * 50;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Illustration Area
          Expanded(
            flex: 5,
            child: Center(
              child: ClipRect(
                child: Transform.translate(
                  offset: Offset(offsetMultiplier * 150, 0),
                  child: visual,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Text Content Area
          Expanded(
            flex: 3,
            child: Transform.translate(
              offset: Offset(textParallax, 0),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.grey400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Visual Component Builders ---

  // Slide 1: Net Worth Card with Assets vs Liabilities Ratio
  Widget _buildSlide1Visual() {
    return Container(
      width: 280,
      height: 200,
      alignment: Alignment.center,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderColor: AppColors.darkPrimary.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NET WORTH',
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 250000),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutQuart,
              builder: (context, val, child) {
                return Text(
                  '₹${NumberFormat.decimalPattern().format(val.toInt())}',
                  style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                );
              },
            ),
            const SizedBox(height: 16),
            // Progress Bar split
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Container(
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.darkSuccess,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.darkDanger,
                      borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assets', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('₹3,50,000', style: TextStyle(color: AppColors.darkSuccess, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Liabilities', style: GoogleFonts.inter(fontSize: 9, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('₹1,00,000', style: TextStyle(color: AppColors.darkDanger, fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Slide 2: Floating 3D Portfolio Cards
  Widget _buildSlide2Visual() {
    return SizedBox(
      width: 300,
      height: 220,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final time = _floatController.value * 2 * math.pi;
          
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Bottom Card (Liabilities)
              Positioned(
                bottom: 10 + math.sin(time) * 8,
                left: 10,
                child: Transform.rotate(
                  angle: -0.05,
                  child: _buildMiniCard('Liabilities', '-₹1,00,000', AppColors.darkDanger, 200),
                ),
              ),
              // Middle Card (Investments)
              Positioned(
                top: 40 + math.sin(time + math.pi / 2) * 10,
                right: 15,
                child: Transform.rotate(
                  angle: 0.04,
                  child: _buildMiniCard('Investments', '₹1,80,000', AppColors.darkPrimary, 210),
                ),
              ),
              // Top Card (Assets Summary)
              Positioned(
                top: 90 + math.sin(time + math.pi) * 12,
                left: 30,
                child: Transform.rotate(
                  angle: -0.02,
                  child: _buildMiniCard('Goals Owed', '₹1,20,000', AppColors.darkSuccess, 210, isHighlighted: true),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMiniCard(String label, String value, Color color, double width, {bool isHighlighted = false}) {
    return SizedBox(
      width: width,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderColor: isHighlighted ? AppColors.darkPrimary.withOpacity(0.3) : AppColors.glassBorder,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
              ),
              child: Icon(Icons.circle_outlined, size: 12, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.grey500, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Slide 3: Wealth growth custom-drawn path
  Widget _buildSlide3Visual() {
    return SizedBox(
      width: 280,
      height: 200,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WEALTH ACCELERATION',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.8),
                ),
                Text(
                  '+45.2% YTD',
                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.darkSuccess),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: _chartDrawController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: OnboardingChartPainter(
                      progress: _chartDrawController.value,
                      lineColor: AppColors.glow,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 4: Security Pulse with Fingerprint and DB check status
  Widget _buildSlide4Visual() {
    return SizedBox(
      width: 280,
      height: 200,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.08);
          final opacity = 0.4 - (_pulseController.value * 0.3);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Glowing pulse rings
              Container(
                width: 110 * scale,
                height: 110 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.darkPrimary.withOpacity(opacity), width: 2.0),
                ),
              ),
              Container(
                width: 140 * scale,
                height: 140 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glow.withOpacity(opacity * 0.5), width: 1.0),
                ),
              ),

              // Central Fingerprint/Shield Glass Container
              GlassCard(
                borderRadius: 50,
                padding: const EdgeInsets.all(24),
                borderColor: AppColors.darkPrimary.withOpacity(0.2),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  size: 48,
                  color: AppColors.darkPrimary,
                ),
              ),

              // Floating secure storage indicator
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AppColors.darkSuccess, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SECURE LOCAL SQL DB',
                        style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Slide 5: Concentric Worth logo & Floating stars animation
  Widget _buildSlide5Visual() {
    return SizedBox(
      width: 280,
      height: 200,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final glowFactor = _pulseController.value;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Multi-layered concentric ambient glows
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(0.08 + (glowFactor * 0.05)),
                      blurRadius: 50 + (glowFactor * 20),
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              
              // Logo mark
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.layer1,
                  border: Border.all(
                    color: AppColors.darkPrimary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.radar_rounded,
                    color: AppColors.darkPrimary,
                    size: 54,
                  ),
                ),
              ),

              // Orbiting elements
              Positioned(
                top: 30,
                left: 40,
                child: _buildSparkleDot(glowFactor, 6),
              ),
              Positioned(
                bottom: 40,
                right: 35,
                child: _buildSparkleDot(1.0 - glowFactor, 8),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSparkleDot(double pulseVal, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.glow.withOpacity(0.2 + (pulseVal * 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.glow.withOpacity(pulseVal),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Onboarding line chart
class OnboardingChartPainter extends CustomPainter {
  final double progress;
  final Color lineColor;

  OnboardingChartPainter({required this.progress, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Wave points
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.72),
      Offset(size.width * 0.4, size.height * 0.75),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.58),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    // Slice path based on progress
    final pathMetrics = path.computeMetrics();
    final drawingPath = Path();
    
    for (final metric in pathMetrics) {
      final length = metric.length * progress;
      drawingPath.addPath(metric.extractPath(0, length), Offset.zero);
    }

    // Draw the gradient area fill below the line
    if (progress > 0) {
      final fillPath = Path.from(drawingPath);
      // Find the last coordinates of the drawingPath to close it properly
      final metricList = drawingPath.computeMetrics().toList();
      if (metricList.isNotEmpty) {
        final lastPoint = metricList.last.getTangentForOffset(metricList.last.length)?.position ?? Offset(size.width * progress, size.height);
        fillPath.lineTo(lastPoint.dx, size.height);
        fillPath.lineTo(0, size.height);
        fillPath.close();

        fillPaint.shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withOpacity(0.18),
            lineColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));
        
        canvas.drawPath(fillPath, fillPaint);
      }
    }

    // Draw grid helper lines
    final gridPaint = Paint()
      ..color = AppColors.glassBorder
      ..strokeWidth = 1.0;
    
    for (double y = size.height * 0.25; y < size.height; y += size.height * 0.25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw line
    canvas.drawPath(drawingPath, paint);

    // Draw endpoint dot
    if (progress > 0.1) {
      final metricList = drawingPath.computeMetrics().toList();
      if (metricList.isNotEmpty) {
        final tangent = metricList.last.getTangentForOffset(metricList.last.length);
        if (tangent != null) {
          final dotPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
          final shadowPaint = Paint()
            ..color = lineColor.withOpacity(0.5)
            ..style = PaintingStyle.fill;

          canvas.drawCircle(tangent.position, 7.0, shadowPaint);
          canvas.drawCircle(tangent.position, 4.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant OnboardingChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.lineColor != lineColor;
  }
}

// Tactile press-scaling Button
class TactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final BorderSide? border;
  final double borderRadius;
  final double? width;
  final double height;

  const TactileButton({
    required this.child,
    this.onTap,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius = 18.0,
    this.width,
    this.height = 46.0,
    super.key,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _controller.forward(),
      onTapUp: widget.onTap == null ? null : (_) => _controller.reverse(),
      onTapCancel: widget.onTap == null ? null : () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border != null ? Border.fromBorderSide(widget.border!) : null,
            boxShadow: widget.gradient != null
                ? [
                    BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(0.24),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
