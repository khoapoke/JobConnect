import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/job_search_repository_impl.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/entities/job_search_result.dart';

part 'job_feed_provider.g.dart';

@riverpod
Future<List<JobSearchResult>> jobFeed(Ref ref) async {
  final result = await ref.watch(jobSearchRepositoryProvider).searchJobs(
    filter: const JobFilter(),
    limit: 24,
  );

  return result.fold(
    (failure) => throw Exception(failure.message),
    (jobs) => jobs,
  );
}