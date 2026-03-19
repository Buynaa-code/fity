import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/trainer.dart';
import '../../../data/repositories/trainer_repository.dart';

// Events
abstract class TrainerDetailEvent extends Equatable {
  const TrainerDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrainerDetail extends TrainerDetailEvent {
  final String trainerId;

  const LoadTrainerDetail(this.trainerId);

  @override
  List<Object?> get props => [trainerId];
}

class SelectTimeSlot extends TrainerDetailEvent {
  final TimeSlot slot;

  const SelectTimeSlot(this.slot);

  @override
  List<Object?> get props => [slot];
}

class SelectDate extends TrainerDetailEvent {
  final DateTime date;

  const SelectDate(this.date);

  @override
  List<Object?> get props => [date];
}

// States
abstract class TrainerDetailState extends Equatable {
  const TrainerDetailState();

  @override
  List<Object?> get props => [];
}

class TrainerDetailInitial extends TrainerDetailState {}

class TrainerDetailLoading extends TrainerDetailState {}

class TrainerDetailLoaded extends TrainerDetailState {
  final Trainer trainer;
  final List<Review> reviews;
  final TimeSlot? selectedSlot;
  final DateTime selectedDate;
  final List<TimeSlot> slotsForSelectedDate;

  const TrainerDetailLoaded({
    required this.trainer,
    required this.reviews,
    this.selectedSlot,
    required this.selectedDate,
    required this.slotsForSelectedDate,
  });

  @override
  List<Object?> get props =>
      [trainer, reviews, selectedSlot, selectedDate, slotsForSelectedDate];

  TrainerDetailLoaded copyWith({
    Trainer? trainer,
    List<Review>? reviews,
    TimeSlot? selectedSlot,
    DateTime? selectedDate,
    List<TimeSlot>? slotsForSelectedDate,
  }) {
    return TrainerDetailLoaded(
      trainer: trainer ?? this.trainer,
      reviews: reviews ?? this.reviews,
      selectedSlot: selectedSlot,
      selectedDate: selectedDate ?? this.selectedDate,
      slotsForSelectedDate: slotsForSelectedDate ?? this.slotsForSelectedDate,
    );
  }
}

class TrainerDetailError extends TrainerDetailState {
  final String message;

  const TrainerDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class TrainerDetailBloc extends Bloc<TrainerDetailEvent, TrainerDetailState> {
  final TrainerRepository repository;

  TrainerDetailBloc({required this.repository}) : super(TrainerDetailInitial()) {
    on<LoadTrainerDetail>(_onLoadTrainerDetail);
    on<SelectTimeSlot>(_onSelectTimeSlot);
    on<SelectDate>(_onSelectDate);
  }

  void _onLoadTrainerDetail(
      LoadTrainerDetail event, Emitter<TrainerDetailState> emit) {
    emit(TrainerDetailLoading());
    try {
      final trainer = repository.getTrainerById(event.trainerId);
      if (trainer == null) {
        emit(const TrainerDetailError('Дасгалжуулагч олдсонгүй'));
        return;
      }

      final reviews = repository.getTrainerReviews(event.trainerId);
      final today = DateTime.now();
      final selectedDate = DateTime(today.year, today.month, today.day);
      final slotsForDate = _getSlotsForDate(trainer, selectedDate);

      emit(TrainerDetailLoaded(
        trainer: trainer,
        reviews: reviews,
        selectedDate: selectedDate,
        slotsForSelectedDate: slotsForDate,
      ));
    } catch (e) {
      emit(TrainerDetailError(e.toString()));
    }
  }

  void _onSelectTimeSlot(SelectTimeSlot event, Emitter<TrainerDetailState> emit) {
    final currentState = state;
    if (currentState is TrainerDetailLoaded) {
      emit(currentState.copyWith(selectedSlot: event.slot));
    }
  }

  void _onSelectDate(SelectDate event, Emitter<TrainerDetailState> emit) {
    final currentState = state;
    if (currentState is TrainerDetailLoaded) {
      final slotsForDate = _getSlotsForDate(currentState.trainer, event.date);
      emit(currentState.copyWith(
        selectedDate: event.date,
        slotsForSelectedDate: slotsForDate,
        selectedSlot: null,
      ));
    }
  }

  List<TimeSlot> _getSlotsForDate(Trainer trainer, DateTime date) {
    return trainer.availableSlots.where((slot) {
      return slot.dateTime.year == date.year &&
          slot.dateTime.month == date.month &&
          slot.dateTime.day == date.day;
    }).toList();
  }
}
