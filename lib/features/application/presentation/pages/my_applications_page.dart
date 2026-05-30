import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../../auth/domain/entities/auth_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/application.dart';
import '../../domain/entities/application_status_filter.dart';
import '../providers/application_provider.dart';
import '../widgets/application_status_chip.dart';

class MyApplicationsPage extends ConsumerStatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  ConsumerState<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends ConsumerState<MyApplicationsPage> {
  ApplicationStatusFilter _filter = ApplicationStatusFilter.all;

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(myApplicationsProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myApplications),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            onPressed: () => context.push('/resumes'),
            icon: const Icon(Icons.description_outlined),
            tooltip: AppStrings.resumeManager,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: ApplicationStatusFilter.values
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_labelFor(filter)),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: applicationsAsync.when(
              data: (applications) {
                if (applications.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.noApplications,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(myApplicationsProvider(_filter)),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: applications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final application = applications[index];
                      return InkWell(
                        onTap: () =>
                            context.push('/applications/${application.id}'),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
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
                                  _CompanyLogo(
                                    logoUrl: application.companyLogoUrl,
                                    companyName: application.companyName,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          application.jobTitle,
                                          style: AppTextStyles.title.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          application.companyName,
                                          style: AppTextStyles.body.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ApplicationStatusChip(
                                        status: application.status,
                                      ),
                                      if (application.isJobPostClosed) ...[
                                        const SizedBox(height: 6),
                                        const _ClosedBadge(),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy · HH:mm',
                                ).format(application.createdAt),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (application.interviewSchedule != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    '${AppStrings.interviewSchedule}: ${DateFormat('dd/MM/yyyy · HH:mm').format(application.interviewSchedule!.scheduledAt)}${application.interviewSchedule!.location?.isNotEmpty == true ? ' · ${application.interviewSchedule!.location}' : ''}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                              if (application.canWithdraw) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        _confirmWithdraw(application),
                                    child: const Text(
                                      AppStrings.withdrawApplication,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
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
          ),
        ],
      ),
    );
  }

  Future<void> _confirmWithdraw(Application application) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;

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
          title: const Text(AppStrings.withdrawConfirmTitle),
          content: const Text(AppStrings.withdrawConfirmMessage),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text(AppStrings.cancel),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text(AppStrings.withdrawApplication),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;
    final result = await ref
        .read(applicationActionNotifierProvider.notifier)
        .withdraw(seekerId: auth.userId, applicationId: application.id);
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.applicationWithdrawn)),
      ),
    );
  }

  String _labelFor(ApplicationStatusFilter filter) => switch (filter) {
    ApplicationStatusFilter.all => AppStrings.all,
    ApplicationStatusFilter.pending => AppStrings.statusPending,
    ApplicationStatusFilter.reviewing => AppStrings.statusReviewing,
    ApplicationStatusFilter.interview => AppStrings.statusInterview,
    ApplicationStatusFilter.rejected => AppStrings.statusRejectedApplication,
    ApplicationStatusFilter.withdrawn => AppStrings.statusWithdrawn,
  };
}

class _ClosedBadge extends StatelessWidget {
  const _ClosedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withAlpha(24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        AppStrings.jobPostClosed,
        style: AppTextStyles.label.copyWith(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({required this.logoUrl, required this.companyName});

  final String? logoUrl;
  final String companyName;

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.surfaceVariant,
        child: Text(companyName.isEmpty ? '?' : companyName[0].toUpperCase()),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundImage: NetworkImage(StorageUtils.publicUrl(logoUrl!)),
    );
  }
}
