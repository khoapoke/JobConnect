import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/presentation/widgets/app_skeleton.dart';

class JobDetailSkeleton extends StatelessWidget {
  const JobDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          pinned: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroSkeleton(),
                SizedBox(height: AppSpacing.space4),
                _SectionSkeleton(lines: 3),
                SizedBox(height: AppSpacing.space4),
                _SectionSkeleton(lines: 4),
                SizedBox(height: AppSpacing.space4),
                _SectionSkeleton(lines: 1),
                SizedBox(height: AppSpacing.space4),
                _SectionSkeleton(lines: 3),
                SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xl,
        border: Border.all(color: AppColors.outline),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSkeleton(
                width: 64,
                height: 64,
                shape: BoxShape.circle,
              ),
              SizedBox(width: AppSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 120, height: 16),
                    SizedBox(height: AppSpacing.space2),
                    AppSkeleton(
                      width: 80,
                      height: 14,
                      borderRadius: AppRadii.sm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.space5),
          AppSkeleton(width: 240, height: 30),
          SizedBox(height: AppSpacing.space4),
          Row(
            children: [
              AppSkeleton(
                width: 80,
                height: 28,
                borderRadius: AppRadii.sm,
              ),
              SizedBox(width: AppSpacing.space2),
              AppSkeleton(
                width: 80,
                height: 28,
                borderRadius: AppRadii.sm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lg,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton(width: 120, height: 18),
          const SizedBox(height: AppSpacing.space3),
          ...List.generate(lines, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space2),
              child: AppSkeleton(
                width: index == lines - 1 ? 160 : double.infinity,
                height: 14,
              ),
            );
          }),
        ],
      ),
    );
  }
}
