import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ApplicationStatusChip extends StatelessWidget {
  const ApplicationStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending' => (AppStrings.statusPending, AppColors.warning),
      'reviewing' => (AppStrings.statusReviewing, AppColors.primary),
      'interview' => (AppStrings.statusInterview, AppColors.success),
      'rejected' => (AppStrings.statusRejectedApplication, AppColors.error),
      'withdrawn' => (AppStrings.statusWithdrawn, AppColors.textSecondary),
      _ => (status, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
