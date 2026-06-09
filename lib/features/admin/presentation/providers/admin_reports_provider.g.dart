// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminReportStatsHash() => r'7e6aa5a6c41569fc58ae2688251ca459ae2a9a95';

/// See also [adminReportStats].
@ProviderFor(adminReportStats)
final adminReportStatsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
      adminReportStats,
      name: r'adminReportStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminReportStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminReportStatsRef =
    AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$adminReportsHash() => r'db0114be7d33833e86afb4becdc6b446e7a0afb6';

/// See also [adminReports].
@ProviderFor(adminReports)
final adminReportsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      adminReports,
      name: r'adminReportsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminReportsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminReportsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$adminReportDetailHash() => r'830b41413614b5f23525aff4f77a15757a174acb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [adminReportDetail].
@ProviderFor(adminReportDetail)
const adminReportDetailProvider = AdminReportDetailFamily();

/// See also [adminReportDetail].
class AdminReportDetailFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [adminReportDetail].
  const AdminReportDetailFamily();

  /// See also [adminReportDetail].
  AdminReportDetailProvider call(String reportId) {
    return AdminReportDetailProvider(reportId);
  }

  @override
  AdminReportDetailProvider getProviderOverride(
    covariant AdminReportDetailProvider provider,
  ) {
    return call(provider.reportId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminReportDetailProvider';
}

/// See also [adminReportDetail].
class AdminReportDetailProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// See also [adminReportDetail].
  AdminReportDetailProvider(String reportId)
    : this._internal(
        (ref) => adminReportDetail(ref as AdminReportDetailRef, reportId),
        from: adminReportDetailProvider,
        name: r'adminReportDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminReportDetailHash,
        dependencies: AdminReportDetailFamily._dependencies,
        allTransitiveDependencies:
            AdminReportDetailFamily._allTransitiveDependencies,
        reportId: reportId,
      );

  AdminReportDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reportId,
  }) : super.internal();

  final String reportId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(AdminReportDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminReportDetailProvider._internal(
        (ref) => create(ref as AdminReportDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reportId: reportId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _AdminReportDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminReportDetailProvider && other.reportId == reportId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reportId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminReportDetailRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `reportId` of this provider.
  String get reportId;
}

class _AdminReportDetailProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with AdminReportDetailRef {
  _AdminReportDetailProviderElement(super.provider);

  @override
  String get reportId => (origin as AdminReportDetailProvider).reportId;
}

String _$adminReportFilterHash() => r'fea75102d8d07a0a4ae6136e93f473cd96cf1eb4';

/// See also [AdminReportFilter].
@ProviderFor(AdminReportFilter)
final adminReportFilterProvider =
    AutoDisposeNotifierProvider<AdminReportFilter, String>.internal(
      AdminReportFilter.new,
      name: r'adminReportFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminReportFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminReportFilter = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
