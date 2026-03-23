import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

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
  final String? contextMessage; // e.g., "Өглөөний мэнд! Дасгалаа эхлүүлээрэй"

  const QuickActionsSection({
    super.key,
    required this.actions,
    required this.isDarkMode,
    this.contextMessage,
  });

  /// Sort actions by priority and context
  List<QuickAction> get _sortedActions {
    final sorted = List<QuickAction>.from(actions);
    sorted.sort((a, b) {
      // Urgent first, then high, normal, low
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      // Then by progress (closer to goal = higher priority)
      if (a.progress != null && b.progress != null) {
        // Items close to completion (0.7-0.99) get priority
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Түргэн үйлдэл',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              // Show context hint if available
              if (contextMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFE7409).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    contextMessage!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFE7409),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 12),
            itemCount: sortedActions.length,
            itemBuilder: (context, index) {
              final action = sortedActions[index];
              return Padding(
                padding: EdgeInsets.only(right: index < sortedActions.length - 1 ? 12 : 0),
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
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
          width: 95,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: action.priority == ActionPriority.urgent
                ? Border.all(color: action.color.withValues(alpha: 0.6), width: 2)
                : isCompleted
                    ? Border.all(color: Colors.green.withValues(alpha: 0.5), width: 2)
                    : null,
            boxShadow: [
              BoxShadow(
                color: action.color.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with progress ring
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress ring (if applicable)
                        if (hasProgress)
                          CustomPaint(
                            size: const Size(52, 52),
                            painter: _ProgressRingPainter(
                              progress: action.progress!,
                              color: action.color,
                              backgroundColor: widget.isDarkMode
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                              isCompleted: isCompleted,
                            ),
                          ),
                        // Icon container
                        Container(
                          width: hasProgress ? 40 : 48,
                          height: hasProgress ? 40 : 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isCompleted
                                  ? [Colors.green, Colors.green.shade400]
                                  : [action.color, action.color.withValues(alpha: 0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(hasProgress ? 12 : 14),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_rounded : action.icon,
                            color: Colors.white,
                            size: hasProgress ? 20 : 24,
                          ),
                        ),
                        // Streak flame
                        if (action.hasStreak)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Text(
                              '🔥',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    action.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.isDarkMode ? Colors.white : Colors.black87,
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
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                            ? Colors.green
                            : (widget.isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ],
                ],
              ),
              // Badge (notification count)
              if (action.badge != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      action.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // XP reward indicator
              if (action.xpReward != null && !isCompleted)
                Positioned(
                  bottom: -6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: action.isBonus
                            ? const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              )
                            : null,
                        color: action.isBonus ? null : Colors.purple.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        action.isBonus
                            ? '2x +${action.xpReward} XP'
                            : '+${action.xpReward} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              // Friends active indicator (social proof)
              if (action.friendsActive != null && action.friendsActive! > 0)
                Positioned(
                  top: -8,
                  left: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people, size: 10, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(
                          '${action.friendsActive}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
    const strokeWidth = 4.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = isCompleted ? Colors.green : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
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
      return '☀️ Өглөө';
    } else if (hour >= 10 && hour < 14) {
      return '💪 Идэвхтэй';
    } else if (hour >= 14 && hour < 18) {
      return '⚡ Эрч';
    } else if (hour >= 18 && hour < 21) {
      return '🌙 Орой';
    }
    return '✨ Амар';
  }

  static ActionPriority getWaterPriority(int currentMl, int goalMl) {
    final progress = currentMl / goalMl;
    if (progress >= 1.0) return ActionPriority.low;
    if (progress < 0.3) return ActionPriority.high;
    if (progress >= 0.7) return ActionPriority.urgent; // Close to goal!
    return ActionPriority.normal;
  }

  static ActionPriority getWorkoutPriority(int todayWorkouts, int streak) {
    if (todayWorkouts > 0) return ActionPriority.low;
    if (streak > 0) return ActionPriority.urgent; // Protect streak!
    return ActionPriority.high;
  }
}
