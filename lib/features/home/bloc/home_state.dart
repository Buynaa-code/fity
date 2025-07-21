import 'package:equatable/equatable.dart';

class GymOccupancy extends Equatable {
  final int currentCount;
  final int maxCapacity;
  final double percentage;

  const GymOccupancy({
    required this.currentCount,
    required this.maxCapacity,
    required this.percentage,
  });

  @override
  List<Object> get props => [currentCount, maxCapacity, percentage];
}

class WorkoutPreview extends Equatable {
  final String id;
  final String name;
  final String sets;
  final double progress;

  const WorkoutPreview({
    required this.id,
    required this.name,
    required this.sets,
    required this.progress,
  });

  WorkoutPreview copyWith({
    String? id,
    String? name,
    String? sets,
    double? progress,
  }) {
    return WorkoutPreview(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object> get props => [id, name, sets, progress];
}

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String userName;
  final GymOccupancy gymOccupancy;
  final List<WorkoutPreview> todayWorkouts;
  final double dailyProgress;

  const HomeLoaded({
    required this.userName,
    required this.gymOccupancy,
    required this.todayWorkouts,
    required this.dailyProgress,
  });

  HomeLoaded copyWith({
    String? userName,
    GymOccupancy? gymOccupancy,
    List<WorkoutPreview>? todayWorkouts,
    double? dailyProgress,
  }) {
    return HomeLoaded(
      userName: userName ?? this.userName,
      gymOccupancy: gymOccupancy ?? this.gymOccupancy,
      todayWorkouts: todayWorkouts ?? this.todayWorkouts,
      dailyProgress: dailyProgress ?? this.dailyProgress,
    );
  }

  @override
  List<Object> get props => [userName, gymOccupancy, todayWorkouts, dailyProgress];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}