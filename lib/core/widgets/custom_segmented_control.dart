import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomSegmentedControl extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onValueChanged;

  const CustomSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onValueChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.layer2 : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppColors.glassBorder : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth / segments.length;
          return Stack(
            children: [
              // Sliding active background indicator
              AnimatedAlign(
                alignment: Alignment(
                  (selectedIndex / (segments.length - 1) * 2.0) - 1.0,
                  0.0,
                ),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                child: Container(
                  width: width - 4.0,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.darkPrimary,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkPrimary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Segment buttons
              Row(
                children: List.generate(
                  segments.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onValueChanged(index),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selectedIndex == index
                                ? Colors.white
                                : (isDark ? AppColors.grey400 : AppColors.grey500),
                          ),
                          child: Text(segments[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
