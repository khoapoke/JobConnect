import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../auth/data/datasources/auth_datasource.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
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
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.profile,
          style: AppTextStyles.headline
              .copyWith(color: AppColors.textPrimaryFor(brightness)),
        ),
        centerTitle: true,
        backgroundColor: AppColors.backgroundFor(brightness),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const [_ThemeModeAction()],
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
                  color: AppColors.textSecondaryFor(brightness),
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
    final brightness = Theme.of(context).brightness;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.surfaceVariantFor(brightness),
            backgroundImage: _avatarImage(),
            child: _avatarImage() == null
                ? Icon(
                    Icons.person,
                    size: 56,
                    color: AppColors.textSecondaryFor(brightness),
                  )
                : null,
          ),
          const SizedBox(height: 16),

          // Full name — Lora identity hero (§3).
          Text(
            profile.fullName,
            style: AppTextStyles.display.copyWith(
              fontFamily: AppTextStyles.lora,
              color: AppColors.textPrimaryFor(brightness),
            ),
            textAlign: TextAlign.center,
          ),

          // Headline
          if (profile.headline != null && profile.headline!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.headline!,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondaryFor(brightness),
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
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondaryFor(brightness),
                ),
                const SizedBox(width: 4),
                Text(
                  profile.location!,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondaryFor(brightness),
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
                  color: AppColors.textPrimaryFor(brightness),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          Divider(color: AppColors.outlineFor(brightness)),
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
                foregroundColor: AppColors.textSecondaryFor(brightness),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                AppStrings.logout,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondaryFor(brightness),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ─── T-13: Company Link (role-gated) ────────────────────
          _CompanyLinkSection(),

          Divider(color: AppColors.outlineFor(brightness)),
          const SizedBox(height: 16),

          // ─── T-11: Work Experiences Section ─────────────────────
          _WorkExperiencesSection(userId: profile.id),

          const SizedBox(height: 16),
          Divider(color: AppColors.outlineFor(brightness)),
          const SizedBox(height: 16),

          // ─── T-11: Educations Section ───────────────────────────
          _EducationsSection(userId: profile.id),

          const SizedBox(height: 16),
          Divider(color: AppColors.outlineFor(brightness)),
          const SizedBox(height: 16),

          // ─── T-11: Certificates Section ─────────────────────
          _CertificatesSection(userId: profile.id),

          const SizedBox(height: 16),
          Divider(color: AppColors.outlineFor(brightness)),
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
    final auth = ref.read(authProvider);
    if (auth is AuthAuthenticated) {
      // Delete FCM token before logout
      await ref.read(notificationRepositoryProvider).deleteFcmToken(
        userId: auth.userId,
        fcmToken: (await ref.read(notificationRepositoryProvider).getFcmToken()).fold(
          (_) => null,
          (token) => token,
        ) ?? '',
      );
    }
    final logoutUseCase = LogoutUseCase(
      AuthRepositoryImpl(
        AuthDatasourceImpl(Supabase.instance.client),
      ),
    );
    await logoutUseCase.call();
    // Do NOT navigate — router guard handles redirect to /login
  }
}

// ─── T-13: Company Link (role-gated) ──────────────────────────────────

class _CompanyLinkSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    if (auth.role != UserRole.recruiter) return const SizedBox.shrink();

    final brightness = Theme.of(context).brightness;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(brightness),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/recruiter/company'),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.business,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.companyProfile,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimaryFor(brightness),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textSecondaryFor(brightness),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Work Experiences Section ─────────────────────────────────────────

class _WorkExperiencesSection extends ConsumerWidget {
  const _WorkExperiencesSection({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiencesAsync = ref.watch(workExperiencesProvider);
    final brightness = Theme.of(context).brightness;

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
                      color: AppColors.textSecondaryFor(brightness),
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
    final brightness = Theme.of(context).brightness;

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
                      color: AppColors.textSecondaryFor(brightness),
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
    final brightness = Theme.of(context).brightness;

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
                      color: AppColors.textSecondaryFor(brightness),
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
    final brightness = Theme.of(context).brightness;

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
                      color: AppColors.textSecondaryFor(brightness),
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
                                color: AppColors.textPrimaryFor(brightness),
                              ),
                            ),
                            backgroundColor: _chipColor(skill.level, brightness),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => _confirmDeleteSkill(
                              context,
                              ref,
                              skill,
                            ),
                            side: BorderSide(
                              color: AppColors.outlineFor(brightness),
                            ),
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

  Color _chipColor(String level, Brightness brightness) => switch (level) {
        'beginner' => AppColors.surfaceVariantFor(brightness),
        'intermediate' => AppColors.primary.withAlpha(30),
        'advanced' => AppColors.primary.withAlpha(64),
        _ => AppColors.surfaceVariantFor(brightness),
      };

  void _confirmDeleteSkill(
    BuildContext context,
    WidgetRef ref,
    UserSkill skill,
  ) {
    final brightness = Theme.of(context).brightness;
    showDialog(
      context: context,
      builder: (dialogContext) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogThemeData(
            backgroundColor: AppColors.surfaceFor(brightness),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.cardBorderRadius),
            ),
          ),
        ),
        child: AlertDialog(
          title: Text(
            AppStrings.confirmDelete,
            style: AppTextStyles.title
                .copyWith(color: AppColors.textPrimaryFor(brightness)),
          ),
          content: Text(
            AppStrings.deleteSkillMessage,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondaryFor(brightness)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppStrings.cancel,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondaryFor(brightness),
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

/// App-bar action to switch theme mode (system / light / dark). Drives
/// [themeModeControllerProvider] which persists the choice (§2 dark rules).
class _ThemeModeAction extends ConsumerWidget {
  const _ThemeModeAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final controller = ref.read(themeModeControllerProvider.notifier);
    final brightness = Theme.of(context).brightness;

    return PopupMenuButton<ThemeMode>(
      tooltip: AppStrings.themeAppearance,
      icon: Icon(
        _iconFor(mode),
        color: AppColors.textPrimaryFor(brightness),
      ),
      color: AppColors.surfaceFor(brightness),
      onSelected: controller.setMode,
      itemBuilder: (context) => [
        _item(ThemeMode.system, AppStrings.themeSystem,
            Icons.brightness_auto_outlined, mode, brightness),
        _item(ThemeMode.light, AppStrings.themeLight,
            Icons.light_mode_outlined, mode, brightness),
        _item(ThemeMode.dark, AppStrings.themeDark,
            Icons.dark_mode_outlined, mode, brightness),
      ],
    );
  }

  PopupMenuItem<ThemeMode> _item(
    ThemeMode value,
    String label,
    IconData icon,
    ThemeMode current,
    Brightness brightness,
  ) {
    final selected = value == current;
    return PopupMenuItem<ThemeMode>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: selected
                ? AppColors.accent
                : AppColors.textSecondaryFor(brightness),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: selected
                  ? AppColors.accent
                  : AppColors.textPrimaryFor(brightness),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto_outlined,
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
      };
}
