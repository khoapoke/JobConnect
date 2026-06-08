// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationDatasourceHash() =>
    r'dc8eeb01633d94e89bdbcdba71f68ad58ac39bc9';

/// See also [notificationDatasource].
@ProviderFor(notificationDatasource)
final notificationDatasourceProvider =
    AutoDisposeProvider<NotificationDatasource>.internal(
      notificationDatasource,
      name: r'notificationDatasourceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationDatasourceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationDatasourceRef =
    AutoDisposeProviderRef<NotificationDatasource>;
String _$notificationRepositoryHash() =>
    r'70d272e4654bff3ea1cd73fffdb6a1815a8830b8';

/// See also [notificationRepository].
@ProviderFor(notificationRepository)
final notificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepository>.internal(
      notificationRepository,
      name: r'notificationRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationRepositoryRef =
    AutoDisposeProviderRef<NotificationRepository>;
String _$fcmTokenHash() => r'74738068abdb3e8364e7357b8d43b2298576b4dd';

/// See also [fcmToken].
@ProviderFor(fcmToken)
final fcmTokenProvider = AutoDisposeFutureProvider<String?>.internal(
  fcmToken,
  name: r'fcmTokenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fcmTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FcmTokenRef = AutoDisposeFutureProviderRef<String?>;
String _$fcmTokenSaverHash() => r'06890034f0e4eb33e6bcf3b9ae2fd5c395e0350d';

/// Saves FCM token to Supabase after login. Call this once when auth is ready.
///
/// Copied from [FcmTokenSaver].
@ProviderFor(FcmTokenSaver)
final fcmTokenSaverProvider =
    AutoDisposeAsyncNotifierProvider<FcmTokenSaver, void>.internal(
      FcmTokenSaver.new,
      name: r'fcmTokenSaverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fcmTokenSaverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FcmTokenSaver = AutoDisposeAsyncNotifier<void>;
String _$notificationListHash() => r'051595bfe5c63c449f1f3e4de5ae42b15e9e5778';

/// See also [NotificationList].
@ProviderFor(NotificationList)
final notificationListProvider =
    AutoDisposeAsyncNotifierProvider<
      NotificationList,
      List<Notification>
    >.internal(
      NotificationList.new,
      name: r'notificationListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationList = AutoDisposeAsyncNotifier<List<Notification>>;
String _$unreadCountHash() => r'd3415d8770c8637ce0aa5ffc186bc58eea14e9fb';

/// See also [UnreadCount].
@ProviderFor(UnreadCount)
final unreadCountProvider =
    AutoDisposeAsyncNotifierProvider<UnreadCount, int>.internal(
      UnreadCount.new,
      name: r'unreadCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unreadCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$UnreadCount = AutoDisposeAsyncNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
