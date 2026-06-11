import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';

/// Light Minimal auth field (§5): white surface fill, hairline border that
/// turns to a 1.5px orange on focus — no Material default blue, no glow.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hairline = AppColors.hairlineFor(brightness);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: color, width: width),
        );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surfaceFor(brightness),
        floatingLabelStyle: const TextStyle(color: AppColors.accent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(hairline),
        enabledBorder: border(hairline),
        focusedBorder: border(AppColors.accent, 1.5),
        errorBorder: border(AppColors.errorFor(brightness)),
        focusedErrorBorder: border(AppColors.errorFor(brightness), 1.5),
      ),
    );
  }
}
