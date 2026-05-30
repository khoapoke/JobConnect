import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'animated_pressable.dart';

class SpotlightSearchBar extends StatelessWidget {
  const SpotlightSearchBar({
    super.key,
    this.hintText = 'Tìm việc, công ty, kỹ năng...',
    this.onTap,
    this.leading,
    this.trailing,
  });

  final String hintText;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPressable(
      onTap: onTap,
      borderRadius: AppRadii.lg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppRadii.lg,
          border: Border.all(
            color: isDark ? AppColors.outline : AppColors.outlineLight,
          ),
          boxShadow: isDark ? AppShadows.focusGlow : const [],
        ),
        child: Row(
          children: [
            leading ?? const Icon(Icons.search_rounded, color: AppColors.focusGlow),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                hintText,
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            trailing ??
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.space3,
                    vertical: AppSpacing.space2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.focusGlow.withValues(alpha: 0.1),
                    borderRadius: AppRadii.sm,
                  ),
                  child: Text(
                    '⌘K',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.focusGlow,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}