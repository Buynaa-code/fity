import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/health_service.dart';
import '../../../../core/services/user_preferences_service.dart';
import 'health_event.dart';
import 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  final HealthService _healthService;
  final UserPreferencesService _preferencesService;
  StreamSubscription<int>? _stepsSubscription;

  HealthBloc({
    required HealthService healthService,
    required UserPreferencesService preferencesService,
  })  : _healthService = healthService,
        _preferencesService = preferencesService,
        super(const HealthState()) {
    on<LoadHealthData>(_onLoadHealthData);
    on<RequestHealthPermissions>(_onRequestPermissions);
    on<RefreshHealthData>(_onRefreshHealthData);
    on<StepsUpdated>(_onStepsUpdated);
    on<UpdateStepsGoal>(_onUpdateStepsGoal);
  }

  Future<void> _onLoadHealthData(
    LoadHealthData event,
    Emitter<HealthState> emit,
  ) async {
    emit(state.copyWith(status: HealthStatus.loading));

    try {
      final hasPermission = await _healthService.hasPermissions();
      final stepsGoal = _preferencesService.stepsGoal;

      if (!hasPermission) {
        emit(state.copyWith(
          status: HealthStatus.permissionDenied,
          hasPermission: false,
          stepsGoal: stepsGoal,
        ));
        return;
      }

      final steps = await _healthService.getTodaySteps();
      final calories = await _healthService.getTodayActiveCalories();

      emit(state.copyWith(
        stepsToday: steps,
        stepsGoal: stepsGoal,
        activeCalories: calories,
        hasPermission: true,
        status: HealthStatus.loaded,
      ));

      _startWatchingSteps();
    } catch (e) {
      emit(state.copyWith(
        status: HealthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRequestPermissions(
    RequestHealthPermissions event,
    Emitter<HealthState> emit,
  ) async {
    emit(state.copyWith(status: HealthStatus.loading));

    try {
      final granted = await _healthService.requestPermissions();

      if (granted) {
        add(const LoadHealthData());
      } else {
        emit(state.copyWith(
          status: HealthStatus.permissionDenied,
          hasPermission: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HealthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshHealthData(
    RefreshHealthData event,
    Emitter<HealthState> emit,
  ) async {
    if (!state.hasPermission) {
      return;
    }

    try {
      final steps = await _healthService.getTodaySteps();
      final calories = await _healthService.getTodayActiveCalories();

      emit(state.copyWith(
        stepsToday: steps,
        activeCalories: calories,
        status: HealthStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HealthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onStepsUpdated(
    StepsUpdated event,
    Emitter<HealthState> emit,
  ) {
    emit(state.copyWith(stepsToday: event.steps));
  }

  Future<void> _onUpdateStepsGoal(
    UpdateStepsGoal event,
    Emitter<HealthState> emit,
  ) async {
    await _preferencesService.setStepsGoal(event.stepsGoal);
    emit(state.copyWith(stepsGoal: event.stepsGoal));
  }

  void _startWatchingSteps() {
    _stepsSubscription?.cancel();
    _stepsSubscription = _healthService.watchSteps().listen((steps) {
      add(StepsUpdated(steps));
    });
  }

  @override
  Future<void> close() {
    _stepsSubscription?.cancel();
    return super.close();
  }
}
