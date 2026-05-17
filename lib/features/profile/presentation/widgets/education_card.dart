import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/education.dart';

/// Displays a single education entry in the profile.
///
/// Tappable — opens edit bottom sheet (handled by parent via [onTap]).
/// Uses Container + border instead of Card widget (no shadows per DESIGN.md).
class EducationCard extends StatelessWidget {
  const EducationCard({
    required this.education,
    required this.onTap,
    super.key,
  });

  final Education education;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy');
    final fromStr = dateFormat.format(education.fromDate);
    final toStr = education.toDate != null
        ? dateFormat.format(education.toDate!)
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
                    education.school,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (fromStr.isNotEmpty || toStr.isNotEmpty)
                  Text(
                    toStr.isNotEmpty ? '$fromStr – $toStr' : fromStr,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            if ((education.degree != null && education.degree!.isNotEmpty) ||
                (education.major != null && education.major!.isNotEmpty)) ...[
              const SizedBox(height: 4),
              Text(
                [
                  if (education.degree != null && education.degree!.isNotEmpty)
                    education.degree!,
                  if (education.major != null && education.major!.isNotEmpty)
                    education.major!,
                ].join(' · '),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
