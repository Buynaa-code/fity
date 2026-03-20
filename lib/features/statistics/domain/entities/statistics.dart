import 'package:equatable/equatable.dart';

class WorkoutStatistics extends Equatable {
  final int totalWorkouts;
  final int todayWorkouts;
  final int currentStreak;
  final int bestStreak;
  final double totalCalories;
  final Duration totalTime;
  final Map<String, int> exerciseCounts;
  final DateTime? lastWorkoutDate;
  final List<int> weeklyWorkouts;
  final List<double> weeklyCalories;

  const WorkoutStatistics({
    required this.totalWorkouts,
    this.todayWorkouts = 0,
    required this.currentStreak,
    required this.bestStreak,
    required this.totalCalories,
    required this.totalTime,
    required this.exerciseCounts,
    this.lastWorkoutDate,
    this.weeklyWorkouts = const [0, 0, 0, 0, 0, 0, 0],
    this.weeklyCalories = const [0, 0, 0, 0, 0, 0, 0],
  });

  factory WorkoutStatistics.empty() {
    return const WorkoutStatistics(
      totalWorkouts: 0,
      todayWorkouts: 0,
      currentStreak: 0,
      bestStreak: 0,
      totalCalories: 0,
      totalTime: Duration.zero,
      exerciseCounts: {},
      weeklyWorkouts: [0, 0, 0, 0, 0, 0, 0],
      weeklyCalories: [0, 0, 0, 0, 0, 0, 0],
    );
  }

  @override
  List<Object?> get props => [
        totalWorkouts,
        todayWorkouts,
        currentStreak,
        bestStreak,
        totalCalories,
        totalTime,
        exerciseCounts,
        lastWorkoutDate,
        weeklyWorkouts,
        weeklyCalories,
      ];
}

class DailyActivity extends Equatable {
  final DateTime date;
  final int workoutCount;
  final double caloriesBurned;
  final int waterMl;
  final Duration activeTime;
  final bool isGoalMet;

  const DailyActivity({
    required this.date,
    required this.workoutCount,
    required this.caloriesBurned,
    required this.waterMl,
    required this.activeTime,
    required this.isGoalMet,
  });

  factory DailyActivity.empty(DateTime date) {
    return DailyActivity(
      date: date,
      workoutCount: 0,
      caloriesBurned: 0,
      waterMl: 0,
      activeTime: Duration.zero,
      isGoalMet: false,
    );
  }

  @override
  List<Object?> get props => [
        date,
        workoutCount,
        caloriesBurned,
        waterMl,
        activeTime,
        isGoalMet,
      ];
}

class WeeklyStats extends Equatable {
  final List<DailyActivity> dailyActivities;
  final int totalWorkouts;
  final double totalCalories;
  final int totalWaterMl;
  final int goalsMetCount;

  const WeeklyStats({
    required this.dailyActivities,
    required this.totalWorkouts,
    required this.totalCalories,
    required this.totalWaterMl,
    required this.goalsMetCount,
  });

  factory WeeklyStats.empty() {
    return const WeeklyStats(
      dailyActivities: [],
      totalWorkouts: 0,
      totalCalories: 0,
      totalWaterMl: 0,
      goalsMetCount: 0,
    );
  }

  double get averageDailyCalories =>
      dailyActivities.isEmpty ? 0 : totalCalories / dailyActivities.length;

  int get averageDailyWater =>
      dailyActivities.isEmpty ? 0 : totalWaterMl ~/ dailyActivities.length;

  @override
  List<Object?> get props => [
        dailyActivities,
        totalWorkouts,
        totalCalories,
        totalWaterMl,
        goalsMetCount,
      ];
}
