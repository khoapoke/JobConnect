import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/ai_embedding_result.dart';
import '../entities/ai_suggestion.dart';

abstract class AiSuggestionRepository {
  Future<Either<Failure, AiEmbeddingResult>> rebuildProfileEmbedding();
  Future<Either<Failure, AiEmbeddingResult>> rebuildJobEmbedding(String jobId);
  Future<Either<Failure, List<AiSuggestion>>> getCachedSuggestions();
  Future<Either<Failure, AiEmbeddingResult>> rebuildAiSuggestions();
}
