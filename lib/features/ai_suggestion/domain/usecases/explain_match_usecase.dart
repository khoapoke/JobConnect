import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/match_explanation.dart';
import '../repositories/ai_suggestion_repository.dart';

class ExplainMatchUseCase {
  const ExplainMatchUseCase(this._repository);

  final AiSuggestionRepository _repository;

  Future<Either<Failure, MatchExplanation>> call(String suggestionId) {
    return _repository.explainMatch(suggestionId);
  }
}
