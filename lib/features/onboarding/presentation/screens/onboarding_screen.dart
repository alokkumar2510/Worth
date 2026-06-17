import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

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

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _chartDrawController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
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
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    }
  }

  void _skipToLast() {
    _pageController.animateToPage(
      4,
      duration: const Duration(milliseconds: 700),
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

    // 3. Transition to Login Screen
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background PageView
          PageView(
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
              _buildSlide1(),
              _buildSlide2(),
              _buildSlide3(),
              _buildSlide4(),
              _buildSlide5(),
            ],
          ),

          // Action Overlay Bar (Skip)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                opacity: _currentPage == 4 ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: IgnorePointer(
                  ignoring: _currentPage == 4,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                    child: TextButton(
                      onPressed: _skipToLast,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          color: AppColors.grey500,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Navigation Controls
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dot indicators
                    Row(
                      children: List.generate(5, (index) {
                        final isSelected = _currentPage == index;
                        return GestureDetector(
                          onTap: () => _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 6,
                            width: isSelected ? 28 : 6,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.darkPrimary.withOpacity(0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),

                    // Next / Get Started Action Button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _currentPage == 4
                          ? _OnboardingTactileButton(
                              key: const ValueKey('get_started_btn'),
                              onTap: _finishSetup,
                              gradient: const LinearGradient(
                                colors: [AppColors.darkPrimary, AppColors.glow],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              width: 150,
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
                          : _OnboardingTactileButton(
                              key: const ValueKey('next_btn'),
                              onTap: _nextPage,
                              color: AppColors.layer2.withOpacity(0.5),
                              border: const BorderSide(color: AppColors.glassBorder),
                              width: 60,
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SLIDE 1: Premium Brand Reveal & Concentric Pulse ---
  Widget _buildSlide1() {
    final offsetMultiplier = (0 - _pageOffset);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFF1E1E2C),
            Color(0xFF0F0F16),
            Color(0xFF09090D),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 12),
              // Concentric pulse visual
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(offsetMultiplier * 150, 0),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final value = _pulseController.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // 3 concentric animated glowing rings
                            Container(
                              width: 140 + (value * 80),
                              height: 140 + (value * 80),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.darkPrimary.withOpacity(0.12 * (1.0 - value)),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Container(
                              width: 100 + (value * 40),
                              height: 100 + (value * 40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.glow.withOpacity(0.20 * (1.0 - value)),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.layer1.withOpacity(0.4),
                                border: Border.all(color: AppColors.glassBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.darkPrimary.withOpacity(0.12),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.radar_rounded,
                                  size: 40,
                                  color: AppColors.darkPrimary,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Message Column
              Column(
                children: [
                  Text(
                    "Know What You're Worth.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Track your complete financial life in one place.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.grey400,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SLIDE 2: Stacked Ledger (Apple Wallet Style) ---
  Widget _buildSlide2() {
    final offsetMultiplier = (1 - _pageOffset);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF161623),
            Color(0xFF0C0C14),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 12),
              // Stacked cards visual
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(offsetMultiplier * 150, 0),
                    child: AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        final val = _floatController.value * 2 * math.pi;
                        final shift = math.sin(val) * 6;
                        return Container(
                          width: 280,
                          height: 240,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Liabilities Card (Back)
                              Positioned(
                                top: 10 - shift,
                                child: Transform.rotate(
                                  angle: -0.06,
                                  child: _buildWalletCard('Liabilities Due', '₹1,40,000', AppColors.darkDanger),
                                ),
                              ),
                              // Investments Card (Middle)
                              Positioned(
                                top: 55 + shift,
                                child: Transform.rotate(
                                  angle: 0.04,
                                  child: _buildWalletCard('Investments', '₹3,50,000', AppColors.darkPrimary),
                                ),
                              ),
                              // Assets Card (Front)
                              Positioned(
                                top: 100 - (shift * 0.5),
                                child: Transform.rotate(
                                  angle: -0.02,
                                  child: _buildWalletCard('Cash Assets', '₹8,20,000', AppColors.darkSuccess, isGlow: true),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Message Column
              Column(
                children: [
                  Text(
                    "Everything In One Place.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Manage Assets, Investments, Liabilities, and Goals effortlessly.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.grey400,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(String label, String value, Color color, {bool isGlow = false}) {
    return Container(
      width: 230,
      height: 100,
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        borderColor: isGlow ? AppColors.darkPrimary.withOpacity(0.35) : AppColors.glassBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.grey500, letterSpacing: 0.5),
                ),
                Icon(Icons.circle_outlined, size: 10, color: color),
              ],
            ),
            Text(
              value,
              style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }

  // --- SLIDE 3: Wealth Acceleration Bezier Curve (CRED style) ---
  Widget _buildSlide3() {
    final offsetMultiplier = (2 - _pageOffset);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF131A18),
            Color(0xFF080D0C),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 12),
              // Chart Animation Visual
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(offsetMultiplier * 150, 0),
                    child: Container(
                      width: 290,
                      height: 200,
                      child: GlassCard(
                        padding: const EdgeInsets.all(18.0),
                        borderColor: AppColors.glow.withOpacity(0.25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'WEALTH PROJECTION',
                                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 0.8),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.darkSuccess.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                                  child: Text('+124.5% ACCEL.', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.darkSuccess)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _chartDrawController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    painter: _PremiumOnboardingChartPainter(
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
                    ),
                  ),
                ),
              ),
              // Message Column
              Column(
                children: [
                  Text(
                    "Built For Wealth Growth.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Understand how your net worth grows over time with powerful analytics.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.grey400,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SLIDE 4: Secure Vault handle ---
  Widget _buildSlide4() {
    final offsetMultiplier = (3 - _pageOffset);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color(0xFF191016),
            Color(0xFF0F0B0E),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 12),
              // Vault Handler Visual
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(offsetMultiplier * 150, 0),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.05);
                        final val = _pulseController.value * 2 * math.pi;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulsing grid ring
                            Container(
                              width: 150 * scale,
                              height: 150 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.darkSuccess.withOpacity(0.08 * (1.0 - _pulseController.value)), width: 2),
                              ),
                            ),
                            // Safe wheel handle
                            Transform.rotate(
                              angle: val * 0.1,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.layer1,
                                  border: Border.all(color: AppColors.glassBorder, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.darkSuccess.withOpacity(0.08),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Vault Spokes
                                    ...List.generate(3, (idx) {
                                      return Transform.rotate(
                                        angle: (idx * 2 * math.pi) / 3,
                                        child: Container(
                                          width: 8,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: AppColors.layer2.withOpacity(0.6),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      );
                                    }),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.layer2,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.lock_person_rounded, size: 20, color: AppColors.darkSuccess),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Vault Shield status
                            Positioned(
                              bottom: -20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.darkSuccess.withOpacity(0.25)),
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
                                      'SQLITE SECURE AES-256',
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
                  ),
                ),
              ),
              // Message Column
              Column(
                children: [
                  Text(
                    "Secure & Offline First.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your financial records never leave your device and work completely offline.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.grey400,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SLIDE 5: Premium Logo Launch ---
  Widget _buildSlide5() {
    final offsetMultiplier = (4 - _pageOffset);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.3,
          colors: [
            Color(0xFF22161A),
            Color(0xFF0F0B0C),
            Color(0xFF070506),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 12),
              // Concentric orbital elements
              Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(offsetMultiplier * 150, 0),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final val = _pulseController.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.darkPrimary.withOpacity(0.08 + (val * 0.04)),
                                    blurRadius: 40 + (val * 20),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 104,
                              height: 104,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.layer1,
                                border: Border.all(
                                  color: AppColors.darkPrimary.withOpacity(0.35),
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.radar_rounded,
                                  color: AppColors.darkPrimary,
                                  size: 60,
                                ),
                              ),
                            ),
                            // Floating stars / orbiters
                            Positioned(
                              top: 25,
                              left: 35,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.glow.withOpacity(0.3 + (val * 0.7))),
                              ),
                            ),
                            Positioned(
                              bottom: 30,
                              right: 25,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.glow.withOpacity(1.0 - val)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              // Message Column
              Column(
                children: [
                  Text(
                    "Start Your Journey.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.0,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Take control of your financial future and master your wealth portfolio.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.grey400,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for wealth curve progress
class _PremiumOnboardingChartPainter extends CustomPainter {
  final double progress;
  final Color lineColor;

  _PremiumOnboardingChartPainter({required this.progress, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = AppColors.glassBorder
      ..strokeWidth = 1.0;

    // Grid lines
    for (double y = size.height * 0.25; y < size.height; y += size.height * 0.25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final points = [
      Offset(0, size.height * 0.85),
      Offset(size.width * 0.2, size.height * 0.78),
      Offset(size.width * 0.4, size.height * 0.72),
      Offset(size.width * 0.6, size.height * 0.44),
      Offset(size.width * 0.8, size.height * 0.50),
      Offset(size.width, size.height * 0.15),
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

    final pathMetrics = path.computeMetrics();
    final drawingPath = Path();
    
    for (final metric in pathMetrics) {
      final length = metric.length * progress;
      drawingPath.addPath(metric.extractPath(0, length), Offset.zero);
    }

    if (progress > 0) {
      final fillPath = Path.from(drawingPath);
      final metricList = drawingPath.computeMetrics().toList();
      if (metricList.isNotEmpty) {
        final lastPoint = metricList.last.getTangentForOffset(metricList.last.length)?.position ?? Offset(size.width * progress, size.height);
        fillPath.lineTo(lastPoint.dx, size.height);
        fillPath.lineTo(0, size.height);
        fillPath.close();

        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
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

    canvas.drawPath(drawingPath, paint);

    if (progress > 0.1) {
      final metricList = drawingPath.computeMetrics().toList();
      if (metricList.isNotEmpty) {
        final tangent = metricList.last.getTangentForOffset(metricList.last.length);
        if (tangent != null) {
          final dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
          final shadowPaint = Paint()..color = lineColor.withOpacity(0.6)..style = PaintingStyle.fill;

          canvas.drawCircle(tangent.position, 8.0, shadowPaint);
          canvas.drawCircle(tangent.position, 4.0, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumOnboardingChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Custom Onboarding Button with Press scaling
class _OnboardingTactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final BorderSide? border;
  final double borderRadius;
  final double? width;
  final double height;

  const _OnboardingTactileButton({
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
  State<_OnboardingTactileButton> createState() => _OnboardingTactileButtonState();
}

class _OnboardingTactileButtonState extends State<_OnboardingTactileButton> with SingleTickerProviderStateMixin {
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
