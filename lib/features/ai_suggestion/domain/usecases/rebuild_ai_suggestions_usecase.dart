import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/ai_embedding_result.dart';
import '../repositories/ai_suggestion_repository.dart';

class RebuildAiSuggestionsUseCase {
  const RebuildAiSuggestionsUseCase(this._repository);

  final AiSuggestionRepository _repository;

  Future<Either<Failure, AiEmbeddingResult>> call() {
    return _repository.rebuildAiSuggestions();
  }
}
