import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/job_detail.dart';
import '../../domain/repositories/job_detail_repository.dart';
import '../datasources/job_detail_datasource.dart';

part 'job_detail_repository_impl.g.dart';

class JobDetailRepositoryImpl implements JobDetailRepository {
  const JobDetailRepositoryImpl(this._datasource);

  final JobDetailDatasource _datasource;

  @override
  Future<Either<Failure, JobDetail?>> getActiveJobDetail(
    String jobPostId,
  ) {
    return _datasource.getActiveJobDetail(jobPostId);
  }
}

@riverpod
JobDetailRepository jobDetailRepository(Ref ref) {
  return JobDetailRepositoryImpl(
    JobDetailDatasourceImpl(Supabase.instance.client),
  );
}
