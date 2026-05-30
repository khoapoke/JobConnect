// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookmarkedJobsHash() => r'541bdf835405228573b99bb9029348d3ea345dec';

/// See also [bookmarkedJobs].
@ProviderFor(bookmarkedJobs)
final bookmarkedJobsProvider =
    AutoDisposeFutureProvider<List<BookmarkedJob>>.internal(
      bookmarkedJobs,
      name: r'bookmarkedJobsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookmarkedJobsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BookmarkedJobsRef = AutoDisposeFutureProviderRef<List<BookmarkedJob>>;
String _$activeBookmarkIdsHash() => r'ba7e1f45276241530610f11b9b465e023129aded';

/// See also [ActiveBookmarkIds].
@ProviderFor(ActiveBookmarkIds)
final activeBookmarkIdsProvider =
    AutoDisposeAsyncNotifierProvider<ActiveBookmarkIds, Set<String>>.internal(
      ActiveBookmarkIds.new,
      name: r'activeBookmarkIdsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeBookmarkIdsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveBookmarkIds = AutoDisposeAsyncNotifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
