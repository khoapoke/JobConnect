import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Match Score badge — signature animation #2 (§9).
///
/// An orange ring draws around the score while the number counts 0→N% in
/// tabular numerals (~1.1s, ease-out cubic). No glow — the Light Minimal
/// system retires decorative shadows; the ring + count-up is the moment.
///
/// Ring color by score (handoff thresholds):
/// - >= 0.75: success — "Rất phù hợp"
/// - 0.60–0.74: accent (orange) — "Phù hợp"
/// - 0.45–0.59: warning (amber) — "Có tiềm năng"
/// - < 0.45: gray400 — "Khám phá thêm"
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
    final brightness = Theme.of(context).brightness;
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final score = matchScore.clamp(0.0, 1.0);
    final color = ringColorFor(score, brightness);
    final diameter = size == MatchScoreBadgeSize.small ? 48.0 : 64.0;
    final numberStyle = (size == MatchScoreBadgeSize.small
            ? AppTextStyles.bodyMedium
            : AppTextStyles.title)
        .copyWith(
      fontFamily: AppTextStyles.inter,
      fontFeatures: const [FontFeature.tabularFigures()],
      fontWeight: FontWeight.w800,
      color: AppColors.inkFor(brightness),
    );

    final ring = SizedBox(
      width: diameter,
      height: diameter,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: reducedMotion ? score : 0.0, end: score),
        duration: reducedMotion
            ? Duration.zero
            : const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _MatchRingPainter(
              progress: value,
              color: color,
              trackColor: AppColors.surfaceVariantFor(brightness),
            ),
            child: Center(
              child: Text('${(value * 100).round()}%', style: numberStyle),
            ),
          );
        },
      ),
    );

    if (size == MatchScoreBadgeSize.small) return ring;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ring,
        const SizedBox(height: AppSpacing.space2),
        Text(
          _labelForScore(score),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray600For(brightness),
          ),
        ),
      ],
    );
  }

  String _labelForScore(double score) {
    if (score >= 0.75) return AppStrings.matchVeryRelevant;
    if (score >= 0.60) return AppStrings.matchRelevant;
    if (score >= 0.45) return AppStrings.matchPotential;
    return AppStrings.matchExploreMore;
  }

  /// Ring color by score band (§7 thresholds). Exposed for widget tests.
  @visibleForTesting
  static Color ringColorFor(double score, Brightness brightness) {
    if (score >= 0.75) return AppColors.successFor(brightness);
    if (score >= 0.60) return AppColors.accent;
    if (score >= 0.45) return AppColors.warningFor(brightness);
    return AppColors.gray400For(brightness);
  }
}

class _MatchRingPainter extends CustomPainter {
  const _MatchRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.1;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth * 2) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = trackColor,
    );

    final clamped = progress.clamp(0.0, 1.0);
    if (clamped <= 0) return;

    final path = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi,
      );
    final metric = path.computeMetrics().first;
    final arc = metric.extractPath(0, metric.length * clamped);

    canvas.drawPath(
      arc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _MatchRingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}

enum MatchScoreBadgeSize { small, medium }
