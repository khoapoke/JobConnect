import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Shows a date picker for selecting the job post expiry date.
///
/// Constraints:
/// - firstDate: now + 1 day
/// - lastDate: now + 90 days
/// - initialDate: now + 30 days (default)
Future<DateTime?> showExpiresAtPicker(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  final now = DateTime.now();
  final defaultDate = now.add(const Duration(days: 30));

  return showDatePicker(
    context: context,
    initialDate: initialDate ?? defaultDate,
    firstDate: now.add(const Duration(days: 1)),
    lastDate: now.add(const Duration(days: 90)),
    helpText: AppStrings.selectExpiryDate,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
}

/// Formats a date for display in the expires_at field.
String formatExpiresAt(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}
