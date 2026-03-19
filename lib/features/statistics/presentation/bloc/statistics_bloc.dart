import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/statistics_repository.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final StatisticsRepository repository;

  StatisticsBloc({required this.repository}) : super(const StatisticsState()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<LoadWeeklyStats>(_onLoadWeeklyStats);
    on<LoadMonthlyActivities>(_onLoadMonthlyActivities);
    on<RecordWorkout>(_onRecordWorkout);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    try {
      final workoutStats = await repository.getWorkoutStatistics();
      final weeklyStats = await repository.getWeeklyStats();

      emit(state.copyWith(
        status: StatisticsStatus.loaded,
        workoutStats: workoutStats,
        weeklyStats: weeklyStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatisticsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadWeeklyStats(
    LoadWeeklyStats event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      final weeklyStats = await repository.getWeeklyStats();
      emit(state.copyWith(
        status: StatisticsStatus.loaded,
        weeklyStats: weeklyStats,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatisticsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMonthlyActivities(
    LoadMonthlyActivities event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      final activities = await repository.getMonthlyActivities(
        event.year,
        event.month,
      );
      emit(state.copyWith(
        status: StatisticsStatus.loaded,
        monthlyActivities: activities,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: StatisticsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRecordWorkout(
    RecordWorkout event,
    Emitter<StatisticsState> emit,
  ) async {
    try {
      await repository.recordWorkout(
        exerciseName: event.exerciseName,
        calories: event.calories,
        duration: event.duration,
      );
      add(const LoadStatistics());
    } catch (e) {
      emit(state.copyWith(
        status: StatisticsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
