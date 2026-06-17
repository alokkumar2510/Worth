import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';

class NotificationPermissionScreen extends ConsumerStatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  ConsumerState<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends ConsumerState<NotificationPermissionScreen> {
  bool _transactions = true;
  bool _checkIns = true;
  bool _sips = true;
  bool _goals = true;
  bool _isLoading = false;

  Future<void> _requestNotificationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Trigger native system permission dialog
      final status = await Permission.notification.request();
      final isGranted = status.isGranted;

      final notifier = ref.read(mockDatabaseProvider.notifier);
      
      // Update system status
      notifier.updateNotificationsEnabled(isGranted);
      
      // Save specific category preferences
      notifier.updateNotificationPref('transactions', _transactions);
      notifier.updateNotificationPref('checkins', _checkIns);
      notifier.updateNotificationPref('sip', _sips);
      notifier.updateNotificationPref('goals', _goals);
      
      // Mark as asked to complete flow
      notifier.setNotificationsAsked(true);
    } catch (_) {
      // Fallback
      final notifier = ref.read(mockDatabaseProvider.notifier);
      notifier.setNotificationsAsked(true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipNotifications() {
    final notifier = ref.read(mockDatabaseProvider.notifier);
    notifier.updateNotificationsEnabled(false);
    notifier.setNotificationsAsked(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Background atmospheric glows
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.darkPrimary.withOpacity(0.08),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.06),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 12),
                  // Header section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkPrimary.withOpacity(0.12),
                          border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3), width: 1.5),
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          size: 32,
                          color: AppColors.darkPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Stay on top of your finances.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.0,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enable notifications to secure your financial consistency and stay updated on important activities.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.grey400,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),

                  // Selection choices card
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      borderColor: AppColors.darkPrimary.withOpacity(0.15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPrefSwitch(
                            title: 'Transaction reminders',
                            subtitle: 'Get notified for logs, transfers, and balances',
                            value: _transactions,
                            onChanged: (val) => setState(() => _transactions = val),
                            icon: Icons.swap_horiz_rounded,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          _buildPrefSwitch(
                            title: 'Daily check-ins',
                            subtitle: 'Keep your streak alive with quick updates',
                            value: _checkIns,
                            onChanged: (val) => setState(() => _checkIns = val),
                            icon: Icons.today_rounded,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          _buildPrefSwitch(
                            title: 'SIP reminders',
                            subtitle: 'Automate your investments without missing dates',
                            value: _sips,
                            onChanged: (val) => setState(() => _sips = val),
                            icon: Icons.calendar_month_rounded,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          _buildPrefSwitch(
                            title: 'Goal reminders',
                            subtitle: 'Celebrate progress and milestone achievements',
                            value: _goals,
                            onChanged: (val) => setState(() => _goals = val),
                            icon: Icons.emoji_events_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Button Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Allow Notifications Button
                      _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(color: AppColors.darkPrimary),
                              ),
                            )
                          : _LocalTactileButton(
                              onTap: _requestNotificationPermission,
                              gradient: const LinearGradient(
                                colors: [AppColors.darkPrimary, AppColors.glow],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              child: Text(
                                'Allow Notifications',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                      const SizedBox(height: 12),
                      // Skip Button
                      _LocalTactileButton(
                        onTap: _skipNotifications,
                        color: Colors.transparent,
                        border: const BorderSide(color: AppColors.glassBorder, width: 1.0),
                        child: Text(
                          'Maybe Later',
                          style: GoogleFonts.inter(
                            color: AppColors.grey500,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.darkPrimary,
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
      ),
      secondary: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.layer1.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.darkPrimary),
      ),
    );
  }
}

class _LocalTactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final BorderSide? border;
  final double borderRadius;
  final double? width;
  final double height;

  const _LocalTactileButton({
    required this.child,
    this.onTap,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius = 18.0,
    this.width,
    this.height = 50.0,
  });

  @override
  State<_LocalTactileButton> createState() => _LocalTactileButtonState();
}

class _LocalTactileButtonState extends State<_LocalTactileButton> with SingleTickerProviderStateMixin {
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
