import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._datasource);

  final NotificationDatasource _datasource;

  @override
  Future<Either<Failure, String?>> getFcmToken() {
    return _datasource.getFcmToken();
  }

  @override
  Future<Either<Failure, void>> saveFcmToken({
    required String userId,
    required String fcmToken,
  }) {
    return _datasource.saveFcmToken(userId: userId, fcmToken: fcmToken);
  }

  @override
  Future<Either<Failure, void>> deleteFcmToken({
    required String userId,
    required String fcmToken,
  }) {
    return _datasource.deleteFcmToken(userId: userId, fcmToken: fcmToken);
  }

  @override
  Future<Either<Failure, List<Notification>>> getNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await _datasource.getNotifications(
      userId: userId,
      limit: limit,
      offset: offset,
    );
    return result.fold(
      Left.new,
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, void>> markNotificationRead({
    required String userId,
    required String notificationId,
  }) {
    return _datasource.markNotificationRead(
      userId: userId,
      notificationId: notificationId,
    );
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsRead({
    required String userId,
  }) {
    return _datasource.markAllNotificationsRead(userId: userId);
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({
    required String userId,
  }) {
    return _datasource.getUnreadCount(userId: userId);
  }
}
