import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/trainer.dart';
import '../../../domain/entities/booking.dart';
import '../../../data/repositories/trainer_repository.dart';

// Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookings extends BookingEvent {}

class CreateBooking extends BookingEvent {
  final Trainer trainer;
  final TimeSlot slot;
  final String? notes;

  const CreateBooking({
    required this.trainer,
    required this.slot,
    this.notes,
  });

  @override
  List<Object?> get props => [trainer, slot, notes];
}

class CancelBooking extends BookingEvent {
  final String bookingId;

  const CancelBooking(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

// States
abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;
  final List<Booking> upcomingBookings;
  final List<Booking> pastBookings;

  const BookingsLoaded({
    required this.bookings,
    required this.upcomingBookings,
    required this.pastBookings,
  });

  @override
  List<Object?> get props => [bookings, upcomingBookings, pastBookings];
}

class BookingCreating extends BookingState {}

class BookingCreated extends BookingState {
  final Booking booking;

  const BookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookingCancelled extends BookingState {
  final String bookingId;

  const BookingCancelled(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

// BLoC
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final TrainerRepository repository;
  static const String _userId = 'current_user'; // Mock user ID

  BookingBloc({required this.repository}) : super(BookingInitial()) {
    on<LoadBookings>(_onLoadBookings);
    on<CreateBooking>(_onCreateBooking);
    on<CancelBooking>(_onCancelBooking);
  }

  Future<void> _onLoadBookings(
      LoadBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final bookings = await repository.getBookings();
      final now = DateTime.now();

      final upcoming = bookings
          .where((b) =>
              b.scheduledAt.isAfter(now) && b.status != BookingStatus.cancelled)
          .toList();
      final past = bookings
          .where((b) =>
              b.scheduledAt.isBefore(now) || b.status == BookingStatus.cancelled)
          .toList();

      emit(BookingsLoaded(
        bookings: bookings,
        upcomingBookings: upcoming,
        pastBookings: past,
      ));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCreateBooking(
      CreateBooking event, Emitter<BookingState> emit) async {
    emit(BookingCreating());
    try {
      final booking = await repository.createBooking(
        trainer: event.trainer,
        slot: event.slot,
        userId: _userId,
        notes: event.notes,
      );
      emit(BookingCreated(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCancelBooking(
      CancelBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      await repository.cancelBooking(event.bookingId);
      emit(BookingCancelled(event.bookingId));
      add(LoadBookings()); // Reload bookings
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
