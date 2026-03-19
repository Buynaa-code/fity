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

  @override
  List<Object?> get props => [
        status,
        workoutStats,
        weeklyStats,
        monthlyActivities,
        errorMessage,
      ];
}
