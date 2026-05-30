import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/resume.dart';
import '../providers/application_provider.dart';
import '../widgets/resume_card.dart';

class ResumesPage extends ConsumerWidget {
  const ResumesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(myResumesProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.resumeManager),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: resumesAsync.when(
        data: (resumes) {
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
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myResumesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: resumes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final resume = resumes[index];
                return ResumeCard(
                  resume: resume,
                  onPreview: resume.fileUrl == null
                      ? null
                      : () => context.push('/resumes/preview', extra: resume),
                  onSetDefault: auth is AuthAuthenticated
                      ? () =>
                            _setDefaultResume(context, ref, auth.userId, resume)
                      : null,
                  onEdit: auth is AuthAuthenticated
                      ? () => _editResume(context, ref, auth.userId, resume)
                      : null,
                  onDelete: auth is AuthAuthenticated
                      ? () => _deleteResume(context, ref, auth.userId, resume)
                      : null,
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'builder',
            onPressed: () => context.push('/resumes/builder'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text(AppStrings.createResume),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'upload',
            onPressed: auth is AuthAuthenticated
                ? () => _uploadPdf(context, ref, auth.userId)
                : null,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text(AppStrings.uploadResumePdf),
          ),
        ],
      ),
    );
  }

  Future<void> _setDefaultResume(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Resume resume,
  ) async {
    final result = await ref
        .read(resumeActionNotifierProvider.notifier)
        .setDefaultResume(userId: userId, resumeId: resume.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.resumeDefaultUpdated)),
      ),
    );
  }

  Future<void> _uploadPdf(
    BuildContext context,
    WidgetRef ref,
    String userId,
  ) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );

    if (picked == null ||
        picked.files.isEmpty ||
        picked.files.single.bytes == null) {
      return;
    }

    final file = picked.files.single;
    final result = await ref
        .read(resumeActionNotifierProvider.notifier)
        .uploadResumePdf(
          userId: userId,
          title: _titleFromFileName(file.name),
          pdfBytes: file.bytes!,
          fileName: file.name,
        );

    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.resumeUploaded))),
    );
  }

  Future<void> _editResume(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Resume resume,
  ) async {
    if (resume.isBuilderResume) {
      await context.push('/resumes/builder', extra: resume);
      return;
    }

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );
    if (picked == null ||
        picked.files.isEmpty ||
        picked.files.single.bytes == null) {
      return;
    }

    final file = picked.files.single;
    final result = await ref
        .read(resumeActionNotifierProvider.notifier)
        .updateUploadedResume(
          resumeId: resume.id,
          userId: userId,
          title: _titleFromFileName(file.name),
          pdfBytes: file.bytes!,
          fileName: file.name,
          currentFileUrl: resume.fileUrl ?? '',
        );

    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.resumeUpdated))),
    );
  }

  Future<void> _deleteResume(
    BuildContext context,
    WidgetRef ref,
    String userId,
    Resume resume,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Theme(
        data: Theme.of(dialogContext).copyWith(
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surface,
          ),
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(AppStrings.deleteResumeConfirmTitle),
          content: const Text(AppStrings.deleteResumeConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text(AppStrings.delete),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final result = await ref
        .read(resumeActionNotifierProvider.notifier)
        .deleteResume(userId: userId, resumeId: resume.id);
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.resumeDeleted))),
    );
  }

  String _titleFromFileName(String fileName) {
    final withoutExtension = fileName.replaceAll(
      RegExp(r'\.pdf$', caseSensitive: false),
      '',
    );
    final normalized = withoutExtension
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .trim();
    return normalized.isEmpty ? 'Resume PDF' : normalized;
  }
}
