import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../jobs/domain/entities/job_search_result.dart';
import '../../../jobs/presentation/providers/job_feed_provider.dart';
import '../../../jobs/presentation/widgets/job_card.dart';
import '../../../jobs/presentation/widgets/job_card_skeleton.dart';
import '../../domain/entities/ai_embedding_result.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../providers/ai_suggestion_provider.dart';
import 'ai_suggestion_card.dart';

/// The AI "Dành cho bạn" feed for the first tab of [JobFeedPage].
///
/// Reads cached [AiSuggestion] from Supabase. Supports:
/// - empty-cache onboarding + regular feed preview
/// - stale-cache warning banner
/// - missing-profile / no-job-embeddings fault-tolerant states
/// - pull-to-refresh re-reads cache only
class ForYouFeed extends ConsumerStatefulWidget {
  const ForYouFeed({super.key});

  @override
  ConsumerState<ForYouFeed> createState() => _ForYouFeedState();
}

class _ForYouFeedState extends ConsumerState<ForYouFeed> {
  /// Tracks the last manual rebuild result so we can switch the empty-state
  /// card from generic onboarding to a specific fault-tolerant state.
  AiEmbeddingResult? _lastRebuildResult;
  bool _isRebuilding = false;

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(aiSuggestionsProvider);
    final jobsAsync = ref.watch(jobFeedProvider);

    return suggestionsAsync.when(
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return _EmptyState(
            lastResult: _lastRebuildResult,
            isRebuilding: _isRebuilding,
            onRebuild: _onRebuild,
            jobsAsync: jobsAsync,
          );
        }
        return _SuggestionList(
          suggestions: suggestions,
          onRefresh: () async => ref.invalidate(aiSuggestionsProvider),
          onRebuild: _onRebuild,
          isRebuilding: _isRebuilding,
        );
      },
      loading: () => _LoadingState(jobsAsync: jobsAsync),
      error: (error, _) => _ErrorState(
        error: error,
        onRetry: () => ref.invalidate(aiSuggestionsProvider),
        jobsAsync: jobsAsync,
      ),
    );
  }

  Future<void> _onRebuild() async {
    setState(() => _isRebuilding = true);
    final notifier = ref.read(aiEmbeddingNotifierProvider.notifier);
    final result = await notifier.rebuildSuggestions();
    if (mounted) {
      setState(() {
        _isRebuilding = false;
        _lastRebuildResult = result;
      });

      if (result != null) {
        _showSnack(result.message);
        if (result.status == AiEmbeddingStatus.generated ||
            result.status == AiEmbeddingStatus.success) {
          ref.invalidate(aiSuggestionsProvider);
        }
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

/* ─── Suggestion List (has data) ─────────────────────────────────── */

class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.suggestions,
    required this.onRefresh,
    required this.onRebuild,
    required this.isRebuilding,
  });

  final List<AiSuggestion> suggestions;
  final Future<void> Function() onRefresh;
  final VoidCallback onRebuild;
  final bool isRebuilding;

  bool get _isStale {
    final oldest = suggestions.map((s) => s.cachedAt).reduce(
          (a, b) => a.isBefore(b) ? a : b,
        );
    return DateTime.now().difference(oldest).inHours >= 24;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isStale) ...[
          _StaleBanner(onRebuild: onRebuild, isRebuilding: isRebuilding),
          const SizedBox(height: AppSpacing.space4),
        ],
        Text(
          AppStrings.aiSuggestionsTitle,
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.aiAccent,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          AppStrings.aiSuggestionsSubtitle,
          style: AppTextStyles.body.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space4),
        ...List.generate(suggestions.length, (index) {
          final suggestion = suggestions[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space4),
            child: AiSuggestionCard(suggestion: suggestion),
          );
        }),
      ],
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.onRebuild, required this.isRebuilding});

  final VoidCallback onRebuild;
  final bool isRebuilding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassSurface(
      borderRadius: AppRadii.lg,
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_filled_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Text(
              AppStrings.aiStaleWarning,
              style: AppTextStyles.body.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          isRebuilding
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton(
                  onPressed: onRebuild,
                  child: const Text(AppStrings.aiUpdateSuggestions),
                ),
        ],
      ),
    );
  }
}

