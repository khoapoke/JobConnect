import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/create_job_post_input.dart';
import '../../domain/entities/update_job_post_input.dart';
import '../mappers/recruiter_error_mapper.dart';
import '../models/job_post_model.dart';
import '../models/job_location_model.dart';
import '../models/job_required_skill_model.dart';

abstract class JobPostDatasource {
  Future<Either<Failure, String>> createJobPost(CreateJobPostInput input);
  Future<Either<Failure, List<JobPostModel>>> getMyJobPosts(String companyId);
  Future<Either<Failure, JobPostDetailData>> getJobPostById(String jobId);
  Future<Either<Failure, void>> updateJobPost(UpdateJobPostInput input);
  Future<Either<Failure, void>> updateJobPostStatus(String jobId, String newStatus);
}

/// Aggregated data from Supabase query (job + location + skills).
class JobPostDetailData {
  const JobPostDetailData({
    required this.jobPost,
    required this.location,
    required this.skills,
  });

  final JobPostModel jobPost;
  final JobLocationModel location;
  final List<JobRequiredSkillModel> skills;
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

  @override
  Future<Either<Failure, List<JobPostModel>>> getMyJobPosts(
    String companyId,
  ) async {
    try {
      final data = await _supabase
          .from('job_posts')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false);

      final jobPosts = (data as List)
          .map((json) => JobPostModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(jobPosts);
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, JobPostDetailData>> getJobPostById(
    String jobId,
  ) async {
    try {
      // Fetch job post
      final jobData = await _supabase
          .from('job_posts')
          .select()
          .eq('id', jobId)
          .single();

      final jobPost = JobPostModel.fromJson(jobData);

      // Fetch location
      final locationData = await _supabase
          .from('job_locations')
          .select()
          .eq('job_id', jobId)
          .single();

      final location = JobLocationModel.fromJson(locationData);

      // Fetch required skills with skill names
      final skillsData = await _supabase
          .from('job_required_skills')
          .select('job_id, skill_id, is_required, skills!inner(name)')
          .eq('job_id', jobId);

      final skills = (skillsData as List).map((json) {
        final skillData = json['skills'] as Map<String, dynamic>?;
        final skillName = skillData?['name'] as String?;
        return JobRequiredSkillModel.fromJson({
          'job_id': json['job_id'] as String,
          'skill_id': json['skill_id'] as String,
          'is_required': json['is_required'] as bool,
          'skill_name': skillName,
        });
      }).toList();

      return Right(JobPostDetailData(
        jobPost: jobPost,
        location: location,
        skills: skills,
      ));
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> updateJobPost(
    UpdateJobPostInput input,
  ) async {
    try {
      await _supabase.rpc('update_job_post', params: {
        'p_job_id': input.jobId,
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

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }

  @override
  Future<Either<Failure, void>> updateJobPostStatus(
    String jobId,
    String newStatus,
  ) async {
    try {
      await _supabase.rpc('update_job_post_status', params: {
        'p_job_id': jobId,
        'p_new_status': newStatus,
      });

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(RecruiterErrorMapper.fromPostgrest(e));
    } catch (e, st) {
      return Left(RecruiterErrorMapper.fromUnknown(e, st));
    }
  }
}
