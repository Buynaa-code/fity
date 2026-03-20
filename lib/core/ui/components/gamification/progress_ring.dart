import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Apple Fitness+ style progress rings
class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final Widget? center;
  final bool animate;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 10,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.surfaceVariant,
    this.center,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: backgroundColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress ring
          if (animate)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: _RingPainter(
                    progress: value,
                    color: color,
                    strokeWidth: strokeWidth,
                  ),
                );
              },
            )
          else
            CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(
                progress: progress.clamp(0.0, 1.0),
                color: color,
                strokeWidth: strokeWidth,
              ),
            ),
          // Center content
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Multi-ring progress indicator (like Apple Watch Activity rings)
class ActivityRings extends StatelessWidget {
  final double moveProgress;
  final double exerciseProgress;
  final double standProgress;
  final double size;
  final double ringSpacing;

  const ActivityRings({
    super.key,
    required this.moveProgress,
    required this.exerciseProgress,
    required this.standProgress,
    this.size = 150,
    this.ringSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    final outerStroke = size / 8;
    final middleStroke = size / 9;
    final innerStroke = size / 10;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Move ring (outer - red/orange)
          ProgressRing(
            progress: moveProgress,
            size: size,
            strokeWidth: outerStroke,
            color: AppColors.cardio,
            backgroundColor: AppColors.cardio.withValues(alpha: 0.2),
          ),
          // Exercise ring (middle - green)
          ProgressRing(
            progress: exerciseProgress,
            size: size - outerStroke * 2 - ringSpacing * 2,
            strokeWidth: middleStroke,
            color: AppColors.success,
            backgroundColor: AppColors.success.withValues(alpha: 0.2),
          ),
          // Stand ring (inner - blue)
          ProgressRing(
            progress: standProgress,
            size: size - outerStroke * 4 - ringSpacing * 4,
            strokeWidth: innerStroke,
            color: AppColors.info,
            backgroundColor: AppColors.info.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

/// Simple stat with progress ring
class StatWithRing extends StatelessWidget {
  final String value;
  final String label;
  final double progress;
  final Color color;
  final IconData? icon;

  const StatWithRing({
    super.key,
    required this.value,
    required this.label,
    required this.progress,
    this.color = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProgressRing(
          progress: progress,
          size: 80,
          strokeWidth: 8,
          color: color,
          center: icon != null
              ? Icon(icon, color: color, size: 28)
              : Text(
                  value,
                  style: AppTypography.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        if (icon != null)
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        Text(
          label,
          style: AppTypography.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
