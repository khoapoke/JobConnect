import 'package:flutter/material.dart';

/// Retired scroll-aware bottom nav — now renders as a plain Scaffold with a
/// pinned bottom navigation bar per §8 of the Light Minimal system. The
/// scroll-hide behaviour is removed; `scrollAwareIndexes` and `hideThreshold`
/// are accepted but ignored so call sites compile without changes.
class ScrollAwareBottomNavScaffold extends StatelessWidget {
  const ScrollAwareBottomNavScaffold({
    super.key,
    required this.body,
    required this.bottomNavigationBar,
    required this.currentIndex,
    this.scrollAwareIndexes = const {0, 1}, // ignored
    this.hideThreshold = 28, // ignored
  });

  final Widget body;
  final Widget bottomNavigationBar;
  final int currentIndex;
  final Set<int> scrollAwareIndexes;
  final double hideThreshold;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
