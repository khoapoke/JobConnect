import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';

/// Bottom navigation shell for Recruiter role.
///
/// 4 tabs: Trang chủ · Tin của tôi · Tin nhắn · Hồ sơ
/// Uses navigationShell.goBranch() same as existing Seeker shell.
class RecruiterShell extends ConsumerWidget {
  const RecruiterShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(conversationUnreadCountProvider);
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: AppStrings.recruiterHome,
          ),
          const NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article_rounded),
            label: AppStrings.myPosts,
          ),
          NavigationDestination(
            icon: _BadgedIcon(
              icon: Icons.chat_bubble_outline_rounded,
              hasBadge: unreadCount > 0,
            ),
            selectedIcon: const Icon(Icons.chat_bubble_rounded),
            label: AppStrings.conversations,
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.hasBadge});

  final IconData icon;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    if (!hasBadge) return Icon(icon);
    return Badge(
      smallSize: 8,
      backgroundColor: Colors.red,
      child: Icon(icon),
    );
  }
}
