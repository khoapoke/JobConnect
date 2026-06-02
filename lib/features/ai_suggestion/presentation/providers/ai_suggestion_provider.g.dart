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
String _$explainMatchUseCaseHash() =>
    r'2bb1933ae50c8382d2ea6f8612f50497dcf20314';

/// See also [explainMatchUseCase].
@ProviderFor(explainMatchUseCase)
final explainMatchUseCaseProvider =
    AutoDisposeProvider<ExplainMatchUseCase>.internal(
      explainMatchUseCase,
      name: r'explainMatchUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$explainMatchUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExplainMatchUseCaseRef = AutoDisposeProviderRef<ExplainMatchUseCase>;
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
String _$matchExplanationHash() => r'fe4285d9c490fa36a3da7dc6bd5596d2d5b5ac2f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [matchExplanation].
@ProviderFor(matchExplanation)
const matchExplanationProvider = MatchExplanationFamily();

/// See also [matchExplanation].
class MatchExplanationFamily extends Family<AsyncValue<MatchExplanation>> {
  /// See also [matchExplanation].
  const MatchExplanationFamily();

  /// See also [matchExplanation].
  MatchExplanationProvider call(String suggestionId) {
    return MatchExplanationProvider(suggestionId);
  }

  @override
  MatchExplanationProvider getProviderOverride(
    covariant MatchExplanationProvider provider,
  ) {
    return call(provider.suggestionId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'matchExplanationProvider';
}

/// See also [matchExplanation].
class MatchExplanationProvider
    extends AutoDisposeFutureProvider<MatchExplanation> {
  /// See also [matchExplanation].
  MatchExplanationProvider(String suggestionId)
    : this._internal(
        (ref) => matchExplanation(ref as MatchExplanationRef, suggestionId),
        from: matchExplanationProvider,
        name: r'matchExplanationProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$matchExplanationHash,
        dependencies: MatchExplanationFamily._dependencies,
        allTransitiveDependencies:
            MatchExplanationFamily._allTransitiveDependencies,
        suggestionId: suggestionId,
      );

  MatchExplanationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.suggestionId,
  }) : super.internal();

  final String suggestionId;

  @override
  Override overrideWith(
    FutureOr<MatchExplanation> Function(MatchExplanationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchExplanationProvider._internal(
        (ref) => create(ref as MatchExplanationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        suggestionId: suggestionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MatchExplanation> createElement() {
    return _MatchExplanationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchExplanationProvider &&
        other.suggestionId == suggestionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, suggestionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MatchExplanationRef on AutoDisposeFutureProviderRef<MatchExplanation> {
  /// The parameter `suggestionId` of this provider.
  String get suggestionId;
}

class _MatchExplanationProviderElement
    extends AutoDisposeFutureProviderElement<MatchExplanation>
    with MatchExplanationRef {
  _MatchExplanationProviderElement(super.provider);

  @override
  String get suggestionId => (origin as MatchExplanationProvider).suggestionId;
}

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
