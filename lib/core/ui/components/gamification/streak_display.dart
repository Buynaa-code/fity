import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Streak display widget following gamification best practices
/// Shows current streak with fire animation and progress to next milestone
class StreakDisplay extends StatelessWidget {
  final int currentStreak;
  final int? nextMilestone;
  final bool isCompact;
  final VoidCallback? onTap;

  const StreakDisplay({
    super.key,
    required this.currentStreak,
    this.nextMilestone,
    this.isCompact = false,
    this.onTap,
  });

  int get _nextMilestone => nextMilestone ?? _calculateNextMilestone();

  int _calculateNextMilestone() {
    const milestones = [7, 14, 30, 60, 90, 180, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) return milestone;
    }
    return ((currentStreak ~/ 100) + 1) * 100;
  }

  double get _progressToMilestone {
    final previousMilestone = _getPreviousMilestone();
    final range = _nextMilestone - previousMilestone;
    final progress = currentStreak - previousMilestone;
    return (progress / range).clamp(0.0, 1.0);
  }

  int _getPreviousMilestone() {
    const milestones = [0, 7, 14, 30, 60, 90, 180, 365];
    for (int i = milestones.length - 1; i >= 0; i--) {
      if (currentStreak >= milestones[i]) return milestones[i];
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompact();
    }
    return _buildFull();
  }

  Widget _buildCompact() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.streakGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.streak.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              '$currentStreak',
              style: AppTypography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.streakGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$currentStreak',
                            style: AppTypography.numberSmall.copyWith(
                              color: AppColors.streak,
                            ),
                          ),
                          Text(
                            ' хоногийн streak',
                            style: AppTypography.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getMotivationalText(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress bar to next milestone
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Дараагийн milestone',
                      style: AppTypography.labelSmall,
                    ),
                    Text(
                      '$currentStreak/$_nextMilestone хоног',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.streak,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressToMilestone,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.streak),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMotivationalText() {
    final remaining = _nextMilestone - currentStreak;
    if (remaining == 1) {
      return 'Маргааш milestone-д хүрнэ! 🎉';
    } else if (remaining <= 3) {
      return 'Бараг хүрч байна! $remaining хоног үлдлээ';
    } else if (currentStreak >= 30) {
      return 'Гайхалтай! Тасралтгүй үргэлжлүүл! 💪';
    } else if (currentStreak >= 7) {
      return 'Сайн байна! Давж байгаарай! 👏';
    } else {
      return 'Эхлэл сайн байна! $remaining хоног үлдлээ';
    }
  }
}
