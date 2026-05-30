import 'package:flutter/material.dart';

import '../../../core/theme/app_durations.dart';

class ScrollAwareBottomNavScaffold extends StatefulWidget {
  const ScrollAwareBottomNavScaffold({
    super.key,
    required this.body,
    required this.bottomNavigationBar,
    required this.currentIndex,
    this.scrollAwareIndexes = const {0, 1},
    this.hideThreshold = 28,
  });

  final Widget body;
  final Widget bottomNavigationBar;
  final int currentIndex;
  final Set<int> scrollAwareIndexes;
  final double hideThreshold;

  @override
  State<ScrollAwareBottomNavScaffold> createState() =>
      _ScrollAwareBottomNavScaffoldState();
}

class _ScrollAwareBottomNavScaffoldState
    extends State<ScrollAwareBottomNavScaffold> {
  bool _isVisible = true;
  double _scrollAccumulator = 0;

  @override
  void didUpdateWidget(covariant ScrollAwareBottomNavScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isScrollAware) {
      _showNav();
    }
  }

  bool get _isScrollAware =>
      widget.scrollAwareIndexes.contains(widget.currentIndex);

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!_isScrollAware || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification.metrics.pixels <= 0) {
      _scrollAccumulator = 0;
      _showNav();
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 0) {
        _scrollAccumulator = (_scrollAccumulator + delta).clamp(0, 10000);
        if (_scrollAccumulator >= widget.hideThreshold) {
          _hideNav();
        }
      } else if (delta < 0) {
        _scrollAccumulator = (_scrollAccumulator + delta).clamp(-10000, 0);
        if (_scrollAccumulator <= -widget.hideThreshold) {
          _showNav();
        }
      }
    }

    if (notification is ScrollEndNotification) {
      _scrollAccumulator = 0;
    }

    return false;
  }

  void _hideNav() {
    if (!_isVisible) return;
    setState(() => _isVisible = false);
  }

  void _showNav() {
    if (_isVisible) return;
    setState(() => _isVisible = true);
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration = reducedMotion ? Duration.zero : AppDurations.base;
    final shouldShow = !_isScrollAware || _isVisible;

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: widget.body,
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: duration,
        curve: Curves.easeOutCubic,
        offset: shouldShow ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: duration,
          opacity: shouldShow ? 1 : 0,
          child: IgnorePointer(
            ignoring: !shouldShow,
            child: widget.bottomNavigationBar,
          ),
        ),
      ),
    );
  }
}