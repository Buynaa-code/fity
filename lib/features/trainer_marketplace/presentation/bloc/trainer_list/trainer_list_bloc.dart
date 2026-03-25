import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/trainer.dart';
import '../../../data/repositories/trainer_repository.dart';

// Sorting options
enum TrainerSortOption {
  rating,      // Үнэлгээгээр
  priceHigh,   // Үнэ өндрөөс
  priceLow,    // Үнэ доогуураас
  experience,  // Туршлагаар
  name,        // Нэрээр
}

extension TrainerSortOptionExtension on TrainerSortOption {
  String get displayName {
    switch (this) {
      case TrainerSortOption.rating:
        return 'Үнэлгээ';
      case TrainerSortOption.priceHigh:
        return 'Үнэ ↓';
      case TrainerSortOption.priceLow:
        return 'Үнэ ↑';
      case TrainerSortOption.experience:
        return 'Туршлага';
      case TrainerSortOption.name:
        return 'Нэр';
    }
  }
}

// Events
abstract class TrainerListEvent extends Equatable {
  const TrainerListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrainers extends TrainerListEvent {}

class FilterTrainersBySpecialty extends TrainerListEvent {
  final String? specialty;

  const FilterTrainersBySpecialty(this.specialty);

  @override
  List<Object?> get props => [specialty];
}

class SearchTrainers extends TrainerListEvent {
  final String query;

  const SearchTrainers(this.query);

  @override
  List<Object?> get props => [query];
}

class SortTrainers extends TrainerListEvent {
  final TrainerSortOption sortOption;

  const SortTrainers(this.sortOption);

  @override
  List<Object?> get props => [sortOption];
}

// States
abstract class TrainerListState extends Equatable {
  const TrainerListState();

  @override
  List<Object?> get props => [];
}

class TrainerListInitial extends TrainerListState {}

class TrainerListLoading extends TrainerListState {}

class TrainerListLoaded extends TrainerListState {
  final List<Trainer> trainers;
  final List<Trainer> filteredTrainers;
  final String? selectedSpecialty;
  final String searchQuery;
  final List<String> availableSpecialties;
  final TrainerSortOption sortOption;
  final List<Trainer> featuredTrainers;

  const TrainerListLoaded({
    required this.trainers,
    required this.filteredTrainers,
    this.selectedSpecialty,
    this.searchQuery = '',
    required this.availableSpecialties,
    this.sortOption = TrainerSortOption.rating,
    this.featuredTrainers = const [],
  });

  @override
  List<Object?> get props => [
        trainers,
        filteredTrainers,
        selectedSpecialty,
        searchQuery,
        availableSpecialties,
        sortOption,
        featuredTrainers,
      ];

  TrainerListLoaded copyWith({
    List<Trainer>? trainers,
    List<Trainer>? filteredTrainers,
    String? selectedSpecialty,
    String? searchQuery,
    List<String>? availableSpecialties,
    TrainerSortOption? sortOption,
    List<Trainer>? featuredTrainers,
  }) {
    return TrainerListLoaded(
      trainers: trainers ?? this.trainers,
      filteredTrainers: filteredTrainers ?? this.filteredTrainers,
      selectedSpecialty: selectedSpecialty,
      searchQuery: searchQuery ?? this.searchQuery,
      availableSpecialties: availableSpecialties ?? this.availableSpecialties,
      sortOption: sortOption ?? this.sortOption,
      featuredTrainers: featuredTrainers ?? this.featuredTrainers,
    );
  }
}

class TrainerListError extends TrainerListState {
  final String message;

  const TrainerListError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class TrainerListBloc extends Bloc<TrainerListEvent, TrainerListState> {
  final TrainerRepository repository;

  TrainerListBloc({required this.repository}) : super(TrainerListInitial()) {
    on<LoadTrainers>(_onLoadTrainers);
    on<FilterTrainersBySpecialty>(_onFilterBySpecialty);
    on<SearchTrainers>(_onSearchTrainers);
    on<SortTrainers>(_onSortTrainers);
  }

  void _onLoadTrainers(LoadTrainers event, Emitter<TrainerListState> emit) {
    emit(TrainerListLoading());
    try {
      final trainers = repository.getTrainers();
      final specialties = <String>{};
      for (final trainer in trainers) {
        specialties.addAll(trainer.specialties);
      }

      // Featured trainers: top rated with most reviews
      final featured = List<Trainer>.from(trainers)
        ..sort((a, b) {
          final ratingCompare = b.rating.compareTo(a.rating);
          if (ratingCompare != 0) return ratingCompare;
          return b.reviewCount.compareTo(a.reviewCount);
        });

      // Sort by rating initially
      final sortedTrainers = _applySorting(trainers, TrainerSortOption.rating);

      emit(TrainerListLoaded(
        trainers: trainers,
        filteredTrainers: sortedTrainers,
        availableSpecialties: specialties.toList()..sort(),
        sortOption: TrainerSortOption.rating,
        featuredTrainers: featured.take(3).toList(),
      ));
    } catch (e) {
      emit(TrainerListError(e.toString()));
    }
  }

  void _onFilterBySpecialty(
      FilterTrainersBySpecialty event, Emitter<TrainerListState> emit) {
    final currentState = state;
    if (currentState is TrainerListLoaded) {
      final filtered = event.specialty == null
          ? currentState.trainers
          : currentState.trainers
              .where((t) => t.specialties.contains(event.specialty))
              .toList();

      final searchFiltered = _applySearch(filtered, currentState.searchQuery);
      final sorted = _applySorting(searchFiltered, currentState.sortOption);

      emit(currentState.copyWith(
        filteredTrainers: sorted,
        selectedSpecialty: event.specialty,
      ));
    }
  }

  void _onSearchTrainers(SearchTrainers event, Emitter<TrainerListState> emit) {
    final currentState = state;
    if (currentState is TrainerListLoaded) {
      var trainers = currentState.selectedSpecialty == null
          ? currentState.trainers
          : currentState.trainers
              .where((t) => t.specialties.contains(currentState.selectedSpecialty))
              .toList();

      final searchFiltered = _applySearch(trainers, event.query);
      final sorted = _applySorting(searchFiltered, currentState.sortOption);

      emit(currentState.copyWith(
        filteredTrainers: sorted,
        searchQuery: event.query,
      ));
    }
  }

  void _onSortTrainers(SortTrainers event, Emitter<TrainerListState> emit) {
    final currentState = state;
    if (currentState is TrainerListLoaded) {
      final sorted = _applySorting(currentState.filteredTrainers, event.sortOption);
      emit(currentState.copyWith(
        filteredTrainers: sorted,
        sortOption: event.sortOption,
      ));
    }
  }

  List<Trainer> _applySearch(List<Trainer> trainers, String query) {
    if (query.isEmpty) return trainers;
    final lowerQuery = query.toLowerCase();
    return trainers.where((t) {
      return t.name.toLowerCase().contains(lowerQuery) ||
          t.specialties.any((s) => s.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<Trainer> _applySorting(List<Trainer> trainers, TrainerSortOption option) {
    final sorted = List<Trainer>.from(trainers);
    switch (option) {
      case TrainerSortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case TrainerSortOption.priceHigh:
        sorted.sort((a, b) => b.hourlyRate.compareTo(a.hourlyRate));
        break;
      case TrainerSortOption.priceLow:
        sorted.sort((a, b) => a.hourlyRate.compareTo(b.hourlyRate));
        break;
      case TrainerSortOption.experience:
        sorted.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
      case TrainerSortOption.name:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return sorted;
  }
}
