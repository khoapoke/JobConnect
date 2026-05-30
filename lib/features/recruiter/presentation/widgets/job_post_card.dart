import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/job_post.dart';

/// Card widget for displaying a job post in the recruiter's list.
/// Shows title, status badge, created date, and action buttons.
class JobPostCard extends StatelessWidget {
  const JobPostCard({
    super.key,
    required this.jobPost,
    this.onEdit,
    this.onPublish,
    this.onClose,
    this.onDiscard,
    this.onResubmit,
    this.onViewApplicants,
    this.applicantCount,
  });

  final JobPost jobPost;
  final VoidCallback? onEdit;
  final VoidCallback? onPublish;
  final VoidCallback? onClose;
  final VoidCallback? onDiscard;
  final VoidCallback? onResubmit;
  final VoidCallback? onViewApplicants;
  final int? applicantCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    jobPost.title,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 8),

            // Created date
            Text(
              _formatDate(jobPost.createdAt),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            // Applicant count (only for active posts)
            if (jobPost.status == 'active' && applicantCount != null) ...[
              const SizedBox(height: 4),
              Text(
                '$applicantCount ${AppStrings.applicants}',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ],

            // Rejected banner
            if (jobPost.status == 'rejected') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AppStrings.removedByAdmin,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            // Action buttons
            if (_hasActions) ...[const SizedBox(height: 12), _buildActions()],
          ],
        ),
      ),
    );
  }

  bool get _hasActions {
    return onEdit != null ||
        onPublish != null ||
        onClose != null ||
        onDiscard != null ||
        onResubmit != null ||
        onViewApplicants != null;
  }

  Widget _buildStatusBadge() {
    final (label, color) = switch (jobPost.status) {
      'draft' => (AppStrings.statusDraft, AppColors.textSecondary),
      'active' => (AppStrings.statusActive, AppColors.success),
      'closed' => (AppStrings.statusClosed, AppColors.textSecondary),
      'rejected' => (AppStrings.statusRejected, AppColors.error),
      _ => (jobPost.status, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (onEdit != null)
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Sửa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        if (onPublish != null)
          FilledButton.icon(
            onPressed: onPublish,
            icon: const Icon(Icons.publish, size: 16),
            label: Text(
              jobPost.status == 'rejected'
                  ? AppStrings.resubmit
                  : AppStrings.publish,
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        if (onClose != null)
          OutlinedButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Đóng'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: const BorderSide(color: AppColors.warning),
            ),
          ),
        if (onViewApplicants != null)
          OutlinedButton.icon(
            onPressed: onViewApplicants,
            icon: const Icon(Icons.people_outline, size: 16),
            label: const Text(AppStrings.viewApplicants),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        if (onDiscard != null)
          TextButton.icon(
            onPressed: onDiscard,
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Xóa'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hôm nay';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
