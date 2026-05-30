import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../recruiter/data/models/company_model.dart';
import '../../../recruiter/data/models/job_location_model.dart';
import '../../../recruiter/data/models/job_post_model.dart';
import '../../../recruiter/data/models/job_required_skill_model.dart';
import '../../domain/entities/bookmarked_job.dart';
import '../../domain/entities/job_search_result.dart';
import '../../domain/repositories/bookmark_repository.dart';

abstract class BookmarkDatasource {
  Future<Either<Failure, Set<String>>> getActiveBookmarkedJobIds(
    String seekerId,
  );

  Future<Either<Failure, List<BookmarkedJob>>> getBookmarkedJobs(
    String seekerId,
  );

  Future<Either<Failure, Unit>> addBookmark({
    required String seekerId,
    required String jobPostId,
  });

  Future<Either<Failure, Unit>> removeBookmark({
    required String seekerId,
    required String jobPostId,
  });
}

class BookmarkDatasourceImpl implements BookmarkDatasource {
  const BookmarkDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, Set<String>>> getActiveBookmarkedJobIds(
    String seekerId,
  ) async {
    try {
      final data = await _supabase
          .from('bookmarks')
          .select('job_id, job_posts!inner(id)')
          .eq('seeker_id', seekerId)
          .eq('job_posts.status', 'active');

      final ids = (data as List<Object?>)
          .map((row) => (row as Map<String, Object?>)['job_id'] as String)
          .toSet();
      return Right(ids);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookmarkedJob>>> getBookmarkedJobs(
    String seekerId,
  ) async {
    try {
      final data = await _supabase
          .from('bookmarks')
          .select('''
            id,
            seeker_id,
            job_id,
            created_at,
            job_posts(
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
              job_locations(
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
            )
          ''')
          .eq('seeker_id', seekerId)
          .order('created_at', ascending: false);

      final bookmarks = (data as List<Object?>)
          .map((row) => _parseBookmarkedJob(row as Map<String, Object?>))
          .toList();
      return Right(bookmarks);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> addBookmark({
    required String seekerId,
    required String jobPostId,
  }) async {
    try {
      await _supabase.from('bookmarks').insert({
        'seeker_id': seekerId,
        'job_id': jobPostId,
      });
      return const Right(unit);
    } on PostgrestException catch (e) {
      if (e.code == '23505') return const Right(unit);
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeBookmark({
    required String seekerId,
    required String jobPostId,
  }) async {
    try {
      await _supabase
          .from('bookmarks')
          .delete()
          .eq('seeker_id', seekerId)
          .eq('job_id', jobPostId);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  BookmarkedJob _parseBookmarkedJob(Map<String, Object?> json) {
    final jobData = json['job_posts'] as Map<String, Object?>?;
    final isAvailable = jobData != null && jobData['status'] == 'active';

    return BookmarkedJob(
      bookmarkId: json['id'] as String,
      jobPostId: json['job_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      result: isAvailable ? _parseSearchResult(jobData) : null,
    );
  }

  JobSearchResult _parseSearchResult(Map<String, Object?> json) {
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

    return JobSearchResult(
      jobPost: jobPost.toEntity(),
      company: company.toEntity(),
      location: location.toEntity(),
      skills: skills.map((skill) => skill.toEntity()).toList(),
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
