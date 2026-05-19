import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/company_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/storage_utils.dart';
import '../../domain/entities/company.dart';
import '../providers/company_provider.dart';

/// Read-only company profile view (push route at `/recruiter/company`).
///
/// Two states based on currentCompanyProvider:
/// - Empty state (company == null): CTA to create company
/// - Data state (company != null): Display company details + edit button
class CompanyProfilePage extends ConsumerWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyAsync = ref.watch(currentCompanyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.companyProfile,
          style: AppTextStyles.headline.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: companyAsync.when(
        data: (company) => company == null
            ? _EmptyState()
            : _CompanyContent(company: company),
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
                onPressed: () => ref.invalidate(currentCompanyProvider),
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.business,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.companyEmptyTitle,
              style: AppTextStyles.headline.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.companyEmptySubtitle,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/recruiter/company/edit'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.createCompany,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyContent extends StatelessWidget {
  const _CompanyContent({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Logo
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 100,
              height: 100,
              color: AppColors.surfaceVariant,
              child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                  ? Image.network(
                      StorageUtils.publicUrl(company.logoUrl!),
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.business,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.business,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Company name
          Text(
            company.name,
            style: AppTextStyles.headline.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          // Description
          if (company.description != null &&
              company.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Text(
                company.description!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Info cards
          if (company.website != null && company.website!.isNotEmpty)
            _InfoCard(
              icon: Icons.language,
              label: AppStrings.companyWebsite,
              value: company.website!,
            ),

          if (company.size != null)
            _InfoCard(
              icon: Icons.people,
              label: AppStrings.companySize,
              value: CompanySize.fromValue(company.size)?.displayLabel ??
                  company.size!,
            ),

          if (company.province != null && company.province!.isNotEmpty)
            _InfoCard(
              icon: Icons.location_on_outlined,
              label: AppStrings.companyProvince,
              value: company.province!,
            ),

          const SizedBox(height: 24),

          // Edit button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/recruiter/company/edit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.editCompany,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
