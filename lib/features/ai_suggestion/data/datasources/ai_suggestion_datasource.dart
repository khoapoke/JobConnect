import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../jobs/domain/entities/job_search_result.dart';
import '../../../recruiter/data/models/company_model.dart';
import '../../../recruiter/data/models/job_location_model.dart';
import '../../../recruiter/data/models/job_post_model.dart';
import '../../../recruiter/data/models/job_required_skill_model.dart';
import '../../domain/entities/ai_embedding_result.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/match_explanation.dart';

Failure _extractFunctionFailure(FunctionException error) {
  final details = error.details;
  if (details is Map<String, dynamic>) {
    final message = details['message'] as String? ?? error.toString();
    final status = details['status'] as String?;
    return NetworkFailure(message: message, code: status);
  }

  return NetworkFailure(message: error.toString());
}

abstract class AiSuggestionDatasource {
  Future<Either<Failure, AiEmbeddingResult>> rebuildProfileEmbedding();
  Future<Either<Failure, AiEmbeddingResult>> rebuildJobEmbedding(String jobId);
  Future<Either<Failure, List<AiSuggestion>>> getCachedSuggestions();
  Future<Either<Failure, AiEmbeddingResult>> rebuildAiSuggestions();
  Future<Either<Failure, MatchExplanation>> explainMatch(String suggestionId);
}

class AiSuggestionDatasourceImpl implements AiSuggestionDatasource {
  const AiSuggestionDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, AiEmbeddingResult>> rebuildProfileEmbedding() async {
    try {
      final response = await _supabase.functions.invoke(
        'ai',
        body: {'action': 'rebuild_profile_embedding'},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return const Left(
          UnexpectedFailure(message: 'Empty response from AI function'),
        );
      }

      return Right(_parseResult(data));
    } on FunctionException catch (e) {
      return Left(_extractFunctionFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiEmbeddingResult>> rebuildJobEmbedding(
    String jobId,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'ai',
        body: {'action': 'rebuild_job_embedding', 'jobId': jobId},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return const Left(
          UnexpectedFailure(message: 'Empty response from AI function'),
        );
      }

      return Right(_parseResult(data));
    } on FunctionException catch (e) {
      return Left(_extractFunctionFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AiSuggestion>>> getCachedSuggestions() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'User not authenticated'));
      }

      final data = await _supabase
          .from('ai_suggestions')
          .select('''
            id,
            seeker_id,
            job_id,
            score,
            reason,
            cached_at,
            job_posts!inner(
              *,
              companies!inner(*),
              job_locations!inner(*),
              job_required_skills(*, skills(name)),
              job_categories(name)
            )
          ''')
          .eq('seeker_id', user.id)
          .order('score', ascending: false)
          .limit(20);

      final results = (data as List).map((json) {
        final map = json as Map<String, dynamic>;
        return _parseAiSuggestion(map);
      }).toList();

      return Right(results);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiEmbeddingResult>> rebuildAiSuggestions() async {
    try {
      final response = await _supabase.functions.invoke(
        'ai',
        body: {'action': 'rebuild_ai_suggestions'},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return const Left(
          UnexpectedFailure(message: 'Empty response from AI function'),
        );
      }

      return Right(_parseResult(data));
    } on FunctionException catch (e) {
      return Left(_extractFunctionFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchExplanation>> explainMatch(
    String suggestionId,
  ) async {
    try {
      final response = await _supabase.functions.invoke(
        'ai',
        body: {'action': 'explain_match', 'suggestionId': suggestionId},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return const Left(
          UnexpectedFailure(message: 'Empty response from AI function'),
        );
      }

      return Right(
        MatchExplanation(
          suggestionId: data['suggestionId'] as String? ?? suggestionId,
          reason: (data['reason'] as String? ?? '').trim(),
          isCached: data['cached'] as bool? ?? false,
        ),
      );
    } on FunctionException catch (e) {
      return Left(_extractFunctionFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  AiEmbeddingResult _parseResult(Map<String, dynamic> json) {
    final statusRaw = json['status'] as String? ?? 'error';
    final status = AiEmbeddingStatus.values.firstWhere(
      (e) => e.name == statusRaw,
      orElse: () => AiEmbeddingStatus.error,
    );
    final message = json['message'] as String? ?? '';
    final sourceHash = json['sourceHash'] as String?;
    final updatedAtRaw = json['updatedAt'] as String?;
    final updatedAt = updatedAtRaw != null
        ? DateTime.tryParse(updatedAtRaw)
        : null;

    return AiEmbeddingResult(
      status: status,
      message: message,
      sourceHash: sourceHash,
      updatedAt: updatedAt,
    );
  }

  AiSuggestion _parseAiSuggestion(Map<String, dynamic> json) {
    final jobPostData = json['job_posts'] as Map<String, dynamic>;
    final jobPost = JobPostModel.fromJson(_extractJobPostFields(jobPostData));

    final companyData = jobPostData['companies'] as Map<String, dynamic>?;
    final company = companyData != null
        ? CompanyModel.fromJson(companyData)
        : CompanyModel(
            id: jobPost.companyId,
            recruiterId: '',
            name: 'Không xác định',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    final locationList = jobPostData['job_locations'] as List<dynamic>? ?? [];
    final locationData = locationList.isNotEmpty
        ? locationList.first as Map<String, dynamic>?
        : null;
    final location = locationData != null
        ? JobLocationModel.fromJson(locationData)
        : JobLocationModel(
            id: '',
            jobId: jobPost.id,
            isRemote: false,
            createdAt: DateTime.now(),
          );

    final skillsData =
        jobPostData['job_required_skills'] as List<dynamic>? ?? [];
    final skills = skillsData.map((skillJson) {
      final s = skillJson as Map<String, dynamic>;
      final skillNested = s['skills'] as Map<String, dynamic>?;
      final skillName = skillNested?['name'] as String?;
      return JobRequiredSkillModel.fromJson({
        'job_id': s['job_id'] as String? ?? jobPost.id,
        'skill_id': s['skill_id'] as String,
        'is_required': s['is_required'] as bool,
        'skill_name': skillName,
      });
    }).toList();

    final categoryData = jobPostData['job_categories'] as Map<String, dynamic>?;
    final categoryName = categoryData?['name'] as String?;

    final score = (json['score'] as num?)?.toDouble() ?? 0.0;
    final cachedAtRaw = json['cached_at'] as String?;
    final cachedAt = cachedAtRaw != null
        ? DateTime.tryParse(cachedAtRaw) ?? DateTime.now()
        : DateTime.now();

    return AiSuggestion(
      id: json['id'] as String,
      result: JobSearchResult(
        jobPost: jobPost.toEntity(),
        company: company.toEntity(),
        location: location.toEntity(),
        skills: skills.map((s) => s.toEntity()).toList(),
        categoryName: categoryName,
      ),
      matchScore: score,
      cachedAt: cachedAt,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> _extractJobPostFields(Map<String, dynamic> json) {
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
