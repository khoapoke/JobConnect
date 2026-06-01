import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/ai_suggestion_repository_impl.dart';
import '../../domain/entities/ai_embedding_result.dart';
import '../../domain/usecases/rebuild_job_embedding_usecase.dart';
import '../../domain/usecases/rebuild_profile_embedding_usecase.dart';

part 'ai_suggestion_provider.g.dart';

@riverpod
RebuildProfileEmbeddingUseCase rebuildProfileEmbeddingUseCase(Ref ref) {
  final repository = ref.watch(aiSuggestionRepositoryProvider);
  return RebuildProfileEmbeddingUseCase(repository);
}

@riverpod
RebuildJobEmbeddingUseCase rebuildJobEmbeddingUseCase(Ref ref) {
  final repository = ref.watch(aiSuggestionRepositoryProvider);
  return RebuildJobEmbeddingUseCase(repository);
}

/// Action notifier for AI embedding rebuilds.
@riverpod
class AiEmbeddingNotifier extends _$AiEmbeddingNotifier {
  @override
  void build() {}

  Future<AiEmbeddingResult?> rebuildProfileEmbedding() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return null;

    final useCase = ref.read(rebuildProfileEmbeddingUseCaseProvider);
    final result = await useCase.call();

    return result.fold(
      (failure) => AiEmbeddingResult(
        status: AiEmbeddingStatus.error,
        message: failure.message,
      ),
      (success) => success,
    );
  }

  Future<AiEmbeddingResult?> rebuildJobEmbedding(String jobId) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return null;

    final useCase = ref.read(rebuildJobEmbeddingUseCaseProvider);
    final result = await useCase.call(jobId);

    return result.fold(
      (failure) => AiEmbeddingResult(
        status: AiEmbeddingStatus.error,
        message: failure.message,
      ),
      (success) => success,
    );
  }
}
