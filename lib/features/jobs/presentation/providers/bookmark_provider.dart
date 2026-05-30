import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/router/user_role.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/bookmark_repository_impl.dart';
import '../../domain/entities/bookmarked_job.dart';

part 'bookmark_provider.g.dart';

@riverpod
class ActiveBookmarkIds extends _$ActiveBookmarkIds {
  String? _seekerId;
  bool _canUseBookmarks = false;

  @override
  Future<Set<String>> build() async {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated || auth.role != UserRole.seeker) {
      _seekerId = null;
      _canUseBookmarks = false;
      return <String>{};
    }

    _seekerId = auth.userId;
    _canUseBookmarks = true;
    final result = await ref
        .watch(bookmarkRepositoryProvider)
        .getActiveBookmarkedJobIds(auth.userId);
    return result.fold(
      (failure) => throw failure,
      (ids) => ids,
    );
  }

  Future<bool> toggleBookmark(String jobPostId) async {
    final seekerId = _currentSeekerId();
    if (seekerId == null) return false;

    final current = state.valueOrNull ?? <String>{};
    final wasBookmarked = current.contains(jobPostId);
    final next = {...current};
    if (wasBookmarked) {
      next.remove(jobPostId);
    } else {
      next.add(jobPostId);
    }
    state = AsyncValue.data(next);

    final repository = ref.read(bookmarkRepositoryProvider);
    final result = wasBookmarked
        ? await repository.removeBookmark(
            seekerId: seekerId,
            jobPostId: jobPostId,
          )
        : await repository.addBookmark(
            seekerId: seekerId,
            jobPostId: jobPostId,
          );

    return result.fold(
      (failure) {
        state = AsyncValue<Set<String>>.error(failure, StackTrace.current);
        state = AsyncValue.data(current);
        return false;
      },
      (_) {
        ref.invalidate(bookmarkedJobsProvider);
        return true;
      },
    );
  }

  Future<bool> removeBookmark(String jobPostId) async {
    final seekerId = _currentSeekerId();
    if (seekerId == null) return false;

    final current = state.valueOrNull ?? <String>{};
    final next = {...current}..remove(jobPostId);
    state = AsyncValue.data(next);

    final result = await ref.read(bookmarkRepositoryProvider).removeBookmark(
          seekerId: seekerId,
          jobPostId: jobPostId,
        );

    return result.fold(
      (failure) {
        state = AsyncValue<Set<String>>.error(failure, StackTrace.current);
        state = AsyncValue.data(current);
        return false;
      },
      (_) {
        ref.invalidate(bookmarkedJobsProvider);
        return true;
      },
    );
  }

  String? _currentSeekerId() {
    if (_seekerId != null && _canUseBookmarks) return _seekerId;
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated || auth.role != UserRole.seeker) {
      return null;
    }
    _seekerId = auth.userId;
    _canUseBookmarks = true;
    return auth.userId;
  }
}

@riverpod
Future<List<BookmarkedJob>> bookmarkedJobs(BookmarkedJobsRef ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated || auth.role != UserRole.seeker) {
    return <BookmarkedJob>[];
  }

  final result = await ref
      .watch(bookmarkRepositoryProvider)
      .getBookmarkedJobs(auth.userId);
  return result.fold(
    (failure) => throw failure,
    (bookmarks) => bookmarks,
  );
}

String bookmarkFailureMessage({required bool adding}) {
  return adding
      ? 'Không thể lưu Bookmark. Vui lòng thử lại.'
      : 'Không thể bỏ Bookmark. Vui lòng thử lại.';
}

bool isBookmarkAuthFailure(Object error) {
  return error is AuthFailure;
}
