import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/core/theme/app_colors.dart';
import 'package:job_connect/shared/presentation/widgets/premium_button.dart';
import 'package:job_connect/shared/presentation/widgets/status_chip.dart';

void main() {
  group('PremiumButton', () {
    testWidgets('primary variant has accent background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumButton(label: 'Test'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(PremiumButton),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, AppColors.accent);
    });

    testWidgets('destructive variant has transparent background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              label: 'Delete',
              variant: PremiumButtonVariant.destructive,
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(PremiumButton),
          matching: find.byType(Container),
        ),
      );
      final hasTransparentBg = containers.any((c) {
        final d = c.decoration as BoxDecoration?;
        return d?.color == Colors.transparent;
      });
      expect(hasTransparentBg, isTrue);
    });

    testWidgets('destructive label text uses error color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              label: 'Rút đơn',
              variant: PremiumButtonVariant.destructive,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('Rút đơn'));
      expect(text.style?.color, AppColors.error);
    });

    testWidgets('secondary variant has surfaceVariant background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumButton(
              label: 'Secondary',
              variant: PremiumButtonVariant.secondary,
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(PremiumButton),
          matching: find.byType(Container),
        ),
      );
      final hasSurfaceVariantBg = containers.any((c) {
        final d = c.decoration as BoxDecoration?;
        return d?.color == AppColors.surfaceVariant;
      });
      expect(hasSurfaceVariantBg, isTrue);
    });

    testWidgets('loading state shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumButton(label: 'Test', isLoading: true),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('StatusChip', () {
    testWidgets('renders label and 6px dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(label: 'Đang chờ'),
          ),
        ),
      );

      expect(find.text('Đang chờ'), findsOneWidget);
      // Verify 6px dot container exists
      final dots = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.byType(Container),
        ),
      ).where((c) {
        final d = c.decoration as BoxDecoration?;
        return d?.shape == BoxShape.circle;
      });
      expect(dots.length, 1);
    });

    testWidgets('success tone uses success dot color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(label: 'Active', tone: StatusChipTone.success),
          ),
        ),
      );

      final dots = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.byType(Container),
        ),
      ).where((c) {
        final d = c.decoration as BoxDecoration?;
        return d?.shape == BoxShape.circle && d?.color == AppColors.success;
      });
      expect(dots.length, 1);
    });

    testWidgets('error tone uses error dot color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(label: 'Rejected', tone: StatusChipTone.error),
          ),
        ),
      );

      final dots = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.byType(Container),
        ),
      ).where((c) {
        final d = c.decoration as BoxDecoration?;
        return d?.shape == BoxShape.circle && d?.color == AppColors.error;
      });
      expect(dots.length, 1);
    });

    testWidgets('pill shape uses surfaceVariant background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusChip(label: 'Neutral'),
          ),
        ),
      );

      final outerContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StatusChip),
          matching: find.byType(Container),
        ),
      ).where((c) {
        final d = c.decoration as BoxDecoration?;
        return d?.color == AppColors.surfaceVariant;
      });
      expect(outerContainers.isNotEmpty, isTrue);
    });
  });
}
