import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaterProgressRing extends StatefulWidget {
  final double progress;
  final int currentMl;
  final int goalMl;
  final double size;
  final bool isDarkMode;
  final bool showCelebration;

  const WaterProgressRing({
    super.key,
    required this.progress,
    required this.currentMl,
    required this.goalMl,
    this.size = 220,
    this.isDarkMode = false,
    this.showCelebration = false,
  });

  @override
  State<WaterProgressRing> createState() => _WaterProgressRingState();
}

class _WaterProgressRingState extends State<WaterProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _progressController;
  late AnimationController _celebrationController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(WaterProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = oldWidget.progress;
      _progressAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0);

      // Trigger celebration when goal is reached
      if (widget.progress >= 1.0 && oldWidget.progress < 1.0) {
        _celebrationController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGoalReached = widget.progress >= 1.0;
    final primaryColor = isGoalReached ? const Color(0xFF2ECC71) : const Color(0xFF3498DB);
    final secondaryColor = isGoalReached ? const Color(0xFF27AE60) : const Color(0xFF2980B9);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with subtle gradient
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isDarkMode
                  ? Colors.grey.shade800.withValues(alpha: 0.3)
                  : Colors.grey.shade100,
            ),
          ),

          // Wave effect inside the ring
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return ClipOval(
                child: CustomPaint(
                  size: Size(widget.size - 32, widget.size - 32),
                  painter: _WavePainter(
                    progress: widget.progress.clamp(0.0, 1.0),
                    waveAnimation: _waveController.value,
                    primaryColor: primaryColor.withValues(alpha: 0.3),
                    secondaryColor: secondaryColor.withValues(alpha: 0.2),
                  ),
                ),
              );
            },
          ),

          // Background ring
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RingPainter(
              progress: 1.0,
              color: widget.isDarkMode
                  ? Colors.grey.shade700
                  : Colors.blue.shade100,
              strokeWidth: 14,
            ),
          ),

          // Progress ring with gradient
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GradientRingPainter(
                  progress: _progressAnimation.value.clamp(0.0, 1.0),
                  colors: [primaryColor, secondaryColor],
                  strokeWidth: 14,
                ),
              );
            },
          ),

          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated water drop icon
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: isGoalReached ? 1.1 : scale,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isGoalReached ? Icons.check_circle : Icons.water_drop,
                        size: 28,
                        color: primaryColor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Current amount
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '${widget.currentMl}',
                  key: ValueKey(widget.currentMl),
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: widget.isDarkMode ? Colors.white : Colors.grey.shade900,
                  ),
                ),
              ),
              Text(
                '/ ${widget.goalMl} мл',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 14,
                  color: widget.isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 6),
              // Percentage with animation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Celebration particles
          if (isGoalReached)
            AnimatedBuilder(
              animation: _celebrationController,
              builder: (context, child) {
                if (_celebrationController.value == 0) return const SizedBox();
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _CelebrationPainter(
                    progress: _celebrationController.value,
                  ),
                );
              },
            ),
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

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _GradientRingPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final double strokeWidth;

  _GradientRingPainter({
    required this.progress,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [...colors, colors.first],
      stops: const [0.0, 0.5, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final double waveAnimation;
  final Color primaryColor;
  final Color secondaryColor;

  _WavePainter({
    required this.progress,
    required this.waveAnimation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final waterHeight = size.height * (1 - progress);
    final path1 = Path();
    final path2 = Path();

    // First wave
    path1.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = waterHeight +
          math.sin((x / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi)) * 8;
      path1.lineTo(x, y);
    }
    path1.lineTo(size.width, size.height);
    path1.close();

    // Second wave (offset)
    path2.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = waterHeight +
          math.sin((x / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi) + math.pi) * 6;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.close();

    canvas.drawPath(path2, Paint()..color = secondaryColor);
    canvas.drawPath(path1, Paint()..color = primaryColor);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.waveAnimation != waveAnimation ||
        oldDelegate.progress != progress;
  }
}

class _CelebrationPainter extends CustomPainter {
  final double progress;
  final math.Random _random = math.Random(42);

  _CelebrationPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final colors = [
      const Color(0xFF3498DB),
      const Color(0xFF2ECC71),
      const Color(0xFFF39C12),
      const Color(0xFFE74C3C),
      const Color(0xFF9B59B6),
    ];

    for (int i = 0; i < 20; i++) {
      final angle = (i / 20) * 2 * math.pi + _random.nextDouble() * 0.5;
      final distance = 40 + progress * 80 + _random.nextDouble() * 30;
      final particleSize = 4.0 + _random.nextDouble() * 4;

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance - progress * 20;

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 1.0 - progress)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), particleSize * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
