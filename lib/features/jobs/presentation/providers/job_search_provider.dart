import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/job_search_repository_impl.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/entities/job_search_result.dart';

part 'job_search_provider.g.dart';

/// Page size for cursor-based pagination.
const kPageSize = 20;

/// Debounce delay for search-as-you-type (milliseconds).
const kSearchDebounceMs = 400;

/// Notifier managing job search state: query, filters, pagination.
@riverpod
class JobSearchNotifier extends _$JobSearchNotifier {
  final List<JobSearchResult> _results = [];
  String? _cursor;
  bool _hasMore = true;
  Timer? _debounceTimer;
  String _searchQuery = '';
  JobFilter _filter = const JobFilter();
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  AsyncValue<List<JobSearchResult>> build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    return const AsyncValue.data([]);
  }

  /// Load jobs (first page or refresh).
  Future<void> loadJobs({bool refresh = false}) async {
    if (refresh) {
      _results.clear();
      _cursor = null;
      _hasMore = true;
      _isLoadingMore = false;
    }

    if (!_hasMore && !refresh) {
      state = AsyncValue.data(List.unmodifiable(_results));
      return;
    }

    state = const AsyncValue.loading();

    final repository = ref.read(jobSearchRepositoryProvider);
    final result = await repository.searchJobs(
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      filter: _filter,
      cursor: _cursor,
      limit: kPageSize,
    );

    result.fold(
      (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
      (newResults) {
        _results.addAll(newResults);
        _hasMore = newResults.length >= kPageSize;
        if (newResults.isNotEmpty) {
          _cursor = newResults.last.jobPost.createdAt.toIso8601String();
        }
        state = AsyncValue.data(List.unmodifiable(_results));
      },
    );
  }

  /// Update search query with debouncing.
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: kSearchDebounceMs),
      () => loadJobs(refresh: true),
    );
  }

  /// Apply filters and reset pagination.
  void applyFilters(JobFilter filter) {
    _filter = filter;
    loadJobs(refresh: true);
  }

  /// Clear all filters and reset.
  void clearFilters() {
    _filter = const JobFilter();
    loadJobs(refresh: true);
  }

  /// Load next page (infinite scroll).
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    state = AsyncValue.data(List.unmodifiable(_results));

    final repository = ref.read(jobSearchRepositoryProvider);
    final result = await repository.searchJobs(
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      filter: _filter,
      cursor: _cursor,
      limit: kPageSize,
    );

    _isLoadingMore = false;

    result.fold(
      (_) {
        // Keep current results on load-more error.
        state = AsyncValue.data(List.unmodifiable(_results));
      },
      (moreResults) {
        _results.addAll(moreResults);
        _hasMore = moreResults.length >= kPageSize;
        if (moreResults.isNotEmpty) {
          _cursor = moreResults.last.jobPost.createdAt.toIso8601String();
        }
        state = AsyncValue.data(List.unmodifiable(_results));
      },
    );
  }
}
