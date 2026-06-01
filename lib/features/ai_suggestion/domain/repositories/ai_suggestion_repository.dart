import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/ai_embedding_result.dart';

abstract class AiSuggestionRepository {
  Future<Either<Failure, AiEmbeddingResult>> rebuildProfileEmbedding();
  Future<Either<Failure, AiEmbeddingResult>> rebuildJobEmbedding(String jobId);
}
