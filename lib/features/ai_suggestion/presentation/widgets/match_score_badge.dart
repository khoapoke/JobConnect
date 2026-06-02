import 'dart:math' as math;

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
///
/// High scores receive a subtle pulsing glow.
class MatchScoreBadge extends StatefulWidget {
  const MatchScoreBadge({
    super.key,
    required this.matchScore,
    this.size = MatchScoreBadgeSize.medium,
  });

  final double matchScore;
  final MatchScoreBadgeSize size;

  @override
  State<MatchScoreBadge> createState() => _MatchScoreBadgeState();
}

class _MatchScoreBadgeState extends State<MatchScoreBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (widget.matchScore >= 0.75) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MatchScoreBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.matchScore >= 0.75 && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (widget.matchScore < 0.75 && _glowController.isAnimating) {
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.matchScore * 100).round();
    final label = _labelForScore(widget.matchScore);
    final color = _colorForScore(widget.matchScore);
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final padding = widget.size == MatchScoreBadgeSize.small
        ? const EdgeInsets.symmetric(
            horizontal: AppSpacing.space2,
            vertical: AppSpacing.space1,
          )
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          );

    final textStyle = widget.size == MatchScoreBadgeSize.small
        ? AppTextStyles.bodySmall
        : AppTextStyles.label.copyWith(fontWeight: FontWeight.w700);

    final child = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadii.md,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!reducedMotion)
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => Text(
                '$value%',
                style: textStyle.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else
            Text(
              '$percentage%',
              style: textStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (widget.size != MatchScoreBadgeSize.small) ...[
            const SizedBox(width: AppSpacing.space1),
            Text(
              label,
              style: textStyle.copyWith(color: color),
            ),
          ],
        ],
      ),
    );

    if (reducedMotion || widget.matchScore < 0.75) return child;

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final intensity = math.sin(_glowController.value * math.pi);
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadii.md,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.28 * intensity),
                blurRadius: 10 + (10 * intensity),
                spreadRadius: 1 + (3 * intensity),
              ),
            ],
          ),
          child: child,
        );
      },
      child: child,
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
