import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

/// Retired glass/blur card — now renders as a plain bordered `surface` card
/// per §5 of the Light Minimal system. API is kept unchanged so call sites
/// compile without modification. `blurSigma` is accepted but ignored.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.space4),
    this.borderRadius = AppRadii.lg,
    this.borderColor,
    this.backgroundColor,
    this.blurSigma = 16, // ignored
    this.shadows,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double blurSigma;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceFor(brightness),
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? AppColors.hairlineFor(brightness),
        ),
        boxShadow: shadows ?? AppShadows.card,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
