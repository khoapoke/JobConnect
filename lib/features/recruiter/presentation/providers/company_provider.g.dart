// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$companyRepositoryHash() => r'8b9ae8a2866758515e0966bb245a930ffce94487';

/// See also [companyRepository].
@ProviderFor(companyRepository)
final companyRepositoryProvider =
    AutoDisposeProvider<CompanyRepository>.internal(
      companyRepository,
      name: r'companyRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$companyRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompanyRepositoryRef = AutoDisposeProviderRef<CompanyRepository>;
String _$currentCompanyHash() => r'a9eb371006961ce3a94afeb6ba67029eb5bec349';

/// See also [currentCompany].
@ProviderFor(currentCompany)
final currentCompanyProvider = AutoDisposeFutureProvider<Company?>.internal(
  currentCompany,
  name: r'currentCompanyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentCompanyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentCompanyRef = AutoDisposeFutureProviderRef<Company?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
