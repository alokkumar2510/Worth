import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'worth_background.dart';

typedef RestartCallback = void Function(Object error, StackTrace? stack);

RestartCallback? globalRestartCallback;

/// Triggers a global app restart with an error description.
/// Uses a microtask to ensure it doesn't interrupt layout/paint phases.
void triggerGlobalRestart(Object error, StackTrace? stack) {
  Future.microtask(() {
    if (globalRestartCallback != null) {
      globalRestartCallback!(error, stack);
    } else {
      debugPrint('[Worth Error Recovery] No global restart callback registered! Error: $error');
    }
  });
}

class AppRestartBoundary extends StatefulWidget {
  final Widget child;
  const AppRestartBoundary({required this.child, super.key});

  static AppRestartBoundaryState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppRestartBoundaryState>();
  }

  @override
  AppRestartBoundaryState createState() => AppRestartBoundaryState();
}

class AppRestartBoundaryState extends State<AppRestartBoundary> {
  Key _key = UniqueKey();
  String? _pendingError;
  DateTime? _lastRestartTime;
  bool _isInSafeMode = false;
  String? _safeModeError;
  String? _safeModeStackTrace;

  String? get pendingError => _pendingError;
  bool get isInSafeMode => _isInSafeMode;
  String? get safeModeError => _safeModeError;

  void clearPendingError() {
    setState(() {
      _pendingError = null;
    });
  }

  void resetSafeMode() {
    setState(() {
      _isInSafeMode = false;
      _safeModeError = null;
      _safeModeStackTrace = null;
      _key = UniqueKey();
      _lastRestartTime = DateTime.now(); // Reset consecutive timer
    });
  }

  void restartApp(Object error, StackTrace? stack) {
    if (_isInSafeMode) {
      debugPrint('[Worth Error Recovery] CRITICAL: Exception occurred while in Safe Mode! Aborting nested restart. Error: $error\n$stack');
      return;
    }

    final now = DateTime.now();
    debugPrint('[Worth Error Recovery] restartApp called with error: $error');

    // If we crashed within 3 seconds of a previous restart, trigger Safe Mode
    if (_lastRestartTime != null && now.difference(_lastRestartTime!) < const Duration(seconds: 3)) {
      debugPrint('[Worth Error Recovery] Consecutive crash detected! Entering Safe Mode.');
      setState(() {
        _isInSafeMode = true;
        _safeModeError = error.toString();
        _safeModeStackTrace = stack?.toString();
      });
      return;
    }

    setState(() {
      _key = UniqueKey();
      _pendingError = error.toString();
      _lastRestartTime = now;
    });
  }

  @override
  void initState() {
    super.initState();
    globalRestartCallback = restartApp;
  }

  @override
  void dispose() {
    if (globalRestartCallback == restartApp) {
      globalRestartCallback = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInSafeMode) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.darkBackground,
          useMaterial3: true,
        ),
        home: SafeModeCrashScreen(
          error: _safeModeError ?? 'Unknown exception',
          stackTrace: _safeModeStackTrace,
          onRetry: resetSafeMode,
        ),
      );
    }

    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

class CrashErrorPopupGuard extends StatefulWidget {
  final Widget child;
  const CrashErrorPopupGuard({required this.child, super.key});

  @override
  State<CrashErrorPopupGuard> createState() => _CrashErrorPopupGuardState();
}

class _CrashErrorPopupGuardState extends State<CrashErrorPopupGuard> with SingleTickerProviderStateMixin {
  String? _displayedError;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    // Check for pending error after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingError();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _checkPendingError() {
    if (!mounted) return;
    final boundary = AppRestartBoundary.of(context);
    if (boundary != null && boundary.pendingError != null) {
      setState(() {
        _displayedError = boundary.pendingError;
      });
      boundary.clearPendingError();
      _animController.forward();
    }
  }

  Future<void> _dismissPopup() async {
    await _animController.reverse();
    if (mounted) {
      setState(() {
        _displayedError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        if (_displayedError != null)
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                children: [
                  // Blur background
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _dismissPopup,
                      child: Container(
                        color: Colors.black.withOpacity(0.65),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                  // Glassmorphic dialog card
                  Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 480),
                            decoration: BoxDecoration(
                              color: AppColors.layer1.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: AppColors.darkDanger.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkDanger.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                                const BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 20,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Gradient Top Bar
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.darkDanger.withOpacity(0.15),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.darkDanger.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.darkDanger.withOpacity(0.4),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.error_outline_rounded,
                                            color: AppColors.darkDanger,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'System Recovered',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  letterSpacing: -0.2,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Auto-restart triggered successfully',
                                                style: GoogleFonts.inter(
                                                  color: AppColors.grey400,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Message & Error display
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Worth intercepted an unexpected crash and safely restarted the application runtime to prevent state or database corruption.',
                                          style: GoogleFonts.inter(
                                            color: AppColors.darkText.withOpacity(0.9),
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'INTERCEPTED EXCEPTION',
                                          style: GoogleFonts.inter(
                                            color: AppColors.grey500,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Error Log Block
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppColors.layer2,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppColors.glassBorder,
                                              width: 1,
                                            ),
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              _displayedError ?? 'Unknown error',
                                              style: GoogleFonts.jetBrainsMono(
                                                color: AppColors.darkDanger.withOpacity(0.95),
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Bottom button bar
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    decoration: const BoxDecoration(
                                      color: AppColors.layer2,
                                      border: Border(
                                        top: BorderSide(color: AppColors.glassBorder, width: 1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Builder(
                                          builder: (context) => TextButton(
                                            onPressed: () {
                                              Clipboard.setData(ClipboardData(text: _displayedError ?? ''));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Copied error to clipboard'),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.grey400,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'Copy Details',
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton(
                                          onPressed: _dismissPopup,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.darkPrimary,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            'Acknowledge',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
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
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class SafeModeCrashScreen extends StatelessWidget {
  final String error;
  final String? stackTrace;
  final VoidCallback onRetry;

  const SafeModeCrashScreen({
    required this.error,
    this.stackTrace,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E13), // Deep obsidian background directly
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: const Color(0xFF15141B), // Solid layer color instead of glassmorphism
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE53935).withOpacity(0.3), // Solid red border
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Safe Mode Header Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE53935).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.bug_report_rounded,
                        color: Color(0xFFE53935),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titles
                  const Center(
                    child: Text(
                      'Safe Mode Console',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'System Recovery & Offline Ledger Protection',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Explanation text
                  const Text(
                    'Worth has detected consecutive crashes during startup. To prevent data corruption or infinite bootloops in your offline SQLite ledger, the app has suspended normal launch and initialized the Safe Mode Console.',
                    style: TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Console pane header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DIAGNOSTIC SYSTEM LOG',
                        style: TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'LEVEL: CRITICAL',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Monospace Code Log Pane
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0E13), // Dark solid box
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EXCEPTION: $error',
                              style: const TextStyle(
                                color: Color(0xFFE53935),
                                fontFamily: 'monospace', // Standard fallback monospace
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (stackTrace != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                'STACK TRACE:\n$stackTrace',
                                style: const TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final logText = 'Error: $error\n\nStackTrace:\n$stackTrace';
                            Clipboard.setData(ClipboardData(text: logText));
                          },
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          label: const Text('Copy Error Log'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF9E9E9E),
                            side: BorderSide(color: Colors.white.withOpacity(0.08)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Try Restarting'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7), // Premium indigo/purple primary
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
