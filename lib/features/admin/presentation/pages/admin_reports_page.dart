import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../providers/admin_reports_provider.dart';
import '../widgets/report_card.dart';

class AdminReportsPage extends ConsumerWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(adminReportsProvider);
    final statsAsync = ref.watch(adminReportStatsProvider);
    final filter = ref.watch(adminReportFilterProvider);

    const filters = ['pending', 'resolved', 'dismissed', 'all'];
    const filterLabels = {
      'pending': 'Chờ xử lý',
      'resolved': 'Đã xử lý',
      'dismissed': 'Bỏ qua',
      'all': 'Tất cả',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Báo cáo vi phạm'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stats section
          statsAsync.when(
            data: (stats) => _ReportStatsHeader(stats: stats),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final f = filters[index];
                final isSelected = filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filterLabels[f]!),
                    selected: isSelected,
                    onSelected: (_) =>
                        ref.read(adminReportFilterProvider.notifier).setFilter(f),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(adminReportsProvider);
                ref.invalidate(adminReportStatsProvider);
              },
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: reportsAsync.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return LayoutBuilder(
                      builder: (context, constraints) => ListView(
                        children: [
                          SizedBox(height: constraints.maxHeight / 2),
                          const Center(
                            child: Text(
                              'Không có báo cáo nào',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return ReportCard(
                        report: report,
                        onTap: () => context.push('/admin/reports/${report['id']}'),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Lỗi: $e',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportStatsHeader extends StatelessWidget {
  const _ReportStatsHeader({required this.stats});

  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final byStatus = stats['byStatus'] as Map<String, dynamic>? ?? {};
    final byType = stats['byType'] as Map<String, dynamic>? ?? {};
    final total = stats['total'] as int? ?? 0;

    final pending = (byStatus['pending'] as int?) ?? 0;
    final resolved = (byStatus['resolved'] as int?) ?? 0;
    final dismissed = (byStatus['dismissed'] as int?) ?? 0;

    final userCount = (byType['user'] as int?) ?? 0;
    final jobPostCount = (byType['job_post'] as int?) ?? 0;
    final companyCount = (byType['company'] as int?) ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatBadge(
                label: 'Tổng',
                value: total,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _StatBadge(
                label: 'Chờ',
                value: pending,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _StatBadge(
                label: 'Đã xử lý',
                value: resolved,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              _StatBadge(
                label: 'Bỏ qua',
                value: dismissed,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: [
                          _pieSection(userCount, total, AppColors.primary),
                          _pieSection(jobPostCount, total, AppColors.warning),
                          _pieSection(companyCount, total, AppColors.aiAccent),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(color: AppColors.primary, label: 'Người dùng', value: userCount),
                        _LegendItem(color: AppColors.warning, label: 'Tin tuyển dụng', value: jobPostCount),
                        _LegendItem(color: AppColors.aiAccent, label: 'Công ty', value: companyCount),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  PieChartSectionData _pieSection(int count, int total, Color color) {
    return PieChartSectionData(
      value: count.toDouble(),
      color: count > 0 ? color : Colors.transparent,
      radius: 16,
      showTitle: false,
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text('$value', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
