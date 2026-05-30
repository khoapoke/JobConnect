import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_durations.dart';
import '../../../core/theme/app_gradients.dart';
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
      duration: AppDurations.splash,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reducedMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
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
    final wordmarkColor = AppColors.textPrimaryFor(brightness);

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
                  brightness: brightness,
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
              curve: const Interval(0.45, 1, curve: Curves.easeOut),
            ),
            child: Text(
              AppConstants.appName,
              style: AppTextStyles.title.copyWith(
                color: wordmarkColor,
                fontFamily: AppTextStyles.spaceGrotesk,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConnectionLoopPainter extends CustomPainter {
  const _ConnectionLoopPainter({
    required this.progress,
    required this.brightness,
  });

  final double progress;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.11;
    final rect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    final loopPath = Path()
      ..addArc(rect, -math.pi * 0.15, math.pi * 1.7)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.78,
        size.width * 0.58,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.34,
        size.height * 0.98,
        size.width * 0.2,
        size.height * 0.7,
      );

    final metric = loopPath.computeMetrics().first;
    final drawPath = metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0));

    final gradientRect = Offset.zero & size;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..shader = AppGradients.connectionLoop.createShader(gradientRect);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth * 1.35
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = (brightness == Brightness.dark
              ? AppColors.primarySoft
              : AppColors.primaryLight)
          .withValues(alpha: 0.22);

    canvas.drawPath(drawPath, glowPaint);
    canvas.drawPath(drawPath, strokePaint);

    final startNode = Offset(size.width * 0.78, size.height * 0.2);
    final endNode = Offset(size.width * 0.24, size.height * 0.7);
    final pulse = 1 + (math.sin(progress * math.pi * 3) * 0.08);
    final nodePaint = Paint()
      ..color = brightness == Brightness.dark
          ? AppColors.aiAccent
          : AppColors.aiAccentLight;

    canvas.drawCircle(startNode, strokeWidth * 0.58, nodePaint);
    canvas.drawCircle(endNode, strokeWidth * 0.52 * pulse, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _ConnectionLoopPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.brightness != brightness;
  }
}