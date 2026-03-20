import 'package:equatable/equatable.dart';
import '../../domain/entities/statistics.dart';

enum StatisticsStatus { initial, loading, loaded, error }

class StatisticsState extends Equatable {
  final StatisticsStatus status;
  final WorkoutStatistics? workoutStats;
  final WeeklyStats? weeklyStats;
  final List<DailyActivity> monthlyActivities;
  final String? errorMessage;

  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.workoutStats,
    this.weeklyStats,
    this.monthlyActivities = const [],
    this.errorMessage,
  });

  StatisticsState copyWith({
    StatisticsStatus? status,
    WorkoutStatistics? workoutStats,
    WeeklyStats? weeklyStats,
    List<DailyActivity>? monthlyActivities,
    String? errorMessage,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      workoutStats: workoutStats ?? this.workoutStats,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyActivities: monthlyActivities ?? this.monthlyActivities,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper getters for today's data
  int get todayWorkouts {
    if (weeklyStats == null || weeklyStats!.dailyActivities.isEmpty) return 0;
    final today = DateTime.now();
    final todayActivity = weeklyStats!.dailyActivities.where((activity) {
      return activity.date.year == today.year &&
          activity.date.month == today.month &&
          activity.date.day == today.day;
    }).firstOrNull;
    return todayActivity?.workoutCount ?? 0;
  }

  double get todayCalories {
    if (weeklyStats == null || weeklyStats!.dailyActivities.isEmpty) return 0;
    final today = DateTime.now();
    final todayActivity = weeklyStats!.dailyActivities.where((activity) {
      return activity.date.year == today.year &&
          activity.date.month == today.month &&
          activity.date.day == today.day;
    }).firstOrNull;
    return todayActivity?.caloriesBurned ?? 0;
  }

  // Helper getters for weekly arrays (7 elements, Mon-Sun)
  List<int> get weeklyWorkoutCounts {
    if (weeklyStats == null || weeklyStats!.dailyActivities.isEmpty) {
      return List.filled(7, 0);
    }
    final result = List.filled(7, 0);
    for (final activity in weeklyStats!.dailyActivities) {
      final dayIndex = (activity.date.weekday - 1) % 7;
      if (dayIndex >= 0 && dayIndex < 7) {
        result[dayIndex] = activity.workoutCount;
      }
    }
    return result;
  }

  List<int> get weeklyCaloriesArray {
    if (weeklyStats == null || weeklyStats!.dailyActivities.isEmpty) {
      return List.filled(7, 0);
    }
    final result = List.filled(7, 0);
    for (final activity in weeklyStats!.dailyActivities) {
      final dayIndex = (activity.date.weekday - 1) % 7;
      if (dayIndex >= 0 && dayIndex < 7) {
        result[dayIndex] = activity.caloriesBurned.toInt();
      }
    }
    return result;
  }

  @override
  List<Object?> get props => [
        status,
        workoutStats,
        weeklyStats,
        monthlyActivities,
        errorMessage,
      ];
}
