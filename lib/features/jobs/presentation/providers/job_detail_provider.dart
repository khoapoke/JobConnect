import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/job_detail_repository_impl.dart';
import '../../domain/entities/job_detail.dart';

part 'job_detail_provider.g.dart';

@riverpod
Future<JobDetail?> jobDetail(JobDetailRef ref, String jobPostId) async {
  final repository = ref.watch(jobDetailRepositoryProvider);
  final result = await repository.getActiveJobDetail(jobPostId);
  return result.fold(
    (failure) => throw failure,
    (detail) => detail,
  );
}
