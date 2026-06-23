import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';

/// Premium floating glass bottom navigation bar for Worth
class WorthNavBar extends StatefulWidget {
  final StatefulNavigationShell shell;
  const WorthNavBar({required this.shell, super.key});

  @override
  State<WorthNavBar> createState() => _WorthNavBarState();
}

class _WorthNavBarState extends State<WorthNavBar> {
  static const _items = [
    _NavItem(icon: Icons.dashboard_rounded,       label: 'Dashboard'),
    _NavItem(icon: Icons.account_balance_wallet,  label: 'Portfolio'),
    _NavItem(icon: Icons.trending_up_rounded,     label: 'Invest'),
    _NavItem(icon: Icons.receipt_long_rounded,    label: 'Reports'),
    _NavItem(icon: Icons.settings_rounded,        label: 'Settings'),
  ];

  int get _currentIndex => widget.shell.currentIndex;

  void _onTap(int index) {
    HapticFeedback.selectionClick();
    widget.shell.goBranch(
      index,
      initialLocation: index == _currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.layer2.withOpacity(0.95),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: const [
            BoxShadow(
              color: AppColors.violetShadow,
              blurRadius: 32,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final selected = i == _currentIndex;
            return _NavPill(
              item: _items[i],
              isSelected: selected,
              onTap: () => _onTap(i),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _NavPill extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavPill({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavPill> createState() => _NavPillState();
}

class _NavPillState extends State<_NavPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.isSelected) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavPill old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      if (widget.isSelected) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return SizedBox(
            width: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: widget.isSelected ? AppGradients.primary : null,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.glow
                                    .withOpacity(0.6 * _glow.value),
                                blurRadius: 16,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.item.icon,
                      size: 20,
                      color: widget.isSelected
                          ? Colors.white
                          : AppColors.grey500,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? AppColors.darkPrimary
                        : AppColors.grey600,
                    letterSpacing: 0.3,
                  ),
                  child: Text(widget.item.label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
