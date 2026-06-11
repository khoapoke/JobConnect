import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_durations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class ConnectionLoopLogo extends StatefulWidget {
  const ConnectionLoopLogo({
    super.key,
    this.size = 64,
    this.animated = false,
    this.showWordmark = true,
  });

  final double size;
  final bool animated;
  final bool showWordmark;

  @override
  State<ConnectionLoopLogo> createState() => _ConnectionLoopLogoState();
}

class _ConnectionLoopLogoState extends State<ConnectionLoopLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.launch,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.animated && !reducedMotion) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant ConnectionLoopLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated != oldWidget.animated) {
      if (widget.animated) {
        _controller
          ..reset()
          ..forward();
      } else {
        _controller.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final wordmarkColor = AppColors.inkFor(brightness);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConnectionLoopPainter(
                  progress: _controller.value,
                ),
              );
            },
          ),
        ),
        if (widget.showWordmark) ...[
          const SizedBox(width: AppSpacing.space3),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.5, 1, curve: Curves.easeOut),
            ),
            child: Text(
              AppConstants.appName,
              style: AppTextStyles.display.copyWith(
                color: wordmarkColor,
                fontFamily: AppTextStyles.lora,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConnectionLoopPainter extends CustomPainter {
  const _ConnectionLoopPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.1;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth * 2) / 2;

    // Draw arc from top (−π/2) sweeping full circle * progress
    final circlePath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi,
      );
    final metric = circlePath.computeMetrics().first;
    final arcPath = metric.extractPath(
      0,
      metric.length * progress.clamp(0.0, 1.0),
    );

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = AppColors.accent;

    canvas.drawPath(arcPath, strokePaint);

    // Nodes at top-right (~315°) and bottom-left (~135°)
    final node1 = Offset(
      center.dx + radius * math.cos(-math.pi / 4),
      center.dy + radius * math.sin(-math.pi / 4),
    );
    final node2 = Offset(
      center.dx + radius * math.cos(3 * math.pi / 4),
      center.dy + radius * math.sin(3 * math.pi / 4),
    );
    final nodePaint = Paint()..color = AppColors.accent;

    if (progress > 0.1) {
      canvas.drawCircle(node1, strokeWidth * 0.65, nodePaint);
    }
    if (progress > 0.6) {
      canvas.drawCircle(node2, strokeWidth * 0.65, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectionLoopPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
