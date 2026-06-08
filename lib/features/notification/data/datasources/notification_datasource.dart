import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../models/notification_model.dart';

abstract class NotificationDatasource {
  Future<Either<Failure, String?>> getFcmToken();
  Future<Either<Failure, void>> saveFcmToken({
    required String userId,
    required String fcmToken,
  });
  Future<Either<Failure, void>> deleteFcmToken({
    required String userId,
    required String fcmToken,
  });
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
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

class NotificationDatasourceImpl implements NotificationDatasource {
  const NotificationDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, String?>> getFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      return Right(token);
    } catch (e, st) {
      debugPrint('FCM getToken error: $e');
      return Left(
        UnexpectedFailure(
          message: 'Không thể lấy FCM token.',
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _supabase.from('device_tokens').upsert({
        'user_id': userId,
        'fcm_token': fcmToken,
        'platform': platform,
      });
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi lưu FCM token: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, st) {
      return Left(
        UnexpectedFailure(
          message: 'Lỗi lưu FCM token: $e',
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      await _supabase
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('fcm_token', fcmToken);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi xóa FCM token: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, st) {
      return Left(
        UnexpectedFailure(
          message: 'Lỗi xóa FCM token: $e',
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final notifications = (data as List<dynamic>)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(notifications);
    } on PostgrestException catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi tải thông báo: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, st) {
      return Left(
        UnexpectedFailure(
          message: 'Lỗi tải thông báo: $e',
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationRead({
    required String userId,
    required String notificationId,
  }) async {
    try {
      final response = await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('id', notificationId)
          .eq('user_id', userId)
          .select();

      if ((response as List<dynamic>).isEmpty) {
        return const Left(
          DatabaseFailure(message: 'Không thể đánh dấu đã đọc.'),
        );
      }
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi đánh dấu đã đọc: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, st) {
      return Left(
        UnexpectedFailure(
          message: 'Lỗi đánh dấu đã đọc: $e',
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsRead({
    required String userId,
  }) async {
    try {
      await _supabase
          .from('notifications')
          .update({'read': true})
          .eq('user_id', userId)
          .eq('read', false);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi đánh dấu tất cả đã đọc: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, st) {
      return Left(
        UnexpectedFailure(
          message: 'Lỗi đánh dấu tất cả đã đọc: $e',
          stackTrace: st,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({
    required String userId,
  }) async {
    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('read', false)
          .count(CountOption.exact);

      return Right(data.count);
    } on PostgrestException catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Lỗi đếm thông báo: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e, st) {
      return Left(
        UnexpectedFailure(
          message: 'Lỗi đếm thông báo: $e',
          stackTrace: st,
        ),
      );
    }
  }
}
