import '../../domain/entities/water_intake.dart';
import '../../domain/repositories/water_repository.dart';
import '../datasources/water_local_datasource.dart';
import '../models/water_intake_model.dart';

class WaterRepositoryImpl implements WaterRepository {
  final WaterLocalDatasource localDatasource;

  WaterRepositoryImpl({required this.localDatasource});

  @override
  Future<DailyWaterSummary> getDailySummary(DateTime date) async {
    return await localDatasource.getDailySummary(date);
  }

  @override
  Future<List<DailyWaterSummary>> getWeeklySummary() async {
    return await localDatasource.getWeeklySummary();
  }

  @override
  Future<void> addIntake(int amountMl) async {
    final now = DateTime.now();
    final summary = await localDatasource.getDailySummary(now);

    final newIntake = WaterIntakeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      timestamp: now,
    );

    final updatedIntakes = [...summary.intakes, newIntake];
    final updatedSummary = DailyWaterSummaryModel(
      date: DateTime(now.year, now.month, now.day),
      totalMl: summary.totalMl + amountMl,
      goalMl: summary.goalMl,
      intakes: updatedIntakes,
    );

    await localDatasource.saveDailySummary(updatedSummary);
  }

  @override
  Future<void> removeIntake(String intakeId) async {
    final now = DateTime.now();
    final summary = await localDatasource.getDailySummary(now);

    final intakeIndex = summary.intakes.indexWhere((e) => e.id == intakeId);
    if (intakeIndex == -1) return;

    final intakeToRemove = summary.intakes[intakeIndex];
    final updatedIntakes = summary.intakes.where((e) => e.id != intakeId).toList();
    final updatedSummary = DailyWaterSummaryModel(
      date: DateTime(now.year, now.month, now.day),
      totalMl: summary.totalMl - intakeToRemove.amountMl,
      goalMl: summary.goalMl,
      intakes: updatedIntakes,
    );

    await localDatasource.saveDailySummary(updatedSummary);
  }

  @override
  Future<void> updateDailyGoal(int goalMl) async {
    await localDatasource.setDailyGoal(goalMl);
  }

  @override
  Future<int> getDailyGoal() async {
    return await localDatasource.getDailyGoal();
  }
}
