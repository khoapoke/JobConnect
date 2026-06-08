import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/notification_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';

part 'notification_provider.g.dart';

@riverpod
NotificationDatasource notificationDatasource(Ref ref) {
  return NotificationDatasourceImpl(Supabase.instance.client);
}

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl(ref.watch(notificationDatasourceProvider));
}

// ─── FCM Token ─────────────────────────────────────────────────────────────

@riverpod
Future<String?> fcmToken(Ref ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  final result = await repo.getFcmToken();
  return result.fold((failure) => null, (token) => token);
}

/// Saves FCM token to Supabase after login. Call this once when auth is ready.
@riverpod
class FcmTokenSaver extends _$FcmTokenSaver {
  @override
  Future<void> build() async {
    // No-op; state is mutated via saveToken()
    return;
  }

  Future<void> saveToken(String userId) async {
    state = const AsyncLoading();
    final repo = ref.read(notificationRepositoryProvider);
    final tokenResult = await repo.getFcmToken();
    final token = tokenResult.fold((_) => null, (t) => t);
    if (token == null) {
      state = const AsyncData(null);
      return;
    }
    final result = await repo.saveFcmToken(userId: userId, fcmToken: token);
    state = result.fold(
      (failure) => AsyncError(failure.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> deleteToken(String userId) async {
    final repo = ref.read(notificationRepositoryProvider);
    final tokenResult = await repo.getFcmToken();
    final token = tokenResult.fold((_) => null, (t) => t);
    if (token == null) return;
    await repo.deleteFcmToken(userId: userId, fcmToken: token);
  }
}

// ─── Notification List ─────────────────────────────────────────────────────

@riverpod
class NotificationList extends _$NotificationList {
  @override
  Future<List<Notification>> build() async {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated) return const [];

    final repo = ref.watch(notificationRepositoryProvider);
    final result = await repo.getNotifications(userId: auth.userId);
    return result.fold((failure) => throw Exception(failure.message), (list) => list);
  }

  Future<void> markRead(String notificationId) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;

    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markNotificationRead(
      userId: auth.userId,
      notificationId: notificationId,
    );

    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) {
        final current = state.valueOrNull ?? const <Notification>[];
        state = AsyncData([
          for (final n in current)
            if (n.id == notificationId) n.copyWith(read: true) else n,
        ]);
        ref.invalidate(unreadCountProvider);
      },
    );
  }

  Future<void> markAllRead() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;

    final repo = ref.read(notificationRepositoryProvider);
    final result = await repo.markAllNotificationsRead(userId: auth.userId);

    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) {
        final current = state.valueOrNull ?? const <Notification>[];
        state = AsyncData([
          for (final n in current) n.copyWith(read: true),
        ]);
        ref.invalidate(unreadCountProvider);
      },
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ─── Unread Count ────────────────────────────────────────────────────────────

@riverpod
class UnreadCount extends _$UnreadCount {
  Timer? _timer;

  @override
  Future<int> build() async {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated) return 0;

    _startPolling(auth.userId);

    ref.onDispose(() {
      _timer?.cancel();
    });

    final repo = ref.watch(notificationRepositoryProvider);
    final result = await repo.getUnreadCount(userId: auth.userId);
    return result.fold((failure) => 0, (count) => count);
  }

  void _startPolling(String userId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final repo = ref.read(notificationRepositoryProvider);
      final result = await repo.getUnreadCount(userId: userId);
      result.fold(
        (_) {},
        (count) {
          final current = state.valueOrNull ?? 0;
          if (current != count) {
            state = AsyncData(count);
          }
        },
      );
    });
  }

  void refresh() {
    ref.invalidateSelf();
  }
}
