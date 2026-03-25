import 'package:flutter/material.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_typography.dart';
import '../../../../core/ui/theme/app_spacing.dart';

class WeeklyProgressChart extends StatelessWidget {
  final List<int> weeklyWorkouts; // 7 days of workout counts
  final List<double> weeklyCalories; // 7 days of calories
  final int currentStreak;
  final bool isDarkMode;

  const WeeklyProgressChart({
    super.key,
    required this.weeklyWorkouts,
    required this.weeklyCalories,
    required this.currentStreak,
    required this.isDarkMode,
  });

  static const List<String> _dayLabels = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0 = Monday
    final maxCalories = weeklyCalories.isEmpty
        ? 500.0
        : weeklyCalories.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : AppColors.textSecondary).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Долоо хоногийн тойм',
                      style: AppTypography.titleLarge.copyWith(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${weeklyWorkouts.where((w) => w > 0).length}/7 өдөр идэвхтэй',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$currentStreak',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Bar chart - Fixed overflow by using LayoutBuilder and Flexible
          SizedBox(
            height: 140, // Increased height to accommodate all elements
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isToday = index == today;
                final hasWorkout = weeklyWorkouts.length > index && weeklyWorkouts[index] > 0;
                final calories = weeklyCalories.length > index ? weeklyCalories[index] : 0.0;

                // Calculate bar height - reserve space for indicator (20px), spacing (8px), label (18px)
                // Available for bar: 140 - 20 - 8 - 18 = 94px max
                const maxBarHeight = 90.0;
                const minBarHeight = 8.0;
                final barHeight = maxCalories > 0
                    ? (calories / maxCalories * maxBarHeight).clamp(minBarHeight, maxBarHeight)
                    : minBarHeight;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Workout indicator - use SizedBox to reserve consistent space
                        SizedBox(
                          height: 20,
                          child: hasWorkout
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 16,
                                )
                              : null,
                        ),

                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? AppColors.primaryGradient
                                : LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: hasWorkout
                                        ? [AppColors.success, AppColors.success.withValues(alpha: 0.7)]
                                        : isDarkMode
                                            ? [AppColors.darkBorder, AppColors.darkSurfaceVariant]
                                            : [AppColors.border, AppColors.surfaceVariant],
                                  ),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Day label
                        Text(
                          _dayLabels[index],
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? AppColors.primary
                                : (isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppColors.success, 'Дасгал хийсэн'),
              const SizedBox(width: AppSpacing.lg),
              _buildLegendItem(AppColors.primary, 'Өнөөдөр'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
