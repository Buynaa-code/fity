import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_typography.dart';
import '../../../../core/ui/theme/app_spacing.dart';

/// Enhanced QuickAction with progress and gamification support
class QuickAction {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  final double? progress; // 0.0 to 1.0 for progress ring
  final String? progressLabel; // e.g., "1.8L", "3/5"
  final int? xpReward; // XP earned for this action
  final bool hasStreak; // Show streak flame
  final bool isBonus; // Surprise 2x bonus indicator
  final int? friendsActive; // Social proof: friends doing this now
  final ActionPriority priority;

  const QuickAction({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    this.progress,
    this.progressLabel,
    this.xpReward,
    this.hasStreak = false,
    this.isBonus = false,
    this.friendsActive,
    this.priority = ActionPriority.normal,
  });

  QuickAction copyWith({
    String? id,
    String? title,
    IconData? icon,
    Color? color,
    VoidCallback? onTap,
    String? badge,
    double? progress,
    String? progressLabel,
    int? xpReward,
    bool? hasStreak,
    bool? isBonus,
    int? friendsActive,
    ActionPriority? priority,
  }) {
    return QuickAction(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      onTap: onTap ?? this.onTap,
      badge: badge ?? this.badge,
      progress: progress ?? this.progress,
      progressLabel: progressLabel ?? this.progressLabel,
      xpReward: xpReward ?? this.xpReward,
      hasStreak: hasStreak ?? this.hasStreak,
      isBonus: isBonus ?? this.isBonus,
      friendsActive: friendsActive ?? this.friendsActive,
      priority: priority ?? this.priority,
    );
  }
}

enum ActionPriority { urgent, high, normal, low }

class QuickActionsSection extends StatelessWidget {
  final List<QuickAction> actions;
  final bool isDarkMode;
  final String? contextMessage;

  const QuickActionsSection({
    super.key,
    required this.actions,
    required this.isDarkMode,
    this.contextMessage,
  });

  List<QuickAction> get _sortedActions {
    final sorted = List<QuickAction>.from(actions);
    sorted.sort((a, b) {
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      if (a.progress != null && b.progress != null) {
        final aClose = a.progress! >= 0.7 && a.progress! < 1.0;
        final bClose = b.progress! >= 0.7 && b.progress! < 1.0;
        if (aClose && !bClose) return -1;
        if (bClose && !aClose) return 1;
      }
      return 0;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final sortedActions = _sortedActions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Text(
            'Түргэн үйлдэл',
            style: AppTypography.headlineSmall.copyWith(
              color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(
              left: AppSpacing.screenPadding,
              right: AppSpacing.screenPadding,
              top: AppSpacing.sm,
              bottom: AppSpacing.sm,
            ),
            itemCount: sortedActions.length,
            itemBuilder: (context, index) {
              final action = sortedActions[index];
              return Padding(
                padding: EdgeInsets.only(right: index < sortedActions.length - 1 ? AppSpacing.sm : 0),
                child: _EnhancedQuickActionItem(
                  action: action,
                  isDarkMode: isDarkMode,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EnhancedQuickActionItem extends StatefulWidget {
  final QuickAction action;
  final bool isDarkMode;

  const _EnhancedQuickActionItem({
    required this.action,
    required this.isDarkMode,
  });

  @override
  State<_EnhancedQuickActionItem> createState() => _EnhancedQuickActionItemState();
}

class _EnhancedQuickActionItemState extends State<_EnhancedQuickActionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;
    final hasProgress = action.progress != null;
    final isCompleted = (action.progress ?? 0) >= 1.0;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.lightImpact();
        action.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 88,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.4)
                  : (widget.isDarkMode ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5)),
              width: isCompleted ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.15 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional progress ring
              SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (hasProgress)
                      CustomPaint(
                        size: const Size(48, 48),
                        painter: _ProgressRingPainter(
                          progress: action.progress!,
                          color: action.color,
                          backgroundColor: widget.isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.border,
                          isCompleted: isCompleted,
                        ),
                      ),
                    Container(
                      width: hasProgress ? 36 : 44,
                      height: hasProgress ? 36 : 44,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.15)
                            : action.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check_rounded : action.icon,
                        color: isCompleted ? AppColors.success : action.color,
                        size: hasProgress ? 18 : 22,
                      ),
                    ),
                    if (action.hasStreak)
                      const Positioned(
                        top: -2,
                        right: -2,
                        child: Text('🔥', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Title
              Text(
                action.title,
                style: AppTypography.labelMedium.copyWith(
                  color: widget.isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Progress label
              if (action.progressLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  action.progressLabel!,
                  style: AppTypography.labelSmall.copyWith(
                    color: isCompleted
                        ? AppColors.success
                        : (widget.isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for progress ring around icon
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final bool isCompleted;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const strokeWidth = 3.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = isCompleted ? AppColors.success : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isCompleted != isCompleted;
  }
}

/// Helper to generate context-aware actions based on time of day
class QuickActionContextHelper {
  static String getContextMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) {
      return 'Өглөө';
    } else if (hour >= 10 && hour < 14) {
      return 'Идэвхтэй';
    } else if (hour >= 14 && hour < 18) {
      return 'Эрч';
    } else if (hour >= 18 && hour < 21) {
      return 'Орой';
    }
    return 'Амар';
  }

  static ActionPriority getWaterPriority(int currentMl, int goalMl) {
    final progress = currentMl / goalMl;
    if (progress >= 1.0) return ActionPriority.low;
    if (progress < 0.3) return ActionPriority.high;
    if (progress >= 0.7) return ActionPriority.urgent;
    return ActionPriority.normal;
  }

  static ActionPriority getWorkoutPriority(int todayWorkouts, int streak) {
    if (todayWorkouts > 0) return ActionPriority.low;
    if (streak > 0) return ActionPriority.urgent;
    return ActionPriority.high;
  }
}
