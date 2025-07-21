import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {}

class RefreshGymOccupancy extends HomeEvent {}

class UpdateWorkoutProgress extends HomeEvent {
  final String exerciseId;
  final double progress;

  const UpdateWorkoutProgress({
    required this.exerciseId,
    required this.progress,
  });

  @override
  List<Object> get props => [exerciseId, progress];
}