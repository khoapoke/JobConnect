import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/router/user_role.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/skill_gap_repository_impl.dart';
import '../../domain/entities/skill_gap_advice.dart';
import '../../domain/usecases/get_skill_gap_advice_usecase.dart';

part 'skill_gap_provider.g.dart';

@riverpod
GetSkillGapAdviceUseCase getSkillGapAdviceUseCase(Ref ref) {
  final repository = ref.watch(skillGapRepositoryProvider);
  return GetSkillGapAdviceUseCase(repository);
}

class SkillGapAdviceViewState {
  const SkillGapAdviceViewState({
    this.advice,
    this.contextKey,
    this.isCollapsed = false,
  });

  final SkillGapAdvice? advice;
  final String? contextKey;
  final bool isCollapsed;

  bool hasAdviceFor(String currentContextKey) =>
      advice != null && contextKey == currentContextKey;

  bool hasStaleAdviceFor(String currentContextKey) =>
      advice != null && contextKey != currentContextKey;

  SkillGapAdviceViewState copyWith({
    SkillGapAdvice? advice,
    String? contextKey,
    bool? isCollapsed,
  }) {
    return SkillGapAdviceViewState(
      advice: advice ?? this.advice,
      contextKey: contextKey ?? this.contextKey,
      isCollapsed: isCollapsed ?? this.isCollapsed,
    );
  }
}

/// Button-triggered AI learning advice for a Job Post's Skill Gap.
///
/// Hiding advice is only a presentation state change. It must not discard the
/// cached advice, otherwise showing it again would waste a Gemini request.
@riverpod
class SkillGapAdviceViewNotifier extends _$SkillGapAdviceViewNotifier {
  @override
  AsyncValue<SkillGapAdviceViewState> build() {
    return const AsyncData(SkillGapAdviceViewState());
  }

  Future<void> fetchAdvice({
    required String jobId,
    required String contextKey,
  }) async {
    state = const AsyncLoading();

    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated || auth.role != UserRole.seeker) {
      state = const AsyncData(SkillGapAdviceViewState());
      return;
    }

    final useCase = ref.read(getSkillGapAdviceUseCaseProvider);
    final result = await useCase.call(jobId);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (advice) => AsyncData(
        SkillGapAdviceViewState(
          advice: advice,
          contextKey: contextKey,
        ),
      ),
    );
  }

  void hideAdvice() {
    final value = state.valueOrNull;
    if (value == null || value.advice == null) return;
    state = AsyncData(value.copyWith(isCollapsed: true));
  }

  void showAdvice() {
    final value = state.valueOrNull;
    if (value == null || value.advice == null) return;
    state = AsyncData(value.copyWith(isCollapsed: false));
  }
}
