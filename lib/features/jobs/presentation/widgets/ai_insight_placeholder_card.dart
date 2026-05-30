import 'package:flutter/material.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';

class AiInsightPlaceholderCard extends StatelessWidget {
  const AiInsightPlaceholderCard({
    super.key,
    required this.jobCount,
    this.onPressed,
  });

  final int jobCount;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.ai,
        borderRadius: AppRadii.xl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Match sắp mở',
              style: AppTextStyles.sectionTitle.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              'Hiện có $jobCount cơ hội đang chờ bạn. Ở Phase 6, JobConnect sẽ giải thích vì sao từng job phù hợp và gợi ý kỹ năng còn thiếu.',
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: AppSpacing.space4),
            PremiumButton(
              label: 'Khám phá feed',
              variant: PremiumButtonVariant.secondary,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}