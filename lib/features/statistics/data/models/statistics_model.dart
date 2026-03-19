import '../../domain/entities/statistics.dart';

class WorkoutStatisticsModel extends WorkoutStatistics {
  const WorkoutStatisticsModel({
    required super.totalWorkouts,
    required super.currentStreak,
    required super.bestStreak,
    required super.totalCalories,
    required super.totalTime,
    required super.exerciseCounts,
    super.lastWorkoutDate,
  });

  factory WorkoutStatisticsModel.fromJson(Map<String, dynamic> json) {
    return WorkoutStatisticsModel(
      totalWorkouts: json['totalWorkouts'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0,
      totalTime: Duration(minutes: json['totalTimeMinutes'] as int? ?? 0),
      exerciseCounts: Map<String, int>.from(json['exerciseCounts'] ?? {}),
      lastWorkoutDate: json['lastWorkoutDate'] != null
          ? DateTime.parse(json['lastWorkoutDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalWorkouts': totalWorkouts,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalCalories': totalCalories,
      'totalTimeMinutes': totalTime.inMinutes,
      'exerciseCounts': exerciseCounts,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
    };
  }
}

class DailyActivityModel extends DailyActivity {
  const DailyActivityModel({
    required super.date,
    required super.workoutCount,
    required super.caloriesBurned,
    required super.waterMl,
    required super.activeTime,
    required super.isGoalMet,
  });

  factory DailyActivityModel.fromJson(Map<String, dynamic> json) {
    return DailyActivityModel(
      date: DateTime.parse(json['date'] as String),
      workoutCount: json['workoutCount'] as int? ?? 0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0,
      waterMl: json['waterMl'] as int? ?? 0,
      activeTime: Duration(minutes: json['activeTimeMinutes'] as int? ?? 0),
      isGoalMet: json['isGoalMet'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'workoutCount': workoutCount,
      'caloriesBurned': caloriesBurned,
      'waterMl': waterMl,
      'activeTimeMinutes': activeTime.inMinutes,
      'isGoalMet': isGoalMet,
    };
  }
}
