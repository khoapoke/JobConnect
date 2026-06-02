import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/ai_embedding_result.dart';
import '../../domain/entities/ai_suggestion.dart';
import '../../domain/entities/match_explanation.dart';
import '../../domain/repositories/ai_suggestion_repository.dart';
import '../datasources/ai_suggestion_datasource.dart';

part 'ai_suggestion_repository_impl.g.dart';

class AiSuggestionRepositoryImpl implements AiSuggestionRepository {
  const AiSuggestionRepositoryImpl(this._datasource);

  final AiSuggestionDatasource _datasource;

  @override
  Future<Either<Failure, AiEmbeddingResult>> rebuildProfileEmbedding() {
    return _datasource.rebuildProfileEmbedding();
  }

  @override
  Future<Either<Failure, AiEmbeddingResult>> rebuildJobEmbedding(String jobId) {
    return _datasource.rebuildJobEmbedding(jobId);
  }

  @override
  Future<Either<Failure, List<AiSuggestion>>> getCachedSuggestions() {
    return _datasource.getCachedSuggestions();
  }

  @override
  Future<Either<Failure, AiEmbeddingResult>> rebuildAiSuggestions() {
    return _datasource.rebuildAiSuggestions();
  }

  @override
  Future<Either<Failure, MatchExplanation>> explainMatch(String suggestionId) {
    return _datasource.explainMatch(suggestionId);
  }
}

@riverpod
AiSuggestionRepository aiSuggestionRepository(Ref ref) {
  final supabase = Supabase.instance.client;
  return AiSuggestionRepositoryImpl(AiSuggestionDatasourceImpl(supabase));
}
