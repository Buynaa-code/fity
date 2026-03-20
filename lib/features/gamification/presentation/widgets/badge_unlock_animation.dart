import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/badge_definitions.dart';

class BadgeUnlockAnimation extends StatefulWidget {
  final UserBadge userBadge;
  final VoidCallback? onComplete;

  const BadgeUnlockAnimation({
    super.key,
    required this.userBadge,
    this.onComplete,
  });

  static Future<void> show(BuildContext context, UserBadge userBadge) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BadgeUnlockAnimation(
          userBadge: userBadge,
          onComplete: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  State<BadgeUnlockAnimation> createState() => _BadgeUnlockAnimationState();
}

class _BadgeUnlockAnimationState extends State<BadgeUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;

  Badge? badge;

  @override
  void initState() {
    super.initState();

    badge = BadgeDefinitions.getBadgeById(widget.userBadge.badgeId);

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    HapticFeedback.heavyImpact();
    _scaleController.forward();
    _shimmerController.repeat();
    _particleController.forward();

    // Auto close after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (badge == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onComplete,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleController,
              _shimmerController,
              _particleController,
            ]),
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Particles
                  _buildParticles(),

                  // Badge icon with effects
                  Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow effect
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: badge!.color.withValues(alpha: 0.6),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        // Shimmer ring
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.8),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              stops: [
                                _shimmerAnimation.value - 0.3,
                                _shimmerAnimation.value,
                                _shimmerAnimation.value + 0.3,
                              ].map((s) => s.clamp(0.0, 1.0)).toList(),
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                          ),
                        ),

                        // Badge icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                badge!.color,
                                badge!.color.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            badge!.iconData,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'ШИНЭ ШАГНАЛ!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Badge name
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      badge!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Rarity
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: badge!.rarityGradient,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge!.rarityName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // XP reward
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: Colors.amber[400],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${badge!.xpReward} XP',
                          style: TextStyle(
                            color: Colors.amber[400],
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Tap to continue
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Үргэлжлүүлэхийн тулд дарна уу',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return SizedBox(
      width: 300,
      height: 200,
      child: CustomPaint(
        painter: ParticlePainter(
          animation: _particleController,
          color: badge!.color,
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  ParticlePainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = [
      Offset(0.2, 0.3),
      Offset(0.8, 0.2),
      Offset(0.5, 0.1),
      Offset(0.3, 0.7),
      Offset(0.7, 0.6),
      Offset(0.1, 0.5),
      Offset(0.9, 0.4),
      Offset(0.4, 0.8),
    ];

    for (var i = 0; i < random.length; i++) {
      final progress = (animation.value + i * 0.1) % 1.0;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      paint.color = i % 2 == 0
          ? color.withValues(alpha: opacity * 0.6)
          : Colors.amber.withValues(alpha: opacity * 0.6);

      final x = random[i].dx * size.width;
      final y = random[i].dy * size.height - progress * 100;
      final radius = 4.0 + (1.0 - progress) * 4;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