/* ─── Empty States ─────────────────────────────────────────────────── */

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.lastResult,
    required this.isRebuilding,
    required this.onRebuild,
    required this.jobsAsync,
  });

  final AiEmbeddingResult? lastResult;
  final bool isRebuilding;
  final VoidCallback onRebuild;
  final AsyncValue<List<JobSearchResult>> jobsAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPrimaryCard(context),
        const SizedBox(height: AppSpacing.space5),
        Text(
          AppStrings.latestJobs,
          style: AppTextStyles.sectionTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        _buildPreviewFeed(context),
      ],
    );
  }

  Widget _buildPrimaryCard(BuildContext context) {
    if (lastResult?.status == AiEmbeddingStatus.missingData) {
      return _CompleteProfileCard(onUpdateProfile: () => context.go('/profile'));
    }
    if (lastResult?.status == AiEmbeddingStatus.noJobEmbeddings) {
      return _PreparingCard(onViewLatest: () => context.go('/search'));
    }
    return _OnboardingCard(
      isRebuilding: isRebuilding,
      onRebuild: onRebuild,
    );
  }

  Widget _buildPreviewFeed(BuildContext context) {
    return jobsAsync.when(
      data: (jobs) {
        final preview = jobs.take(3).toList();
        if (preview.isEmpty) {
          return Text(
            AppStrings.noJobPostsYet,
            style: AppTextStyles.body.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }
        return Column(
          children: preview.map((job) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space4),
              child: JobCard(result: job),
            );
          }).toList(),
        );
      },
      loading: () => const Column(
        children: [
          JobCardSkeleton(),
          SizedBox(height: AppSpacing.space4),
          JobCardSkeleton(),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.isRebuilding, required this.onRebuild});

  final bool isRebuilding;
  final VoidCallback onRebuild;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassSurface(
      borderRadius: AppRadii.xl,
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_fix_high_rounded,
                color: AppColors.aiAccent,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(
                AppStrings.aiOnboardingTitle,
                style: AppTextStyles.title.copyWith(
                  color: AppColors.aiAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            AppStrings.aiOnboardingBody,
            style: AppTextStyles.body.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          isRebuilding
              ? const Center(child: CircularProgressIndicator())
              : PremiumButton(
                  label: AppStrings.aiCreateSuggestions,
                  onPressed: onRebuild,
                ),
        ],
      ),
    );
  }
}

class _CompleteProfileCard extends StatelessWidget {
  const _CompleteProfileCard({required this.onUpdateProfile});

  final VoidCallback onUpdateProfile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassSurface(
      borderRadius: AppRadii.xl,
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.aiCompleteProfileTitle,
            style: AppTextStyles.title.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            AppStrings.aiCompleteProfileBody,
            style: AppTextStyles.body.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          PremiumButton(
            label: AppStrings.aiUpdateProfile,
            onPressed: onUpdateProfile,
          ),
        ],
      ),
    );
  }
}

class _PreparingCard extends StatelessWidget {
  const _PreparingCard({required this.onViewLatest});

  final VoidCallback onViewLatest;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassSurface(
      borderRadius: AppRadii.xl,
      padding: const EdgeInsets.all(AppSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.aiPreparingTitle,
            style: AppTextStyles.title.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            AppStrings.aiPreparingBody,
            style: AppTextStyles.body.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          PremiumButton(
            label: AppStrings.aiViewLatestJobs,
            onPressed: onViewLatest,
          ),
        ],
      ),
    );
  }
}

/* ─── Loading State ────────────────────────────────────────────────── */

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.jobsAsync});

  final AsyncValue<List<JobSearchResult>> jobsAsync;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassSurface(
          borderRadius: AppRadii.xl,
          padding: const EdgeInsets.all(AppSpacing.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadii.sm,
                ),
              ),
              const SizedBox(height: AppSpacing.space3),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadii.sm,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Container(
                width: 200,
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadii.sm,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadii.md,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        Text(
          AppStrings.latestJobs,
          style: AppTextStyles.sectionTitle.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        const JobCardSkeleton(),
        const SizedBox(height: AppSpacing.space4),
        const JobCardSkeleton(),
      ],
    );
  }
}

/* ─── Error State ──────────────────────────────────────────────────── */

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.error,
    required this.onRetry,
    required this.jobsAsync,
  });

  final Object error;
  final VoidCallback onRetry;
  final AsyncValue<List<JobSearchResult>> jobsAsync;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassSurface(
          borderRadius: AppRadii.xl,
          child: Column(
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 40),
              const SizedBox(height: AppSpacing.space3),
              Text(
                AppStrings.aiSuggestionsError,
                style: AppTextStyles.title.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                AppStrings.aiSuggestionsErrorBody,
                style: AppTextStyles.body.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space4),
              PremiumButton(label: AppStrings.retry, onPressed: onRetry),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        Text(
          AppStrings.latestJobs,
          style: AppTextStyles.sectionTitle.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.space2),
        _ErrorStatePreviewFeed(jobsAsync: jobsAsync),
      ],
    );
  }
}

class _ErrorStatePreviewFeed extends StatelessWidget {
  const _ErrorStatePreviewFeed({required this.jobsAsync});

  final AsyncValue<List<JobSearchResult>> jobsAsync;

  @override
  Widget build(BuildContext context) {
    return jobsAsync.when(
      data: (jobs) {
        final preview = jobs.take(2).toList();
        if (preview.isEmpty) return const SizedBox.shrink();
        return Column(
          children: preview.map((job) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space4),
              child: JobCard(result: job),
            );
          }).toList(),
        );
      },
      loading: () => const Column(
        children: [
          JobCardSkeleton(),
          SizedBox(height: AppSpacing.space4),
          JobCardSkeleton(),
        ],
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
