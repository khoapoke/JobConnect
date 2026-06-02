import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../profile/domain/entities/user_skill.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../recruiter/domain/entities/job_required_skill.dart';
import '../../domain/entities/skill_gap.dart';
import '../../domain/entities/skill_gap_advice.dart';
import '../../domain/usecases/get_skill_gap_usecase.dart';
import '../providers/skill_gap_provider.dart';

class SkillGapWidget extends ConsumerWidget {
  const SkillGapWidget({
    super.key,
    required this.jobPostId,
    required this.requiredSkills,
  });

  final String jobPostId;
  final List<JobRequiredSkill> requiredSkills;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated || auth.role != UserRole.seeker) {
      return const SizedBox.shrink();
    }

    final userSkillsAsync = ref.watch(userSkillsProvider);
    final currentProfileAsync = ref.watch(currentProfileProvider);
    final userSkills = userSkillsAsync.valueOrNull ?? [];
    final currentProfile = currentProfileAsync.valueOrNull;
    final skillGap = const GetSkillGapUseCase().call(requiredSkills, userSkills);
    final adviceState = ref.watch(skillGapAdviceViewNotifierProvider);
    final isAdviceContextReady =
        userSkillsAsync.hasValue && currentProfileAsync.hasValue;
    final adviceContextKey = _adviceContextKey(
      jobPostId: jobPostId,
      requiredSkills: requiredSkills,
      userSkills: userSkills,
      currentProfile: currentProfile,
    );

    if (skillGap.totalCount == 0) {
      return const _EmptySkillGap();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadii.lg,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.skillGapTitle,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              _CompletionBadge(
                owned: skillGap.ownedCount,
                total: skillGap.totalCount,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          _SkillList(
            ownedSkills: skillGap.ownedSkills,
            missingSkills: skillGap.missingSkills,
          ),
          const SizedBox(height: AppSpacing.space3),
          if (skillGap.missingSkills.isNotEmpty)
            _AdviceSection(
              jobPostId: jobPostId,
              contextKey: adviceContextKey,
              isContextReady: isAdviceContextReady,
              state: adviceState,
            ),
        ],
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.owned, required this.total});

  final int owned;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 1.0 : owned / total;
    final color = ratio >= 0.75
        ? AppColors.success
        : ratio >= 0.5
            ? AppColors.warning
            : AppColors.error;

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: ratio,
            strokeWidth: 4,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(ratio * 100).round()}%',
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillList extends StatelessWidget {
  const _SkillList({
    required this.ownedSkills,
    required this.missingSkills,
  });

  final List<OwnedSkillInfo> ownedSkills;
  final List<MissingSkillInfo> missingSkills;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ownedSkills.isNotEmpty)
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: ownedSkills.map((s) => _OwnedPill(skill: s)).toList(),
          ),
        if (ownedSkills.isNotEmpty && missingSkills.isNotEmpty)
          const SizedBox(height: AppSpacing.space2),
        if (missingSkills.isNotEmpty)
          Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: missingSkills.map((s) => _MissingPill(skill: s)).toList(),
          ),
      ],
    );
  }
}

class _OwnedPill extends StatelessWidget {
  const _OwnedPill({required this.skill});

