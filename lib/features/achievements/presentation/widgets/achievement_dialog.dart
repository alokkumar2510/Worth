import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'crystal_badge.dart';
import '../../domain/services/gamification_engine.dart';
import '../../../../core/constants/app_colors.dart';

class AchievementDialog extends StatefulWidget {
  final GamificationEvent event;

  const AchievementDialog({
    super.key,
    required this.event,
  });

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
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
        return 'DEBT MANAGEMENT';
      case 'receivables':
        return 'RECEIVABLES';
      case 'consistency':
        return 'CONSISTENCY';
      case 'goals':
        return 'GOALS';
      default:
        return 'ACHIEVEMENT';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(
      widget.event.type == 'milestone' ? '' : widget.event.description, // Event passes category description sometimes, let's map properly
      widget.event.type,
    );
    
    // In our event model, we can pass category in the event. Let's see: 
    // milestone events: type = 'milestone', category is empty or id is milestone amount.
    // achievement events: type = 'achievement', id = ach.id. 
    // We can infer category from event.id:
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0E).withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: catColor.withOpacity(0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: catColor.withOpacity(0.12),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: catColor.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    catLabel,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: catColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Crystal Badge with rotating halo
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating decorative light halo
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animController.value * 2.0 * math.pi * 0.25,
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  catColor.withOpacity(0.0),
                                  catColor.withOpacity(0.15),
                                  catColor.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // Core Crystal
                    CrystalBadge(
                      color: catColor,
                      progress: 1.0,
                      isUnlocked: true,
                      size: 140.0,
                      category: category,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Congratulations Title
                Text(
                  widget.event.type == 'milestone' ? 'Milestone Reached' : 'Achievement Unlocked',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),

                // Main Achievement Name
                Text(
                  widget.event.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  widget.event.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.grey400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Achieved Date Info
                Text(
                  'Achieved on ${DateFormat('d MMM yyyy').format(widget.event.date)}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 32),

                // Premium CTA Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          catColor.withOpacity(0.15),
                          catColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: catColor.withOpacity(0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      'Acknowledge',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
