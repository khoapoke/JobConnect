import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/admin_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_stats.dart';

part 'admin_dashboard_provider.g.dart';

@riverpod
AdminRepositoryImpl adminRepository(Ref ref) {
  return AdminRepositoryImpl(AdminDatasource(Supabase.instance.client));
}

@riverpod
Future<AdminStats> adminDashboardStats(Ref ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.getDashboardStats();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
}

@riverpod
class AdminInviteCodes extends _$AdminInviteCodes {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    final repo = ref.read(adminRepositoryProvider);
    final result = await repo.getInviteCodes();
    return result.fold(
      (failure) => throw Exception(failure.message),
      (codes) => codes,
    );
  }

  Future<void> generate({String role = 'admin'}) async {
    state = const AsyncLoading();
    final repo = ref.read(adminRepositoryProvider);
    final result = await repo.createInviteCode(role: role);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }
}
