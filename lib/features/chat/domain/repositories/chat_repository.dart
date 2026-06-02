import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<Conversation>>> getConversations(String userId);

  Future<Either<Failure, List<Message>>> getMessages(String conversationId);

  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  });

  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  });

  Future<Either<Failure, Conversation?>> findConversation({
    required String seekerId,
    required String recruiterId,
    required String jobId,
  });

  Future<Either<Failure, Conversation>> createConversation({
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
