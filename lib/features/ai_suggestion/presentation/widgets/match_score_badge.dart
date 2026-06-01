import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Displays a Match Score badge with an encouraging label.
///
/// Thresholds (handoff decision):
/// - >= 0.75: "Rất phù hợp"
/// - 0.60–0.74: "Phù hợp"
/// - 0.45–0.59: "Có tiềm năng"
/// - < 0.45: "Khám phá thêm"
class MatchScoreBadge extends StatelessWidget {
  const MatchScoreBadge({
    super.key,
    required this.matchScore,
    this.size = MatchScoreBadgeSize.medium,
  });

  final double matchScore;
  final MatchScoreBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final percentage = (matchScore * 100).round();
    final label = _labelForScore(matchScore);
    final color = _colorForScore(matchScore);

    final padding = size == MatchScoreBadgeSize.small
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space1,
          )
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          );

    final textStyle = size == MatchScoreBadgeSize.small
        ? AppTextStyles.bodySmall
        : AppTextStyles.label.copyWith(fontWeight: FontWeight.w700);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadii.md,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$percentage%',
            style: textStyle.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (size != MatchScoreBadgeSize.small) ...[
            const SizedBox(width: AppSpacing.space1),
            Text(
              label,
              style: textStyle.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }

  String _labelForScore(double score) {
    if (score >= 0.75) return AppStrings.matchVeryRelevant;
    if (score >= 0.60) return AppStrings.matchRelevant;
    if (score >= 0.45) return AppStrings.matchPotential;
    return AppStrings.matchExploreMore;
  }

  Color _colorForScore(double score) {
    if (score >= 0.75) return AppColors.success;
    if (score >= 0.60) return AppColors.primary;
    if (score >= 0.45) return AppColors.warning;
    return AppColors.textSecondary;
  }
}

enum MatchScoreBadgeSize { small, medium }
