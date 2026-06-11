import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Secondary-tier auth action (§ buttons): surfaceVariant fill, no harsh
/// outline, neutral icon — matches the "Tiếp tục với Google" pill in the
/// Light Minimal prototype (panel 10).
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.iconUrl,
  });

  final String text;
  final VoidCallback onPressed;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final ink = AppColors.inkFor(brightness);

    return Material(
      color: AppColors.surfaceVariantFor(brightness),
      borderRadius: AppRadii.button,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.button,
        child: Container(
          height: AppSpacing.buttonHeight,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata, size: 28, color: ink),
              const SizedBox(width: AppSpacing.space2),
              Text(text, style: AppTextStyles.label.copyWith(color: ink)),
            ],
          ),
        ),
      ),
    );
  }
}
