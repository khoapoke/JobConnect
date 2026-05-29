import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Skeleton shimmer card shown while job search results are loading.
class JobCardSkeleton extends StatefulWidget {
  const JobCardSkeleton({super.key});

  @override
  State<JobCardSkeleton> createState() => _JobCardSkeletonState();
}

class _JobCardSkeletonState extends State<JobCardSkeleton>
    with SingleTickerProviderStateMixin {
  static const _kCardRadius = 16.0;
  static const _kSmallRadius = 6.0;
  static const _kMediumRadius = 10.0;
  static const _kPillRadius = 999.0;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kCardRadius),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonCircle(size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(height: 18, width: double.infinity),
                      const SizedBox(height: 8),
                      _skeletonBox(height: 13, width: 110),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _skeletonBox(height: 24, width: 20, radius: _kSmallRadius),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _skeletonCircle(size: 14),
                const SizedBox(width: 6),
                _skeletonBox(height: 12, width: 132),
                const SizedBox(width: 16),
                _skeletonBox(height: 12, width: 92),
              ],
            ),
            const SizedBox(height: 12),
            _skeletonBox(height: 16, width: 78, radius: _kPillRadius),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _skeletonBox(height: 24, width: 68, radius: _kPillRadius),
                _skeletonBox(height: 24, width: 88, radius: _kPillRadius),
                _skeletonBox(height: 24, width: 58, radius: _kPillRadius),
              ],
            ),
            const SizedBox(height: 14),
            _skeletonBox(height: 11, width: 76),
          ],
        ),
      ),
    );
  }

  Widget _skeletonCircle({required double size}) {
    return _shimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _skeletonBox({
    required double height,
    required double width,
    double radius = _kMediumRadius,
  }) {
    return _shimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _shimmer({required Widget child}) {
    return AnimatedBuilder(
      animation: _animation,
      child: child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1.0, -0.3),
              end: Alignment(_animation.value, 0.3),
              colors: const [
                AppColors.divider,
                AppColors.surface,
                AppColors.divider,
              ],
              stops: const [0.2, 0.5, 0.8],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}
