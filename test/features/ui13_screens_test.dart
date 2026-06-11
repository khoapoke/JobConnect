import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_test/flutter_test.dart';
import 'package:job_connect/core/theme/app_colors.dart';
import 'package:job_connect/features/notification/domain/entities/notification.dart';
import 'package:job_connect/features/notification/presentation/widgets/notification_card.dart';

void main() {
  Notification makeNotification({required bool read}) => Notification(
        id: 'n1',
        userId: 'u1',
        type: 'application_status',
        title: 'Hồ sơ của bạn đã được xem',
        body: 'Nhà tuyển dụng vừa xem hồ sơ.',
        read: read,
        createdAt: DateTime(2026, 6, 11, 10),
      );

  Widget host(Notification n) => MaterialApp(
        home: Scaffold(
          body: NotificationCard(notification: n, onTap: () {}),
        ),
      );

  // Finds the small orange unread indicator dot (one-color rule: orange is
  // reserved exclusively for this dot — §1 / §7).
  Finder orangeDot() => find.byWidgetPredicate((w) {
        if (w is! Container) return false;
        final decoration = w.decoration;
        return decoration is BoxDecoration &&
            decoration.color == AppColors.primary;
      });

  testWidgets('NotificationCard shows orange unread dot when unread',
      (tester) async {
    await tester.pumpWidget(host(makeNotification(read: true)));
    expect(find.text('Hồ sơ của bạn đã được xem'), findsOneWidget);
    expect(orangeDot(), findsNothing);

    await tester.pumpWidget(host(makeNotification(read: false)));
    expect(orangeDot(), findsOneWidget);
  });

  testWidgets('NotificationCard type icon uses quiet surfaceVariant bubble',
      (tester) async {
    await tester.pumpWidget(host(makeNotification(read: false)));

    // The icon bubble is a surfaceVariant fill, never the orange accent.
    final bubble = find.byWidgetPredicate((w) {
      if (w is! Container) return false;
      final decoration = w.decoration;
      return decoration is BoxDecoration &&
          decoration.color == AppColors.surfaceVariant;
    });
    expect(bubble, findsOneWidget);

    // Icon tint is the quiet secondary ink, not the accent.
    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.color, AppColors.textSecondary);
    expect(icon.color, isNot(AppColors.primary));
  });
}
