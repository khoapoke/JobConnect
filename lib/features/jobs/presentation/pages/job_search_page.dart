import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/entities/job_search_result.dart';
import '../providers/job_search_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/job_card.dart';
import '../widgets/job_card_skeleton.dart';

/// Seeker-facing job search page with search bar, filters, and infinite scroll.
class JobSearchPage extends ConsumerStatefulWidget {
  const JobSearchPage({super.key});

  @override
  ConsumerState<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends ConsumerState<JobSearchPage> {
  final _searchController = TextEditingController();
  JobFilter _activeFilter = const JobFilter();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized && mounted) {
        _initialized = true;
        ref.read(jobSearchNotifierProvider.notifier).loadJobs(refresh: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSearchNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar + Filter button
            _buildSearchBar(),

            // Active filter chips
            if (_activeFilter.hasFilters) _buildActiveFilterChips(),

            // Results count or loading indicator
            _buildResultsHeader(state),

            // Job list
            Expanded(
              child: state.when(
                data: (jobs) => _buildJobList(jobs),
                loading: () => _buildSkeletonList(),
                error: (error, _) => _buildErrorState(error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref
                    .read(jobSearchNotifierProvider.notifier)
                    .updateSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          _buildFilterButton(),
          const SizedBox(width: 8),
          _buildBookmarksButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: _openFilterSheet,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.tune,
            color: _activeFilter.hasFilters
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksButton() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.push('/search/bookmarks'),
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.bookmark_border, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ..._buildFilterChipList(),
          TextButton(
            onPressed: _clearAllFilters,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppStrings.clearAll,
              style: AppTextStyles.label.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChipList() {
    final chips = <Widget>[];

    // Category chips
    for (final id in _activeFilter.categoryIds) {
      chips.add(
        _FilterChip(
          label: 'Ngành: $id',
          onRemove: () =>
              _removeFilter(_activeFilter.copyWith(categoryIds: [])),
        ),
      );
    }

    // Province chips
    for (final province in _activeFilter.provinces) {
      chips.add(
        _FilterChip(
          label: province,
          onRemove: () {
            final updated = _activeFilter.provinces.toList()..remove(province);
            _removeFilter(_activeFilter.copyWith(provinces: updated));
          },
        ),
      );
    }

    // Job type chips
    for (final type in _activeFilter.jobTypes) {
      final label = kJobTypeLabels[type] ?? type;
      chips.add(
        _FilterChip(
          label: label,
          onRemove: () {
            final updated = _activeFilter.jobTypes.toList()..remove(type);
            _removeFilter(_activeFilter.copyWith(jobTypes: updated));
          },
        ),
      );
    }

    // Salary chip
    if (_activeFilter.salaryRange != null) {
      chips.add(
        _FilterChip(
          label: _activeFilter.salaryRange!.label,
          onRemove: () =>
              _removeFilter(_activeFilter.copyWith(salaryRange: null)),
        ),
      );
    }

    // Remote chip
    if (_activeFilter.isRemote != null) {
      chips.add(
        _FilterChip(
          label: 'Từ xa',
          onRemove: () => _removeFilter(_activeFilter.copyWith(isRemote: null)),
        ),
      );
    }

    return chips;
  }

  Widget _buildResultsHeader(AsyncValue<List<JobSearchResult>> state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: state.maybeWhen(
        data: (jobs) {
          if (jobs.isEmpty) return const SizedBox.shrink();
          return Text(
            '${jobs.length} ${AppStrings.jobResultsCount}',
            style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildJobList(List<JobSearchResult> jobs) {
    if (jobs.isEmpty) {
      return _buildEmptyState();
    }

    final notifier = ref.read(jobSearchNotifierProvider.notifier);
    final showLoadMoreIndicator = notifier.isLoadingMore && jobs.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(jobSearchNotifierProvider.notifier)
            .loadJobs(refresh: true);
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notifier.hasMore &&
              notification is ScrollEndNotification &&
              notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
            ref.read(jobSearchNotifierProvider.notifier).loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: jobs.length + (showLoadMoreIndicator ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == jobs.length) {
              return const _LoadMoreIndicator();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: JobCard(result: jobs[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: JobCardSkeleton(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary.withAlpha(76),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noResults,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_activeFilter.hasFilters) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _clearAllFilters,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text(AppStrings.clearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              AppStrings.loadMoreError,
              style: AppTextStyles.body.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref
                    .read(jobSearchNotifierProvider.notifier)
                    .loadJobs(refresh: true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final result = await showModalBottomSheet<JobFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: FilterBottomSheet(initialFilter: _activeFilter),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _activeFilter = result;
      });
      ref.read(jobSearchNotifierProvider.notifier).applyFilters(_activeFilter);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilter = const JobFilter();
    });
    ref.read(jobSearchNotifierProvider.notifier).clearFilters();
  }

  void _removeFilter(JobFilter updated) {
    setState(() {
      _activeFilter = updated;
    });
    ref.read(jobSearchNotifierProvider.notifier).applyFilters(_activeFilter);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: AppColors.primary),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
