import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/animated_pressable.dart';
import '../../../../shared/presentation/widgets/app_gradient_background.dart';
import '../../../../shared/presentation/widgets/glass_surface.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/resume.dart';
import '../providers/application_provider.dart';

class ApplyPage extends ConsumerStatefulWidget {
  const ApplyPage({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<ApplyPage> createState() => _ApplyPageState();
}

class _ApplyPageState extends ConsumerState<ApplyPage> {
  final _coverLetterController = TextEditingController();
  String? _selectedResumeUrl;
  bool _didPrefill = false;

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resumesAsync = ref.watch(myResumesProvider);
    final existingApplicationAsync = ref.watch(
      myApplicationForJobProvider(widget.jobId),
    );
    final auth = ref.watch(authProvider);
    final actionState = ref.watch(applicationActionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.apply),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: AppGradientBackground(
        child: resumesAsync.when(
          data: (resumes) => existingApplicationAsync.when(
            data: (existingApplication) {
              if (!_didPrefill) {
                _didPrefill = true;
                _selectedResumeUrl =
                    existingApplication?.resumeUrl ??
                    (resumes.where((resume) => resume.isDefault).firstOrNull ??
                            resumes.firstOrNull)
                        ?.fileUrl;
                _coverLetterController.text =
                    existingApplication?.coverLetter ?? '';
              }

              if (resumes.isEmpty) {
                return _EmptyResumesState(
                  onCreateResume: () => context.push('/resumes'),
                );
              }

              final isEditable = existingApplication?.canEditSubmission ?? true;

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.space4),
                children: [
                  if (existingApplication != null) ...[
                    _ApplicationHintCard(application: existingApplication),
                    const SizedBox(height: AppSpacing.space4),
                  ],
                  Text(
                    AppStrings.resume,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space3),
                  ...resumes.map(
                    (resume) => _ResumeOptionTile(
                      resume: resume,
                      selected: _selectedResumeUrl == resume.fileUrl,
                      enabled: isEditable,
                      onTap: () =>
                          setState(() => _selectedResumeUrl = resume.fileUrl),
                      onPreview: resume.fileUrl == null
                          ? null
                          : () =>
                              context.push('/resumes/preview', extra: resume),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space5),
                  GlassSurface(
                    borderRadius: AppRadii.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.coverLetter,
                          style: AppTextStyles.sectionTitle.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        TextField(
                          controller: _coverLetterController,
                          minLines: 5,
                          maxLines: 8,
                          enabled: isEditable,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: AppStrings.coverLetterHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, _) => Center(
              child: Text(
                error.toString(),
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ),
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(
            child: Text(
              error.toString(),
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            AppSpacing.space3,
            AppSpacing.space4,
            AppSpacing.space4,
          ),
          child: PremiumButton(
            label: _submitLabel(existingApplicationAsync.valueOrNull),
            icon: const Icon(Icons.send_outlined),
            isLoading: actionState.isLoading,
            onPressed: actionState.isLoading || auth is! AuthAuthenticated
                ? null
                : _submit,
            expand: true,
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final auth = ref.read(authProvider);
    final existingApplication = ref
        .read(myApplicationForJobProvider(widget.jobId))
        .valueOrNull;
    if (auth is! AuthAuthenticated || _selectedResumeUrl == null) return;
    if (existingApplication != null && !existingApplication.canEditSubmission) {
      if (!mounted) return;
      _showError(AppStrings.applicationBlocked);
      return;
    }

    final result = await ref
        .read(applicationActionNotifierProvider.notifier)
        .apply(
          seekerId: auth.userId,
          jobId: widget.jobId,
          resumeUrl: _selectedResumeUrl!,
          coverLetter: _coverLetterController.text.trim().isEmpty
              ? null
              : _coverLetterController.text.trim(),
        );

    if (!mounted) return;
    result.fold(
      (failure) => _showError(failure.message),
      (success) {
        final message = switch (success.action) {
          'updated' => AppStrings.applicationUpdated,
          'resubmitted' => AppStrings.applicationResubmitted,
          _ => AppStrings.applicationSubmitted,
        };
        const route = '/applications';
        _showSuccessAndNavigate(message, route);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodyMedium),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessAndNavigate(String message, String route) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ApplySuccessDialog(message: message),
    );

    Future.delayed(
      AppDurations.base + AppDurations.fast,
      () {
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go(route);
        });
      },
    );
  }

  String _submitLabel(Application? application) {
    if (application == null) return AppStrings.submitApplication;
    return application.isResubmittable
        ? AppStrings.submitApplication
        : AppStrings.saveChanges;
  }
}

class _ApplicationHintCard extends StatelessWidget {
  const _ApplicationHintCard({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.lg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.space2),
          Expanded(
            child: Text(
              _applicationHint(application),
              style: AppTextStyles.body.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _applicationHint(Application application) {
    return switch (application.status) {
      'pending' =>
        'Bạn đã Apply Job Post này. Bạn vẫn có thể đổi Resume hoặc cover letter trước khi Recruiter bắt đầu xem xét.',
      'withdrawn' =>
        'Application này đã được Withdraw. Bạn có thể chỉnh sửa và nộp lại.',
      'rejected' =>
        'Application này đã bị từ chối. Bạn có thể cập nhật lại và nộp lại.',
      'reviewing' =>
        'Recruiter đang xem xét Application này. Bạn không thể chỉnh sửa lúc này.',
      'interview' =>
        'Application này đang ở giai đoạn phỏng vấn. Bạn không thể chỉnh sửa lúc này.',
      _ => '',
    };
  }
}

class _EmptyResumesState extends StatelessWidget {
  const _EmptyResumesState({required this.onCreateResume});

  final VoidCallback onCreateResume;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 72,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              AppStrings.noResumes,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              AppStrings.noResumesSubtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space4),
            PremiumButton(
              label: AppStrings.resumeManager,
              onPressed: onCreateResume,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeOptionTile extends StatelessWidget {
  const _ResumeOptionTile({
    required this.resume,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.onPreview,
  });

  final Resume resume;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space3),
      child: AnimatedPressable(
        onTap: enabled ? onTap : null,
        borderRadius: AppRadii.lg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadii.lg,
            border: Border.all(
              color: selected ? AppColors.primary : colorScheme.outline,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? AppColors.primary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume.title,
                      style: AppTextStyles.title.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      resume.isDefault
                          ? AppStrings.defaultResume
                          : (resume.isBuilderResume
                                ? AppStrings.builderResume
                                : AppStrings.uploadedResume),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onPreview != null)
                IconButton(
                  onPressed: onPreview,
                  icon: Icon(
                    Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApplySuccessDialog extends StatelessWidget {
  const _ApplySuccessDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.xl,
          border: Border.all(color: AppColors.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            Text(
              message,
              style: AppTextStyles.title.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Chuyển hướng...',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
