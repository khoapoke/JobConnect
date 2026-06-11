import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadii.sm,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final BoxShape shape;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reducedMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final baseColor = AppColors.surfaceVariantFor(brightness);
    final highlightColor = AppColors.surfaceFor(brightness);
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final child = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: baseColor,
        shape: widget.shape,
        borderRadius:
            widget.shape == BoxShape.circle ? null : widget.borderRadius,
      ),
    );

    if (reducedMotion) return child;

    return AnimatedBuilder(
      animation: _controller,
      child: child,
      builder: (context, innerChild) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(
              Rect.fromLTWH(
                bounds.width * (_controller.value * 2 - 1),
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          blendMode: BlendMode.srcATop,
          child: innerChild,
        );
      },
    );
  }
}
