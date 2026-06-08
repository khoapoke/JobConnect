// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_setup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationSetupHash() => r'fff0e25738943b34bbbc86ba6e02f46888f7e91e';

/// Watches auth state and manages FCM token lifecycle.
/// - On login (AuthAuthenticated): saves FCM token to device_tokens.
/// - On logout: token is deleted by the logout handler before signOut.
///
/// Copied from [NotificationSetup].
@ProviderFor(NotificationSetup)
final notificationSetupProvider =
    AutoDisposeAsyncNotifierProvider<NotificationSetup, void>.internal(
      NotificationSetup.new,
      name: r'notificationSetupProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationSetupHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationSetup = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
