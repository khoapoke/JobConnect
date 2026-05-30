import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/bookmarked_job.dart';
import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_datasource.dart';

part 'bookmark_repository_impl.g.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  const BookmarkRepositoryImpl(this._datasource);

  final BookmarkDatasource _datasource;

  @override
  Future<Either<Failure, Set<String>>> getActiveBookmarkedJobIds(
    String seekerId,
  ) {
    return _datasource.getActiveBookmarkedJobIds(seekerId);
  }

  @override
  Future<Either<Failure, List<BookmarkedJob>>> getBookmarkedJobs(
    String seekerId,
  ) {
    return _datasource.getBookmarkedJobs(seekerId);
  }

  @override
  Future<Either<Failure, Unit>> addBookmark({
    required String seekerId,
    required String jobPostId,
  }) {
    return _datasource.addBookmark(
      seekerId: seekerId,
      jobPostId: jobPostId,
    );
  }

  @override
  Future<Either<Failure, Unit>> removeBookmark({
    required String seekerId,
    required String jobPostId,
  }) {
    return _datasource.removeBookmark(
      seekerId: seekerId,
      jobPostId: jobPostId,
    );
  }
}

@riverpod
BookmarkRepository bookmarkRepository(Ref ref) {
  return BookmarkRepositoryImpl(
    BookmarkDatasourceImpl(Supabase.instance.client),
  );
}
