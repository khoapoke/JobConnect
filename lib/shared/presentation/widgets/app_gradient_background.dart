import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({
    super.key,
    required this.child,
    this.padding,
    this.gradient, // ignored — gradients retired in Light Minimal system
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return ColoredBox(
      color: AppColors.canvasFor(brightness),
      child: SizedBox.expand(
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
