import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Өнөөдрийн статистик',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stats grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Water
              Expanded(
                child: _StatTile(
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFF3498DB),
                  title: 'Ус',
                  value: '$waterMl',
                  unit: 'мл',
                  progress: waterMl / waterGoalMl,
                  goal: waterGoalMl,
                  isDarkMode: isDarkMode,
                  onTap: onWaterTap,
                ),
              ),
              const SizedBox(width: 12),
              // Calories
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: const Color(0xFFE74C3C),
                  title: 'Калори',
                  value: '$caloriesBurned',
                  unit: 'kcal',
                  progress: caloriesBurned / caloriesGoal,
                  goal: caloriesGoal,
                  isDarkMode: isDarkMode,
                  onTap: onCaloriesTap,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Workouts
              Expanded(
                child: _StatTile(
                  icon: Icons.fitness_center_rounded,
                  iconColor: const Color(0xFF9B59B6),
                  title: 'Дасгал',
                  value: '$workoutsToday',
                  unit: 'удаа',
                  progress: workoutsToday / 2, // Goal is 2 workouts
                  goal: 2,
                  isDarkMode: isDarkMode,
                  onTap: onWorkoutTap,
                ),
              ),
              const SizedBox(width: 12),
              // Steps
              Expanded(
                child: _StatTile(
                  icon: Icons.directions_walk_rounded,
                  iconColor: const Color(0xFF27AE60),
                  title: 'Алхалт',
                  value: _formatNumber(stepsToday),
                  unit: 'алхам',
                  progress: stepsToday / stepsGoal,
                  goal: stepsGoal,
                  isDarkMode: isDarkMode,
                  onTap: onStepsTap,
                ),
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
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;
  final double progress;
  final int goal;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.progress,
    required this.goal,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isComplete
              ? Border.all(color: iconColor.withValues(alpha: 0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.grey).withValues(alpha: 0.1),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Spacer(),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: clampedProgress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [iconColor, iconColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${(clampedProgress * 100).toInt()}% зорилгын',
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
