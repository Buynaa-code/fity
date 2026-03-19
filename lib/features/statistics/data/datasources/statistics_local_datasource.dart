import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/statistics_model.dart';

abstract class StatisticsLocalDatasource {
  Future<WorkoutStatisticsModel> getWorkoutStatistics();
  Future<void> saveWorkoutStatistics(WorkoutStatisticsModel stats);
  Future<List<DailyActivityModel>> getDailyActivities(DateTime start, DateTime end);
  Future<void> saveDailyActivity(DailyActivityModel activity);
}

class StatisticsLocalDatasourceImpl implements StatisticsLocalDatasource {
  final SharedPreferences prefs;

  static const String _statsKey = 'workout_statistics';
  static const String _dailyActivityPrefix = 'daily_activity_';

  StatisticsLocalDatasourceImpl({required this.prefs});

  String _getDailyKey(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$_dailyActivityPrefix$dateStr';
  }

  @override
  Future<WorkoutStatisticsModel> getWorkoutStatistics() async {
    final jsonStr = prefs.getString(_statsKey);

    if (jsonStr == null) {
      return WorkoutStatisticsModel(
        totalWorkouts: 0,
        currentStreak: 0,
        bestStreak: 0,
        totalCalories: 0,
        totalTime: Duration.zero,
        exerciseCounts: const {},
      );
    }

    return WorkoutStatisticsModel.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveWorkoutStatistics(WorkoutStatisticsModel stats) async {
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  @override
  Future<List<DailyActivityModel>> getDailyActivities(
    DateTime start,
    DateTime end,
  ) async {
    final activities = <DailyActivityModel>[];
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      final key = _getDailyKey(current);
      final jsonStr = prefs.getString(key);

      if (jsonStr != null) {
        activities.add(
          DailyActivityModel.fromJson(
            jsonDecode(jsonStr) as Map<String, dynamic>,
          ),
        );
      } else {
        activities.add(
          DailyActivityModel(
            date: current,
            workoutCount: 0,
            caloriesBurned: 0,
            waterMl: 0,
            activeTime: Duration.zero,
            isGoalMet: false,
          ),
        );
      }

      current = current.add(const Duration(days: 1));
    }

    return activities;
  }

  @override
  Future<void> saveDailyActivity(DailyActivityModel activity) async {
    final key = _getDailyKey(activity.date);
    await prefs.setString(key, jsonEncode(activity.toJson()));
  }
}
