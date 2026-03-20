import '../entities/badge.dart';

/// Repository interface for badge operations
abstract class BadgeRepository {
  /// Get all earned badges for current user
  Future<List<UserBadge>> getEarnedBadges();

  /// Get progress for all badges
  Future<List<BadgeProgress>> getAllProgress();

  /// Get progress for a specific badge
  Future<BadgeProgress?> getBadgeProgress(String badgeId);

  /// Award a badge to the user
  Future<UserBadge> awardBadge(String badgeId);

  /// Update progress for a badge
  Future<void> updateProgress(String badgeId, int value);

  /// Mark badge as seen (remove "new" indicator)
  Future<void> markBadgeAsSeen(String userBadgeId);

  /// Get total XP earned from badges
  Future<int> getTotalBadgeXp();

  /// Get count of newly earned badges
  Future<int> getNewBadgeCount();

  /// Check and award any badges based on current stats
  Future<List<UserBadge>> checkAndAwardBadges({
    int? currentStreak,
    int? totalWorkouts,
    int? completedChallenges,
    int? waterStreak,
  });
}
