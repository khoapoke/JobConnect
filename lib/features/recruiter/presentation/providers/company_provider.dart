import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/user_role.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/company_datasource.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';

part 'company_provider.g.dart';

// Repository provider
@riverpod
CompanyRepository companyRepository(Ref ref) {
  final supabase = Supabase.instance.client;
  return CompanyRepositoryImpl(CompanyDatasourceImpl(supabase));
}

// Central company provider — nullable (null = not created yet)
@riverpod
Future<Company?> currentCompany(Ref ref) async {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return null;
  if (auth.role != UserRole.recruiter) return null;

  final result = await ref.watch(companyRepositoryProvider)
      .getCompanyByRecruiterId(auth.userId);
  return result.fold<Company?>(
    (failure) => throw Exception(failure.message),
    (company) => company, // nullable — null = not created yet
  );
}
