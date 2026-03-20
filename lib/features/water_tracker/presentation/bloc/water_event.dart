import 'package:equatable/equatable.dart';
import '../../domain/entities/water_intake.dart';

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

class ResetDailyWater extends WaterEvent {
  final DateTime? date;

  const ResetDailyWater({this.date});

  @override
  List<Object?> get props => [date];
}

class UndoResetDailyWater extends WaterEvent {
  final List<WaterIntake> previousIntakes;
  final int previousTotalMl;

  const UndoResetDailyWater({
    required this.previousIntakes,
    required this.previousTotalMl,
  });

  @override
  List<Object?> get props => [previousIntakes, previousTotalMl];
}
