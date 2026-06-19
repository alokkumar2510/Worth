import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../providers/auth_providers.dart';
import '../../../../core/providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isRegistering = false;
  bool _isLoading = false;
  bool _showEmailForm = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    if (_isRegistering && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      User? user;
      if (_isRegistering) {
        user = await authRepo.signUpWithEmailAndPassword(email, password, displayName: name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
        }
      } else {
        user = await authRepo.signInWithEmailAndPassword(email, password);
      }

      if (user != null) {
        ref.read(isRestoringProvider.notifier).state = true;
        try {
          final syncService = ref.read(syncServiceProvider);
          final isLocalEmpty = await syncService.isLocalDatabaseEmpty();
          if (isLocalEmpty) {
            final cloudCount = await syncService.getCloudRecordCount(user.uid);
            if (cloudCount > 0) {
              await syncService.manualRestore();
            }
          } else {
            await syncService.forceSync();
          }
        } catch (e) {
          print('[Login] Sync check failed: $e');
        } finally {
          ref.read(isRestoringProvider.notifier).state = false;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll(RegExp(r'\[.*\]\s*'), ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      if (user != null) {
        ref.read(isRestoringProvider.notifier).state = true;
        try {
          final syncService = ref.read(syncServiceProvider);
          final isLocalEmpty = await syncService.isLocalDatabaseEmpty();
          if (isLocalEmpty) {
            final cloudCount = await syncService.getCloudRecordCount(user.uid);
            if (cloudCount > 0) {
              await syncService.manualRestore();
            }
          } else {
            await syncService.forceSync();
          }
        } catch (e) {
          print('[Login] Google sign-in sync check failed: $e');
        } finally {
          ref.read(isRestoringProvider.notifier).state = false;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first to reset password.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset instructions sent to your email.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRestoring = ref.watch(isRestoringProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 64,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top: Minimalist Worth Logo Column
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 24),
                            const WorthLogo(size: 44),
                            const SizedBox(height: 12),
                            Text(
                              'Worth',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        // Middle: Headline & Auth Card
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Headline
                              Text(
                                "Know What You're Worth.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1.5,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Subheadline
                              Text(
                                "Track assets, liabilities, investments, and net worth in one place.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.grey400,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Auth Glass Container (Constrained width like Linear/Notion web panel)
                              Center(
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(28.0),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0.0, 0.05),
                                              end: Offset.zero,
                                            ).animate(CurvedAnimation(
                                              parent: animation,
                                              curve: Curves.easeOutCubic,
                                            )),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: _showEmailForm ? _buildEmailForm() : _buildOAuthChoices(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom: Luxury Apple-style Footer
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            "Privacy First  ·  Offline First  ·  Secure Sync",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grey500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (isRestoring)
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.layer2.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkPrimary.withOpacity(0.08),
                              blurRadius: 40,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 44,
                              height: 44,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkPrimary),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Restoring Profile',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Downloading cloud backup and rebuilding local transaction ledgers...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.grey400,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOAuthChoices() {
    return Column(
      key: const ValueKey('oauth_choices'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Continue with Google
        TactileButton(
          color: AppColors.layer2,
          border: const BorderSide(color: AppColors.glassBorder, width: 1.0),
          onTap: _isLoading ? null : _handleGoogleSignIn,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CustomPaint(
                  painter: GoogleLogoPainter(),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Continue with Google',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Continue with Email
        TactileButton(
          color: AppColors.layer1.withOpacity(0.4),
          border: const BorderSide(color: AppColors.glassBorder, width: 1.0),
          onTap: () {
            setState(() {
              _showEmailForm = true;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mail_outline_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Continue with Email',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return AutofillGroup(
      child: Column(
        key: const ValueKey('email_form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showEmailForm = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.grey500),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isRegistering ? 'Create Account' : 'Sign In',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isRegistering) ...[
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.grey500, size: 18),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Email field
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.grey500, size: 18),
            ),
          ),
          const SizedBox(height: 16),

          // Password field
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            autofillHints: _isRegistering ? const [AutofillHints.newPassword] : const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.grey500, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.grey500,
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            onSubmitted: (_) => _handleAuth(),
          ),
          const SizedBox(height: 10),

          // Forgot Password link
          if (!_isRegistering)
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _isLoading ? null : _handleForgotPassword,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      color: AppColors.glow,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Submit Button
          TactileButton(
            gradient: const LinearGradient(
              colors: [AppColors.darkPrimary, AppColors.glow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: _isLoading ? null : _handleAuth,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    _isRegistering ? 'Create Account' : 'Sign In',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          // Mode Switch Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isRegistering ? "Already have an account? " : "Don't have an account? ",
                style: const TextStyle(color: AppColors.grey500, fontSize: 13),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isRegistering = !_isRegistering;
                  });
                },
                child: Text(
                  _isRegistering ? 'Sign In' : 'Sign Up',
                  style: const TextStyle(color: AppColors.darkPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Worth Logo Emblem Widget
class WorthLogo extends StatelessWidget {
  final double size;
  const WorthLogo({required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkPrimary.withOpacity(0.08),
        border: Border.all(
          color: AppColors.darkPrimary.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.5),
          child: Image.asset(
            AssetPaths.logoMark,
            width: size * 0.6,
            height: size * 0.6,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// Vector Google Logo Painter
class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    
    final double scaleX = size.width / 24.0;
    final double scaleY = size.height / 24.0;
    
    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Blue segment
    paint.color = const Color(0xFF4285F4);
    final Path bluePath = Path()
      ..moveTo(23.49, 12.27)
      ..cubicTo(23.49, 11.46, 23.42, 10.65, 23.29, 9.87)
      ..lineTo(12.0, 9.87)
      ..lineTo(12.0, 14.38)
      ..lineTo(18.46, 14.38)
      ..cubicTo(18.17, 15.86, 17.32, 17.11, 16.04, 17.94)
      ..lineTo(16.04, 20.85)
      ..lineTo(19.94, 20.85)
      ..cubicTo(22.23, 18.77, 23.49, 15.72, 23.49, 12.27)
      ..close();
    canvas.drawPath(bluePath, paint);

    // Green segment
    paint.color = const Color(0xFF34A853);
    final Path greenPath = Path()
      ..moveTo(12.0, 24.0)
      ..cubicTo(15.24, 24.0, 17.95, 22.94, 19.93, 21.09)
      ..lineTo(16.04, 18.18)
      ..cubicTo(14.96, 18.9, 13.56, 19.34, 12.0, 19.34)
      ..cubicTo(8.9, 19.34, 6.28, 17.27, 5.35, 14.47)
      ..lineTo(1.3, 17.48)
      ..cubicTo(3.28, 21.36, 7.37, 24.0, 12.0, 24.0)
      ..close();
    canvas.drawPath(greenPath, paint);

    // Yellow segment
    paint.color = const Color(0xFFFBBC05);
    final Path yellowPath = Path()
      ..moveTo(5.35, 14.47)
      ..cubicTo(5.11, 13.75, 4.98, 12.99, 4.98, 12.2)
      ..cubicTo(4.98, 11.41, 5.11, 10.65, 5.35, 9.93)
      ..lineTo(1.3, 6.78)
      ..cubicTo(0.47, 8.41, 0.0, 10.23, 0.0, 12.2)
      ..cubicTo(0.0, 14.17, 0.47, 15.99, 1.3, 17.62)
      ..lineTo(5.35, 14.47)
      ..close();
    canvas.drawPath(yellowPath, paint);

    // Red segment
    paint.color = const Color(0xFFEA4335);
    final Path redPath = Path()
      ..moveTo(12.0, 4.75)
      ..cubicTo(13.77, 4.75, 15.35, 5.36, 16.6, 6.55)
      ..lineTo(20.02, 3.13)
      ..cubicTo(17.93, 1.19, 15.22, 0.0, 12.0, 0.0)
      ..cubicTo(7.37, 0.0, 3.28, 2.64, 1.3, 6.78)
      ..lineTo(5.35, 9.93)
      ..cubicTo(6.28, 7.13, 8.9, 5.06, 12.0, 5.06)
      ..close();
    canvas.drawPath(redPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    this.height = 50.0,
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
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
