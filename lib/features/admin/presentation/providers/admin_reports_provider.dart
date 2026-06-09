import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'admin_dashboard_provider.dart';

part 'admin_reports_provider.g.dart';

@riverpod
class AdminReportFilter extends _$AdminReportFilter {
  @override
  String build() => 'pending'; // pending | resolved | dismissed | all

  void setFilter(String value) => state = value;
}

@riverpod
Future<Map<String, dynamic>> adminReportStats(Ref ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.getReportStats();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
}

@riverpod
Future<List<Map<String, dynamic>>> adminReports(Ref ref) async {
  final filter = ref.watch(adminReportFilterProvider);
  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.getReports(
    status: filter == 'all' ? null : filter,
  );
  return result.fold(
    (failure) => throw Exception(failure.message),
    (reports) => reports,
  );
}

@riverpod
Future<Map<String, dynamic>?> adminReportDetail(Ref ref, String reportId) async {
  final repo = ref.watch(adminRepositoryProvider);
  final result = await repo.getReportById(reportId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (report) => report,
  );
}
