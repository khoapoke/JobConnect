import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'notification_provider.dart';

part 'notification_setup_provider.g.dart';

/// Watches auth state and manages FCM token lifecycle.
/// - On login (AuthAuthenticated): saves FCM token to device_tokens.
/// - On logout: token is deleted by the logout handler before signOut.
@riverpod
class NotificationSetup extends _$NotificationSetup {
  @override
  Future<void> build() async {
    final auth = ref.watch(authProvider);

    if (auth is AuthAuthenticated) {
      await ref.read(fcmTokenSaverProvider.notifier).saveToken(auth.userId);
    }

    return;
  }
}
