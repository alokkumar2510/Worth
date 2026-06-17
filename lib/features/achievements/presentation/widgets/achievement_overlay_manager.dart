import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/services/gamification_engine.dart';
import '../../../../core/constants/app_colors.dart';
import 'crystal_badge.dart';

class AchievementOverlayManager {
  static OverlayEntry? _currentEntry;

  static void show({
    required BuildContext context,
    required GamificationEvent event,
    required VoidCallback onDismiss,
  }) {
    dismiss();

    final overlay = Overlay.of(context);
    
    _currentEntry = OverlayEntry(
      builder: (context) {
        return AchievementBannerWidget(
          event: event,
          onDismiss: () {
            dismiss();
            onDismiss();
          },
        );
      },
    );

    overlay.insert(_currentEntry!);
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class AchievementBannerWidget extends StatefulWidget {
  final GamificationEvent event;
  final VoidCallback onDismiss;

  const AchievementBannerWidget({
    required this.event,
    required this.onDismiss,
    super.key,
  });

  @override
  State<AchievementBannerWidget> createState() => _AchievementBannerWidgetState();
}

class _AchievementBannerWidgetState extends State<AchievementBannerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _dismissTimer;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      reverseDuration: const Duration(milliseconds: 450),
    );

    _controller.forward().then((_) {
      _startDismissTimer();
    });
  }

  void _startDismissTimer() {
    _dismissTimer = Timer(const Duration(milliseconds: 3500), () {
      _triggerExit();
    });
  }

  void _triggerExit() {
    if (_isExiting) return;
    if (!mounted) return;
    setState(() {
      _isExiting = true;
    });
    _dismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category, String type) {
    if (type == 'milestone') {
      return const Color(0xFFD4AF37); // Gold for milestones
    }
    switch (category) {
      case 'wealth_building':
        return const Color(0xFF00E676); // Emerald Green
      case 'investment':
        return const Color(0xFF00B0FF); // Sapphire Blue
      case 'debt_management':
        return const Color(0xFFE040FB); // Amethyst Purple
      case 'receivables':
        return const Color(0xFFFF9100); // Amber Orange
      case 'consistency':
        return const Color(0xFFB0BEC5); // Silver/Platinum
      case 'goals':
        return const Color(0xFFFF1744); // Ruby Red
      default:
        return const Color(0xFFD4AF37); // Gold default
    }
  }

  String _getCategoryLabel(String category, String type) {
    if (type == 'milestone') return 'NET WORTH MILESTONE';
    switch (category) {
      case 'wealth_building':
        return 'WEALTH BUILDING';
      case 'investment':
        return 'INVESTMENT';
      case 'debt_management':
        return 'DEBT COMPLIANCE';
      case 'receivables':
        return 'DEBT RECOVERY';
      case 'consistency':
        return 'TRACKING STREAK';
      case 'goals':
        return 'GOAL COMPLETE';
      default:
        return 'ACHIEVEMENT';
    }
  }

  @override
  Widget build(BuildContext context) {
    String category = 'wealth_building';
    if (widget.event.id.startsWith('inv_')) {
      category = 'investment';
    } else if (widget.event.id.startsWith('debt_')) {
      category = 'debt_management';
    } else if (widget.event.id.startsWith('rec_')) {
      category = 'receivables';
    } else if (widget.event.id.startsWith('con_')) {
      category = 'consistency';
    } else if (widget.event.id.startsWith('goal_')) {
      category = 'goals';
    }

    final catColor = _getCategoryColor(category, widget.event.type);
    final catLabel = _getCategoryLabel(category, widget.event.type);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double value = _controller.value;
              double opacity;
              double scale;
              Offset slideOffset;

              if (!_isExiting) {
                // Entrance: forward animation (0.0 -> 1.0)
                opacity = Curves.easeOut.transform(value);
                scale = 0.95 + 0.05 * Curves.easeOutBack.transform(value);
                final double slideProgress = Curves.easeOutQuart.transform(value);
                slideOffset = Offset(0, 0.08 * (1.0 - slideProgress));
              } else {
                // Exit: reverse animation (1.0 -> 0.0)
                opacity = Curves.easeIn.transform(value);
                scale = 1.0;
                final double slideProgress = Curves.easeInQuart.transform(1.0 - value);
                slideOffset = Offset(0, -0.08 * slideProgress);
              }

              return FractionalTranslation(
                translation: slideOffset,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                ),
              );
            },
            child: GestureDetector(
              onTap: _triggerExit,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C0C14).withOpacity(0.82),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: catColor.withOpacity(0.28),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: catColor.withOpacity(0.14),
                              blurRadius: 30,
                              spreadRadius: -4,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Glowing Crystal Badge
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: catColor.withOpacity(0.1),
                                    border: Border.all(
                                      color: catColor.withOpacity(0.2),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                CrystalBadge(
                                  color: catColor,
                                  progress: 1.0,
                                  isUnlocked: true,
                                  size: 38.0,
                                  category: category,
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // Text Content
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    catLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: catColor,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.event.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.event.description,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: AppColors.grey400,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Close Icon
                            Icon(
                              Icons.close_rounded,
                              color: AppColors.grey500.withOpacity(0.5),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
