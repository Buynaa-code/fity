import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/water_repository.dart';
import 'water_event.dart';
import 'water_state.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository repository;

  WaterBloc({required this.repository}) : super(const WaterState()) {
    on<LoadDailySummary>(_onLoadDailySummary);
    on<LoadWeeklySummary>(_onLoadWeeklySummary);
    on<AddWaterIntake>(_onAddWaterIntake);
    on<RemoveWaterIntake>(_onRemoveWaterIntake);
    on<UpdateDailyGoal>(_onUpdateDailyGoal);
  }

  Future<void> _onLoadDailySummary(
    LoadDailySummary event,
    Emitter<WaterState> emit,
  ) async {
    emit(state.copyWith(status: WaterStatus.loading));
    try {
      final date = event.date ?? DateTime.now();
      final summary = await repository.getDailySummary(date);
      emit(state.copyWith(
        status: WaterStatus.loaded,
        dailySummary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadWeeklySummary(
    LoadWeeklySummary event,
    Emitter<WaterState> emit,
  ) async {
    emit(state.copyWith(status: WaterStatus.loading));
    try {
      final weeklySummary = await repository.getWeeklySummary();
      final dailySummary = await repository.getDailySummary(DateTime.now());
      emit(state.copyWith(
        status: WaterStatus.loaded,
        dailySummary: dailySummary,
        weeklySummary: weeklySummary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WaterStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddWaterIntake(
    AddWaterIntake event,
    Emitter<WaterState> emit,
  ) async {
    try {
      await repository.addIntake(event.amountMl);
      add(const LoadWeeklySummary());
    } catch (e) {
      emit(state.copyWith(
        status: WaterStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRemoveWaterIntake(
    RemoveWaterIntake event,
    Emitter<WaterState> emit,
  ) async {
    try {
      await repository.removeIntake(event.intakeId);
      add(const LoadWeeklySummary());
    } catch (e) {
      emit(state.copyWith(
        status: WaterStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateDailyGoal(
    UpdateDailyGoal event,
    Emitter<WaterState> emit,
  ) async {
    try {
      await repository.updateDailyGoal(event.goalMl);
      add(const LoadWeeklySummary());
    } catch (e) {
      emit(state.copyWith(
        status: WaterStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
