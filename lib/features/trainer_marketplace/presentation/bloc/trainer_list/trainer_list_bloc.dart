import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/trainer.dart';
import '../../../data/repositories/trainer_repository.dart';

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

  const TrainerListLoaded({
    required this.trainers,
    required this.filteredTrainers,
    this.selectedSpecialty,
    this.searchQuery = '',
    required this.availableSpecialties,
  });

  @override
  List<Object?> get props =>
      [trainers, filteredTrainers, selectedSpecialty, searchQuery, availableSpecialties];

  TrainerListLoaded copyWith({
    List<Trainer>? trainers,
    List<Trainer>? filteredTrainers,
    String? selectedSpecialty,
    String? searchQuery,
    List<String>? availableSpecialties,
  }) {
    return TrainerListLoaded(
      trainers: trainers ?? this.trainers,
      filteredTrainers: filteredTrainers ?? this.filteredTrainers,
      selectedSpecialty: selectedSpecialty,
      searchQuery: searchQuery ?? this.searchQuery,
      availableSpecialties: availableSpecialties ?? this.availableSpecialties,
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
  }

  void _onLoadTrainers(LoadTrainers event, Emitter<TrainerListState> emit) {
    emit(TrainerListLoading());
    try {
      final trainers = repository.getTrainers();
      final specialties = <String>{};
      for (final trainer in trainers) {
        specialties.addAll(trainer.specialties);
      }

      emit(TrainerListLoaded(
        trainers: trainers,
        filteredTrainers: trainers,
        availableSpecialties: specialties.toList()..sort(),
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

      emit(currentState.copyWith(
        filteredTrainers: _applySearch(filtered, currentState.searchQuery),
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

      emit(currentState.copyWith(
        filteredTrainers: _applySearch(trainers, event.query),
        searchQuery: event.query,
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
}
