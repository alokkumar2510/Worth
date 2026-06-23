import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Premium violet-tinted shimmer loading placeholders
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
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
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
    // Violet-tinted shimmer instead of plain grey
    const baseColor  = Color(0xFF13101F);
    const midColor   = Color(0xFF1E1835);
    const glowColor  = Color(0x267B3FF2);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            colors: const [baseColor, midColor, glowColor, midColor, baseColor],
            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            begin: Alignment(_animation.value - 1.0, -0.3),
            end: Alignment(_animation.value, 0.3),
          ),
        ),
      ),
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
        color: AppColors.layer1,
        borderRadius: BorderRadius.circular(isPrimary ? 32.0 : 24.0),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          ShimmerLoading(width: 80, height: 12, borderRadius: 6),
          SizedBox(height: 14),
          ShimmerLoading(width: 150, height: 28, borderRadius: 8),
          SizedBox(height: 8),
          ShimmerLoading(width: 100, height: 10, borderRadius: 5),
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
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.layer1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: const [
            ShimmerLoading(width: 44, height: 44, borderRadius: 22),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(width: 120, height: 14, borderRadius: 7),
                  SizedBox(height: 8),
                  ShimmerLoading(width: 80, height: 10, borderRadius: 5),
                ],
              ),
            ),
            SizedBox(width: 14),
            ShimmerLoading(width: 60, height: 18, borderRadius: 9),
          ],
        ),
      ),
    );
  }
}

class ChartShimmer extends StatelessWidget {
  final double height;
  const ChartShimmer({this.height = 200, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.layer1,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoading(width: 100, height: 14, borderRadius: 7),
              ShimmerLoading(width: 60, height: 14, borderRadius: 7),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              ShimmerLoading(width: 28, height: 55, borderRadius: 6),
              ShimmerLoading(width: 28, height: 95, borderRadius: 6),
              ShimmerLoading(width: 28, height: 75, borderRadius: 6),
              ShimmerLoading(width: 28, height: 115, borderRadius: 6),
              ShimmerLoading(width: 28, height: 65, borderRadius: 6),
              ShimmerLoading(width: 28, height: 85, borderRadius: 6),
            ],
          ),
        ],
      ),
    );
  }
}
