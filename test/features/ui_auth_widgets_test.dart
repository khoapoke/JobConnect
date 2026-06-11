import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/core/theme/app_colors.dart';
import 'package:job_connect/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:job_connect/features/auth/presentation/widgets/social_login_button.dart';

/// Auth-screen Light Minimal pass: fields use the hairline→accent-focus system
/// and the social button is a quiet secondary pill, not a blue Material outline.
void main() {
  group('AuthTextField', () {
    testWidgets('uses hairline enabled border and accent focus border',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(label: 'Email', controller: controller),
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      final decoration = field.decoration!;
      final enabled = decoration.enabledBorder as OutlineInputBorder;
      final focused = decoration.focusedBorder as OutlineInputBorder;

      expect(decoration.filled, isTrue);
      expect(enabled.borderSide.color, AppColors.hairline);
      expect(focused.borderSide.color, AppColors.accent);
      // No Material-blue default: focus is the single accent, 1.5px.
      expect(focused.borderSide.width, 1.5);
    });
  });

  group('SocialLoginButton', () {
    testWidgets('renders as a surfaceVariant secondary pill with its label',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SocialLoginButton(
              text: 'Tiếp tục với Google',
              iconUrl: 'assets/icons/google.png',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Tiếp tục với Google'), findsOneWidget);

      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(SocialLoginButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, AppColors.surfaceVariant);
    });
  });
}