  final OwnedSkillInfo skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: AppRadii.md,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 14,
          ),
          const SizedBox(width: AppSpacing.space2),
          Text(
            skill.skillName,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingPill extends StatelessWidget {
  const _MissingPill({required this.skill});

  final MissingSkillInfo skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space3,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.10),
        borderRadius: AppRadii.md,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: AppColors.warning,
            size: 14,
          ),
          const SizedBox(width: AppSpacing.space2),
          Text(
            skill.skillName.isNotEmpty ? skill.skillName : AppStrings.skills,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _adviceContextKey({
  required String jobPostId,
  required List<JobRequiredSkill> requiredSkills,
  required List<UserSkill> userSkills,
  required UserProfile? currentProfile,
}) {
  final requiredSkillKeys = requiredSkills
      .map((skill) => '${skill.skillId}:${skill.skillName ?? ''}')
      .toList()
    ..sort();
  final userSkillKeys = userSkills
      .map((skill) => '${skill.skillId}:${skill.level}')
      .toList()
    ..sort();
  final profileKeys = [
    currentProfile?.headline ?? '',
    currentProfile?.bio ?? '',
    currentProfile?.location ?? '',
  ];
  return [
    jobPostId,
    ...requiredSkillKeys,
    '|skills|',
    ...userSkillKeys,
    '|profile|',
    ...profileKeys,
  ].join(';');
}

class _AdviceSection extends ConsumerWidget {
  const _AdviceSection({
    required this.jobPostId,
    required this.contextKey,
    required this.isContextReady,
    required this.state,
  });

  final String jobPostId;
  final String contextKey;
  final bool isContextReady;
  final AsyncValue<SkillGapAdviceViewState> state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.when(
      data: (adviceState) {
        if (adviceState.hasStaleAdviceFor(contextKey)) {
          return _CreateAdviceBlock(
            message: AppStrings.skillGapContextChanged,
            isLoading: !isContextReady,
            onPressed: isContextReady
                ? () => ref
                    .read(skillGapAdviceViewNotifierProvider.notifier)
                    .fetchAdvice(jobId: jobPostId, contextKey: contextKey)
                : null,
          );
        }

        final advice = adviceState.advice;
        if (advice == null) {
          return _CreateAdviceBlock(
            isLoading: !isContextReady,
            onPressed: isContextReady
                ? () => ref
                    .read(skillGapAdviceViewNotifierProvider.notifier)
                    .fetchAdvice(jobId: jobPostId, contextKey: contextKey)
                : null,
          );
        }

        if (adviceState.isCollapsed) {
          return PremiumButton(
            label: AppStrings.skillGapShowAdvice,
            icon: const Icon(Icons.visibility_outlined),
            variant: PremiumButtonVariant.secondary,
            onPressed: () => ref
                .read(skillGapAdviceViewNotifierProvider.notifier)
                .showAdvice(),
          );
        }

        return _AdviceCard(
          advice: advice,
          onHide: () => ref
              .read(skillGapAdviceViewNotifierProvider.notifier)
              .hideAdvice(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.space3),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (err, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.skillGapAdviceError,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: AppSpacing.space2),
          PremiumButton(
            label: AppStrings.skillGapAdviceRetry,
            icon: const Icon(Icons.refresh),
            variant: PremiumButtonVariant.secondary,
            onPressed: () => ref
                .read(skillGapAdviceViewNotifierProvider.notifier)
                .fetchAdvice(jobId: jobPostId, contextKey: contextKey),
          ),
        ],
      ),
    );
  }
}

class _AdviceCard extends StatefulWidget {
  const _AdviceCard({required this.advice, required this.onHide});

  final SkillGapAdvice advice;
  final VoidCallback onHide;

  @override
  State<_AdviceCard> createState() => _AdviceCardState();
}

class _AdviceCardState extends State<_AdviceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!reducedMotion && _controller.value == 0) {
      _controller.forward();
    } else if (reducedMotion) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - _animation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.ai,
          borderRadius: AppRadii.lg,
        ),
        child: GlassSurface(
          borderRadius: AppRadii.lg,
          backgroundColor: Colors.white.withValues(alpha: 0.08),
          borderColor: Colors.white.withValues(alpha: 0.14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: AppSpacing.space2),
                  Text(
                    AppStrings.skillGapAdviceTitle,
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                widget.advice.advice,
                style: AppTextStyles.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onHide,
                  child: Text(
                    AppStrings.skillGapHideAdvice,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateAdviceBlock extends StatelessWidget {
  const _CreateAdviceBlock({
    this.message,
    this.isLoading = false,
    required this.onPressed,
  });

  final String? message;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message != null) ...[
          Text(
            message!,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
        ],
        PremiumButton(
          label: AppStrings.skillGapAskAdvice,
          icon: const Icon(Icons.auto_awesome),
          variant: PremiumButtonVariant.ai,
          isLoading: isLoading,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

class _EmptySkillGap extends StatelessWidget {
  const _EmptySkillGap();

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
            AppStrings.skillGapTitle,
            style: AppTextStyles.sectionTitle.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.success.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: AppSpacing.space2),
              Expanded(
                child: Text(
                  AppStrings.skillGapEmpty,
                  style: AppTextStyles.body.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
