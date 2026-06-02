import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../../shared/presentation/widgets/animated_pressable.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../../shared/presentation/widgets/status_chip.dart';
import '../../../ai_suggestion/domain/entities/ai_suggestion.dart';
import '../../../ai_suggestion/presentation/widgets/ai_match_explanation_card.dart';
import '../../../skill_gap/presentation/widgets/skill_gap_widget.dart';
import '../../../application/presentation/providers/application_provider.dart';
import '../../../recruiter/domain/entities/job_required_skill.dart';
import '../../domain/entities/job_detail.dart';
import '../providers/job_detail_provider.dart';
import '../widgets/animated_bookmark_button.dart';
import '../widgets/job_detail_skeleton.dart';

class JobDetailPage extends ConsumerWidget {
  const JobDetailPage({super.key, required this.jobPostId, this.aiSuggestion});

  final String jobPostId;
  final AiSuggestion? aiSuggestion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(jobDetailProvider(jobPostId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppGradientBackground(
        child: state.when(
          data: (detail) {
            if (detail == null) return const _UnavailableJobDetail();
            return _JobDetailContent(
              detail: detail,
              aiSuggestion: aiSuggestion,
            );
          },
          loading: () => const JobDetailSkeleton(),
          error: (_, __) => const _UnavailableJobDetail(),
        ),
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
  const _JobDetailContent({required this.detail, required this.aiSuggestion});

  final JobDetail detail;
  final AiSuggestion? aiSuggestion;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text(AppStrings.jobDetail),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          pinned: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space4,
              0,
              AppSpacing.space4,
              AppSpacing.space8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSection(detail: detail),
                if (aiSuggestion != null) ...[
                  const SizedBox(height: AppSpacing.space4),
                  AiMatchExplanationCard(suggestion: aiSuggestion!),
                ],
                const SizedBox(height: AppSpacing.space4),
                SkillGapWidget(
                  jobPostId: detail.jobPost.id,
                  requiredSkills: detail.requiredSkills,
                ),
                const SizedBox(height: AppSpacing.space4),
                _OverviewSection(detail: detail),
                const SizedBox(height: AppSpacing.space4),
                if (detail.jobPost.description?.isNotEmpty ?? false)
                  _ContentSection(
                    title: AppStrings.jobDescription,
                    child: _Paragraph(detail.jobPost.description!),
                  ),
                if (detail.jobPost.description?.isNotEmpty ?? false)
                  const SizedBox(height: AppSpacing.space4),
                if (detail.jobPost.requirements?.isNotEmpty ?? false)
                  _ContentSection(
                    title: AppStrings.jobRequirements,
                    child: _Paragraph(detail.jobPost.requirements!),
                  ),
                if (detail.jobPost.requirements?.isNotEmpty ?? false)
                  const SizedBox(height: AppSpacing.space4),
                _SkillsSection(skills: detail.requiredSkills),
                const SizedBox(height: AppSpacing.space4),
                _CompanySection(detail: detail),
                const SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.detail});

  final JobDetail detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadii.xl,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CompanyLogo(detail: detail),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.company.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (detail.categoryName != null) ...[
                      const SizedBox(height: AppSpacing.space1),
                      StatusChip(
                        label: detail.categoryName!,
                        icon: Icons.category_outlined,
                        tone: StatusChipTone.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space5),
          Text(
            detail.jobPost.title,
            style: AppTextStyles.headline.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              StatusChip(
                label: _salaryDisplay(detail),
                icon: Icons.payments_outlined,
                tone: StatusChipTone.primary,
              ),
              StatusChip(
                label: _locationDisplay(detail),
                icon: Icons.location_on_outlined,
              ),
              StatusChip(
                label: _jobTypeLabel(detail.jobPost.type),
                icon: Icons.work_outline,
              ),
            ],
          ),
        ],
      ),
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

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({required this.detail});

  final JobDetail detail;

  @override
  Widget build(BuildContext context) {
    final logoUrl = detail.company.logoUrl;
    if (logoUrl == null || logoUrl.isEmpty) return _fallbackLogo();
    return ClipRRect(
      borderRadius: AppRadii.md,
      child: CachedNetworkImage(
        imageUrl: StorageUtils.publicUrl(logoUrl),
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        placeholder: (_, __) => _fallbackLogo(),
        errorWidget: (_, __, ___) => _fallbackLogo(),
      ),
    );
  }

  Widget _fallbackLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.14),
        borderRadius: AppRadii.md,
      ),
      alignment: Alignment.center,
      child: Text(
        detail.company.name.isNotEmpty
            ? detail.company.name[0].toUpperCase()
            : '?',
        style: AppTextStyles.title.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.detail});

  final JobDetail detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadii.lg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.jobOverview,
            style: AppTextStyles.sectionTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
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

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadii.lg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          child,
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.skills});

  final List<JobRequiredSkill> skills;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadii.lg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.requiredSkills,
            style: AppTextStyles.sectionTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          if (skills.isEmpty)
            Text(
              AppStrings.noData,
              style: AppTextStyles.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: AppSpacing.space2,
              runSpacing: AppSpacing.space2,
              children: skills
                  .map(
                    (skill) => StatusChip(
                      label: skill.skillName ?? AppStrings.skills,
                      tone: StatusChipTone.ai,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _CompanySection extends StatelessWidget {
  const _CompanySection({required this.detail});

  final JobDetail detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadii.lg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.companyInfo,
            style: AppTextStyles.sectionTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            detail.company.description ?? AppStrings.noData,
            style: AppTextStyles.body.copyWith(
              color: colorScheme.onSurface,
              height: 1.6,
            ),
          ),
          if (detail.company.website?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.space3),
            AnimatedPressable(
              onTap: () {
                // URL launch can be wired when url_launcher is approved
              },
              child: _InfoRow(
                icon: Icons.language,
                label: detail.company.website!,
              ),
            ),
          ],
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              label.isEmpty ? AppStrings.noData : label,
              style: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Text(
      text,
      style: AppTextStyles.body.copyWith(
        color: colorScheme.onSurface,
        height: 1.6,
      ),
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  const _BottomActionBar({required this.jobPostId});

  final String jobPostId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existingApplicationAsync = ref.watch(
      myApplicationForJobProvider(jobPostId),
    );

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space3,
          AppSpacing.space4,
          AppSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        child: Row(
          children: [
            AnimatedBookmarkButton(
              jobPostId: jobPostId,
              size: 26,
              padding: const EdgeInsets.all(AppSpacing.space3),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: existingApplicationAsync.when(
                data: (application) {
                  if (application != null) {
                    return const PremiumButton(
                      label: AppStrings.applied,
                      icon: Icon(Icons.check),
                      onPressed: null,
                      variant: PremiumButtonVariant.secondary,
                    );
                  }
                  return PremiumButton(
                    label: AppStrings.apply,
                    icon: const Icon(Icons.send_outlined),
                    onPressed: () => context.push('/search/$jobPostId/apply'),
                  );
                },
                loading: () => const PremiumButton(
                  label: AppStrings.loading,
                  isLoading: true,
                  onPressed: null,
                ),
                error: (_, __) => PremiumButton(
                  label: AppStrings.apply,
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () => context.push('/search/$jobPostId/apply'),
                ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.space4),
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
    );
  }
}
