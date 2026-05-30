import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../domain/entities/job_detail.dart';
import '../providers/job_detail_provider.dart';
import '../widgets/animated_bookmark_button.dart';

class JobDetailPage extends ConsumerWidget {
  const JobDetailPage({super.key, required this.jobPostId});

  final String jobPostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobDetailProvider(jobPostId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.when(
        data: (detail) {
          if (detail == null) return const _UnavailableJobDetail();
          return _JobDetailContent(detail: detail);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => const _UnavailableJobDetail(),
      ),
      bottomNavigationBar: state.maybeWhen(
        data: (detail) => detail == null
            ? null
            : _BottomActionBar(jobPostId: detail.jobPost.id),
        orElse: () => null,
      ),
    );
  }
}

class _JobDetailContent extends StatelessWidget {
  const _JobDetailContent({required this.detail});

  final JobDetail detail;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text(AppStrings.jobDetail),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          pinned: true,
          elevation: 0,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCard(detail: detail),
                const SizedBox(height: 16),
                _Section(
                  title: AppStrings.jobOverview,
                  children: [
                    _InfoRow(
                      icon: Icons.payments_outlined,
                      label: _salaryDisplay(detail),
                    ),
                    _InfoRow(
                      icon: Icons.work_outline,
                      label: _jobTypeLabel(detail.jobPost.type),
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: _locationDisplay(detail),
                    ),
                    if (detail.categoryName != null)
                      _InfoRow(
                        icon: Icons.category_outlined,
                        label: detail.categoryName!,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (detail.jobPost.description?.isNotEmpty ?? false)
                  _Section(
                    title: AppStrings.jobDescription,
                    children: [_Paragraph(detail.jobPost.description!)],
                  ),
                const SizedBox(height: 16),
                if (detail.jobPost.requirements?.isNotEmpty ?? false)
                  _Section(
                    title: AppStrings.jobRequirements,
                    children: [_Paragraph(detail.jobPost.requirements!)],
                  ),
                const SizedBox(height: 16),
                _Section(
                  title: AppStrings.requiredSkills,
                  children: [
                    if (detail.requiredSkills.isEmpty)
                      Text(
                        AppStrings.noData,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: detail.requiredSkills
                            .map(
                              (skill) => _SkillPill(
                                label: skill.skillName ?? AppStrings.skills,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: AppStrings.companyInfo,
                  children: [
                    Text(
                      detail.company.description ?? AppStrings.noData,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (detail.company.website?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: Icons.language,
                        label: detail.company.website!,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 96),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _salaryDisplay(JobDetail detail) {
    if (!detail.jobPost.isSalaryVisible) return AppStrings.seekerSalaryHidden;
    final min = detail.jobPost.salaryMin ~/ 1000000;
    final max = detail.jobPost.salaryMax ~/ 1000000;
    return '$min-${max}M ${AppStrings.salaryMillionPerMonth}';
  }

  String _locationDisplay(JobDetail detail) {
    if (detail.location.isRemote) return AppStrings.remoteWork;
    return [
      detail.location.address,
      detail.location.district,
      detail.location.province,
    ].whereType<String>().where((part) => part.isNotEmpty).join(', ');
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.detail});

  final JobDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CompanyLogo(detail: detail),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  detail.company.name,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            detail.jobPost.title,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({required this.detail});

  final JobDetail detail;

  @override
  Widget build(BuildContext context) {
    final logoUrl = detail.company.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) return _fallbackLogo();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: StorageUtils.publicUrl(logoUrl),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (_, __) => _fallbackLogo(),
        errorWidget: (_, __, ___) => _fallbackLogo(),
      ),
    );
  }

  Widget _fallbackLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(24),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        detail.company.name.isNotEmpty
            ? detail.company.name[0].toUpperCase()
            : '?',
        style: AppTextStyles.headline.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label.isEmpty ? AppStrings.noData : label,
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
    );
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.jobPostId});

  final String jobPostId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            AnimatedBookmarkButton(
              jobPostId: jobPostId,
              size: 26,
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.send_outlined),
                label: const Text('${AppStrings.apply} • ${AppStrings.comingSoon}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableJobDetail extends StatelessWidget {
  const _UnavailableJobDetail();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.jobDetail),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_off_outlined,
                size: 64,
                color: AppColors.textSecondary.withAlpha(90),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.unavailableJobPost,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
