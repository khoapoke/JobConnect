import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: resumesAsync.when(
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
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 72,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.noResumes,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.noResumesSubtitle,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.push('/resumes'),
                        child: const Text(AppStrings.resumeManager),
                      ),
                    ],
                  ),
                ),
              );
            }

            final isEditable = existingApplication?.canEditSubmission ?? true;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (existingApplication != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      _applicationHint(existingApplication),
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
                Text(
                  AppStrings.resume,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...resumes.map(
                  (resume) => _ResumeOptionTile(
                    resume: resume,
                    selected: _selectedResumeUrl == resume.fileUrl,
                    enabled: isEditable,
                    onTap: () =>
                        setState(() => _selectedResumeUrl = resume.fileUrl),
                    onPreview: resume.fileUrl == null
                        ? null
                        : () => context.push('/resumes/preview', extra: resume),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.coverLetter,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _coverLetterController,
                        minLines: 5,
                        maxLines: 8,
                        enabled: isEditable,
                        decoration: const InputDecoration(
                          hintText: AppStrings.coverLetterHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => Center(child: Text(error.toString())),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: FilledButton.icon(
            onPressed: actionState.isLoading || auth is! AuthAuthenticated
                ? null
                : _submit,
            icon: actionState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Icon(Icons.send_outlined),
            label: Text(_submitLabel(existingApplicationAsync.valueOrNull)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.applicationBlocked)),
      );
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
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (success) {
        final message = switch (success.action) {
          'updated' => AppStrings.applicationUpdated,
          'resubmitted' => AppStrings.applicationResubmitted,
          _ => AppStrings.applicationSubmitted,
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        if (success.action == 'submitted') {
          context.go('/search');
        } else {
          context.go('/applications');
        }
      },
    );
  }

  String _submitLabel(Application? application) {
    if (application == null) return AppStrings.submitApplication;
    return application.isResubmittable
        ? AppStrings.submitApplication
        : AppStrings.saveChanges;
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume.title,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resume.isDefault
                          ? AppStrings.defaultResume
                          : (resume.isBuilderResume
                                ? AppStrings.builderResume
                                : AppStrings.uploadedResume),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPreview,
                icon: const Icon(Icons.visibility_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
