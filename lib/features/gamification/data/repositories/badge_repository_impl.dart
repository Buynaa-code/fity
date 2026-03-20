import '../../domain/entities/badge.dart';
import '../../domain/entities/badge_definitions.dart';
import '../../domain/repositories/badge_repository.dart';
import '../datasources/badge_local_datasource.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  final BadgeLocalDatasource _localDatasource;

  BadgeRepositoryImpl(this._localDatasource);

  @override
  Future<List<UserBadge>> getEarnedBadges() async {
    final models = await _localDatasource.getEarnedBadges();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<BadgeProgress>> getAllProgress() async {
    final progressMap = await _localDatasource.getBadgeProgress();
    final earnedBadges = await getEarnedBadges();
    final earnedIds = earnedBadges.map((b) => b.badgeId).toSet();

    return BadgeDefinitions.allBadges
        .where((badge) => !earnedIds.contains(badge.id))
        .map((badge) {
      return BadgeProgress(
        badgeId: badge.id,
        currentValue: progressMap[badge.id] ?? 0,
        requiredValue: badge.requiredValue,
      );
    }).toList();
  }

  @override
  Future<BadgeProgress?> getBadgeProgress(String badgeId) async {
    final badge = BadgeDefinitions.getBadgeById(badgeId);
    if (badge == null) return null;

    final progressMap = await _localDatasource.getBadgeProgress();
    return BadgeProgress(
      badgeId: badgeId,
      currentValue: progressMap[badgeId] ?? 0,
      requiredValue: badge.requiredValue,
    );
  }

  @override
  Future<UserBadge> awardBadge(String badgeId) async {
    final model = await _localDatasource.addEarnedBadge(badgeId);
    return model.toEntity();
  }

  @override
  Future<void> updateProgress(String badgeId, int value) async {
    await _localDatasource.updateBadgeProgress(badgeId, value);
  }

  @override
  Future<void> markBadgeAsSeen(String userBadgeId) async {
    await _localDatasource.markBadgeAsSeen(userBadgeId);
  }

  @override
  Future<int> getTotalBadgeXp() async {
    final earnedBadges = await getEarnedBadges();
    int totalXp = 0;

    for (final userBadge in earnedBadges) {
      final badge = BadgeDefinitions.getBadgeById(userBadge.badgeId);
      if (badge != null) {
        totalXp += badge.xpReward;
      }
    }

    return totalXp;
  }

  @override
  Future<int> getNewBadgeCount() async {
    return await _localDatasource.getNewBadgeCount();
  }

  @override
  Future<List<UserBadge>> checkAndAwardBadges({
    int? currentStreak,
    int? totalWorkouts,
    int? completedChallenges,
    int? waterStreak,
  }) async {
    final List<UserBadge> newlyAwarded = [];
    final earnedBadges = await getEarnedBadges();
    final earnedIds = earnedBadges.map((b) => b.badgeId).toSet();

    // Update stats
    final stats = <String, int>{};
    if (currentStreak != null) stats['currentStreak'] = currentStreak;
    if (totalWorkouts != null) stats['totalWorkouts'] = totalWorkouts;
    if (completedChallenges != null) stats['completedChallenges'] = completedChallenges;
    if (waterStreak != null) stats['waterStreak'] = waterStreak;

    if (stats.isNotEmpty) {
      await _localDatasource.updateUserStats(stats);
    }

    // Check streak badges
    if (currentStreak != null) {
      final streakBadges = BadgeDefinitions.getBadgesByCategory(BadgeCategory.streak);
      for (final badge in streakBadges) {
        if (!earnedIds.contains(badge.id) && currentStreak >= badge.requiredValue) {
          final awarded = await awardBadge(badge.id);
          newlyAwarded.add(awarded);
        } else if (!earnedIds.contains(badge.id)) {
          await updateProgress(badge.id, currentStreak);
        }
      }
    }

    // Check workout badges
    if (totalWorkouts != null) {
      final workoutBadges = BadgeDefinitions.getBadgesByCategory(BadgeCategory.workout);
      for (final badge in workoutBadges) {
        if (!earnedIds.contains(badge.id) && totalWorkouts >= badge.requiredValue) {
          final awarded = await awardBadge(badge.id);
          newlyAwarded.add(awarded);
        } else if (!earnedIds.contains(badge.id)) {
          await updateProgress(badge.id, totalWorkouts);
        }
      }
    }

    // Check challenge badges
    if (completedChallenges != null) {
      final challengeBadges = BadgeDefinitions.getBadgesByCategory(BadgeCategory.challenge);
      for (final badge in challengeBadges) {
        if (!earnedIds.contains(badge.id) && completedChallenges >= badge.requiredValue) {
          final awarded = await awardBadge(badge.id);
          newlyAwarded.add(awarded);
        } else if (!earnedIds.contains(badge.id)) {
          await updateProgress(badge.id, completedChallenges);
        }
      }
    }

    // Check water badges
    if (waterStreak != null) {
      final waterBadges = BadgeDefinitions.getBadgesByCategory(BadgeCategory.water);
      for (final badge in waterBadges) {
        if (!earnedIds.contains(badge.id) && waterStreak >= badge.requiredValue) {
          final awarded = await awardBadge(badge.id);
          newlyAwarded.add(awarded);
        } else if (!earnedIds.contains(badge.id)) {
          await updateProgress(badge.id, waterStreak);
        }
      }
    }

    return newlyAwarded;
  }
}
