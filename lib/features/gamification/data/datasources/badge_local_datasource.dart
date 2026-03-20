import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_badge_model.dart';
import '../../domain/entities/badge_definitions.dart';

class BadgeLocalDatasource {
  static const String _earnedBadgesKey = 'earned_badges';
  static const String _badgeProgressKey = 'badge_progress';
  static const String _statsKey = 'user_stats';

  final SharedPreferences _prefs;

  BadgeLocalDatasource(this._prefs);

  /// Get all earned badges
  Future<List<UserBadgeModel>> getEarnedBadges() async {
    final String? data = _prefs.getString(_earnedBadgesKey);
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList
        .map((json) => UserBadgeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Save earned badges
  Future<void> saveEarnedBadges(List<UserBadgeModel> badges) async {
    final String data = jsonEncode(badges.map((b) => b.toJson()).toList());
    await _prefs.setString(_earnedBadgesKey, data);
  }

  /// Add a new earned badge
  Future<UserBadgeModel> addEarnedBadge(String badgeId) async {
    final badges = await getEarnedBadges();

    // Check if already earned
    if (badges.any((b) => b.badgeId == badgeId)) {
      return badges.firstWhere((b) => b.badgeId == badgeId);
    }

    final badge = BadgeDefinitions.getBadgeById(badgeId);
    final newBadge = UserBadgeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      badgeId: badgeId,
      earnedAt: DateTime.now(),
      currentProgress: badge?.requiredValue ?? 0,
      isNew: true,
    );

    badges.add(newBadge);
    await saveEarnedBadges(badges);
    return newBadge;
  }

  /// Mark badge as seen
  Future<void> markBadgeAsSeen(String userBadgeId) async {
    final badges = await getEarnedBadges();
    final index = badges.indexWhere((b) => b.id == userBadgeId);

    if (index != -1) {
      badges[index] = badges[index].copyWith(isNew: false);
      await saveEarnedBadges(badges);
    }
  }

  /// Get badge progress
  Future<Map<String, int>> getBadgeProgress() async {
    final String? data = _prefs.getString(_badgeProgressKey);
    if (data == null) return {};

    final Map<String, dynamic> json = jsonDecode(data);
    return json.map((key, value) => MapEntry(key, value as int));
  }

  /// Update badge progress
  Future<void> updateBadgeProgress(String badgeId, int value) async {
    final progress = await getBadgeProgress();
    progress[badgeId] = value;

    final String data = jsonEncode(progress);
    await _prefs.setString(_badgeProgressKey, data);
  }

  /// Get user stats for badge checking
  Future<Map<String, int>> getUserStats() async {
    final String? data = _prefs.getString(_statsKey);
    if (data == null) {
      return {
        'currentStreak': 0,
        'totalWorkouts': 0,
        'completedChallenges': 0,
        'waterStreak': 0,
      };
    }

    final Map<String, dynamic> json = jsonDecode(data);
    return json.map((key, value) => MapEntry(key, value as int));
  }

  /// Update user stats
  Future<void> updateUserStats(Map<String, int> stats) async {
    final currentStats = await getUserStats();
    currentStats.addAll(stats);

    final String data = jsonEncode(currentStats);
    await _prefs.setString(_statsKey, data);
  }

  /// Get new badge count
  Future<int> getNewBadgeCount() async {
    final badges = await getEarnedBadges();
    return badges.where((b) => b.isNew).length;
  }
}
