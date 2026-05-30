import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/resume.dart';

class ResumeCard extends StatelessWidget {
  const ResumeCard({
    super.key,
    required this.resume,
    this.onPreview,
    this.onSetDefault,
    this.onEdit,
    this.onDelete,
  });

  final Resume resume;
  final VoidCallback? onPreview;
  final VoidCallback? onSetDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                    const SizedBox(height: 6),
                    Text(
                      resume.isBuilderResume
                          ? AppStrings.builderResume
                          : AppStrings.uploadedResume,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (resume.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(24),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    AppStrings.defaultResume,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            DateFormat('dd/MM/yyyy · HH:mm').format(resume.updatedAt),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text(AppStrings.previewPdf),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: resume.isDefault ? null : onSetDefault,
                  child: const Text(AppStrings.setDefaultResume),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(
                    resume.isBuilderResume
                        ? Icons.edit_outlined
                        : Icons.upload_file_outlined,
                  ),
                  label: Text(
                    resume.isBuilderResume
                        ? AppStrings.editResume
                        : AppStrings.replacePdf,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text(AppStrings.deleteResume),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
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
