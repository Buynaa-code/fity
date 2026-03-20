import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_local_datasource.dart';
import '../models/statistics_model.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsLocalDatasource localDatasource;

  StatisticsRepositoryImpl({required this.localDatasource});

  @override
  Future<WorkoutStatistics> getWorkoutStatistics() async {
    return await localDatasource.getWorkoutStatistics();
  }

  @override
  Future<WeeklyStats> getWeeklyStats() async {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = today;

    final activities = await localDatasource.getDailyActivities(weekStart, weekEnd);

    final totalWorkouts = activities.fold<int>(0, (sum, a) => sum + a.workoutCount);
    final totalCalories = activities.fold<double>(0, (sum, a) => sum + a.caloriesBurned);
    final totalWater = activities.fold<int>(0, (sum, a) => sum + a.waterMl);
    final goalsMetCount = activities.where((a) => a.isGoalMet).length;

    return WeeklyStats(
      dailyActivities: activities,
      totalWorkouts: totalWorkouts,
      totalCalories: totalCalories,
      totalWaterMl: totalWater,
      goalsMetCount: goalsMetCount,
    );
  }

  @override
  Future<List<DailyActivity>> getMonthlyActivities(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return await localDatasource.getDailyActivities(start, end);
  }

  @override
  Future<void> recordWorkout({
    required String exerciseName,
    required double calories,
    required Duration duration,
  }) async {
    // Update overall statistics
    final stats = await localDatasource.getWorkoutStatistics();
    final newExerciseCounts = Map<String, int>.from(stats.exerciseCounts);
    newExerciseCounts[exerciseName] = (newExerciseCounts[exerciseName] ?? 0) + 1;

    // Calculate streak
    int newStreak = stats.currentStreak;
    int bestStreak = stats.bestStreak;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (stats.lastWorkoutDate != null) {
      final lastDate = DateTime(
        stats.lastWorkoutDate!.year,
        stats.lastWorkoutDate!.month,
        stats.lastWorkoutDate!.day,
      );
      final diff = todayDate.difference(lastDate).inDays;

      if (diff == 1) {
        newStreak = stats.currentStreak + 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    if (newStreak > bestStreak) {
      bestStreak = newStreak;
    }

    // Get weekly data
    final weekStart = todayDate.subtract(Duration(days: todayDate.weekday - 1));
    final weekActivities = await localDatasource.getDailyActivities(
      weekStart,
      todayDate,
    );

    // Build weekly arrays (Mon-Sun)
    final weeklyWorkouts = List<int>.filled(7, 0);
    final weeklyCalories = List<double>.filled(7, 0);

    for (final activity in weekActivities) {
      final dayIndex = activity.date.weekday - 1; // 0-6 (Mon-Sun)
      if (dayIndex >= 0 && dayIndex < 7) {
        weeklyWorkouts[dayIndex] = activity.workoutCount;
        weeklyCalories[dayIndex] = activity.caloriesBurned;
      }
    }

    // Add current workout to today's count
    final todayIndex = todayDate.weekday - 1;
    weeklyWorkouts[todayIndex] = (weeklyWorkouts[todayIndex]) + 1;
    weeklyCalories[todayIndex] = weeklyCalories[todayIndex] + calories;

    final updatedStats = WorkoutStatisticsModel(
      totalWorkouts: stats.totalWorkouts + 1,
      todayWorkouts: weeklyWorkouts[todayIndex],
      currentStreak: newStreak,
      bestStreak: bestStreak,
      totalCalories: stats.totalCalories + calories,
      totalTime: stats.totalTime + duration,
      exerciseCounts: newExerciseCounts,
      lastWorkoutDate: today,
      weeklyWorkouts: weeklyWorkouts,
      weeklyCalories: weeklyCalories,
    );

    await localDatasource.saveWorkoutStatistics(updatedStats);

    // Update daily activity
    final activities = await localDatasource.getDailyActivities(todayDate, todayDate);
    final currentActivity = activities.isNotEmpty
        ? activities.first
        : DailyActivityModel(
            date: todayDate,
            workoutCount: 0,
            caloriesBurned: 0,
            waterMl: 0,
            activeTime: Duration.zero,
            isGoalMet: false,
          );

    final updatedActivity = DailyActivityModel(
      date: todayDate,
      workoutCount: currentActivity.workoutCount + 1,
      caloriesBurned: currentActivity.caloriesBurned + calories,
      waterMl: currentActivity.waterMl,
      activeTime: currentActivity.activeTime + duration,
      isGoalMet: (currentActivity.workoutCount + 1) >= 1,
    );

    await localDatasource.saveDailyActivity(updatedActivity);
  }
}
