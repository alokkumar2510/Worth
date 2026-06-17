import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../providers/app_lock_provider.dart';
import '../providers/mock_database.dart';
import '../services/lock_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP LOCK GUARD - LIFECYCLE OBSERVER & ROUTER OVERLAY
// ─────────────────────────────────────────────────────────────────────────────
class AppLockGuard extends ConsumerStatefulWidget {
  final Widget child;
  const AppLockGuard({required this.child, super.key});

  @override
  ConsumerState<AppLockGuard> createState() => _AppLockGuardState();
}

class _AppLockGuardState extends ConsumerState<AppLockGuard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Lock immediately on cold start if app lock is enabled
    Future.microtask(() {
      final dbState = ref.read(mockDatabaseProvider);
      if (dbState.appLockEnabled) {
        ref.read(appLockProvider.notifier).lockImmediately();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lockNotifier = ref.read(appLockProvider.notifier);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      lockNotifier.recordBackgroundTime();
    } else if (state == AppLifecycleState.resumed) {
      lockNotifier.handleAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockProvider);
    final dbState = ref.watch(mockDatabaseProvider);

    if (dbState.appLockEnabled && lockState.isLocked) {
      return Stack(
        textDirection: TextDirection.ltr,
        children: [
          widget.child,
          const AppLockScreen(),
        ],
      );
    }
    return widget.child;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP LOCK SCREEN - FROSTED GLASS & PIN PAD UI
// ─────────────────────────────────────────────────────────────────────────────
class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String _enteredPin = '';
  bool _isBiometricsAvailable = false;
  bool _showError = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometrics();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBiometrics();
    }
  }

  Future<void> _checkBiometrics() async {
    final lockState = ref.read(appLockProvider);
    if (lockState.isAuthenticating) return;

    final lockService = ref.read(lockServiceProvider);
    final isAvailable = await lockService.isBiometricsAvailable();
    if (mounted) {
      setState(() {
        _isBiometricsAvailable = isAvailable;
      });
    }

    // Auto-trigger biometric prompt on screen reveal
    if (isAvailable) {
      _triggerBiometrics();
    }
  }

  Future<void> _triggerBiometrics() async {
    final lockNotifier = ref.read(appLockProvider.notifier);
    lockNotifier.setAuthenticating(true);
    final lockService = ref.read(lockServiceProvider);
    final success = await lockService.authenticate();
    if (success && mounted) {
      lockNotifier.unlock();
    } else {
      lockNotifier.setAuthenticating(false);
    }
  }

  void _handleKeyPress(String value) {
    if (_showError) {
      setState(() {
        _showError = false;
        _enteredPin = '';
      });
    }

    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += value;
      });

      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _showError = false;
      });
    }
  }

  void _verifyPin() {
    final dbState = ref.read(mockDatabaseProvider);
    final targetPin = dbState.appLockPin.isEmpty ? '1234' : dbState.appLockPin;

    if (_enteredPin == targetPin) {
      ref.read(appLockProvider.notifier).unlock();
    } else {
      setState(() {
        _showError = true;
      });
      _shakeController.forward(from: 0.0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect PIN. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
        color: Colors.transparent,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: AppColors.darkBackground.withOpacity(0.85),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Header section
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.darkPrimary.withOpacity(0.08),
                            border: Border.all(
                              color: AppColors.darkPrimary.withOpacity(0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkPrimary.withOpacity(0.12),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.darkPrimary,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Worth.',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showError ? 'Incorrect PIN' : 'Enter PIN to Unlock',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _showError ? AppColors.darkDanger : AppColors.grey400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
  
                    // PIN Dots
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        final offset = math.sin(_shakeAnimation.value * math.pi) * 8.0;
                        return Transform.translate(
                          offset: Offset(offset, 0.0),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isActive = index < _enteredPin.length;
                          return Container(
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? (_showError ? AppColors.darkDanger : AppColors.darkPrimary)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isActive
                                    ? (_showError ? AppColors.darkDanger : AppColors.darkPrimary)
                                    : AppColors.glassBorder,
                                width: 1.5,
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: (_showError ? AppColors.darkDanger : AppColors.darkPrimary).withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                    ),
  
                    // Keypad grid
                    Container(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildKeyButton('1'),
                              _buildKeyButton('2'),
                              _buildKeyButton('3'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildKeyButton('4'),
                              _buildKeyButton('5'),
                              _buildKeyButton('6'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildKeyButton('7'),
                              _buildKeyButton('8'),
                              _buildKeyButton('9'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Biometric button or spacer
                              _isBiometricsAvailable
                                  ? _buildIconButton(Icons.fingerprint_rounded, _triggerBiometrics)
                                  : const SizedBox(width: 68, height: 68),
                              _buildKeyButton('0'),
                              _buildIconButton(Icons.backspace_outlined, _handleBackspace),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(String val) {
    return GestureDetector(
      onTap: () => _handleKeyPress(val),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.layer2.withOpacity(0.4),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Center(
          child: Text(
            val,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.layer1.withOpacity(0.2),
        ),
        child: Icon(
          icon,
          color: Colors.white70,
          size: 22,
        ),
      ),
    );
  }
}
