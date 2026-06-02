// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatRepositoryHash() => r'0c8412966f481d0e7604747f8aa9cc123f0cba30';

/// See also [chatRepository].
@ProviderFor(chatRepository)
final chatRepositoryProvider = AutoDisposeProvider<ChatRepository>.internal(
  chatRepository,
  name: r'chatRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatRepositoryRef = AutoDisposeProviderRef<ChatRepository>;
String _$getOrCreateConversationUseCaseHash() =>
    r'5217559d459cc08d5d35927ae78405266e80c060';

/// See also [getOrCreateConversationUseCase].
@ProviderFor(getOrCreateConversationUseCase)
final getOrCreateConversationUseCaseProvider =
    AutoDisposeProvider<GetOrCreateConversationUseCase>.internal(
      getOrCreateConversationUseCase,
      name: r'getOrCreateConversationUseCaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$getOrCreateConversationUseCaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetOrCreateConversationUseCaseRef =
    AutoDisposeProviderRef<GetOrCreateConversationUseCase>;
String _$conversationListNotifierHash() =>
    r'e7c0dad40477880660484c3489aa49c2d204d624';

/// See also [ConversationListNotifier].
@ProviderFor(ConversationListNotifier)
final conversationListNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      ConversationListNotifier,
      List<Conversation>
    >.internal(
      ConversationListNotifier.new,
      name: r'conversationListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConversationListNotifier =
    AutoDisposeAsyncNotifier<List<Conversation>>;
String _$chatNotifierHash() => r'79a6fbdbeb4cb8818c47048ff1934aa7f063e667';

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

abstract class _$ChatNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Message>> {
  late final String conversationId;

  FutureOr<List<Message>> build(String conversationId);
}

/// See also [ChatNotifier].
@ProviderFor(ChatNotifier)
const chatNotifierProvider = ChatNotifierFamily();

/// See also [ChatNotifier].
class ChatNotifierFamily extends Family<AsyncValue<List<Message>>> {
  /// See also [ChatNotifier].
  const ChatNotifierFamily();

  /// See also [ChatNotifier].
  ChatNotifierProvider call(String conversationId) {
    return ChatNotifierProvider(conversationId);
  }

  @override
  ChatNotifierProvider getProviderOverride(
    covariant ChatNotifierProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatNotifierProvider';
}

/// See also [ChatNotifier].
class ChatNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ChatNotifier, List<Message>> {
  /// See also [ChatNotifier].
  ChatNotifierProvider(String conversationId)
    : this._internal(
        () => ChatNotifier()..conversationId = conversationId,
        from: chatNotifierProvider,
        name: r'chatNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatNotifierHash,
        dependencies: ChatNotifierFamily._dependencies,
        allTransitiveDependencies:
            ChatNotifierFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  ChatNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  FutureOr<List<Message>> runNotifierBuild(covariant ChatNotifier notifier) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(ChatNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatNotifierProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ChatNotifier, List<Message>>
  createElement() {
    return _ChatNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatNotifierProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Message>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _ChatNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ChatNotifier, List<Message>>
    with ChatNotifierRef {
  _ChatNotifierProviderElement(super.provider);

  @override
  String get conversationId => (origin as ChatNotifierProvider).conversationId;
}

String _$chatActionNotifierHash() =>
    r'40b205c2344df372dba6dd469524fe0dfa466d07';

/// See also [ChatActionNotifier].
@ProviderFor(ChatActionNotifier)
final chatActionNotifierProvider =
    AutoDisposeNotifierProvider<ChatActionNotifier, AsyncValue<void>>.internal(
      ChatActionNotifier.new,
      name: r'chatActionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatActionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatActionNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
