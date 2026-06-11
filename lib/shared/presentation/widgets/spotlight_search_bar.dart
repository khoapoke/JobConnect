import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
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
    final brightness = Theme.of(context).brightness;

    return AnimatedPressable(
      onTap: onTap,
      borderRadius: AppRadii.input,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space3,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantFor(brightness),
          borderRadius: AppRadii.input,
          border: Border.all(color: AppColors.hairlineFor(brightness)),
        ),
        child: Row(
          children: [
            leading ??
                Icon(
                  Icons.search_rounded,
                  color: AppColors.gray400For(brightness),
                  size: 20,
                ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Text(
                hintText,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.gray400For(brightness),
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
