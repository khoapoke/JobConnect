import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/ai_embedding_result.dart';

String _extractErrorMessage(dynamic error) {
  if (error is FunctionException) {
    final details = error.details;
    if (details is Map<String, dynamic>) {
      final msg = details['message'] as String?;
      final status = details['status'] as String?;
      if (msg != null) return '[$status] $msg';
    }
    return error.toString();
  }
  return error.toString();
}

abstract class AiSuggestionDatasource {
  Future<Either<Failure, AiEmbeddingResult>> rebuildProfileEmbedding();
  Future<Either<Failure, AiEmbeddingResult>> rebuildJobEmbedding(String jobId);
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
        return const Left(UnexpectedFailure(message: 'Empty response from AI function'));
      }

      return Right(_parseResult(data));
    } on FunctionException catch (e) {
      return Left(NetworkFailure(message: _extractErrorMessage(e)));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AiEmbeddingResult>> rebuildJobEmbedding(String jobId) async {
    try {
      final response = await _supabase.functions.invoke(
        'ai',
        body: {
          'action': 'rebuild_job_embedding',
          'jobId': jobId,
        },
      );

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return const Left(UnexpectedFailure(message: 'Empty response from AI function'));
      }

      return Right(_parseResult(data));
    } on FunctionException catch (e) {
      return Left(NetworkFailure(message: _extractErrorMessage(e)));
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
    final updatedAt = updatedAtRaw != null ? DateTime.tryParse(updatedAtRaw) : null;

    return AiEmbeddingResult(
      status: status,
      message: message,
      sourceHash: sourceHash,
      updatedAt: updatedAt,
    );
  }
}
