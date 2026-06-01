import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/ai_suggestion.dart';
import '../repositories/ai_suggestion_repository.dart';

class GetAiSuggestionsUseCase {
  const GetAiSuggestionsUseCase(this._repository);

  final AiSuggestionRepository _repository;

  Future<Either<Failure, List<AiSuggestion>>> call() {
    return _repository.getCachedSuggestions();
  }
}
