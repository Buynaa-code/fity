import 'package:equatable/equatable.dart';

class WorkoutExercise extends Equatable {
  final String id;
  final String name;
  final String sets;
  final double progress;
  final bool isCompleted;

  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.progress,
    required this.isCompleted,
  });

  WorkoutExercise copyWith({
    String? id,
    String? name,
    String? sets,
    double? progress,
    bool? isCompleted,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object> get props => [id, name, sets, progress, isCompleted];
}

enum TimerStatus { initial, running, paused, stopped }

abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<WorkoutExercise> exercises;
  final double overallProgress;
  final TimerStatus timerStatus;
  final int timerSeconds;
  final String? currentExercise;

  const WorkoutLoaded({
    required this.exercises,
    required this.overallProgress,
    this.timerStatus = TimerStatus.initial,
    this.timerSeconds = 0,
    this.currentExercise,
  });

  WorkoutLoaded copyWith({
    List<WorkoutExercise>? exercises,
    double? overallProgress,
    TimerStatus? timerStatus,
    int? timerSeconds,
    String? currentExercise,
  }) {
    return WorkoutLoaded(
      exercises: exercises ?? this.exercises,
      overallProgress: overallProgress ?? this.overallProgress,
      timerStatus: timerStatus ?? this.timerStatus,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      currentExercise: currentExercise ?? this.currentExercise,
    );
  }

  @override
  List<Object> get props => [
        exercises,
        overallProgress,
        timerStatus,
        timerSeconds,
        currentExercise ?? '',
      ];
}

class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError(this.message);

  @override
  List<Object> get props => [message];
}