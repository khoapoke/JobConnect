import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/entities/job_search_result.dart';
import '../../domain/repositories/job_search_repository.dart';
import '../datasources/job_search_datasource.dart';

part 'job_search_repository_impl.g.dart';

class JobSearchRepositoryImpl implements JobSearchRepository {
  const JobSearchRepositoryImpl(this._datasource);

  final JobSearchDatasource _datasource;

  @override
  Future<Either<Failure, List<JobSearchResult>>> searchJobs({
    String? searchQuery,
    required JobFilter filter,
    String? cursor,
    int limit = 20,
  }) async {
    return _datasource.searchJobs(
      searchQuery: searchQuery,
      filter: filter,
      cursor: cursor,
      limit: limit,
    );
  }
}

@riverpod
JobSearchRepository jobSearchRepository(Ref ref) {
  final supabase = Supabase.instance.client;
  return JobSearchRepositoryImpl(JobSearchDatasourceImpl(supabase));
}
