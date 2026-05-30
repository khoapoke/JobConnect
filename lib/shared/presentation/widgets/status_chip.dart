import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

enum StatusChipTone { neutral, primary, success, warning, error, ai }

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = StatusChipTone.neutral,
  });

  final String label;
  final IconData? icon;
  final StatusChipTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(context, tone);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: palette.$1,
        borderRadius: AppRadii.sm,
        border: Border.all(color: palette.$2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: palette.$3),
            const SizedBox(width: AppSpacing.space2),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: palette.$3),
          ),
        ],
      ),
    );
  }

  (Color, Color, Color) _palette(BuildContext context, StatusChipTone tone) {
    final scheme = Theme.of(context).colorScheme;
    return switch (tone) {
      StatusChipTone.primary => (
        AppColors.primary.withValues(alpha: 0.14),
        AppColors.primary.withValues(alpha: 0.24),
        AppColors.primary,
      ),
      StatusChipTone.success => (
        AppColors.success.withValues(alpha: 0.14),
        AppColors.success.withValues(alpha: 0.24),
        AppColors.success,
      ),
      StatusChipTone.warning => (
        AppColors.warning.withValues(alpha: 0.16),
        AppColors.warning.withValues(alpha: 0.28),
        AppColors.warning,
      ),
      StatusChipTone.error => (
        AppColors.error.withValues(alpha: 0.14),
        AppColors.error.withValues(alpha: 0.24),
        AppColors.error,
      ),
      StatusChipTone.ai => (
        AppColors.aiAccent.withValues(alpha: 0.16),
        AppColors.aiAccent.withValues(alpha: 0.24),
        AppColors.aiAccent,
      ),
      StatusChipTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.outline,
        scheme.onSurfaceVariant,
      ),
    };
  }
}