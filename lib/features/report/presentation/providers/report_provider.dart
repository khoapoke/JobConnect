import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/report_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';

part 'report_provider.g.dart';

@riverpod
ReportRepository reportRepository(Ref ref) {
  final client = Supabase.instance.client;
  return ReportRepositoryImpl(ReportDatasource(client));
}

@riverpod
class ReportNotifier extends _$ReportNotifier {
  @override
  FutureOr<void> build() => null;

  Future<bool> submit({
    required String targetType,
    required String targetId,
    required String reason,
    String? details,
    Map<String, dynamic>? targetSnapshot,
  }) async {
    state = const AsyncLoading();
    final repo = ref.read(reportRepositoryProvider);

    final dupResult = await repo.checkDuplicate(
      targetType: targetType,
      targetId: targetId,
    );

    final isDup = dupResult.fold((l) => false, (r) => r);
    if (isDup) {
      state = AsyncError('Bạn đã báo cáo mục này trước đó', StackTrace.current);
      return false;
    }

    final result = await repo.submitReport(
      targetType: targetType,
      targetId: targetId,
      reason: reason,
      details: details,
      targetSnapshot: targetSnapshot,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        return true;
      },
    );
  }
}
