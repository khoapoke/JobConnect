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
    final brightness = Theme.of(context).brightness;
    final dotColor = _dotColorFor(brightness, tone);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariantFor(brightness),
        borderRadius: AppRadii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray600For(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _dotColorFor(Brightness brightness, StatusChipTone tone) {
    return switch (tone) {
      StatusChipTone.success => AppColors.successFor(brightness),
      StatusChipTone.warning => AppColors.warningFor(brightness),
      StatusChipTone.error => AppColors.errorFor(brightness),
      StatusChipTone.primary || StatusChipTone.ai => AppColors.accent,
      StatusChipTone.neutral => AppColors.gray400For(brightness),
    };
  }
}
