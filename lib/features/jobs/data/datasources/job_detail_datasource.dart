import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../recruiter/data/models/company_model.dart';
import '../../../recruiter/data/models/job_location_model.dart';
import '../../../recruiter/data/models/job_post_model.dart';
import '../../../recruiter/data/models/job_required_skill_model.dart';
import '../../domain/entities/job_detail.dart';

abstract class JobDetailDatasource {
  Future<Either<Failure, JobDetail?>> getActiveJobDetail(String jobPostId);
}

class JobDetailDatasourceImpl implements JobDetailDatasource {
  const JobDetailDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, JobDetail?>> getActiveJobDetail(
    String jobPostId,
  ) async {
    try {
      final data = await _supabase
          .from('job_posts')
          .select('''
            *,
            companies(
              id,
              recruiter_id,
              name,
              logo_url,
              description,
              website,
              size,
              province,
              created_at,
              updated_at
            ),
            job_locations!inner(
              id,
              job_id,
              province,
              district,
              address,
              is_remote,
              created_at
            ),
            job_required_skills(
              job_id,
              skill_id,
              is_required,
              skills(name)
            ),
            job_categories(name)
          ''')
          .eq('id', jobPostId)
          .eq('status', 'active')
          .maybeSingle();

      if (data == null) return const Right(null);
      return Right(_parseJobDetail(data));
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  JobDetail _parseJobDetail(Map<String, Object?> json) {
    final jobPost = JobPostModel.fromJson(_extractJobPostFields(json));

    final companyData = json['companies'] as Map<String, Object?>?;
    final company = companyData != null
        ? CompanyModel.fromJson(companyData)
        : CompanyModel(
            id: json['company_id'] as String,
            recruiterId: '',
            name: 'Không xác định',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    final locationList = json['job_locations'] as List<Object?>? ?? [];
    final locationData = locationList.isNotEmpty
        ? locationList.first as Map<String, Object?>?
        : null;
    final location = locationData != null
        ? JobLocationModel.fromJson(locationData)
        : JobLocationModel(
            id: '',
            jobId: jobPost.id,
            isRemote: false,
            createdAt: DateTime.now(),
          );

    final skillsData = json['job_required_skills'] as List<Object?>? ?? [];
    final skills = skillsData.map((skillJson) {
      final skillMap = skillJson as Map<String, Object?>;
      final skillNested = skillMap['skills'] as Map<String, Object?>?;
      return JobRequiredSkillModel.fromJson({
        'job_id': skillMap['job_id'] as String? ?? jobPost.id,
        'skill_id': skillMap['skill_id'] as String,
        'is_required': skillMap['is_required'] as bool,
        'skill_name': skillNested?['name'] as String?,
      });
    }).toList();

    final categoryData = json['job_categories'] as Map<String, Object?>?;

    return JobDetail(
      jobPost: jobPost.toEntity(),
      company: company.toEntity(),
      location: location.toEntity(),
      requiredSkills: skills.map((skill) => skill.toEntity()).toList(),
      categoryName: categoryData?['name'] as String?,
    );
  }

  Map<String, Object?> _extractJobPostFields(Map<String, Object?> json) {
    return {
      'id': json['id'],
      'company_id': json['company_id'],
      'title': json['title'],
      'description': json['description'],
      'requirements': json['requirements'],
      'salary_min': json['salary_min'],
      'salary_max': json['salary_max'],
      'is_salary_visible': json['is_salary_visible'],
      'type': json['type'],
      'category_id': json['category_id'],
      'status': json['status'],
      'expires_at': json['expires_at'],
      'created_at': json['created_at'],
      'updated_at': json['updated_at'],
    };
  }
}
