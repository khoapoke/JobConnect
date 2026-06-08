import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, String?>> getFcmToken();
  Future<Either<Failure, void>> saveFcmToken({
    required String userId,
    required String fcmToken,
  });
  Future<Either<Failure, void>> deleteFcmToken({
    required String userId,
    required String fcmToken,
  });
  Future<Either<Failure, List<Notification>>> getNotifications({
    required String userId,
    int limit,
    int offset,
  });
  Future<Either<Failure, void>> markNotificationRead({
    required String userId,
    required String notificationId,
  });
  Future<Either<Failure, void>> markAllNotificationsRead({
    required String userId,
  });
  Future<Either<Failure, int>> getUnreadCount({
    required String userId,
  });
}
