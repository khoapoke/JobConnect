// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminRepositoryHash() => r'd55f2dfcd203cbde258a407e6e343cd9a64f6280';

/// See also [adminRepository].
@ProviderFor(adminRepository)
final adminRepositoryProvider =
    AutoDisposeProvider<AdminRepositoryImpl>.internal(
      adminRepository,
      name: r'adminRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRepositoryRef = AutoDisposeProviderRef<AdminRepositoryImpl>;
String _$adminDashboardStatsHash() =>
    r'eba162d24f5975d684e8263754088d8a8e1c9601';

/// See also [adminDashboardStats].
@ProviderFor(adminDashboardStats)
final adminDashboardStatsProvider =
    AutoDisposeFutureProvider<AdminStats>.internal(
      adminDashboardStats,
      name: r'adminDashboardStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminDashboardStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminDashboardStatsRef = AutoDisposeFutureProviderRef<AdminStats>;
String _$adminInviteCodesHash() => r'5ea8afab7ab4f2955b972ca509b24b29d7c82f54';

/// See also [AdminInviteCodes].
@ProviderFor(AdminInviteCodes)
final adminInviteCodesProvider =
    AutoDisposeAsyncNotifierProvider<
      AdminInviteCodes,
      List<Map<String, dynamic>>
    >.internal(
      AdminInviteCodes.new,
      name: r'adminInviteCodesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminInviteCodesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminInviteCodes =
    AutoDisposeAsyncNotifier<List<Map<String, dynamic>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
