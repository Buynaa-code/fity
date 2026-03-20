import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  final SharedPreferences _prefs;

  static const String _caloriesGoalKey = 'calories_goal';
  static const String _stepsGoalKey = 'steps_goal';
  static const String _workoutGoalKey = 'workout_goal';

  static const int defaultCaloriesGoal = 500;
  static const int defaultStepsGoal = 10000;
  static const int defaultWorkoutGoal = 2;

  UserPreferencesService({required SharedPreferences prefs}) : _prefs = prefs;

  // Calories goal
  int get caloriesGoal => _prefs.getInt(_caloriesGoalKey) ?? defaultCaloriesGoal;

  Future<void> setCaloriesGoal(int goal) async {
    await _prefs.setInt(_caloriesGoalKey, goal);
  }

  // Steps goal
  int get stepsGoal => _prefs.getInt(_stepsGoalKey) ?? defaultStepsGoal;

  Future<void> setStepsGoal(int goal) async {
    await _prefs.setInt(_stepsGoalKey, goal);
  }

  // Workout goal (daily)
  int get workoutGoal => _prefs.getInt(_workoutGoalKey) ?? defaultWorkoutGoal;

  Future<void> setWorkoutGoal(int goal) async {
    await _prefs.setInt(_workoutGoalKey, goal);
  }

  // Reset all goals to defaults
  Future<void> resetGoals() async {
    await Future.wait([
      _prefs.remove(_caloriesGoalKey),
      _prefs.remove(_stepsGoalKey),
      _prefs.remove(_workoutGoalKey),
    ]);
  }
}
