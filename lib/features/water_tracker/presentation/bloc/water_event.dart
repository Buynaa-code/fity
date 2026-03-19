import 'package:equatable/equatable.dart';

abstract class WaterEvent extends Equatable {
  const WaterEvent();

  @override
  List<Object?> get props => [];
}

class LoadDailySummary extends WaterEvent {
  final DateTime? date;

  const LoadDailySummary({this.date});

  @override
  List<Object?> get props => [date];
}

class LoadWeeklySummary extends WaterEvent {
  const LoadWeeklySummary();
}

class AddWaterIntake extends WaterEvent {
  final int amountMl;

  const AddWaterIntake(this.amountMl);

  @override
  List<Object?> get props => [amountMl];
}

class RemoveWaterIntake extends WaterEvent {
  final String intakeId;

  const RemoveWaterIntake(this.intakeId);

  @override
  List<Object?> get props => [intakeId];
}

class UpdateDailyGoal extends WaterEvent {
  final int goalMl;

  const UpdateDailyGoal(this.goalMl);

  @override
  List<Object?> get props => [goalMl];
}
