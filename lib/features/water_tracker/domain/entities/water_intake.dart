import 'package:equatable/equatable.dart';

class WaterIntake extends Equatable {
  final String id;
  final int amountMl;
  final DateTime timestamp;

  const WaterIntake({
    required this.id,
    required this.amountMl,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, amountMl, timestamp];
}

class DailyWaterSummary extends Equatable {
  final DateTime date;
  final int totalMl;
  final int goalMl;
  final List<WaterIntake> intakes;

  const DailyWaterSummary({
    required this.date,
    required this.totalMl,
    required this.goalMl,
    required this.intakes,
  });

  double get progress => (totalMl / goalMl).clamp(0.0, 1.0);
  bool get isGoalReached => totalMl >= goalMl;
  int get remaining => (goalMl - totalMl).clamp(0, goalMl);

  @override
  List<Object?> get props => [date, totalMl, goalMl, intakes];
}
