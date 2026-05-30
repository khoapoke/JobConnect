import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../domain/entities/recruiter_application.dart';
import 'application_status_chip.dart';

class ApplicantCard extends StatelessWidget {
  const ApplicantCard({super.key, required this.application, this.onTap});

  final RecruiterApplication application;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage:
                  application.seekerAvatarUrl == null ||
                      application.seekerAvatarUrl!.isEmpty
                  ? null
                  : NetworkImage(
                      StorageUtils.publicUrl(application.seekerAvatarUrl!),
                    ),
              child:
                  application.seekerAvatarUrl == null ||
                      application.seekerAvatarUrl!.isEmpty
                  ? Text(
                      application.seekerName.isEmpty
                          ? '?'
                          : application.seekerName[0].toUpperCase(),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.seekerName,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (application.seekerHeadline?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        application.seekerHeadline!,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd/MM/yyyy').format(application.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ApplicationStatusChip(status: application.status),
          ],
        ),
      ),
    );
  }
}
