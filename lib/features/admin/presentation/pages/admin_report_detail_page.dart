import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../providers/admin_reports_provider.dart';

class AdminReportDetailPage extends ConsumerWidget {
  const AdminReportDetailPage({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(adminReportDetailProvider(reportId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chi tiết báo cáo'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: reportAsync.when(
        data: (report) {
          if (report == null) {
            return const Center(
              child: Text(
                'Không tìm thấy báo cáo',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return _ReportDetailContent(report: report);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Lỗi: $e', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}

class _ReportDetailContent extends ConsumerWidget {
  const _ReportDetailContent({required this.report});

  final Map<String, dynamic> report;

  Future<void> _resolve(BuildContext context, WidgetRef ref, String status, {String? action}) async {
    final auth = ref.read(authProvider);
    final adminId = auth is AuthAuthenticated ? auth.userId : '';
    final repo = ref.read(adminRepositoryProvider);

    // If action includes warning, send warning notification first
    if (action == 'warning') {
      String? targetUserId;
      if (report['target_type'] == 'user' && report['target_id'] != null) {
        targetUserId = report['target_id'] as String;
      }
      // For job_post / company reports, warn the reporter instead? Or skip.
      // Admin warning should go to the entity owner; for MVP we skip if not user.
      if (targetUserId != null && targetUserId.isNotEmpty) {
        final warnResult = await repo.sendWarning(
          targetUserId,
          'Tài khoản của bạn đã bị cảnh cáo do vi phạm nội quy. Vui lòng kiểm tra lại hành vi.',
        );
        final isWarnFailed = warnResult.fold(
          (_) => true,
          (_) => false,
        );
        if (isWarnFailed) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không thể gửi cảnh cáo')),
            );
          }
          return;
        }
      }
    }

    final result = await repo.resolveReport(
      reportId: report['id'] as String,
      status: status,
      action: action,
      resolvedBy: adminId,
    );

    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (_) {
        if (context.mounted) {
          ref.invalidate(adminReportsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(status == 'resolved' ? 'Đã xử lý báo cáo' : 'Đã bỏ qua báo cáo')),
          );
          context.pop();
        }
      },
    );
  }

  Future<void> _closeJobPost(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(adminRepositoryProvider);
    final result = await repo.closeJobPost(report['target_id'] as String);
    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã đóng tin tuyển dụng')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = report['status'] as String? ?? 'pending';
    final targetType = report['target_type'] as String? ?? 'unknown';
    final reason = report['reason'] as String? ?? '';
    final details = report['details'] as String?;
    final snapshot = report['target_snapshot'] as Map<String, dynamic>?;
    final createdAt = report['created_at'] != null
        ? DateTime.tryParse(report['created_at'].toString())
        : null;

    final reporter = report['reporter'] as Map<String, dynamic>?;
    final targetUser = report['target_user'] as Map<String, dynamic>?;

    Color statusColor;
    switch (status) {
      case 'resolved':
        statusColor = AppColors.success;
      case 'dismissed':
        statusColor = AppColors.textTertiary;
      default:
        statusColor = AppColors.warning;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              if (createdAt != null)
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Lý do báo cáo', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(reason, style: AppTextStyles.bodyMedium),
          ),
          if (details != null && details.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Chi tiết thêm', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(details, style: AppTextStyles.bodyMedium),
            ),
          ],
          const SizedBox(height: 20),
          const Text('Mục tiêu', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          _InfoRow(label: 'Loại', value: _targetLabel(targetType)),
          if (snapshot != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${e.key}: ${e.value}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (reporter != null) ...[
            const Text('Người báo cáo', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            _UserMiniCard(user: reporter),
          ],
          if (targetUser != null) ...[
            const SizedBox(height: 16),
            const Text('Người bị báo cáo', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            _UserMiniCard(user: targetUser),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 32),
            // One-color action stack (§6): a single accent primary (resolve),
            // quiet secondaries, and red text for the destructive close.
            if (targetType == 'job_post') ...[
              PremiumButton(
                label: 'Đóng tin tuyển dụng',
                variant: PremiumButtonVariant.destructive,
                icon: const Icon(Icons.close),
                onPressed: () => _closeJobPost(context, ref),
              ),
              const SizedBox(height: 12),
            ],
            PremiumButton(
              label: 'Cảnh cáo & Xử lý',
              variant: PremiumButtonVariant.secondary,
              icon: const Icon(Icons.warning_amber),
              onPressed: () => _resolve(context, ref, 'resolved', action: 'warning'),
            ),
            const SizedBox(height: 12),
            PremiumButton(
              label: 'Xử lý (không cảnh cáo)',
              icon: const Icon(Icons.check),
              onPressed: () => _resolve(context, ref, 'resolved'),
            ),
            const SizedBox(height: 12),
            PremiumButton(
              label: 'Bỏ qua báo cáo',
              variant: PremiumButtonVariant.ghost,
              icon: const Icon(Icons.close),
              onPressed: () => _resolve(context, ref, 'dismissed'),
            ),
          ],
        ],
      ),
    );
  }

  String _targetLabel(String type) {
    return switch (type) {
      'job_post' => 'Tin tuyển dụng',
      'user' => 'Người dùng',
      'company' => 'Công ty',
      _ => 'Khác',
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'resolved' => 'Đã xử lý',
      'dismissed' => 'Bỏ qua',
      _ => 'Chờ xử lý',
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class _UserMiniCard extends StatelessWidget {
  const _UserMiniCard({required this.user});

  final Map<String, dynamic> user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: user['avatar_url'] != null
                ? NetworkImage(user['avatar_url'] as String)
                : null,
            child: user['avatar_url'] == null
                ? const Icon(Icons.person, size: 20, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['full_name'] ?? 'Không tên',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                if (user['email'] != null)
                  Text(
                    user['email'] as String,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
