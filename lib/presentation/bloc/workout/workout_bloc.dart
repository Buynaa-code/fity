import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'workout_event.dart';
import 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  Timer? _timer;

  WorkoutBloc() : super(WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<UpdateExerciseProgress>(_onUpdateExerciseProgress);
    on<CompleteExercise>(_onCompleteExercise);
    on<StartWorkoutTimer>(_onStartWorkoutTimer);
    on<PauseWorkoutTimer>(_onPauseWorkoutTimer);
    on<ResumeWorkoutTimer>(_onResumeWorkoutTimer);
    on<ResetWorkoutTimer>(_onResetWorkoutTimer);
    on<StopWorkoutTimer>(_onStopWorkoutTimer);
    on<WorkoutTimerTick>(_onWorkoutTimerTick);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _onLoadWorkouts(LoadWorkouts event, Emitter<WorkoutState> emit) async {
    emit(WorkoutLoading());
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final exercises = [
        const WorkoutExercise(
          id: '1',
          name: 'Push-ups',
          sets: '3 sets of 15 reps',
          progress: 0.3,
          isCompleted: false,
        ),
        const WorkoutExercise(
          id: '2',
          name: 'Squats',
          sets: '3 sets of 20 reps',
          progress: 0.0,
          isCompleted: false,
        ),
        const WorkoutExercise(
          id: '3',
          name: 'Plank',
          sets: '3 sets of 30 sec',
          progress: 0.0,
          isCompleted: false,
        ),
        const WorkoutExercise(
          id: '4',
          name: 'Lunges',
          sets: '3 sets of 12 reps',
          progress: 0.0,
          isCompleted: false,
        ),
        const WorkoutExercise(
          id: '5',
          name: 'Burpees',
          sets: '3 sets of 10 reps',
          progress: 0.0,
          isCompleted: false,
        ),
      ];

      final overallProgress = _calculateOverallProgress(exercises);

      emit(WorkoutLoaded(
        exercises: exercises,
        overallProgress: overallProgress,
      ));
    } catch (e) {
      emit(WorkoutError('Failed to load workouts: $e'));
    }
  }

  Future<void> _onUpdateExerciseProgress(UpdateExerciseProgress event, Emitter<WorkoutState> emit) async {
    if (state is WorkoutLoaded) {
      final currentState = state as WorkoutLoaded;
      
      final updatedExercises = currentState.exercises.map((exercise) {
        if (exercise.id == event.exerciseId) {
          return exercise.copyWith(progress: event.progress);
        }
        return exercise;
      }).toList();

      final overallProgress = _calculateOverallProgress(updatedExercises);

      emit(currentState.copyWith(
        exercises: updatedExercises,
        overallProgress: overallProgress,
      ));
    }
  }

  Future<void> _onCompleteExercise(CompleteExercise event, Emitter<WorkoutState> emit) async {
    if (state is WorkoutLoaded) {
      final currentState = state as WorkoutLoaded;
      
      final updatedExercises = currentState.exercises.map((exercise) {
        if (exercise.id == event.exerciseId) {
          return exercise.copyWith(
            isCompleted: true,
            progress: 1.0,
          );
        }
        return exercise;
      }).toList();

      final overallProgress = _calculateOverallProgress(updatedExercises);

      emit(currentState.copyWith(
        exercises: updatedExercises,
        overallProgress: overallProgress,
      ));
    }
  }

  Future<void> _onStartWorkoutTimer(StartWorkoutTimer event, Emitter<WorkoutState> emit) async {
    if (state is WorkoutLoaded) {
      final currentState = state as WorkoutLoaded;
      
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(WorkoutTimerTick(timer.tick));
      });

      emit(currentState.copyWith(
        timerStatus: TimerStatus.running,
        currentExercise: event.exerciseName,
      ));
    }
  }

  Future<void> _onPauseWorkoutTimer(PauseWorkoutTimer event, Emitter<WorkoutState> emit) async {
    if (state is WorkoutLoaded) {
      final currentState = state as WorkoutLoaded;
      
      _timer?.cancel();

      emit(currentState.copyWith(timerStatus: TimerStatus.paused));
    }
  }

  Future<void> _onResumeWorkoutTimer(ResumeWorkoutTimer event, Emitter<WorkoutState> emit) async {
    if (state is WorkoutLoaded) {
      final currentState = state as WorkoutLoaded;
      
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(WorkoutTimerTick(currentState.timerSeconds + timer.tick));
      });

      emit(currentState.copyWith(timerStatus: TimerStatus.running));
    }
  }

  Future<void> _onResetWorkoutTimer(ResetWorkoutTimer event, Emitter<WorkoutState> emit) async {
    if (state is WorkoutLoaded) {
      final currentState = state as WorkoutLoaded;
      
      _timer?.cancel();

      emit(currentState.copyWith(
        timerStatus: TimerStatus.initial,
        timerSeconds: 0,
      ));
    }
  }

  Future<void> _onStopWorkoutTimer(StopWorkoutTimer event, Emitter<WorkoutState> emit) async {
    if (state is WorkoutLoaded) {
      final currentState = state as WorkoutLoaded;
      
      _timer?.cancel();

      emit(currentState.copyWith(
        timerStatus: TimerStatus.stopped,
      ));
    }
  }

  Future<void> _onWorkoutTimerTick(WorkoutTimerTick event, Emitter<WorkoutState> emit) async {
    if (state is WorkoutLoaded) {
      final currentState = state as WorkoutLoaded;
      
      emit(currentState.copyWith(timerSeconds: event.seconds));
    }
  }

  double _calculateOverallProgress(List<WorkoutExercise> exercises) {
    if (exercises.isEmpty) return 0.0;
    final totalProgress = exercises.map((e) => e.progress).reduce((a, b) => a + b);
    return totalProgress / exercises.length;
  }
}