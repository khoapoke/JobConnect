import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/bookmarked_job.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/job_card.dart';

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookmarkedJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.bookmarkList),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: state.when(
        data: (bookmarks) {
          if (bookmarks.isEmpty) return const _EmptyBookmarks();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(bookmarkedJobsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => _ErrorBookmarks(
          onRetry: () => ref.invalidate(bookmarkedJobsProvider),
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

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.work_off_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.unavailableBookmark,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.unavailableJobPost,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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
        SnackBar(
          content: Text(
            bookmarkFailureMessage(adding: false),
            style: AppTextStyles.body.copyWith(color: AppColors.onPrimary),
          ),
          backgroundColor: AppColors.error,
        ),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 64,
              color: AppColors.textSecondary.withAlpha(90),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noBookmarks,
              style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.noBookmarksSubtitle,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorGeneral,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
