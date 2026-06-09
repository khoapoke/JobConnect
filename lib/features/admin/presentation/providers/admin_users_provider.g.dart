// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminUsersHash() => r'01575a81d31f50f6baead3a5e6c68bd8aece1581';

/// See also [adminUsers].
@ProviderFor(adminUsers)
final adminUsersProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      adminUsers,
      name: r'adminUsersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminUsersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminUsersRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$adminUserFilterHash() => r'835575ad717c1d8557fe6217de111d48c27bd12b';

/// See also [AdminUserFilter].
@ProviderFor(AdminUserFilter)
final adminUserFilterProvider =
    AutoDisposeNotifierProvider<AdminUserFilter, String>.internal(
      AdminUserFilter.new,
      name: r'adminUserFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminUserFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminUserFilter = AutoDisposeNotifier<String>;
String _$adminUserSearchHash() => r'258d39f043214aa3f1ce40e840ffec2af2d31049';

/// See also [AdminUserSearch].
@ProviderFor(AdminUserSearch)
final adminUserSearchProvider =
    AutoDisposeNotifierProvider<AdminUserSearch, String>.internal(
      AdminUserSearch.new,
      name: r'adminUserSearchProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminUserSearchHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminUserSearch = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
