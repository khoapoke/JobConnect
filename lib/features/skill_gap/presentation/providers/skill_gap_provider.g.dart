// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_gap_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getSkillGapAdviceUseCaseHash() =>
    r'261c6a56f34e7b6ab38b826f72ef4ee38b9e38f8';

/// See also [getSkillGapAdviceUseCase].
@ProviderFor(getSkillGapAdviceUseCase)
final getSkillGapAdviceUseCaseProvider =
    AutoDisposeProvider<GetSkillGapAdviceUseCase>.internal(
      getSkillGapAdviceUseCase,
      name: r'getSkillGapAdviceUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getSkillGapAdviceUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetSkillGapAdviceUseCaseRef =
    AutoDisposeProviderRef<GetSkillGapAdviceUseCase>;
String _$skillGapAdviceViewNotifierHash() =>
    r'1ad886591480c7537518fa0cb5b12ddbdb6599d6';

/// Button-triggered AI learning advice for a Job Post's Skill Gap.
///
/// Hiding advice is only a presentation state change. It must not discard the
/// cached advice, otherwise showing it again would waste a Gemini request.
///
/// Copied from [SkillGapAdviceViewNotifier].
@ProviderFor(SkillGapAdviceViewNotifier)
final skillGapAdviceViewNotifierProvider =
    AutoDisposeNotifierProvider<
      SkillGapAdviceViewNotifier,
      AsyncValue<SkillGapAdviceViewState>
    >.internal(
      SkillGapAdviceViewNotifier.new,
      name: r'skillGapAdviceViewNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$skillGapAdviceViewNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SkillGapAdviceViewNotifier =
    AutoDisposeNotifier<AsyncValue<SkillGapAdviceViewState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
