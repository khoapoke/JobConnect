import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._datasource);

  final ChatDatasource _datasource;

  @override
  Future<Either<Failure, List<Conversation>>> getConversations(
    String userId,
  ) async {
    return _datasource.getConversations(userId);
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String conversationId) async {
    final result = await _datasource.getMessages(conversationId);
    return result.fold(
      Left.new,
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    final result = await _datasource.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      content: content,
    );
    return result.fold(Left.new, (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) {
    return _datasource.markMessagesAsRead(
      conversationId: conversationId,
      userId: userId,
    );
  }

  @override
  Future<Either<Failure, Conversation?>> findConversation({
    required String seekerId,
    required String recruiterId,
    required String jobId,
  }) async {
    final result = await _datasource.findConversation(
      seekerId: seekerId,
      recruiterId: recruiterId,
      jobId: jobId,
    );
    return result.fold(Left.new, (model) => Right(model?.toEntity()));
  }

  @override
  Future<Either<Failure, Conversation>> createConversation({
    required String seekerId,
    required String recruiterId,
    required String jobId,
  }) async {
    final result = await _datasource.createConversation(
      seekerId: seekerId,
      recruiterId: recruiterId,
      jobId: jobId,
    );
    return result.fold(Left.new, (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, String?>> getRecruiterIdForJob(String jobId) {
    return _datasource.getRecruiterIdForJob(jobId);
  }

  @override
  Future<Either<Failure, String?>> getApplicationStatusForChat({
    required String seekerId,
    required String jobId,
  }) {
    return _datasource.getApplicationStatusForChat(
      seekerId: seekerId,
      jobId: jobId,
    );
  }
}
