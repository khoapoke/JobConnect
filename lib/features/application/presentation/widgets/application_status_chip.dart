import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ApplicationStatusChip extends StatelessWidget {
  const ApplicationStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final (label, dotColor) = switch (status) {
      'pending' => (AppStrings.statusPending, AppColors.gray400For(brightness)),
      'reviewing' => (
          AppStrings.statusReviewing,
          AppColors.warningFor(brightness)
        ),
      'interview' => (AppStrings.statusInterview, AppColors.inkFor(brightness)),
      'rejected' => (
          AppStrings.statusRejectedApplication,
          AppColors.errorFor(brightness)
        ),
      'withdrawn' => (
          AppStrings.statusWithdrawn,
          AppColors.gray400For(brightness)
        ),
      'accepted' => (AppStrings.statusAccepted, AppColors.successFor(brightness)),
      _ => (status, AppColors.gray400For(brightness)),
    };

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
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray600For(brightness),
            ),
          ),
        ],
      ),
    );
  }
}
