import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/providers/mock_database.dart';

// ─────────────────────────────────────────────────────────────
//  WORTH — Premium "Luxury OS" Onboarding
//
//  A cinematic, full-bleed, immersive entry experience.
//  5 slides: Brand Reveal → Wealth Ecosystem → Net Worth
//            → Vault Security → Begin Journey
//
//  Design language: Apple Vision Pro, CRED, Linear, Arc
//  70% visuals, 30% text. Zero empty space.
// ─────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;
  double _pageOffset = 0.0;

  // Global animation controllers
  late AnimationController _meshController;
  late AnimationController _pulseController;
  late AnimationController _orbitalController;
  late AnimationController _breatheController;
  late AnimationController _chartController;
  late AnimationController _entranceController;

  // Entrance fade
  late Animation<double> _entranceFade;
  late Animation<double> _entranceScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    _pageController = PageController();
    _pageController.addListener(() {
      if (mounted) {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      }
    });

    // Slow mesh gradient morph
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Concentric ring pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Orbital float animation
    _orbitalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Breathe animation for vault
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Wealth chart draw
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    // Initial entrance cinematic
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _entranceFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _entranceScale = Tween<double>(begin: 1.08, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _meshController.dispose();
    _pulseController.dispose();
    _orbitalController.dispose();
    _breatheController.dispose();
    _chartController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutQuint,
      );
    }
  }

  void _skipToLast() {
    _pageController.animateToPage(
      4,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuint,
    );
  }

  void _finishSetup() async {
    final notifier = ref.read(mockDatabaseProvider.notifier);

    // Create default primary bank account container
    await notifier.addAccount(
      'Primary Bank',
      'bank',
      'Setup automatically during onboarding',
      0.0,
      id: 'acc_primary_bank_uuid',
    );

    // Complete onboarding state transition
    await notifier.completeOnboarding();

    // Transition to Login Screen
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF030305),
      body: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          return Opacity(
            opacity: _entranceFade.value,
            child: Transform.scale(
              scale: _entranceScale.value,
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // ── Full-screen living mesh gradient background ──
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _meshController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _LivingMeshPainter(
                      time: _meshController.value,
                      pageOffset: _pageOffset,
                    ),
                  );
                },
              ),
            ),

            // ── Floating particle field ──
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _orbitalController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ParticleFieldPainter(
                      time: _orbitalController.value,
                      screenSize: size,
                    ),
                  );
                },
              ),
            ),

            // ── Cinematic noise overlay ──
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _CinematicNoisePainter(),
                ),
              ),
            ),

            // ── Main PageView content ──
            PageView(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                if (page == 2) {
                  _chartController.reset();
                  _chartController.forward();
                }
                HapticFeedback.selectionClick();
              },
              children: [
                _buildBrandRevealSlide(size),
                _buildWealthEcosystemSlide(size),
                _buildNetWorthSlide(size),
                _buildVaultSecuritySlide(size),
                _buildBeginJourneySlide(size),
              ],
            ),

            // ── Top-right skip button ──
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: AnimatedOpacity(
                  opacity: _currentPage == 4 ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: _currentPage == 4,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0, top: 12.0),
                      child: GestureDetector(
                        onTap: _skipToLast,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom navigation bar ──
            _buildBottomBar(size),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  BOTTOM NAVIGATION BAR
  // ═══════════════════════════════════════════════════════════
  Widget _buildBottomBar(Size size) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.06),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Fluid dot indicators
                  Row(
                    children: List.generate(5, (i) {
                      final isActive = _currentPage == i;
                      return GestureDetector(
                        onTap: () => _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          height: 5,
                          width: isActive ? 32 : 5,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: isActive
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.darkPrimary,
                                      AppColors.glow,
                                    ],
                                  )
                                : null,
                            color: isActive
                                ? null
                                : Colors.white.withOpacity(0.15),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.darkPrimary.withOpacity(0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),

                  // Action Button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _currentPage == 4
                        ? _PremiumActionButton(
                            key: const ValueKey('get_started'),
                            onTap: _finishSetup,
                            isGetStarted: true,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'BEGIN',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
                          )
                        : _PremiumActionButton(
                            key: const ValueKey('next'),
                            onTap: _nextPage,
                            isGetStarted: false,
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SLIDE 1 — BRAND REVEAL
  //  Full-screen amethyst mesh → Logo → Tagline
  // ═══════════════════════════════════════════════════════════
  Widget _buildBrandRevealSlide(Size size) {
    final parallax = (0 - _pageOffset).clamp(-1.5, 1.5);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Concentric emanation rings
          ...List.generate(4, (i) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final delay = i * 0.15;
                final progress =
                    ((_pulseController.value + delay) % 1.0);
                final scale = 1.0 + (progress * 0.8);
                final opacity = (1.0 - progress) * 0.12;

                return Transform.translate(
                  offset: Offset(parallax * 40, 0),
                  child: Container(
                    width: 200 * scale,
                    height: 200 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.darkPrimary.withOpacity(opacity),
                        width: 1.0,
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Core logo orb
          Transform.translate(
            offset: Offset(parallax * 60, 0),
            child: AnimatedBuilder(
              animation: _breatheController,
              builder: (context, _) {
                final breathe = _breatheController.value;
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment(-0.3, -0.3),
                      radius: 0.9,
                      colors: [
                        AppColors.darkPrimary.withOpacity(0.25),
                        AppColors.glow.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.darkPrimary.withOpacity(0.3 + breathe * 0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkPrimary.withOpacity(0.15 + breathe * 0.08),
                        blurRadius: 60 + breathe * 20,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: AppColors.glow.withOpacity(0.05),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        AssetPaths.logoMark,
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom text
          Positioned(
            bottom: 120,
            left: 32,
            right: 32,
            child: Transform.translate(
              offset: Offset(parallax * 30, 0),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Colors.white,
                        Color(0xFFE0D4FF),
                        AppColors.glow,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'Worth',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2.0,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your complete financial\noperating system.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.45),
                      height: 1.5,
                      letterSpacing: -0.2,
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

  // ═══════════════════════════════════════════════════════════
  //  SLIDE 2 — WEALTH ECOSYSTEM
  //  Floating, orbiting category orbs around a central hub
  // ═══════════════════════════════════════════════════════════
  Widget _buildWealthEcosystemSlide(Size size) {
    final parallax = (1 - _pageOffset).clamp(-1.5, 1.5);

    final categories = [
      _EcoCategory('Assets', Icons.account_balance_wallet_rounded, const Color(0xFF22C55E)),
      _EcoCategory('Investments', Icons.trending_up_rounded, AppColors.darkPrimary),
      _EcoCategory('Liabilities', Icons.receipt_long_rounded, const Color(0xFFEF4444)),
      _EcoCategory('Goals', Icons.flag_rounded, const Color(0xFFF59E0B)),
      _EcoCategory('Income', Icons.payments_rounded, const Color(0xFF06B6D4)),
      _EcoCategory('SIPs', Icons.loop_rounded, const Color(0xFFA78BFA)),
    ];

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Orbital paths (ghost rings)
          Transform.translate(
            offset: Offset(parallax * 40, -size.height * 0.06),
            child: AnimatedBuilder(
              animation: _orbitalController,
              builder: (context, _) {
                final time = _orbitalController.value * 2 * math.pi;

                return SizedBox(
                  width: size.width,
                  height: size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ghost orbit ring
                      Container(
                        width: size.width * 0.72,
                        height: size.width * 0.72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.04),
                            width: 1,
                          ),
                        ),
                      ),
                      // Inner ghost orbit ring
                      Container(
                        width: size.width * 0.44,
                        height: size.width * 0.44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.03),
                            width: 1,
                          ),
                        ),
                      ),

                      // Central hub
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.layer2.withOpacity(0.8),
                          border: Border.all(
                            color: AppColors.darkPrimary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkPrimary.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.hub_rounded,
                            color: AppColors.darkPrimary,
                            size: 28,
                          ),
                        ),
                      ),

                      // Orbiting category nodes
                      ...List.generate(categories.length, (i) {
                        final cat = categories[i];
                        final angle =
                            time + (i * 2 * math.pi / categories.length);
                        final radius = i.isEven
                            ? size.width * 0.22
                            : size.width * 0.36;
                        final x = math.cos(angle) * radius;
                        final y = math.sin(angle) * radius * 0.85;

                        return Transform.translate(
                          offset: Offset(x, y),
                          child: _buildOrbitNode(cat),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom text
          Positioned(
            bottom: 120,
            left: 32,
            right: 32,
            child: Transform.translate(
              offset: Offset(parallax * 20, 0),
              child: Column(
                children: [
                  Text(
                    'Everything\nIn One Place.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Assets, investments, liabilities, goals,\nSIPs, receivables — unified.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.5,
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

  Widget _buildOrbitNode(_EcoCategory cat) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cat.color.withOpacity(0.12),
            border: Border.all(
              color: cat.color.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: cat.color.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(cat.icon, color: cat.color, size: 22),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            cat.label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SLIDE 3 — NET WORTH VISUALIZATION
  //  Premium animated bezier chart with glass card
  // ═══════════════════════════════════════════════════════════
  Widget _buildNetWorthSlide(Size size) {
    final parallax = (2 - _pageOffset).clamp(-1.5, 1.5);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Chart card
          Transform.translate(
            offset: Offset(parallax * 50, -size.height * 0.05),
            child: Container(
              width: size.width - 40,
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkPrimary.withOpacity(0.06),
                    blurRadius: 60,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NET WORTH',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.35),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '₹24,85,000',
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.darkSuccess.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      AppColors.darkSuccess.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.trending_up_rounded,
                                    size: 12,
                                    color: AppColors.darkSuccess,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+18.4%',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkSuccess,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Chart area
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _chartController,
                            builder: (context, _) {
                              return CustomPaint(
                                size: Size.infinite,
                                painter: _PremiumWealthChartPainter(
                                  progress: _chartController.value,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Time labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov']
                              .map((m) => Text(
                                    m,
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      color: Colors.white.withOpacity(0.2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Stats row and Bottom text column (combined to prevent overlap)
          Positioned(
            bottom: 110,
            left: 32,
            right: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(parallax * 25, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniStat('Assets', '₹32.4L', AppColors.darkSuccess),
                      _buildStatDivider(),
                      _buildMiniStat('Liabilities', '₹7.5L', AppColors.darkDanger),
                      _buildStatDivider(),
                      _buildMiniStat('Growth', '+124%', AppColors.darkPrimary),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Transform.translate(
                  offset: Offset(parallax * 15, 0),
                  child: Column(
                    children: [
                      Text(
                        'Watch Your\nWealth Grow.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Real-time analytics that track every\nrupee of your net worth over time.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.4),
                          height: 1.5,
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

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.3),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.06),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SLIDE 4 — VAULT SECURITY
  //  Rotating vault handle with shield layers
  // ═══════════════════════════════════════════════════════════
  Widget _buildVaultSecuritySlide(Size size) {
    final parallax = (3 - _pageOffset).clamp(-1.5, 1.5);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vault visual
          Transform.translate(
            offset: Offset(parallax * 50, -size.height * 0.05),
            child: AnimatedBuilder(
              animation: Listenable.merge([_orbitalController, _breatheController]),
              builder: (context, _) {
                final rotation = _orbitalController.value * 2 * math.pi;
                final breathe = _breatheController.value;

                return SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer shield ring 3
                      Container(
                        width: 240 + breathe * 8,
                        height: 240 + breathe * 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.darkSuccess.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                      ),
                      // Outer shield ring 2
                      Container(
                        width: 200 + breathe * 4,
                        height: 200 + breathe * 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.darkSuccess.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      // Outer vault ring with arc segments
                      Transform.rotate(
                        angle: rotation * 0.3,
                        child: CustomPaint(
                          size: const Size(170, 170),
                          painter: _VaultArcPainter(
                            color: AppColors.darkSuccess.withOpacity(0.2),
                          ),
                        ),
                      ),
                      // Main vault body
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.2, -0.3),
                            colors: [
                              AppColors.layer2,
                              AppColors.layer1,
                              const Color(0xFF080810),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.darkSuccess.withOpacity(0.25),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkSuccess.withOpacity(0.1),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Vault spokes
                            ...List.generate(4, (i) {
                              return Transform.rotate(
                                angle: rotation * 0.15 +
                                    (i * math.pi / 2),
                                child: Container(
                                  width: 3,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.darkSuccess.withOpacity(0.0),
                                        AppColors.darkSuccess.withOpacity(0.15),
                                        AppColors.darkSuccess.withOpacity(0.0),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }),
                            // Center lock icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0A0A12),
                                border: Border.all(
                                  color: AppColors.darkSuccess.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.shield_rounded,
                                color: AppColors.darkSuccess,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Security badges and Bottom text column (combined to prevent overlap)
          Positioned(
            bottom: 110,
            left: 32,
            right: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: Offset(parallax * 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSecurityBadge('AES-256', Icons.lock_rounded),
                      const SizedBox(width: 10),
                      _buildSecurityBadge('OFFLINE', Icons.cloud_off_rounded),
                      const SizedBox(width: 10),
                      _buildSecurityBadge('LOCAL', Icons.phone_android_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Transform.translate(
                  offset: Offset(parallax * 15, 0),
                  child: Column(
                    children: [
                      Text(
                        'Secure &\nOffline First.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Your financial data never leaves your device.\nEncrypted. Private. Always available.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.4),
                          height: 1.5,
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

  Widget _buildSecurityBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.darkSuccess.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkSuccess.withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.darkSuccess.withOpacity(0.7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.darkSuccess.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SLIDE 5 — BEGIN JOURNEY
  //  Culminating orb with radial glow
  // ═══════════════════════════════════════════════════════════
  Widget _buildBeginJourneySlide(Size size) {
    final parallax = (4 - _pageOffset).clamp(-1.5, 1.5);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Massive radial glow
          Transform.translate(
            offset: Offset(parallax * 30, -size.height * 0.05),
            child: AnimatedBuilder(
              animation: _breatheController,
              builder: (context, _) {
                final breathe = _breatheController.value;
                return Container(
                  width: 350 + breathe * 30,
                  height: 350 + breathe * 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.darkPrimary.withOpacity(0.12),
                        AppColors.darkPrimary.withOpacity(0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Concentric rings
          ...List.generate(3, (i) {
            return Transform.translate(
              offset: Offset(parallax * 30, -size.height * 0.05),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final progress = (_pulseController.value + i * 0.2) % 1.0;
                  return Container(
                    width: 160 + (progress * 100) + (i * 40),
                    height: 160 + (progress * 100) + (i * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.glow.withOpacity(
                          (1.0 - progress) * 0.08,
                        ),
                        width: 1,
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Central launch orb
          Transform.translate(
            offset: Offset(parallax * 40, -size.height * 0.05),
            child: AnimatedBuilder(
              animation: _breatheController,
              builder: (context, _) {
                final breathe = _breatheController.value;
                return Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.2, -0.3),
                      radius: 0.8,
                      colors: [
                        AppColors.darkPrimary.withOpacity(0.3),
                        AppColors.glow.withOpacity(0.1),
                        AppColors.layer1.withOpacity(0.8),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.darkPrimary.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkPrimary.withOpacity(0.2 + breathe * 0.1),
                        blurRadius: 80,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, AppColors.glow],
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom text
          Positioned(
            bottom: 120,
            left: 32,
            right: 32,
            child: Transform.translate(
              offset: Offset(parallax * 15, 0),
              child: Column(
                children: [
                  Text(
                    'Start Your\nJourney.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Take control of your financial future.\nMaster your wealth portfolio.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.5,
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
}

// ═══════════════════════════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════════════════════════
class _EcoCategory {
  final String label;
  final IconData icon;
  final Color color;
  const _EcoCategory(this.label, this.icon, this.color);
}

// ═══════════════════════════════════════════════════════════════
//  PREMIUM ACTION BUTTON
//  Tactile press with gradient glow
// ═══════════════════════════════════════════════════════════════
class _PremiumActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isGetStarted;

  const _PremiumActionButton({
    required this.child,
    this.onTap,
    required this.isGetStarted,
    super.key,
  });

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap?.call();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isGetStarted ? 28 : 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: widget.isGetStarted
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.darkPrimary, AppColors.glow],
                  )
                : null,
            color: widget.isGetStarted
                ? null
                : Colors.white.withOpacity(0.08),
            border: widget.isGetStarted
                ? null
                : Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
            boxShadow: widget.isGetStarted
                ? [
                    BoxShadow(
                      color: AppColors.darkPrimary.withOpacity(0.35),
                      blurRadius: 20,
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

// ═══════════════════════════════════════════════════════════════
//  LIVING MESH GRADIENT PAINTER
//  Continuous morphing multi-blob gradient background
// ═══════════════════════════════════════════════════════════════
class _LivingMeshPainter extends CustomPainter {
  final double time;
  final double pageOffset;

  _LivingMeshPainter({required this.time, required this.pageOffset});

  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF030305),
    );

    final pageIndex = pageOffset.floor().clamp(0, 4);
    final pageFraction = pageOffset - pageIndex;

    // Page-specific color palettes
    final palettes = [
      // Slide 1: Brand — Deep Amethyst
      [
        const Color(0xFF1a0a2e),
        const Color(0xFF16082a),
        const Color(0xFF0d0518),
      ],
      // Slide 2: Ecosystem — Teal-Violet
      [
        const Color(0xFF0a1628),
        const Color(0xFF0c1a2e),
        const Color(0xFF0a0d1e),
      ],
      // Slide 3: Net Worth — Emerald-Violet
      [
        const Color(0xFF0a1a15),
        const Color(0xFF0d1a1e),
        const Color(0xFF08100e),
      ],
      // Slide 4: Vault — Steel Green
      [
        const Color(0xFF0a1510),
        const Color(0xFF0d120e),
        const Color(0xFF080e0c),
      ],
      // Slide 5: Launch — Warm Amethyst
      [
        const Color(0xFF1a0e22),
        const Color(0xFF120a18),
        const Color(0xFF0a0810),
      ],
    ];

    final currentPalette = palettes[pageIndex];
    final nextPalette = palettes[(pageIndex + 1).clamp(0, 4)];

    // Interpolate colors between pages
    final colors = List.generate(3, (i) {
      return Color.lerp(currentPalette[i], nextPalette[i], pageFraction)!;
    });

    final t = time * 2 * math.pi;

    // Draw multiple morphing gradient blobs
    _drawBlob(canvas, size,
      cx: size.width * (0.3 + 0.15 * math.sin(t)),
      cy: size.height * (0.25 + 0.1 * math.cos(t * 0.7)),
      radius: size.width * 0.6,
      color: colors[0],
    );

    _drawBlob(canvas, size,
      cx: size.width * (0.7 + 0.1 * math.cos(t * 0.8)),
      cy: size.height * (0.6 + 0.12 * math.sin(t * 0.5)),
      radius: size.width * 0.5,
      color: colors[1],
    );

    _drawBlob(canvas, size,
      cx: size.width * (0.5 + 0.2 * math.sin(t * 0.6)),
      cy: size.height * (0.8 + 0.08 * math.cos(t * 0.9)),
      radius: size.width * 0.45,
      color: colors[2],
    );

    // Subtle accent blob
    _drawBlob(canvas, size,
      cx: size.width * (0.2 + 0.15 * math.cos(t * 1.2)),
      cy: size.height * (0.5 + 0.15 * math.sin(t * 0.4)),
      radius: size.width * 0.35,
      color: AppColors.darkPrimary.withOpacity(0.06),
    );
  }

  void _drawBlob(Canvas canvas, Size size,
      {required double cx,
      required double cy,
      required double radius,
      required Color color}) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0.0)],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      )
      ..blendMode = BlendMode.screen;

    canvas.drawCircle(Offset(cx, cy), radius, paint);
  }

  @override
  bool shouldRepaint(covariant _LivingMeshPainter old) => true;
}

// ═══════════════════════════════════════════════════════════════
//  PARTICLE FIELD PAINTER
//  Subtle floating dust particles for depth
// ═══════════════════════════════════════════════════════════════
class _ParticleFieldPainter extends CustomPainter {
  final double time;
  final Size screenSize;
  static final List<_Particle> _particles = _generateParticles(35);

  _ParticleFieldPainter({required this.time, required this.screenSize});

  static List<_Particle> _generateParticles(int count) {
    final rng = math.Random(42);
    return List.generate(count, (_) {
      return _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 1.0 + rng.nextDouble() * 2.0,
        speed: 0.2 + rng.nextDouble() * 0.6,
        phase: rng.nextDouble() * 2 * math.pi,
        opacity: 0.08 + rng.nextDouble() * 0.15,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = time * 2 * math.pi * p.speed;
      final x = (p.x + 0.03 * math.sin(t + p.phase)) * size.width;
      final y = ((p.y + time * p.speed * 0.1) % 1.0) * size.height;

      final flickerOpacity =
          p.opacity * (0.5 + 0.5 * math.sin(t * 2 + p.phase));

      final paint = Paint()
        ..color = Colors.white.withOpacity(flickerOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter old) => true;
}

class _Particle {
  final double x, y, size, speed, phase, opacity;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}

// ═══════════════════════════════════════════════════════════════
//  CINEMATIC NOISE PAINTER
//  Ultra-subtle film grain for depth
// ═══════════════════════════════════════════════════════════════
class _CinematicNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.008)
      ..strokeWidth = 1.0;

    final points = <Offset>[];
    for (double x = 0; x < size.width; x += 3) {
      for (double y = 0; y < size.height; y += 3) {
        final val = math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
        if ((val - val.floorToDouble()) < 0.08) {
          points.add(Offset(x, y));
        }
      }
    }
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════
//  PREMIUM WEALTH CHART PAINTER
//  Animated bezier wealth curve with gradient fill
// ═══════════════════════════════════════════════════════════════
class _PremiumWealthChartPainter extends CustomPainter {
  final double progress;

  _PremiumWealthChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;

    for (int i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points (smooth wealth curve)
    final points = [
      Offset(0, size.height * 0.82),
      Offset(size.width * 0.12, size.height * 0.75),
      Offset(size.width * 0.24, size.height * 0.68),
      Offset(size.width * 0.36, size.height * 0.60),
      Offset(size.width * 0.48, size.height * 0.52),
      Offset(size.width * 0.58, size.height * 0.48),
      Offset(size.width * 0.68, size.height * 0.38),
      Offset(size.width * 0.78, size.height * 0.30),
      Offset(size.width * 0.88, size.height * 0.22),
      Offset(size.width, size.height * 0.12),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cpX = (p0.dx + p1.dx) / 2;
      path.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
    }

    // Extract animated portion
    final metrics = path.computeMetrics();
    final animPath = Path();

    for (final m in metrics) {
      animPath.addPath(
        m.extractPath(0, m.length * progress),
        Offset.zero,
      );
    }

    // Gradient fill under curve
    if (progress > 0.01) {
      final metricList = animPath.computeMetrics().toList();
      if (metricList.isNotEmpty) {
        final lastPt = metricList.last
                .getTangentForOffset(metricList.last.length)
                ?.position ??
            Offset(size.width * progress, size.height);

        final fillPath = Path.from(animPath)
          ..lineTo(lastPt.dx, size.height)
          ..lineTo(0, size.height)
          ..close();

        final fillPaint = Paint()
          ..style = PaintingStyle.fill
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkPrimary.withOpacity(0.15),
              AppColors.darkPrimary.withOpacity(0.02),
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

        canvas.drawPath(fillPath, fillPaint);
      }
    }

    // Main line
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [AppColors.darkPrimary, AppColors.glow],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(animPath, linePaint);

    // Leading dot
    if (progress > 0.05) {
      final metricList = animPath.computeMetrics().toList();
      if (metricList.isNotEmpty) {
        final tangent = metricList.last
            .getTangentForOffset(metricList.last.length);
        if (tangent != null) {
          // Glow
          canvas.drawCircle(
            tangent.position,
            8,
            Paint()
              ..color = AppColors.glow.withOpacity(0.3)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
          );
          // Dot
          canvas.drawCircle(
            tangent.position,
            4,
            Paint()..color = Colors.white,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumWealthChartPainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════
//  VAULT ARC PAINTER
//  Rotating segmented arcs for vault visual
// ═══════════════════════════════════════════════════════════════
class _VaultArcPainter extends CustomPainter {
  final Color color;

  _VaultArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw 6 arc segments
    for (int i = 0; i < 6; i++) {
      final startAngle = (i * math.pi / 3) + (math.pi / 12);
      const sweepAngle = math.pi / 6;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VaultArcPainter old) => old.color != color;
}
