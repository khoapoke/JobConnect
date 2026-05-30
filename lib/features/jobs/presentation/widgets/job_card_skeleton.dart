import 'package:flutter/material.dart';

import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';

class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({
    super.key,
    this.isFeatured = false,
  });

  final bool isFeatured;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isFeatured ? AppSpacing.space5 : AppSpacing.space4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: isFeatured ? AppRadii.xl : AppRadii.lg,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured) ...[
            const AppSkeleton(width: 120, height: 28),
            const SizedBox(height: AppSpacing.space5),
            const AppSkeleton(height: 28),
            const SizedBox(height: AppSpacing.space2),
            const AppSkeleton(width: 220, height: 28),
            const SizedBox(height: AppSpacing.space4),
          ] else ...[
            const Row(
              children: [
                AppSkeleton(width: 48, height: 48, borderRadius: AppRadii.md),
                SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(height: 16),
                      SizedBox(height: AppSpacing.space2),
                      AppSkeleton(width: 120, height: 14),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.space2),
                AppSkeleton(width: 24, height: 24),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
          ],
          const Wrap(
            spacing: AppSpacing.space2,
            runSpacing: AppSpacing.space2,
            children: [
              AppSkeleton(width: 110, height: 28),
              AppSkeleton(width: 88, height: 28),
              AppSkeleton(width: 96, height: 28),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          const AppSkeleton(width: 180, height: 12),
        ],
      ),
    );
  }
}