import 'package:equatable/equatable.dart';

enum HealthStatus { initial, loading, loaded, error, permissionDenied }

class HealthState extends Equatable {
  final int stepsToday;
  final int stepsGoal;
  final double activeCalories;
  final bool hasPermission;
  final HealthStatus status;
  final String? errorMessage;

  const HealthState({
    this.stepsToday = 0,
    this.stepsGoal = 10000,
    this.activeCalories = 0,
    this.hasPermission = false,
    this.status = HealthStatus.initial,
    this.errorMessage,
  });

  double get stepsProgress => stepsGoal > 0 ? stepsToday / stepsGoal : 0;

  HealthState copyWith({
    int? stepsToday,
    int? stepsGoal,
    double? activeCalories,
    bool? hasPermission,
    HealthStatus? status,
    String? errorMessage,
  }) {
    return HealthState(
      stepsToday: stepsToday ?? this.stepsToday,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      activeCalories: activeCalories ?? this.activeCalories,
      hasPermission: hasPermission ?? this.hasPermission,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        stepsToday,
        stepsGoal,
        activeCalories,
        hasPermission,
        status,
        errorMessage,
      ];
}
