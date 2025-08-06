import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshGymOccupancy>(_onRefreshGymOccupancy);
    on<UpdateWorkoutProgress>(_onUpdateWorkoutProgress);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      const gymOccupancy = GymOccupancy(
        currentCount: 24,
        maxCapacity: 40,
        percentage: 0.6,
      );

      final todayWorkouts = [
        const WorkoutPreview(
          id: '1',
          name: 'Push-ups',
          sets: '3 sets of 15 reps',
          progress: 0.3,
        ),
        const WorkoutPreview(
          id: '2',
          name: 'Squats',
          sets: '3 sets of 20 reps',
          progress: 0.0,
        ),
        const WorkoutPreview(
          id: '3',
          name: 'Plank',
          sets: '3 sets of 30 sec',
          progress: 0.0,
        ),
      ];

      final dailyProgress = _calculateDailyProgress(todayWorkouts);

      emit(HomeLoaded(
        userName: 'Буяна',
        gymOccupancy: gymOccupancy,
        todayWorkouts: todayWorkouts,
        dailyProgress: dailyProgress,
      ));
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
    }
  }

  Future<void> _onRefreshGymOccupancy(RefreshGymOccupancy event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      final newOccupancy = GymOccupancy(
        currentCount: (currentState.gymOccupancy.currentCount + 1) % 45,
        maxCapacity: 40,
        percentage: ((currentState.gymOccupancy.currentCount + 1) % 45) / 40,
      );

      emit(currentState.copyWith(gymOccupancy: newOccupancy));
    }
  }

  Future<void> _onUpdateWorkoutProgress(UpdateWorkoutProgress event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      
      final updatedWorkouts = currentState.todayWorkouts.map((workout) {
        if (workout.id == event.exerciseId) {
          return workout.copyWith(progress: event.progress);
        }
        return workout;
      }).toList();

      final dailyProgress = _calculateDailyProgress(updatedWorkouts);

      emit(currentState.copyWith(
        todayWorkouts: updatedWorkouts,
        dailyProgress: dailyProgress,
      ));
    }
  }

  double _calculateDailyProgress(List<WorkoutPreview> workouts) {
    if (workouts.isEmpty) return 0.0;
    final totalProgress = workouts.map((w) => w.progress).reduce((a, b) => a + b);
    return totalProgress / workouts.length;
  }
}