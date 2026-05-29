import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../recruiter/data/datasources/job_post_datasource.dart';
import '../../../recruiter/data/repositories/job_post_repository_impl.dart';
import '../../domain/entities/create_job_post_input.dart';
import '../../domain/repositories/job_post_repository.dart';

part 'job_post_provider.g.dart';

@riverpod
JobPostRepository jobPostRepository(Ref ref) {
  final supabase = Supabase.instance.client;
  return JobPostRepositoryImpl(JobPostDatasourceImpl(supabase));
}

/// Action-only notifier for creating Job Posts.
/// No build() state — just exposes the create() method.
@riverpod
class JobPostNotifier extends _$JobPostNotifier {
  @override
  void build() {}

  Future<Either<Failure, String>> create(CreateJobPostInput input) async {
    final repository = ref.read(jobPostRepositoryProvider);
    return repository.createJobPost(input);
  }
}
