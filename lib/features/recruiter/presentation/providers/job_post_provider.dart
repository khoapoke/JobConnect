import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../recruiter/data/datasources/job_post_datasource.dart';
import '../../../recruiter/data/repositories/job_post_repository_impl.dart';
import '../../domain/entities/create_job_post_input.dart';
import '../../domain/entities/job_post.dart';
import '../../domain/entities/update_job_post_input.dart';
import '../../domain/repositories/job_post_repository.dart';
import 'company_provider.dart';

part 'job_post_provider.g.dart';

@riverpod
JobPostRepository jobPostRepository(Ref ref) {
  final supabase = Supabase.instance.client;
  return JobPostRepositoryImpl(JobPostDatasourceImpl(supabase));
}

/// Fetches all job posts for the current company.
@riverpod
Future<List<JobPost>> myJobPosts(Ref ref) async {
  final companyAsync = ref.watch(currentCompanyProvider);
  final company = companyAsync.valueOrNull;
  if (company == null) return [];

  final repository = ref.watch(jobPostRepositoryProvider);
  final result = await repository.getMyJobPosts(company.id);
  return result.fold(
    (failure) => throw failure,
    (jobPosts) => jobPosts,
  );
}

/// Fetches a single job post detail by ID.
@riverpod
Future<JobPostDetail> jobPostDetail(Ref ref, String jobId) async {
  final repository = ref.watch(jobPostRepositoryProvider);
  final result = await repository.getJobPostById(jobId);
  return result.fold(
    (failure) => throw failure,
    (detail) => detail,
  );
}

/// Action notifier for Job Post operations (create, update, status changes).
@riverpod
class JobPostNotifier extends _$JobPostNotifier {
  @override
  void build() {}

  Future<Either<Failure, String>> create(CreateJobPostInput input) async {
    final repository = ref.read(jobPostRepositoryProvider);
    return repository.createJobPost(input);
  }

  Future<Either<Failure, void>> update(UpdateJobPostInput input) async {
    final repository = ref.read(jobPostRepositoryProvider);
    return repository.updateJobPost(input);
  }

  Future<Either<Failure, void>> updateStatus(String jobId, String newStatus) async {
    final repository = ref.read(jobPostRepositoryProvider);
    return repository.updateJobPostStatus(jobId, newStatus);
  }
}
