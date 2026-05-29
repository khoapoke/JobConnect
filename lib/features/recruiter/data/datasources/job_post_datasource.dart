import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/create_job_post_input.dart';
import '../mappers/recruiter_error_mapper.dart';

abstract class JobPostDatasource {
  Future<Either<Failure, String>> createJobPost(CreateJobPostInput input);
}

class JobPostDatasourceImpl implements JobPostDatasource {
  const JobPostDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, String>> createJobPost(
    CreateJobPostInput input,
  ) async {
    try {
      final result = await _supabase.rpc('create_job_post', params: {
        'p_company_id': input.companyId,
        'p_title': input.title,
        'p_description': input.description,
        'p_requirements': input.requirements,
        'p_salary_min': input.salaryMin,
        'p_salary_max': input.salaryMax,
        'p_is_salary_visible': input.isSalaryVisible,
        'p_type': input.type,
        'p_category_id': input.categoryId,
        'p_expires_at': input.expiresAt?.toIso8601String(),
        'p_province': input.province,
        'p_district': input.district,
        'p_address': input.address,
        'p_is_remote': input.isRemote,
        'p_skill_ids': input.skillIds,
      });

      if (result == null) {
        return const Left(DatabaseFailure(
          message: 'Không thể tạo tin tuyển dụng. Vui lòng thử lại.',
        ));
      }

      return Right(result as String);
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }
}
