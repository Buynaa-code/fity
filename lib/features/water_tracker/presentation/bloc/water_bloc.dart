import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/water_intake.dart';
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
    on<ResetDailyWater>(_onResetDailyWater);
    on<UndoResetDailyWater>(_onUndoResetDailyWater);
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
    final currentSummary = state.dailySummary;

    // Optimistic update - update UI immediately
    if (currentSummary != null) {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final newIntake = WaterIntake(
        id: tempId,
        amountMl: event.amountMl,
        timestamp: DateTime.now(),
      );

      final optimisticSummary = DailyWaterSummary(
        date: currentSummary.date,
        totalMl: currentSummary.totalMl + event.amountMl,
        goalMl: currentSummary.goalMl,
        intakes: [...currentSummary.intakes, newIntake],
      );

      // Also update weekly summary optimistically
      final optimisticWeekly = state.weeklySummary.map((s) {
        if (_isSameDay(s.date, currentSummary.date)) {
          return optimisticSummary;
        }
        return s;
      }).toList();

      emit(state.copyWith(
        dailySummary: optimisticSummary,
        weeklySummary: optimisticWeekly,
      ));
    }

    try {
      // Persist to storage
      await repository.addIntake(event.amountMl);

      // Reload to get accurate data with correct ID
      final weeklySummary = await repository.getWeeklySummary();
      final dailySummary = await repository.getDailySummary(DateTime.now());

      emit(state.copyWith(
        status: WaterStatus.loaded,
        dailySummary: dailySummary,
        weeklySummary: weeklySummary,
      ));
    } catch (e) {
      // Rollback on error - reload from storage
      try {
        final weeklySummary = await repository.getWeeklySummary();
        final dailySummary = await repository.getDailySummary(DateTime.now());
        emit(state.copyWith(
          status: WaterStatus.loaded,
          dailySummary: dailySummary,
          weeklySummary: weeklySummary,
          errorMessage: 'Алдаа гарлаа: ${e.toString()}',
        ));
      } catch (_) {
        emit(state.copyWith(
          status: WaterStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onRemoveWaterIntake(
    RemoveWaterIntake event,
    Emitter<WaterState> emit,
  ) async {
    final currentSummary = state.dailySummary;

    // Optimistic update - remove from UI immediately
    if (currentSummary != null) {
      WaterIntake? intakeToRemove;
      try {
        intakeToRemove = currentSummary.intakes.firstWhere(
          (i) => i.id == event.intakeId,
        );
      } catch (_) {
        intakeToRemove = null;
      }

      if (intakeToRemove != null) {
        final optimisticSummary = DailyWaterSummary(
          date: currentSummary.date,
          totalMl: (currentSummary.totalMl - intakeToRemove.amountMl).clamp(0, double.maxFinite.toInt()),
          goalMl: currentSummary.goalMl,
          intakes: currentSummary.intakes.where((i) => i.id != event.intakeId).toList(),
        );

        // Also update weekly summary optimistically
        final optimisticWeekly = state.weeklySummary.map((s) {
          if (_isSameDay(s.date, currentSummary.date)) {
            return optimisticSummary;
          }
          return s;
        }).toList();

        emit(state.copyWith(
          dailySummary: optimisticSummary,
          weeklySummary: optimisticWeekly,
        ));
      }
    }

    try {
      // Persist to storage
      await repository.removeIntake(event.intakeId);

      // Reload to ensure consistency
      final weeklySummary = await repository.getWeeklySummary();
      final dailySummary = await repository.getDailySummary(DateTime.now());

      emit(state.copyWith(
        status: WaterStatus.loaded,
        dailySummary: dailySummary,
        weeklySummary: weeklySummary,
      ));
    } catch (e) {
      // Rollback on error - reload from storage
      try {
        final weeklySummary = await repository.getWeeklySummary();
        final dailySummary = await repository.getDailySummary(DateTime.now());
        emit(state.copyWith(
          status: WaterStatus.loaded,
          dailySummary: dailySummary,
          weeklySummary: weeklySummary,
          errorMessage: 'Алдаа гарлаа: ${e.toString()}',
        ));
      } catch (_) {
        emit(state.copyWith(
          status: WaterStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onUpdateDailyGoal(
    UpdateDailyGoal event,
    Emitter<WaterState> emit,
  ) async {
    final currentSummary = state.dailySummary;

    // Optimistic update
    if (currentSummary != null) {
      final optimisticSummary = DailyWaterSummary(
        date: currentSummary.date,
        totalMl: currentSummary.totalMl,
        goalMl: event.goalMl,
        intakes: currentSummary.intakes,
      );

      emit(state.copyWith(dailySummary: optimisticSummary));
    }

    try {
      await repository.updateDailyGoal(event.goalMl);

      // Reload to ensure consistency
      final weeklySummary = await repository.getWeeklySummary();
      final dailySummary = await repository.getDailySummary(DateTime.now());

      emit(state.copyWith(
        status: WaterStatus.loaded,
        dailySummary: dailySummary,
        weeklySummary: weeklySummary,
      ));
    } catch (e) {
      // Rollback on error
      try {
        final weeklySummary = await repository.getWeeklySummary();
        final dailySummary = await repository.getDailySummary(DateTime.now());
        emit(state.copyWith(
          status: WaterStatus.loaded,
          dailySummary: dailySummary,
          weeklySummary: weeklySummary,
          errorMessage: 'Алдаа гарлаа: ${e.toString()}',
        ));
      } catch (_) {
        emit(state.copyWith(
          status: WaterStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onResetDailyWater(
    ResetDailyWater event,
    Emitter<WaterState> emit,
  ) async {
    final currentSummary = state.dailySummary;
    final date = event.date ?? DateTime.now();

    // Optimistic update - clear UI immediately
    if (currentSummary != null) {
      final optimisticSummary = DailyWaterSummary(
        date: currentSummary.date,
        totalMl: 0,
        goalMl: currentSummary.goalMl,
        intakes: const [],
      );

      // Update weekly summary optimistically
      final optimisticWeekly = state.weeklySummary.map((s) {
        if (_isSameDay(s.date, currentSummary.date)) {
          return optimisticSummary;
        }
        return s;
      }).toList();

      emit(state.copyWith(
        dailySummary: optimisticSummary,
        weeklySummary: optimisticWeekly,
      ));
    }

    try {
      await repository.resetDailyWater(date);

      // Reload to ensure consistency
      final weeklySummary = await repository.getWeeklySummary();
      final dailySummary = await repository.getDailySummary(DateTime.now());

      emit(state.copyWith(
        status: WaterStatus.loaded,
        dailySummary: dailySummary,
        weeklySummary: weeklySummary,
      ));
    } catch (e) {
      // Rollback on error
      try {
        final weeklySummary = await repository.getWeeklySummary();
        final dailySummary = await repository.getDailySummary(DateTime.now());
        emit(state.copyWith(
          status: WaterStatus.loaded,
          dailySummary: dailySummary,
          weeklySummary: weeklySummary,
          errorMessage: 'Алдаа гарлаа: ${e.toString()}',
        ));
      } catch (_) {
        emit(state.copyWith(
          status: WaterStatus.error,
          errorMessage: e.toString(),
        ));
      }
    }
  }

  Future<void> _onUndoResetDailyWater(
    UndoResetDailyWater event,
    Emitter<WaterState> emit,
  ) async {
    final currentSummary = state.dailySummary;
    final date = currentSummary?.date ?? DateTime.now();

    // Optimistic update - restore UI immediately
    if (currentSummary != null) {
      final optimisticSummary = DailyWaterSummary(
        date: currentSummary.date,
        totalMl: event.previousTotalMl,
        goalMl: currentSummary.goalMl,
        intakes: event.previousIntakes,
      );

      // Update weekly summary optimistically
      final optimisticWeekly = state.weeklySummary.map((s) {
        if (_isSameDay(s.date, currentSummary.date)) {
          return optimisticSummary;
        }
        return s;
      }).toList();

      emit(state.copyWith(
        dailySummary: optimisticSummary,
        weeklySummary: optimisticWeekly,
      ));
    }

    try {
      await repository.restoreIntakes(date, event.previousIntakes);

      // Reload to ensure consistency
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
        errorMessage: 'Сэргээх үед алдаа гарлаа: ${e.toString()}',
      ));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
