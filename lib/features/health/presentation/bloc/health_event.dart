import 'package:equatable/equatable.dart';

abstract class HealthEvent extends Equatable {
  const HealthEvent();

  @override
  List<Object?> get props => [];
}

class LoadHealthData extends HealthEvent {
  const LoadHealthData();
}

class RequestHealthPermissions extends HealthEvent {
  const RequestHealthPermissions();
}

class RefreshHealthData extends HealthEvent {
  const RefreshHealthData();
}

class StepsUpdated extends HealthEvent {
  final int steps;

  const StepsUpdated(this.steps);

  @override
  List<Object?> get props => [steps];
}

class UpdateStepsGoal extends HealthEvent {
  final int stepsGoal;

  const UpdateStepsGoal(this.stepsGoal);

  @override
  List<Object?> get props => [stepsGoal];
}
