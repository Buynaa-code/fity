import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_intake_model.dart';

abstract class WaterLocalDatasource {
  Future<DailyWaterSummaryModel> getDailySummary(DateTime date);
  Future<List<DailyWaterSummaryModel>> getWeeklySummary();
  Future<void> saveDailySummary(DailyWaterSummaryModel summary);
  Future<int> getDailyGoal();
  Future<void> setDailyGoal(int goalMl);
}

class WaterLocalDatasourceImpl implements WaterLocalDatasource {
  final SharedPreferences prefs;

  static const String _waterDataPrefix = 'water_data_';
  static const String _waterGoalKey = 'water_daily_goal';
  static const int _defaultGoalMl = 2000;

  WaterLocalDatasourceImpl({required this.prefs});

  String _getKeyForDate(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$_waterDataPrefix$dateStr';
  }

  @override
  Future<DailyWaterSummaryModel> getDailySummary(DateTime date) async {
    final key = _getKeyForDate(date);
    final jsonStr = prefs.getString(key);
    final goal = await getDailyGoal();

    if (jsonStr == null) {
      return DailyWaterSummaryModel(
        date: DateTime(date.year, date.month, date.day),
        totalMl: 0,
        goalMl: goal,
        intakes: const [],
      );
    }

    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    json['goalMl'] = goal;
    return DailyWaterSummaryModel.fromJson(json);
  }

  @override
  Future<List<DailyWaterSummaryModel>> getWeeklySummary() async {
    final summaries = <DailyWaterSummaryModel>[];
    final today = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final summary = await getDailySummary(date);
      summaries.add(summary);
    }

    return summaries;
  }

  @override
  Future<void> saveDailySummary(DailyWaterSummaryModel summary) async {
    final key = _getKeyForDate(summary.date);
    final jsonStr = jsonEncode(summary.toJson());
    await prefs.setString(key, jsonStr);
  }

  @override
  Future<int> getDailyGoal() async {
    return prefs.getInt(_waterGoalKey) ?? _defaultGoalMl;
  }

  @override
  Future<void> setDailyGoal(int goalMl) async {
    await prefs.setInt(_waterGoalKey, goalMl);
  }
}
