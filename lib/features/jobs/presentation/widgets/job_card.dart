import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../../shared/presentation/widgets/animated_pressable.dart';
import '../../../../shared/presentation/widgets/status_chip.dart';
import '../../../recruiter/domain/entities/job_post.dart';
import '../../domain/entities/job_search_result.dart';
import 'animated_bookmark_button.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadii.lg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AnimatedPressable(
              onTap: () => context.push('/search/${result.jobPost.id}'),
              borderRadius: AppRadii.lg,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space4,
                  0,
                  AppSpacing.space4,
                ),
                child: _JobCardContent(result: result),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.space2,
              right: AppSpacing.space2,
            ),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CompanyLogo(result: result),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.jobPost.title,
                    style: AppTextStyles.title.copyWith(color: onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.company.name,
                    style: AppTextStyles.body.copyWith(color: onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Wrap(
          spacing: AppSpacing.space2,
          runSpacing: AppSpacing.space2,
          children: [
            StatusChip(
              label: result.location.isRemote
                  ? AppStrings.remoteWork
                  : result.location.province ?? 'Không xác định',
              icon: Icons.location_on_outlined,
            ),
            StatusChip(
              label: _jobTypeLabel(result.jobPost.type),
              icon: Icons.work_outline_rounded,
            ),
            StatusChip(
              label: _salaryDisplay(result.jobPost),
              tone: result.jobPost.isSalaryVisible
                  ? StatusChipTone.primary
                  : StatusChipTone.neutral,
            ),
          ],
        ),
        if (result.skills.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.space3),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: result.skills
                .take(3)
                .map((skill) => _SkillChip(name: skill.skillName ?? ''))
                .toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.space3),
        Text(
          _relativeTime(result.jobPost.createdAt),
          style: AppTextStyles.bodySmall.copyWith(color: onSurfaceVariant),
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
      return _buildFallbackLogo(context);
    }
    return ClipRRect(
      borderRadius: AppRadii.md,
      child: CachedNetworkImage(
        imageUrl: StorageUtils.publicUrl(logoUrl),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildFallbackLogo(context),
        errorWidget: (_, __, ___) => _buildFallbackLogo(context),
      ),
    );
  }

  Widget _buildFallbackLogo(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.md,
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: AppRadii.sm,
      ),
      child: Text(
        name,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}