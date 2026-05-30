import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/job_search_result.dart';
import 'animated_bookmark_button.dart';

class FeaturedJobCard extends StatelessWidget {
  const FeaturedJobCard({
    super.key,
    required this.result,
    this.badgeLabel = 'Nổi bật hôm nay',
  });

  final JobSearchResult result;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: AppRadii.xl,
        boxShadow: AppShadows.featured,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadii.xl,
          onTap: () => context.push('/search/${result.jobPost.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space3,
                        vertical: AppSpacing.space2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: AppRadii.sm,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        badgeLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    AnimatedBookmarkButton(
                      jobPostId: result.jobPost.id,
                      size: 24,
                      padding: const EdgeInsets.all(AppSpacing.space2),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),
                Text(
                  result.jobPost.title,
                  style: AppTextStyles.display.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space3),
                Text(
                  '${result.company.name} · ${result.location.isRemote ? AppStrings.remoteWork : result.location.province ?? 'Không xác định'}',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.space5),
                Wrap(
                  spacing: AppSpacing.space2,
                  runSpacing: AppSpacing.space2,
                  children: [
                    _MetaPill(label: _salaryDisplay()),
                    _MetaPill(label: _jobTypeLabel(result.jobPost.type)),
                    if (result.skills.isNotEmpty)
                      _MetaPill(label: result.skills.first.skillName ?? 'Skill'),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context.push('/search/${result.jobPost.id}/apply'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        child: const Text(AppStrings.apply),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space3),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/search/${result.jobPost.id}'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text('Xem chi tiết'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _salaryDisplay() {
    if (!result.jobPost.isSalaryVisible) {
      return AppStrings.seekerSalaryHidden;
    }
    final min = result.jobPost.salaryMin ~/ 1000000;
    final max = result.jobPost.salaryMax ~/ 1000000;
    return '$min-$max triệu';
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
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: AppRadii.sm,
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: Colors.white),
      ),
    );
  }
}