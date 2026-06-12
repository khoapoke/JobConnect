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
              final t = _controller.value;
              // Orange loop draws first (~0–0.54), then the two nodes pop in
              // with an overshoot at the top and bottom — proto §1 launch.
              return CustomPaint(
                painter: _ConnectionLoopPainter(
                  ringProgress: const Interval(0, 0.54, curve: Curves.easeInOut)
                      .transform(t),
                  node1Scale: const Interval(0.43, 0.68,
                          curve: Curves.easeOutBack)
                      .transform(t),
                  node2Scale: const Interval(0.54, 0.79,
                          curve: Curves.easeOutBack)
                      .transform(t),
                  trackColor: AppColors.hairlineFor(brightness),
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
              curve: const Interval(0.6, 1, curve: Curves.easeOut),
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

/// Pull-to-refresh spinner (§9 signature animation #4): the loop spins in
/// place of the stock spinner. A full orange ring rotating continuously.
class ConnectionLoopSpinner extends StatefulWidget {
  const ConnectionLoopSpinner({super.key, this.size = 32});

  final double size;

  @override
  State<ConnectionLoopSpinner> createState() => _ConnectionLoopSpinnerState();
}

class _ConnectionLoopSpinnerState extends State<ConnectionLoopSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reducedMotion) {
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          painter: _ConnectionLoopPainter(
            ringProgress: 1,
            node1Scale: 1,
            node2Scale: 1,
            trackColor: AppColors.hairlineFor(brightness),
          ),
        ),
      ),
    );
  }
}

class _ConnectionLoopPainter extends CustomPainter {
  const _ConnectionLoopPainter({
    required this.ringProgress,
    required this.node1Scale,
    required this.node2Scale,
    required this.trackColor,
  });

  /// 0→1: how much of the orange loop is drawn.
  final double ringProgress;

  /// 0→1 (with overshoot): pop scale of the top / bottom nodes.
  final double node1Scale;
  final double node2Scale;

  /// Hairline ring that sits under the orange draw — the full loop is
  /// always implied, even mid-animation.
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.1;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth * 2) / 2;

    // Gray track ring underneath.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, trackPaint);

    // Orange loop draws from the top (−π/2), clockwise.
    final circlePath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi,
      );
    final metric = circlePath.computeMetrics().first;
    final arcPath = metric.extractPath(
      0,
      metric.length * ringProgress.clamp(0.0, 1.0),
    );
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = AppColors.accent;
    canvas.drawPath(arcPath, strokePaint);

    // Two connection nodes pop in at the top (0°) and bottom (180°).
    final nodeRadius = strokeWidth * 0.65;
    _drawNode(canvas, Offset(center.dx, center.dy - radius), nodeRadius,
        node1Scale);
    _drawNode(canvas, Offset(center.dx, center.dy + radius), nodeRadius,
        node2Scale);
  }

  void _drawNode(Canvas canvas, Offset center, double radius, double scale) {
    if (scale <= 0) return;
    final opacity = scale.clamp(0.0, 1.0);
    final paint = Paint()
      ..color = AppColors.accent.withAlpha((opacity * 255).round());
    canvas.drawCircle(center, radius * scale, paint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionLoopPainter oldDelegate) =>
      oldDelegate.ringProgress != ringProgress ||
      oldDelegate.node1Scale != node1Scale ||
      oldDelegate.node2Scale != node2Scale ||
      oldDelegate.trackColor != trackColor;
}
