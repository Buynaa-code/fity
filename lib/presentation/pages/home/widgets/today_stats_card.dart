import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_typography.dart';
import '../../../../core/ui/theme/app_spacing.dart';

class TodayStatsCard extends StatelessWidget {
  final int waterMl;
  final int waterGoalMl;
  final int caloriesBurned;
  final int caloriesGoal;
  final int workoutsToday;
  final int stepsToday;
  final int stepsGoal;
  final bool isDarkMode;
  final VoidCallback onWaterTap;
  final VoidCallback onCaloriesTap;
  final VoidCallback onWorkoutTap;
  final VoidCallback onStepsTap;

  const TodayStatsCard({
    super.key,
    required this.waterMl,
    required this.waterGoalMl,
    required this.caloriesBurned,
    required this.caloriesGoal,
    required this.workoutsToday,
    required this.stepsToday,
    required this.stepsGoal,
    required this.isDarkMode,
    required this.onWaterTap,
    required this.onCaloriesTap,
    required this.onWorkoutTap,
    required this.onStepsTap,
  });

  int get _completedGoals {
    int count = 0;
    if (waterMl >= waterGoalMl) count++;
    if (caloriesBurned >= caloriesGoal) count++;
    if (workoutsToday >= 2) count++;
    if (stepsToday >= stepsGoal) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Өнөөдрийн статистик',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              if (_completedGoals > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$_completedGoals/4',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Stats grid - 2x2
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.water_drop_rounded,
                      iconColor: AppColors.water,
                      title: 'Ус',
                      value: _formatWater(waterMl),
                      unit: waterMl >= 1000 ? 'л' : 'мл',
                      progress: waterMl / waterGoalMl,
                      isDarkMode: isDarkMode,
                      onTap: onWaterTap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.cardio,
                      title: 'Калори',
                      value: '$caloriesBurned',
                      unit: 'kcal',
                      progress: caloriesBurned / caloriesGoal,
                      isDarkMode: isDarkMode,
                      onTap: onCaloriesTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.fitness_center_rounded,
                      iconColor: AppColors.flexibility,
                      title: 'Дасгал',
                      value: '$workoutsToday',
                      unit: 'удаа',
                      progress: workoutsToday / 2,
                      isDarkMode: isDarkMode,
                      onTap: onWorkoutTap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.directions_walk_rounded,
                      iconColor: AppColors.success,
                      title: 'Алхалт',
                      value: _formatNumber(stepsToday),
                      unit: '',
                      progress: stepsToday / stepsGoal,
                      isDarkMode: isDarkMode,
                      onTap: onStepsTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }

  String _formatWater(int ml) {
    if (ml >= 1000) {
      return (ml / 1000).toStringAsFixed(1);
    }
    return '$ml';
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final double progress;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.progress,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final isComplete = progress >= 1.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: isComplete
              ? Border.all(color: AppColors.success.withValues(alpha: 0.4), width: 1.5)
              : Border.all(
                  color: isDarkMode ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(
                    color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isComplete)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Value
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.numberSmall.copyWith(
                    color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    fontSize: 22,
                  ),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    color: iconColor.withValues(alpha: 0.15),
                  ),
                  FractionallySizedBox(
                    widthFactor: clampedProgress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isComplete ? AppColors.success : iconColor,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
