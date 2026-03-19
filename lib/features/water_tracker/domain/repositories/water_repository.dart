import '../entities/water_intake.dart';

abstract class WaterRepository {
  Future<DailyWaterSummary> getDailySummary(DateTime date);
  Future<List<DailyWaterSummary>> getWeeklySummary();
  Future<void> addIntake(int amountMl);
  Future<void> removeIntake(String intakeId);
  Future<void> updateDailyGoal(int goalMl);
  Future<int> getDailyGoal();
}
