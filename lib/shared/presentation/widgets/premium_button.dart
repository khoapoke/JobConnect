import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_durations.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'animated_pressable.dart';

enum PremiumButtonVariant { primary, secondary, ai, destructive }

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = PremiumButtonVariant.primary,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isLoading;
  final PremiumButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final foregroundColor = switch (variant) {
      PremiumButtonVariant.secondary => Theme.of(context).colorScheme.onSurface,
      _ => Colors.white,
    };
    final background = _backgroundFor(context);

    final child = AnimatedOpacity(
      duration: AppDurations.fast,
      opacity: isEnabled ? 1 : 0.64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: background,
          color: background == null ? _solidColorFor(context) : null,
          borderRadius: AppRadii.md,
          border: Border.all(color: _borderColorFor(context)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.buttonHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space3,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space3),
                ] else if (icon != null) ...[
                  IconTheme(
                    data: IconThemeData(color: foregroundColor, size: 18),
                    child: icon!,
                  ),
                  const SizedBox(width: AppSpacing.space2),
                ],
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(color: foregroundColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return AnimatedPressable(
      onTap: isEnabled ? onPressed : null,
      borderRadius: AppRadii.md,
      enabled: isEnabled,
      child: child,
    );
  }

  Gradient? _backgroundFor(BuildContext context) {
    return switch (variant) {
      PremiumButtonVariant.primary => AppGradients.primary,
      PremiumButtonVariant.ai => AppGradients.ai,
      PremiumButtonVariant.secondary || PremiumButtonVariant.destructive => null,
    };
  }

  Color _solidColorFor(BuildContext context) {
    return switch (variant) {
      PremiumButtonVariant.secondary =>
        Theme.of(context).colorScheme.surfaceContainerHighest,
      PremiumButtonVariant.destructive => AppColors.error,
      _ => Colors.transparent,
    };
  }

  Color _borderColorFor(BuildContext context) {
    return switch (variant) {
      PremiumButtonVariant.secondary => Theme.of(context).colorScheme.outline,
      PremiumButtonVariant.destructive => AppColors.error.withValues(alpha: 0.7),
      _ => Colors.transparent,
    };
  }
}