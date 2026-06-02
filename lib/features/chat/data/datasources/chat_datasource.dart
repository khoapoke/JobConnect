import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/conversation.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatDatasource {
  Future<Either<Failure, List<Conversation>>> getConversations(
    String userId,
  );

  Future<Either<Failure, List<MessageModel>>> getMessages(
    String conversationId,
  );

  Future<Either<Failure, MessageModel>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  });

  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  });

  Future<Either<Failure, ConversationModel?>> findConversation({
    required String seekerId,
    required String recruiterId,
    required String jobId,
  });

  Future<Either<Failure, ConversationModel>> createConversation({
    required String seekerId,
    required String recruiterId,
    required String jobId,
  });

  Future<Either<Failure, String?>> getRecruiterIdForJob(String jobId);

  Future<Either<Failure, String?>> getApplicationStatusForChat({
    required String seekerId,
    required String jobId,
  });
}

class ChatDatasourceImpl implements ChatDatasource {
  const ChatDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, List<Conversation>>> getConversations(
    String userId,
  ) async {
    try {
      final data = await _supabase
          .from('conversations')
          .select('''
            id, seeker_id, recruiter_id, job_id, created_at,
            job_posts!inner(title, companies!inner(name, logo_url)),
            seeker_profile:profiles!conversations_seeker_id_fkey(full_name, headline, avatar_url),
            recruiter_profile:profiles!conversations_recruiter_id_fkey(full_name, avatar_url)
          ''')
          .or('seeker_id.eq.$userId,recruiter_id.eq.$userId')
          .order('created_at', ascending: false);

      final conversations = (data as List<dynamic>)
          .map(
            (json) => ConversationModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      if (conversations.isEmpty) return const Right(<Conversation>[]);

      final conversationIds = conversations.map((c) => c.id).toList();
      final messagesData = await _supabase
          .from('messages')
          .select()
          .inFilter('conversation_id', conversationIds)
          .order('created_at', ascending: true);

      final messages = (messagesData as List<dynamic>)
          .map(
            (json) => MessageModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final messagesByConversation = <String, List<MessageModel>>{};
      for (final message in messages) {
        messagesByConversation
            .putIfAbsent(message.conversationId, () => [])
            .add(message);
      }

      final enriched = conversations.map((conversation) {
        final msgs = messagesByConversation[conversation.id] ?? [];
        final lastMessage = msgs.isNotEmpty ? msgs.last : null;
        final unreadCount = msgs.where(
          (m) => m.senderId != userId && m.readAt == null,
        ).length;

        return conversation.toEntity(
          lastMessageContent: lastMessage?.content,
          lastMessageCreatedAt: lastMessage?.createdAt,
          unreadCount: unreadCount,
        );
      }).toList();

      return Right(enriched);
    } on PostgrestException catch (e) {
      return Left(_mapPostgrest(e));
    } catch (e, st) {
      return Left(
        UnexpectedFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, List<MessageModel>>> getMessages(
    String conversationId,
  ) async {
    try {
      final data = await _supabase
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      final messages = (data as List<dynamic>)
          .map(
            (json) => MessageModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return Right(messages);
    } on PostgrestException catch (e) {
      return Left(_mapPostgrest(e));
    } catch (e, st) {
      return Left(
        UnexpectedFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, MessageModel>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': content.trim(),
          })
          .select()
          .single();

      return Right(MessageModel.fromJson(response));
    } on PostgrestException catch (e) {
      return Left(_mapPostgrest(e));
    } catch (e, st) {
      return Left(
        UnexpectedFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      await _supabase
          .from('messages')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(_mapPostgrest(e));
    } catch (e, st) {
      return Left(
        UnexpectedFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, ConversationModel?>> findConversation({
    required String seekerId,
    required String recruiterId,
    required String jobId,
  }) async {
    try {
      final data = await _supabase
          .from('conversations')
          .select('''
            id, seeker_id, recruiter_id, job_id, created_at,
            job_posts!inner(title, companies!inner(name, logo_url)),
            seeker_profile:profiles!conversations_seeker_id_fkey(full_name, headline, avatar_url),
            recruiter_profile:profiles!conversations_recruiter_id_fkey(full_name, avatar_url)
          ''')
          .eq('seeker_id', seekerId)
          .eq('recruiter_id', recruiterId)
          .eq('job_id', jobId)
          .maybeSingle();

      if (data == null) return const Right(null);
      return Right(ConversationModel.fromJson(data));
    } on PostgrestException catch (e) {
      return Left(_mapPostgrest(e));
    } catch (e, st) {
      return Left(
        UnexpectedFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, ConversationModel>> createConversation({
    required String seekerId,
    required String recruiterId,
    required String jobId,
  }) async {
    try {
      final response = await _supabase
          .from('conversations')
          .insert({
            'seeker_id': seekerId,
            'recruiter_id': recruiterId,
            'job_id': jobId,
          })
          .select('''
            id, seeker_id, recruiter_id, job_id, created_at,
            job_posts!inner(title, companies!inner(name, logo_url)),
            seeker_profile:profiles!conversations_seeker_id_fkey(full_name, headline, avatar_url),
            recruiter_profile:profiles!conversations_recruiter_id_fkey(full_name, avatar_url)
          ''')
          .single();

      return Right(ConversationModel.fromJson(response));
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        // Unique violation race — select existing
        final existing = await _supabase
            .from('conversations')
            .select('''
              id, seeker_id, recruiter_id, job_id, created_at,
              job_posts!inner(title, companies!inner(name, logo_url)),
              seeker_profile:profiles!conversations_seeker_id_fkey(full_name, headline, avatar_url),
              recruiter_profile:profiles!conversations_recruiter_id_fkey(full_name, avatar_url)
            ''')
            .eq('seeker_id', seekerId)
            .eq('recruiter_id', recruiterId)
            .eq('job_id', jobId)
            .maybeSingle();

        if (existing != null) {
          return Right(ConversationModel.fromJson(existing));
        }
      }
      return Left(_mapPostgrest(e));
    } catch (e, st) {
      return Left(
        UnexpectedFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> getRecruiterIdForJob(String jobId) async {
    try {
      final data = await _supabase
          .from('job_posts')
          .select('id, companies!inner(recruiter_id)')
          .eq('id', jobId)
          .maybeSingle();

      if (data == null) return const Right(null);
      final company = data['companies'] as Map<String, dynamic>?;
      return Right(company?['recruiter_id'] as String?);
    } on PostgrestException catch (e) {
      return Left(_mapPostgrest(e));
    } catch (e, st) {
      return Left(
        UnexpectedFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> getApplicationStatusForChat({
    required String seekerId,
    required String jobId,
  }) async {
    try {
      final data = await _supabase
          .from('applications')
          .select('id, status')
          .eq('seeker_id', seekerId)
          .eq('job_id', jobId)
          .maybeSingle();

      if (data == null) return const Right(null);
      return Right(data['status'] as String?);
    } on PostgrestException catch (e) {
      return Left(_mapPostgrest(e));
    } catch (e, st) {
      return Left(
        UnexpectedFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  Failure _mapPostgrest(PostgrestException e) {
    return switch (e.code) {
      '23505' => DatabaseFailure(
          message: 'Cuộc trò chuyện đã tồn tại.',
          code: e.code,
        ),
      '23503' => DatabaseFailure(
          message: 'Dữ liệu liên quan không tồn tại.',
          code: e.code,
        ),
      '42501' => DatabaseFailure(
          message: 'Bạn không có quyền thực hiện thao tác này.',
          code: e.code,
        ),
      _ => DatabaseFailure(
          message: e.message.isNotEmpty ? e.message : 'Đã có lỗi xảy ra',
          code: e.code,
        ),
    };
  }
}
