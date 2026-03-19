import '../entities/statistics.dart';

abstract class StatisticsRepository {
  Future<WorkoutStatistics> getWorkoutStatistics();
  Future<WeeklyStats> getWeeklyStats();
  Future<List<DailyActivity>> getMonthlyActivities(int year, int month);
  Future<void> recordWorkout({
    required String exerciseName,
    required double calories,
    required Duration duration,
  });
}
