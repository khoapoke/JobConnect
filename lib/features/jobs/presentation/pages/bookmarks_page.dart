import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/entities/bookmarked_job.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/job_card.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkedJobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.bookmarkList)),
      body: AppGradientBackground(
        child: state.when(
          data: (bookmarks) {
            if (bookmarks.isEmpty) return const _EmptyBookmarks();
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(bookmarkedJobsProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.space4),
                itemCount: bookmarks.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];
                  final result = bookmark.result;
                  if (result == null) {
                    return UnavailableBookmarkedJobCard(bookmark: bookmark);
                  }
                  return JobCard(
                    result: result,
                    onBookmarkRemoved: () => ref.invalidate(bookmarkedJobsProvider),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _ErrorBookmarks(
            onRetry: () => ref.invalidate(bookmarkedJobsProvider),
          ),
        ),
      ),
    );
  }
}

class UnavailableBookmarkedJobCard extends ConsumerStatefulWidget {
  const UnavailableBookmarkedJobCard({
    super.key,
    required this.bookmark,
  });

  final BookmarkedJob bookmark;

  @override
  ConsumerState<UnavailableBookmarkedJobCard> createState() =>
      _UnavailableBookmarkedJobCardState();
}

class _UnavailableBookmarkedJobCardState
    extends ConsumerState<UnavailableBookmarkedJobCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  final ValueNotifier<bool> _locked = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1, end: 0.86).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _locked.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(activeBookmarkIdsProvider);

    return GlassSurface(
      borderRadius: AppRadii.lg,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: AppRadii.md,
            ),
            child: const Icon(
              Icons.work_off_outlined,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.unavailableBookmark,
                  style: AppTextStyles.title.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.unavailableJobPost,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _locked,
            builder: (context, locked, _) {
              return IconButton(
                onPressed: locked ? null : _removeBookmark,
                icon: ScaleTransition(
                  scale: _scale,
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _removeBookmark() async {
    _locked.value = true;
    final removeFuture = ref
        .read(activeBookmarkIdsProvider.notifier)
        .removeBookmark(widget.bookmark.jobPostId);
    final animationFuture = _controller.forward(from: 0).then((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    final results = await Future.wait<Object?>([
      removeFuture,
      animationFuture.then((_) => null),
    ]);
    if (!mounted) return;

    final success = results.first as bool;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookmarkFailureMessage(adding: false))),
      );
      await _controller.reverse();
    }
    _locked.value = false;
  }
}

class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: GlassSurface(
          borderRadius: AppRadii.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                AppStrings.noBookmarks,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                AppStrings.noBookmarksSubtitle,
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBookmarks extends StatelessWidget {
  const _ErrorBookmarks({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space8),
        child: GlassSurface(
          borderRadius: AppRadii.xl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.space4),
              Text(
                AppStrings.errorGeneral,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.space4),
              PremiumButton(label: AppStrings.retry, onPressed: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}