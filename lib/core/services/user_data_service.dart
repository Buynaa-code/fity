import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserDataService {
  static const String _workoutDataKey = 'workout_data';
  static const String _challengeDataKey = 'challenge_data';
  static const String _userProgressKey = 'user_progress';
  static const String _streakDataKey = 'streak_data';

  static UserDataService? _instance;
  static UserDataService get instance => _instance ??= UserDataService._();
  UserDataService._();

  // Get user's workout data
  Future<Map<String, dynamic>> getWorkoutData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_workoutDataKey);
    if (data != null) {
      return json.decode(data);
    }
    return {
      'completedWorkouts': 0,
      'totalCaloriesBurned': 0.0,
      'workoutStreak': 0,
      'exerciseProgress': <String, dynamic>{},
      'lastWorkoutDate': null,
    };
  }

  // Save workout data
  Future<void> saveWorkoutData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_workoutDataKey, json.encode(data));
  }

  // Get user's challenge data
  Future<Map<String, dynamic>> getChallengeData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_challengeDataKey);
    if (data != null) {
      return json.decode(data);
    }
    return {
      'joinedChallenges': <String>[],
      'completedChallenges': <String>[],
      'challengeProgress': <String, dynamic>{},
      'totalPoints': 0,
      'badges': <String>[],
    };
  }

  // Save challenge data
  Future<void> saveChallengeData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_challengeDataKey, json.encode(data));
  }

  // Update workout completion
  Future<void> updateWorkoutCompletion(String exerciseName) async {
    final workoutData = await getWorkoutData();
    final challengeData = await getChallengeData();
    
    workoutData['completedWorkouts'] = (workoutData['completedWorkouts'] ?? 0) + 1;
    workoutData['lastWorkoutDate'] = DateTime.now().toIso8601String();
    
    // Update streak
    final lastDate = workoutData['lastWorkoutDate'];
    if (lastDate != null) {
      final last = DateTime.parse(lastDate);
      final today = DateTime.now();
      if (today.difference(last).inDays == 1) {
        workoutData['workoutStreak'] = (workoutData['workoutStreak'] ?? 0) + 1;
      } else if (today.difference(last).inDays > 1) {
        workoutData['workoutStreak'] = 1;
      }
    } else {
      workoutData['workoutStreak'] = 1;
    }

    // Update exercise progress
    final exerciseProgress = Map<String, dynamic>.from(workoutData['exerciseProgress'] ?? {});
    exerciseProgress[exerciseName] = (exerciseProgress[exerciseName] ?? 0) + 1;
    workoutData['exerciseProgress'] = exerciseProgress;

    // Check if workout completion affects any challenge
    await _updateChallengeProgress('workout_completion', workoutData, challengeData);
    
    await saveWorkoutData(workoutData);
  }

  // Join a challenge
  Future<void> joinChallenge(String challengeId) async {
    final challengeData = await getChallengeData();
    final joinedChallenges = List<String>.from(challengeData['joinedChallenges'] ?? []);
    
    if (!joinedChallenges.contains(challengeId)) {
      joinedChallenges.add(challengeId);
      challengeData['joinedChallenges'] = joinedChallenges;
      await saveChallengeData(challengeData);
    }
  }

  // Leave a challenge
  Future<void> leaveChallenge(String challengeId) async {
    final challengeData = await getChallengeData();
    final joinedChallenges = List<String>.from(challengeData['joinedChallenges'] ?? []);
    
    joinedChallenges.remove(challengeId);
    challengeData['joinedChallenges'] = joinedChallenges;
    
    // Remove progress for this challenge
    final progress = Map<String, dynamic>.from(challengeData['challengeProgress'] ?? {});
    progress.remove(challengeId);
    challengeData['challengeProgress'] = progress;
    
    await saveChallengeData(challengeData);
  }

  // Update challenge progress
  Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final challengeData = await getChallengeData();
    final challengeProgress = Map<String, dynamic>.from(challengeData['challengeProgress'] ?? {});
    
    challengeProgress[challengeId] = progress;
    challengeData['challengeProgress'] = challengeProgress;
    
    await saveChallengeData(challengeData);
  }

  // Complete a challenge
  Future<void> completeChallenge(String challengeId, int points) async {
    final challengeData = await getChallengeData();
    final completedChallenges = List<String>.from(challengeData['completedChallenges'] ?? []);
    
    if (!completedChallenges.contains(challengeId)) {
      completedChallenges.add(challengeId);
      challengeData['completedChallenges'] = completedChallenges;
      challengeData['totalPoints'] = (challengeData['totalPoints'] ?? 0) + points;
      await saveChallengeData(challengeData);
    }
  }

  // Internal method to update challenge progress based on activities
  Future<void> _updateChallengeProgress(String activityType, Map<String, dynamic> workoutData, Map<String, dynamic> challengeData) async {
    final joinedChallenges = List<String>.from(challengeData['joinedChallenges'] ?? []);
    final challengeProgress = Map<String, dynamic>.from(challengeData['challengeProgress'] ?? {});
    
    // Example: Update push-up challenge based on workout completions
    if (activityType == 'workout_completion') {
      for (String challengeId in joinedChallenges) {
        if (challengeId == '1') { // Push-up challenge
          challengeProgress[challengeId] = workoutData['completedWorkouts'] ?? 0;
        } else if (challengeId == '2') { // Steps challenge  
          // This would be updated from step tracking
        }
      }
    }
    
    challengeData['challengeProgress'] = challengeProgress;
    await saveChallengeData(challengeData);
  }

  // Get overall user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    final workoutData = await getWorkoutData();
    final challengeData = await getChallengeData();
    
    return {
      'totalWorkouts': workoutData['completedWorkouts'] ?? 0,
      'currentStreak': workoutData['workoutStreak'] ?? 0,
      'totalPoints': challengeData['totalPoints'] ?? 0,
      'activeChallenges': (challengeData['joinedChallenges'] ?? []).length,
      'completedChallenges': (challengeData['completedChallenges'] ?? []).length,
      'lastWorkout': workoutData['lastWorkoutDate'],
    };
  }

  // Check if user is in a challenge
  Future<bool> isInChallenge(String challengeId) async {
    final challengeData = await getChallengeData();
    final joinedChallenges = List<String>.from(challengeData['joinedChallenges'] ?? []);
    return joinedChallenges.contains(challengeId);
  }

  // Get challenge progress
  Future<int> getChallengeProgress(String challengeId) async {
    final challengeData = await getChallengeData();
    final challengeProgress = Map<String, dynamic>.from(challengeData['challengeProgress'] ?? {});
    return challengeProgress[challengeId] ?? 0;
  }

  // Reset all data (for testing/debugging)
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_workoutDataKey);
    await prefs.remove(_challengeDataKey);
    await prefs.remove(_userProgressKey);
    await prefs.remove(_streakDataKey);
  }
}