import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    super.key,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? AppColors.grey700 : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value - 1.0, -0.3),
              end: Alignment(_animation.value, 0.3),
            ),
          ),
        );
      },
    );
  }
}

class CardShimmer extends StatelessWidget {
  final double height;
  final bool isPrimary;
  const CardShimmer({this.height = 120, this.isPrimary = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard.withOpacity(0.4)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(isPrimary ? 32.0 : 24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ShimmerLoading(width: 80, height: 14, borderRadius: 4),
          const SizedBox(height: 12),
          const ShimmerLoading(width: 140, height: 24, borderRadius: 6),
        ],
      ),
    );
  }
}

class ListShimmer extends StatelessWidget {
  final int count;
  const ListShimmer({this.count = 3, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              const ShimmerLoading(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: 120, height: 16, borderRadius: 4),
                    const SizedBox(height: 8),
                    ShimmerLoading(width: 80, height: 12, borderRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const ShimmerLoading(width: 60, height: 16, borderRadius: 4),
            ],
          ),
        );
      },
    );
  }
}

class ChartShimmer extends StatelessWidget {
  final double height;
  const ChartShimmer({this.height = 180, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard.withOpacity(0.4)
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(width: 100, height: 16, borderRadius: 4),
              ShimmerLoading(width: 60, height: 16, borderRadius: 4),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              ShimmerLoading(width: 24, height: 60, borderRadius: 4),
              ShimmerLoading(width: 24, height: 100, borderRadius: 4),
              ShimmerLoading(width: 24, height: 80, borderRadius: 4),
              ShimmerLoading(width: 24, height: 120, borderRadius: 4),
              ShimmerLoading(width: 24, height: 70, borderRadius: 4),
              ShimmerLoading(width: 24, height: 90, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}
