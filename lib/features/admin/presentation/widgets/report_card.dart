import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  final Map<String, dynamic> report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = report['status'] as String? ?? 'pending';
    final targetType = report['target_type'] as String? ?? 'unknown';
    final reason = report['reason'] as String? ?? '';
    final createdAt = report['created_at'] != null
        ? DateTime.tryParse(report['created_at'].toString())
        : null;

    Color statusColor;
    switch (status) {
      case 'resolved':
        statusColor = AppColors.success;
      case 'dismissed':
        statusColor = AppColors.textTertiary;
      default:
        statusColor = AppColors.warning;
    }

    IconData targetIcon;
    switch (targetType) {
      case 'job_post':
        targetIcon = Icons.work_outline;
      case 'user':
        targetIcon = Icons.person_outline;
      case 'company':
        targetIcon = Icons.business_outlined;
      default:
        targetIcon = Icons.report_outlined;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(targetIcon, color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reason,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mục tiêu: ${_targetLabel(targetType)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (createdAt != null)
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusLabel(status),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
