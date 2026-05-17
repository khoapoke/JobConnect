import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Reusable section header with title and add button.
///
/// Used in ProfilePage to delimit sections like
/// Work Experiences, Education, Certificates, and Skills.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.onAdd,
    super.key,
  });

  final String title;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.title.copyWith(color: AppColors.textPrimary),
        ),
        IconButton(
          icon: const Icon(Icons.add, color: AppColors.primary),
          onPressed: onAdd,
        ),
      ],
    );
  }
}
