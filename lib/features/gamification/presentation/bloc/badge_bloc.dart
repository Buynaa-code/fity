import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/badge_repository.dart';
import 'badge_event.dart';
import 'badge_state.dart';

class BadgeBloc extends Bloc<BadgeEvent, BadgeState> {
  final BadgeRepository repository;

  BadgeBloc({required this.repository}) : super(const BadgeState()) {
    on<LoadBadges>(_onLoadBadges);
    on<CheckBadges>(_onCheckBadges);
    on<MarkBadgeSeen>(_onMarkBadgeSeen);
    on<FilterByCategory>(_onFilterByCategory);
    on<AwardBadge>(_onAwardBadge);
  }

  Future<void> _onLoadBadges(
    LoadBadges event,
    Emitter<BadgeState> emit,
  ) async {
    emit(state.copyWith(status: BadgeStatus.loading));

    try {
      final earnedBadges = await repository.getEarnedBadges();
      final progress = await repository.getAllProgress();
      final totalXp = await repository.getTotalBadgeXp();
      final newCount = await repository.getNewBadgeCount();

      emit(state.copyWith(
        status: BadgeStatus.loaded,
        earnedBadges: earnedBadges,
        badgeProgress: progress,
        totalXp: totalXp,
        newBadgeCount: newCount,
        newlyAwardedBadges: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BadgeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCheckBadges(
    CheckBadges event,
    Emitter<BadgeState> emit,
  ) async {
    try {
      final newlyAwarded = await repository.checkAndAwardBadges(
        currentStreak: event.currentStreak,
        totalWorkouts: event.totalWorkouts,
        completedChallenges: event.completedChallenges,
        waterStreak: event.waterStreak,
      );

      if (newlyAwarded.isNotEmpty) {
        // Reload all badges to reflect new state
        final earnedBadges = await repository.getEarnedBadges();
        final progress = await repository.getAllProgress();
        final totalXp = await repository.getTotalBadgeXp();
        final newCount = await repository.getNewBadgeCount();

        emit(state.copyWith(
          status: BadgeStatus.loaded,
          earnedBadges: earnedBadges,
          badgeProgress: progress,
          totalXp: totalXp,
          newBadgeCount: newCount,
          newlyAwardedBadges: newlyAwarded,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: BadgeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMarkBadgeSeen(
    MarkBadgeSeen event,
    Emitter<BadgeState> emit,
  ) async {
    try {
      await repository.markBadgeAsSeen(event.userBadgeId);

      final earnedBadges = await repository.getEarnedBadges();
      final newCount = await repository.getNewBadgeCount();

      emit(state.copyWith(
        earnedBadges: earnedBadges,
        newBadgeCount: newCount,
      ));
    } catch (e) {
      // Silently fail for this operation
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<BadgeState> emit,
  ) async {
    emit(state.copyWith(selectedCategory: event.category));
  }

  Future<void> _onAwardBadge(
    AwardBadge event,
    Emitter<BadgeState> emit,
  ) async {
    try {
      final awarded = await repository.awardBadge(event.badgeId);

      final earnedBadges = await repository.getEarnedBadges();
      final progress = await repository.getAllProgress();
      final totalXp = await repository.getTotalBadgeXp();
      final newCount = await repository.getNewBadgeCount();

      emit(state.copyWith(
        status: BadgeStatus.loaded,
        earnedBadges: earnedBadges,
        badgeProgress: progress,
        totalXp: totalXp,
        newBadgeCount: newCount,
        newlyAwardedBadges: [awarded],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: BadgeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
