import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/certificate.dart';

/// Displays a single certificate entry in the profile.
///
/// Tappable — opens edit bottom sheet (handled by parent via [onTap]).
/// Uses Container + border instead of Card widget (no shadows per DESIGN.md).
class CertificateCard extends StatelessWidget {
  const CertificateCard({
    required this.certificate,
    required this.onTap,
    super.key,
  });

  final Certificate certificate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = certificate.issuedAt != null
        ? DateFormat('MM/yyyy').format(certificate.issuedAt!)
        : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    certificate.name,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (dateStr.isNotEmpty)
                  Text(
                    dateStr,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            if (certificate.issuer != null &&
                certificate.issuer!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                certificate.issuer!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
