import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/work_experience.dart';

/// Displays a single work experience entry in the profile.
///
/// Tappable — opens edit bottom sheet (handled by parent via [onTap]).
/// Uses Container + border instead of Card widget (no shadows per DESIGN.md).
class WorkExperienceCard extends StatelessWidget {
  const WorkExperienceCard({
    required this.experience,
    required this.onTap,
    super.key,
  });

  final WorkExperience experience;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/yyyy');
    final fromStr = dateFormat.format(experience.fromDate);
    final toStr = experience.isCurrent
        ? AppStrings.currently
        : experience.toDate != null
            ? dateFormat.format(experience.toDate!)
            : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    experience.role,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$fromStr – $toStr',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              experience.company,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (experience.description != null &&
                experience.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                experience.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
