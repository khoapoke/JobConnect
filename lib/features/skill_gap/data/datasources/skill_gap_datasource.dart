import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/skill_gap_advice.dart';

Failure _extractFunctionFailure(FunctionException error) {
  final details = error.details;
  if (details is Map<String, dynamic>) {
    final message = details['message'] as String? ?? error.toString();
    final status = details['status'] as String?;
    return NetworkFailure(message: message, code: status);
  }
  return NetworkFailure(message: error.toString());
}

abstract class SkillGapDatasource {
  Future<Either<Failure, SkillGapAdvice>> getSkillGapAdvice(String jobId);
}

class SkillGapDatasourceImpl implements SkillGapDatasource {
  const SkillGapDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, SkillGapAdvice>> getSkillGapAdvice(String jobId) async {
    try {
      final response = await _supabase.functions.invoke(
        'ai',
        body: {'action': 'skill_gap_advice', 'jobId': jobId},
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return const Left(
          UnexpectedFailure(message: 'Empty response from AI function'),
        );
      }

      final status = data['status'] as String? ?? 'error';
      if (status == 'rateLimited') {
        return Left(
          NetworkFailure(
            message: data['message'] as String? ??
                'Bạn đã gửi quá nhiều yêu cầu. Thử lại sau.',
            code: '429',
          ),
        );
      }
      if (status == 'error') {
        return Left(
          UnexpectedFailure(
            message: data['message'] as String? ?? 'AI advice failed',
          ),
        );
      }

      return Right(
        SkillGapAdvice(
          jobId: data['jobId'] as String? ?? jobId,
          advice: (data['advice'] as String? ?? '').trim(),
        ),
      );
    } on FunctionException catch (e) {
      return Left(_extractFunctionFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
