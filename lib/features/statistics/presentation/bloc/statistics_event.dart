import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatistics extends StatisticsEvent {
  const LoadStatistics();
}

class LoadWeeklyStats extends StatisticsEvent {
  const LoadWeeklyStats();
}

class LoadMonthlyActivities extends StatisticsEvent {
  final int year;
  final int month;

  const LoadMonthlyActivities({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}

class RecordWorkout extends StatisticsEvent {
  final String exerciseName;
  final double calories;
  final Duration duration;

  const RecordWorkout({
    required this.exerciseName,
    required this.calories,
    required this.duration,
  });

  @override
  List<Object?> get props => [exerciseName, calories, duration];
}
