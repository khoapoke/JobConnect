// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_suggestion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rebuildProfileEmbeddingUseCaseHash() =>
    r'467872f1d0409af519553b590520b89b44f3021e';

/// See also [rebuildProfileEmbeddingUseCase].
@ProviderFor(rebuildProfileEmbeddingUseCase)
final rebuildProfileEmbeddingUseCaseProvider =
    AutoDisposeProvider<RebuildProfileEmbeddingUseCase>.internal(
      rebuildProfileEmbeddingUseCase,
      name: r'rebuildProfileEmbeddingUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rebuildProfileEmbeddingUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RebuildProfileEmbeddingUseCaseRef =
    AutoDisposeProviderRef<RebuildProfileEmbeddingUseCase>;
String _$rebuildJobEmbeddingUseCaseHash() =>
    r'c2a72a88a65b0222ef8c8bb1613f17c12a619542';

/// See also [rebuildJobEmbeddingUseCase].
@ProviderFor(rebuildJobEmbeddingUseCase)
final rebuildJobEmbeddingUseCaseProvider =
    AutoDisposeProvider<RebuildJobEmbeddingUseCase>.internal(
      rebuildJobEmbeddingUseCase,
      name: r'rebuildJobEmbeddingUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rebuildJobEmbeddingUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RebuildJobEmbeddingUseCaseRef =
    AutoDisposeProviderRef<RebuildJobEmbeddingUseCase>;
String _$getAiSuggestionsUseCaseHash() =>
    r'8c3cdee50a291275a3ecb1fb7b7cbd7a2c230b8a';

/// See also [getAiSuggestionsUseCase].
@ProviderFor(getAiSuggestionsUseCase)
final getAiSuggestionsUseCaseProvider =
    AutoDisposeProvider<GetAiSuggestionsUseCase>.internal(
      getAiSuggestionsUseCase,
      name: r'getAiSuggestionsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getAiSuggestionsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetAiSuggestionsUseCaseRef =
    AutoDisposeProviderRef<GetAiSuggestionsUseCase>;
String _$rebuildAiSuggestionsUseCaseHash() =>
    r'0e76037c12b928e2a6f5c61c499aa2b41ecdb60b';

/// See also [rebuildAiSuggestionsUseCase].
@ProviderFor(rebuildAiSuggestionsUseCase)
final rebuildAiSuggestionsUseCaseProvider =
    AutoDisposeProvider<RebuildAiSuggestionsUseCase>.internal(
      rebuildAiSuggestionsUseCase,
      name: r'rebuildAiSuggestionsUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$rebuildAiSuggestionsUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RebuildAiSuggestionsUseCaseRef =
    AutoDisposeProviderRef<RebuildAiSuggestionsUseCase>;
String _$aiSuggestionsHash() => r'256f7a530e3b095a53890a5822920676a5734053';

/// Watches cached AI suggestions for the current authenticated seeker.
/// Auto-rebuilds when auth state changes.
///
/// Copied from [aiSuggestions].
@ProviderFor(aiSuggestions)
final aiSuggestionsProvider =
    AutoDisposeFutureProvider<List<AiSuggestion>>.internal(
      aiSuggestions,
      name: r'aiSuggestionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiSuggestionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AiSuggestionsRef = AutoDisposeFutureProviderRef<List<AiSuggestion>>;
String _$aiEmbeddingNotifierHash() =>
    r'8b66c1a438920e397032dcdd2ef6adfcdc84b228';

/// Action notifier for AI embedding rebuilds and suggestion rebuilds.
///
/// Copied from [AiEmbeddingNotifier].
@ProviderFor(AiEmbeddingNotifier)
final aiEmbeddingNotifierProvider =
    AutoDisposeNotifierProvider<AiEmbeddingNotifier, void>.internal(
      AiEmbeddingNotifier.new,
      name: r'aiEmbeddingNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$aiEmbeddingNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AiEmbeddingNotifier = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
