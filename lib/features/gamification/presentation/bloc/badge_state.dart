import 'package:equatable/equatable.dart';
import '../../domain/entities/badge.dart';

enum BadgeStatus { initial, loading, loaded, error }

class BadgeState extends Equatable {
  final BadgeStatus status;
  final List<UserBadge> earnedBadges;
  final List<BadgeProgress> badgeProgress;
  final List<UserBadge> newlyAwardedBadges;
  final int totalXp;
  final int newBadgeCount;
  final String? selectedCategory;
  final String? errorMessage;

  const BadgeState({
    this.status = BadgeStatus.initial,
    this.earnedBadges = const [],
    this.badgeProgress = const [],
    this.newlyAwardedBadges = const [],
    this.totalXp = 0,
    this.newBadgeCount = 0,
    this.selectedCategory,
    this.errorMessage,
  });

  BadgeState copyWith({
    BadgeStatus? status,
    List<UserBadge>? earnedBadges,
    List<BadgeProgress>? badgeProgress,
    List<UserBadge>? newlyAwardedBadges,
    int? totalXp,
    int? newBadgeCount,
    String? selectedCategory,
    String? errorMessage,
  }) {
    return BadgeState(
      status: status ?? this.status,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      badgeProgress: badgeProgress ?? this.badgeProgress,
      newlyAwardedBadges: newlyAwardedBadges ?? this.newlyAwardedBadges,
      totalXp: totalXp ?? this.totalXp,
      newBadgeCount: newBadgeCount ?? this.newBadgeCount,
      selectedCategory: selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        earnedBadges,
        badgeProgress,
        newlyAwardedBadges,
        totalXp,
        newBadgeCount,
        selectedCategory,
        errorMessage,
      ];
}
