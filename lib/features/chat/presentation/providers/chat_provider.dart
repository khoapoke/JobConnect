import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/chat_datasource.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_or_create_conversation_usecase.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepositoryImpl(ChatDatasourceImpl(Supabase.instance.client));
}

@riverpod
GetOrCreateConversationUseCase getOrCreateConversationUseCase(Ref ref) {
  return GetOrCreateConversationUseCase(ref.watch(chatRepositoryProvider));
}

@riverpod
class ConversationListNotifier extends _$ConversationListNotifier {
  RealtimeChannel? _channel;
  bool _disposed = false;

  @override
  Future<List<Conversation>> build() async {
    _disposed = false;
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated) return [];

    _subscribe(auth.userId);

    ref.onDispose(() {
      _disposed = true;
      _channel?.unsubscribe();
    });

    final result = await ref
        .read(chatRepositoryProvider)
        .getConversations(auth.userId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (conversations) => conversations,
    );
  }

  void _subscribe(String userId) {
    final channel = Supabase.instance.client
        .channel('conversation_list:$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (_) => _refresh(userId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'messages',
          callback: (_) => _refresh(userId),
        )
        .subscribe();

    _channel = channel;
  }

  Future<void> _refresh(String userId) async {
    if (_disposed) return;
    final result = await ref
        .read(chatRepositoryProvider)
        .getConversations(userId);
    if (_disposed) return;
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (conversations) => state = AsyncData(conversations),
    );
  }
}

@riverpod
class ChatNotifier extends _$ChatNotifier {
  RealtimeChannel? _channel;
  bool _disposed = false;

  @override
  Future<List<Message>> build(String conversationId) async {
    _disposed = false;
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated) return [];

    _subscribe(conversationId);

    ref.onDispose(() {
      _disposed = true;
      _channel?.unsubscribe();
    });

    final result = await ref
        .read(chatRepositoryProvider)
        .getMessages(conversationId);
    return result.fold(
      (failure) => throw Exception(failure.message),
      (messages) => messages,
    );
  }

  void _subscribe(String conversationId) {
    _channel = Supabase.instance.client
        .channel('chat_messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            if (_disposed) return;
            final newMessage =
                MessageModel.fromJson(payload.newRecord).toEntity();
            final current = state.valueOrNull ?? [];
            if (current.any((m) => m.id == newMessage.id)) return;
            state = AsyncData([...current, newMessage]);
          },
        )
        .subscribe();
  }

  Future<void> sendMessage({
    required String senderId,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final result = await ref.read(chatRepositoryProvider).sendMessage(
          conversationId: conversationId,
          senderId: senderId,
          content: trimmed,
        );

    if (_disposed) return;

    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (message) {
        final current = state.valueOrNull ?? [];
        if (!current.any((m) => m.id == message.id)) {
          state = AsyncData([...current, message]);
        }
      },
    );
  }

  Future<Either<Failure, void>> markAsRead({required String userId}) async {
    return ref.read(chatRepositoryProvider).markMessagesAsRead(
          conversationId: conversationId,
          userId: userId,
        );
  }
}

@riverpod
class ConversationUnreadCount extends _$ConversationUnreadCount {
  @override
  Future<int> build() async {
    final conversations = await ref.watch(conversationListNotifierProvider.future);
    return conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
  }
}

@riverpod
class ChatActionNotifier extends _$ChatActionNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String seekerId,
    required String jobId,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(getOrCreateConversationUseCaseProvider)
        .call(seekerId: seekerId, jobId: jobId);
    state = const AsyncData(null);
    if (result is Right<Failure, Conversation>) {
      ref.invalidate(conversationListNotifierProvider);
    }
    return result;
  }
}
