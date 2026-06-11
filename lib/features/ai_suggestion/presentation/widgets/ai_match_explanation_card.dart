import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/match_explanation.dart';
import '../providers/ai_suggestion_provider.dart';
import 'match_score_badge.dart';

class AiMatchExplanationCard extends ConsumerWidget {
  const AiMatchExplanationCard({super.key, required this.suggestion});

  final AiSuggestion suggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedReason = suggestion.reason?.trim();
    if (cachedReason != null && cachedReason.isNotEmpty) {
      return _ExplanationSuccessCard(
        suggestion: suggestion,
        explanation: MatchExplanation(
          suggestionId: suggestion.id,
          reason: cachedReason,
          isCached: true,
        ),
      );
    }

    final state = ref.watch(matchExplanationProvider(suggestion.id));

    return state.when(
      data: (explanation) => _ExplanationSuccessCard(
        suggestion: suggestion,
        explanation: explanation,
      ),
      loading: () => const _ExplanationLoadingCard(),
      error: (error, _) {
        final failure = error is Failure ? error : null;
        final isRateLimited = failure?.code == 'rateLimited';

        return _ExplanationErrorCard(
          message: failure?.message.isNotEmpty == true
              ? failure!.message
              : isRateLimited
                  ? AppStrings.aiMatchExplanationRateLimited
                  : AppStrings.aiMatchExplanationError,
          isRateLimited: isRateLimited,
          onRetry: isRateLimited
              ? null
              : () => ref.invalidate(matchExplanationProvider(suggestion.id)),
        );
      },
    );
  }
}

class _ExplanationLoadingCard extends StatelessWidget {
  const _ExplanationLoadingCard();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GlassSurface(
      borderRadius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(
                AppStrings.aiMatchExplanationTitle,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.inkFor(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            AppStrings.aiMatchExplanationLoading,
            style: AppTextStyles.body.copyWith(
              color: AppColors.gray600For(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          const AppSkeleton(height: 18, width: double.infinity),
          const SizedBox(height: AppSpacing.space2),
          const AppSkeleton(height: 14, width: double.infinity),
          const SizedBox(height: AppSpacing.space2),
          const AppSkeleton(height: 14, width: double.infinity),
          const SizedBox(height: AppSpacing.space2),
          const AppSkeleton(height: 14, width: 220),
        ],
      ),
    );
  }
}

class _ExplanationSuccessCard extends StatefulWidget {
  const _ExplanationSuccessCard({
    required this.suggestion,
    required this.explanation,
  });

  final AiSuggestion suggestion;
  final MatchExplanation explanation;

  @override
  State<_ExplanationSuccessCard> createState() =>
      _ExplanationSuccessCardState();
}

class _ExplanationSuccessCardState extends State<_ExplanationSuccessCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!reducedMotion && _controller.value == 0) {
      _controller.forward();
    } else if (reducedMotion) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final parsed = _ParsedExplanation.fromReason(widget.explanation.reason);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: 0.98 + (0.02 * _fadeAnimation.value),
            child: child,
          ),
        );
      },
      child: GlassSurface(
        borderRadius: AppRadii.xl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_outlined,
                            color: AppColors.accent,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.space2),
                          Text(
                            AppStrings.aiMatchExplanationTitle,
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: AppColors.inkFor(brightness),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        parsed.summary,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.gray600For(brightness),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                MatchScoreBadge(matchScore: widget.suggestion.matchScore),
              ],
            ),
            if (parsed.reasons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space4),
              ...parsed.reasons.asMap().entries.map(
                (entry) => _AnimatedReasonRow(
                  index: entry.key,
                  text: entry.value,
                ),
              ),
            ],
            if (parsed.recommendation != null) ...[
              const SizedBox(height: AppSpacing.space4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space3),
                decoration: BoxDecoration(
                  color: AppColors.accentSoftFor(brightness),
                  borderRadius: AppRadii.lg,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.aiNextStep,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      parsed.recommendation!,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.gray600For(brightness),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space4),
            Text(
              AppStrings.aiMatchExplanationFootnote,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray400For(brightness),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedReasonRow extends StatelessWidget {
  const _AnimatedReasonRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reducedMotion
          ? Duration.zero
          : Duration(milliseconds: 340 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.space2),
        child: _ReasonRow(index: index + 1, text: text),
      ),
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.accentSoftFor(brightness),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.gray600For(brightness),
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExplanationErrorCard extends StatelessWidget {
  const _ExplanationErrorCard({
    required this.message,
    required this.isRateLimited,
    this.onRetry,
  });

  final String message;
  final bool isRateLimited;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GlassSurface(
      borderRadius: AppRadii.xl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                color: AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  AppStrings.aiMatchExplanationTitle,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.inkFor(brightness),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.gray600For(brightness),
              height: 1.5,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.space4),
            PremiumButton(
              label: AppStrings.aiMatchExplanationRetry,
              variant: PremiumButtonVariant.secondary,
              expand: false,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}

class _ParsedExplanation {
  const _ParsedExplanation({
    required this.summary,
    required this.reasons,
    required this.recommendation,
  });

  factory _ParsedExplanation.fromReason(String reason) {
    final lines = reason
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return const _ParsedExplanation(
        summary: AppStrings.aiMatchExplanationError,
        reasons: <String>[],
        recommendation: null,
      );
    }

    final summary = lines.firstWhere(
      (line) => !_isReasonLine(line) && !_isRecommendationLine(line),
      orElse: () => lines.first,
    );

    final reasons = lines
        .where(_isReasonLine)
        .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .take(3)
        .toList();

    final recommendationLine = lines.where(_isRecommendationLine).firstOrNull;
    final recommendation = recommendationLine
        ?.replaceFirst(
          RegExp(r'^Gợi ý tiếp theo:\s*', caseSensitive: false),
          '',
        )
        .trim();

    if (reasons.isEmpty && lines.length > 1) {
      final fallbackReasons = lines
          .skip(1)
          .where((line) => !_isRecommendationLine(line))
          .take(3)
          .toList();
      return _ParsedExplanation(
        summary: summary,
        reasons: fallbackReasons,
        recommendation: recommendation?.isEmpty == true ? null : recommendation,
      );
    }

    return _ParsedExplanation(
      summary: summary,
      reasons: reasons,
      recommendation: recommendation?.isEmpty == true ? null : recommendation,
    );
  }

  final String summary;
  final List<String> reasons;
  final String? recommendation;

  static bool _isReasonLine(String line) => RegExp(r'^\d+\.').hasMatch(line);

  static bool _isRecommendationLine(String line) =>
      line.toLowerCase().startsWith('gợi ý tiếp theo:');
}

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
