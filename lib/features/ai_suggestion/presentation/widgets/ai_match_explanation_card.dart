import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
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
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.ai,
        borderRadius: AppRadii.xl,
      ),
      child: GlassSurface(
        borderRadius: AppRadii.xl,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        borderColor: Colors.white.withValues(alpha: 0.16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.aiMatchExplanationTitle,
              style: AppTextStyles.sectionTitle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              AppStrings.aiMatchExplanationLoading,
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withValues(alpha: 0.84),
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
      ),
    );
  }
}

class _ExplanationSuccessCard extends StatelessWidget {
  const _ExplanationSuccessCard({
    required this.suggestion,
    required this.explanation,
  });

  final AiSuggestion suggestion;
  final MatchExplanation explanation;

  @override
  Widget build(BuildContext context) {
    final parsed = _ParsedExplanation.fromReason(explanation.reason);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.ai,
        borderRadius: AppRadii.xl,
      ),
      child: GlassSurface(
        borderRadius: AppRadii.xl,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        borderColor: Colors.white.withValues(alpha: 0.14),
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
                      Text(
                        AppStrings.aiMatchExplanationTitle,
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        parsed.summary,
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.space3),
                MatchScoreBadge(matchScore: suggestion.matchScore),
              ],
            ),
            if (parsed.reasons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space4),
              ...parsed.reasons.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                  child: _ReasonRow(index: entry.key + 1, text: entry.value),
                ),
              ),
            ],
            if (parsed.recommendation != null) ...[
              const SizedBox(height: AppSpacing.space4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.space3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: AppRadii.lg,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.aiNextStep,
                      style: AppTextStyles.label.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      parsed.recommendation!,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
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
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),
          ],
        ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.space3),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: Colors.white.withValues(alpha: 0.90),
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
    return GlassSurface(
      borderRadius: AppRadii.xl,
      backgroundColor: AppColors.surfaceVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: AppColors.aiAccent),
              SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  AppStrings.aiMatchExplanationTitle,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
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
