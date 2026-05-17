import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/data/datasources/auth_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_skill.dart';
import '../providers/profile_provider.dart';
import '../widgets/certificate_card.dart';
import '../widgets/certificate_form_sheet.dart';
import '../widgets/education_card.dart';
import '../widgets/education_form_sheet.dart';
import '../widgets/skill_picker_sheet.dart';
import '../widgets/work_experience_card.dart';
import '../widgets/work_experience_form_sheet.dart';

/// Read-only profile view (shell tab at `/profile`).
///
/// Layout per plan Section 6:
/// Avatar → Full name → Headline → Location → Bio → Divider → Edit CTA → Logout
/// → Work Experiences → Educations → Certificates
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.profile,
          style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) => _ProfileContent(profile: profile),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(currentProfileProvider),
                child: Text(
                  AppStrings.retry,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
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

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: _avatarImage(),
            child: _avatarImage() == null
                ? const Icon(
                    Icons.person,
                    size: 56,
                    color: AppColors.textSecondary,
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Full name
          Text(
            profile.fullName,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          // Headline
          if (profile.headline != null && profile.headline!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.headline!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Location
          if (profile.location != null && profile.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  profile.location!,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          // Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Text(
                profile.bio!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 24),

          // Edit profile CTA (primary teal)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.push('/profile/edit'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.editProfile,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Logout (secondary, NOT teal)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _handleLogout(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                AppStrings.logout,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // ─── T-11: Work Experiences Section ─────────────────────
          _WorkExperiencesSection(userId: profile.id),

          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // ─── T-11: Educations Section ───────────────────────────
          _EducationsSection(userId: profile.id),

          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // ─── T-11: Certificates Section ─────────────────────
          _CertificatesSection(userId: profile.id),

          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 16),

          // ─── T-12: Skills Section ───────────────────────────
          _SkillsSection(userId: profile.id),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  ImageProvider? _avatarImage() {
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      return NetworkImage(StorageUtils.publicUrl(profile.avatarUrl!));
    }
    return null;
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final logoutUseCase = LogoutUseCase(
      AuthRepositoryImpl(
        AuthDatasourceImpl(Supabase.instance.client),
      ),
    );
    await logoutUseCase.call();
    // Do NOT navigate — router guard handles redirect to /login
  }
}

// ─── Work Experiences Section ─────────────────────────────────────────

class _WorkExperiencesSection extends ConsumerWidget {
  const _WorkExperiencesSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiencesAsync = ref.watch(workExperiencesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.workExperience,
          onAdd: () => showWorkExperienceFormSheet(
            context,
            ref,
            userId: userId,
          ),
        ),
        experiencesAsync.when(
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppStrings.noData,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Column(
                  children: list
                      .map(
                        (exp) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: WorkExperienceCard(
                            experience: exp,
                            onTap: () => showWorkExperienceFormSheet(
                              context,
                              ref,
                              existing: exp,
                              userId: userId,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (_, __) => Text(
            AppStrings.errorGeneral,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

// ─── Educations Section ───────────────────────────────────────────────

class _EducationsSection extends ConsumerWidget {
  const _EducationsSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educationsAsync = ref.watch(educationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.education,
          onAdd: () => showEducationFormSheet(
            context,
            ref,
            userId: userId,
          ),
        ),
        educationsAsync.when(
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppStrings.noData,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Column(
                  children: list
                      .map(
                        (edu) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: EducationCard(
                            education: edu,
                            onTap: () => showEducationFormSheet(
                              context,
                              ref,
                              existing: edu,
                              userId: userId,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (_, __) => Text(
            AppStrings.errorGeneral,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

// ─── Certificates Section ─────────────────────────────────────────────

class _CertificatesSection extends ConsumerWidget {
  const _CertificatesSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsync = ref.watch(certificatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.certificate,
          onAdd: () => showCertificateFormSheet(
            context,
            ref,
            userId: userId,
          ),
        ),
        certificatesAsync.when(
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppStrings.noData,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Column(
                  children: list
                      .map(
                        (cert) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: CertificateCard(
                            certificate: cert,
                            onTap: () => showCertificateFormSheet(
                              context,
                              ref,
                              existing: cert,
                              userId: userId,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
         error: (_, __) => Text(
            AppStrings.errorGeneral,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

// ─── Skills Section (T-12) ──────────────────────────────────────

class _SkillsSection extends ConsumerWidget {
  const _SkillsSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSkillsAsync = ref.watch(userSkillsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: AppStrings.skills,
          onAdd: () => showSkillPickerSheet(
            context,
            ref,
            userId: userId,
          ),
        ),
        userSkillsAsync.when(
          data: (list) => list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    AppStrings.noData,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: list
                      .map(
                        (skill) => GestureDetector(
                          onTap: () => showEditSkillLevelSheet(
                            context,
                            ref,
                            skill: skill,
                            userId: userId,
                          ),
                          child: Chip(
                            label: Text(
                              '${skill.skillName} \u00b7 ${skill.levelLabel}',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            backgroundColor: _chipColor(skill.level),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _confirmDeleteSkill(
                              context,
                              ref,
                              skill,
                            ),
                            side: const BorderSide(color: AppColors.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppConstants.cardBorderRadius,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (_, __) => Text(
            AppStrings.errorGeneral,
            style: AppTextStyles.body.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Color _chipColor(String level) => switch (level) {
        'beginner' => AppColors.surface,
        'intermediate' => AppColors.primary.withAlpha(30),
        'advanced' => AppColors.primary.withAlpha(64),
        _ => AppColors.surface,
      };

  void _confirmDeleteSkill(
    BuildContext context,
    WidgetRef ref,
    UserSkill skill,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
          ),
        ),
        child: AlertDialog(
          title: const Text(AppStrings.confirmDelete, style: AppTextStyles.title),
          content: const Text(
            AppStrings.deleteSkillMessage,
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppStrings.cancel,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _performDeleteSkill(context, ref, skill);
              },
              child: Text(
                AppStrings.delete,
                style:
                    AppTextStyles.label.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performDeleteSkill(
    BuildContext context,
    WidgetRef ref,
    UserSkill skill,
  ) async {
    final result = await ref
        .read(profileRepositoryProvider)
        .deleteUserSkill(userId, skill.skillId);
    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
      },
      (_) => ref.invalidate(userSkillsProvider),
    );
  }
}
