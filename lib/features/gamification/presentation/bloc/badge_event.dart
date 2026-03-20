import 'package:equatable/equatable.dart';

abstract class BadgeEvent extends Equatable {
  const BadgeEvent();

  @override
  List<Object?> get props => [];
}

/// Load all badges and progress
class LoadBadges extends BadgeEvent {
  const LoadBadges();
}

/// Check and award badges based on current stats
class CheckBadges extends BadgeEvent {
  final int? currentStreak;
  final int? totalWorkouts;
  final int? completedChallenges;
  final int? waterStreak;

  const CheckBadges({
    this.currentStreak,
    this.totalWorkouts,
    this.completedChallenges,
    this.waterStreak,
  });

  @override
  List<Object?> get props => [currentStreak, totalWorkouts, completedChallenges, waterStreak];
}

/// Mark a badge as seen (removes "new" indicator)
class MarkBadgeSeen extends BadgeEvent {
  final String userBadgeId;

  const MarkBadgeSeen(this.userBadgeId);

  @override
  List<Object?> get props => [userBadgeId];
}

/// Filter badges by category
class FilterByCategory extends BadgeEvent {
  final String? category; // null means "all"

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Award a specific badge (for testing/admin)
class AwardBadge extends BadgeEvent {
  final String badgeId;

  const AwardBadge(this.badgeId);

  @override
  List<Object?> get props => [badgeId];
}
