import 'package:equatable/equatable.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object> get props => [];
}

class LoadWorkouts extends WorkoutEvent {}

class UpdateExerciseProgress extends WorkoutEvent {
  final String exerciseId;
  final double progress;

  const UpdateExerciseProgress({
    required this.exerciseId,
    required this.progress,
  });

  @override
  List<Object> get props => [exerciseId, progress];
}

class CompleteExercise extends WorkoutEvent {
  final String exerciseId;

  const CompleteExercise(this.exerciseId);

  @override
  List<Object> get props => [exerciseId];
}

class StartWorkoutTimer extends WorkoutEvent {
  final String? exerciseName;

  const StartWorkoutTimer({this.exerciseName});

  @override
  List<Object> get props => [exerciseName ?? ''];
}

class PauseWorkoutTimer extends WorkoutEvent {}

class ResumeWorkoutTimer extends WorkoutEvent {}

class ResetWorkoutTimer extends WorkoutEvent {}

class StopWorkoutTimer extends WorkoutEvent {}

class WorkoutTimerTick extends WorkoutEvent {
  final int seconds;

  const WorkoutTimerTick(this.seconds);

  @override
  List<Object> get props => [seconds];
}