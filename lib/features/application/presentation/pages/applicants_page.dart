import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/application_provider.dart';
import '../widgets/applicant_card.dart';

class ApplicantsPage extends ConsumerWidget {
  const ApplicantsPage({super.key, required this.jobId});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(applicantsProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.applicantsPageTitle),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.background,
      body: applicantsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Text(
                AppStrings.noApplicants,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(applicantsProvider(jobId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final application = applications[index];
                return ApplicantCard(
                  application: application,
                  onTap: () =>
                      context.push('/recruiter/applications/${application.id}'),
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
    );
  }
}
