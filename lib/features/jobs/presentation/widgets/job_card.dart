import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../recruiter/domain/entities/job_post.dart';
import '../../domain/entities/job_search_result.dart';
import 'animated_bookmark_button.dart';

/// Card widget for displaying a Job Post in the Seeker search results.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.result,
    this.onBookmarkRemoved,
  });

  final JobSearchResult result;
  final VoidCallback? onBookmarkRemoved;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push('/search/${result.jobPost.id}'),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                child: _JobCardContent(result: result),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: AnimatedBookmarkButton(
              jobPostId: result.jobPost.id,
              size: 22,
              onRemoved: onBookmarkRemoved,
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCardContent extends StatelessWidget {
  const _JobCardContent({required this.result});

  final JobSearchResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CompanyLogo(result: result),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.jobPost.title,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.company.name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                result.location.isRemote
                    ? AppStrings.remoteWork
                    : result.location.province ?? 'Không xác định',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.work_outline,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              _jobTypeLabel(result.jobPost.type),
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _salaryDisplay(result.jobPost),
          style: AppTextStyles.label.copyWith(
            color: result.jobPost.isSalaryVisible
                ? AppColors.primary
                : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (result.skills.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: result.skills
                .take(3)
                .map((skill) => _SkillChip(name: skill.skillName ?? ''))
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          _relativeTime(result.jobPost.createdAt),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _salaryDisplay(JobPost jobPost) {
    if (!jobPost.isSalaryVisible) {
      return AppStrings.seekerSalaryHidden;
    }
    final min = jobPost.salaryMin ~/ 1000000;
    final max = jobPost.salaryMax ~/ 1000000;
    return '$min-${max}M';
  }

  String _jobTypeLabel(String type) {
    const labels = {
      'full_time': 'Toàn thời gian',
      'part_time': 'Bán thời gian',
      'contract': 'Hợp đồng',
      'internship': 'Thực tập',
      'remote': 'Từ xa',
      'hybrid': 'Hybrid',
    };
    return labels[type] ?? type;
  }

  String _relativeTime(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays >= 7) {
      return '${diff.inDays ~/ 7} ${AppStrings.weeksAgo}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} ${AppStrings.daysAgo}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${AppStrings.hoursAgo}';
    } else {
      return AppStrings.postedJustNow;
    }
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({required this.result});

  final JobSearchResult result;

  @override
  Widget build(BuildContext context) {
    final logoUrl = result.company.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) {
      return _buildFallbackLogo();
    }
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: StorageUtils.publicUrl(logoUrl),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildFallbackLogo(),
        errorWidget: (_, __, ___) => _buildFallbackLogo(),
      ),
    );
  }

  Widget _buildFallbackLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          result.company.name.isNotEmpty
              ? result.company.name[0].toUpperCase()
              : '?',
          style: AppTextStyles.label.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        name,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
