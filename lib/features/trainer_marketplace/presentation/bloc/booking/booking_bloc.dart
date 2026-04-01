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

class RescheduleBooking extends BookingEvent {
  final String bookingId;
  final TimeSlot newSlot;

  const RescheduleBooking({
    required this.bookingId,
    required this.newSlot,
  });

  @override
  List<Object?> get props => [bookingId, newSlot];
}

class CheckSlotAvailability extends BookingEvent {
  final String trainerId;
  final TimeSlot slot;

  const CheckSlotAvailability({
    required this.trainerId,
    required this.slot,
  });

  @override
  List<Object?> get props => [trainerId, slot];
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
  final BookingErrorType type;

  const BookingError(this.message, {this.type = BookingErrorType.general});

  @override
  List<Object?> get props => [message, type];
}

enum BookingErrorType {
  general,
  slotUnavailable,
  cancellationDeadlinePassed,
  alreadyCancelled,
  pastBooking,
}

class BookingCancelled extends BookingState {
  final String bookingId;

  const BookingCancelled(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class BookingRescheduled extends BookingState {
  final Booking booking;

  const BookingRescheduled(this.booking);

  @override
  List<Object?> get props => [booking];
}

class SlotAvailabilityChecked extends BookingState {
  final bool isAvailable;
  final String? message;

  const SlotAvailabilityChecked({required this.isAvailable, this.message});

  @override
  List<Object?> get props => [isAvailable, message];
}

// BLoC
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final TrainerRepository repository;
  static const String _userId = 'current_user'; // Mock user ID

  // Cancellation deadline: 24 hours before the scheduled time
  static const Duration cancellationDeadline = Duration(hours: 24);

  BookingBloc({required this.repository}) : super(BookingInitial()) {
    on<LoadBookings>(_onLoadBookings);
    on<CreateBooking>(_onCreateBooking);
    on<CancelBooking>(_onCancelBooking);
    on<RescheduleBooking>(_onRescheduleBooking);
    on<CheckSlotAvailability>(_onCheckSlotAvailability);
  }

  Future<void> _onLoadBookings(
      LoadBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      // Seed test data for review testing
      await repository.seedTestBookings();

      final bookings = await repository.getBookings();
      final now = DateTime.now();

      final upcoming = bookings
          .where((b) =>
              b.scheduledAt.isAfter(now) && b.status != BookingStatus.cancelled)
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

      final past = bookings
          .where((b) =>
              b.scheduledAt.isBefore(now) || b.status == BookingStatus.cancelled)
          .toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

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
      // 1. Check if the slot is still available
      final isAvailable = await _isSlotAvailable(
        event.trainer.id,
        event.slot,
      );

      if (!isAvailable) {
        emit(const BookingError(
          'Уучлаарай, энэ цаг аль хэдийн захиалагдсан байна',
          type: BookingErrorType.slotUnavailable,
        ));
        return;
      }

      // 2. Check if the slot is not in the past
      if (event.slot.dateTime.isBefore(DateTime.now())) {
        emit(const BookingError(
          'Өнгөрсөн цагийг захиалах боломжгүй',
          type: BookingErrorType.pastBooking,
        ));
        return;
      }

      // 3. Create the booking
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
      // 1. Get the booking
      final bookings = await repository.getBookings();
      final booking = bookings.firstWhere(
        (b) => b.id == event.bookingId,
        orElse: () => throw Exception('Захиалга олдсонгүй'),
      );

      // 2. Check if already cancelled
      if (booking.status == BookingStatus.cancelled) {
        emit(const BookingError(
          'Энэ захиалга аль хэдийн цуцлагдсан',
          type: BookingErrorType.alreadyCancelled,
        ));
        return;
      }

      // 3. Check cancellation deadline (24 hours before)
      final now = DateTime.now();
      final deadline = booking.scheduledAt.subtract(cancellationDeadline);

      if (now.isAfter(deadline)) {
        final hoursLeft = booking.scheduledAt.difference(now).inHours;
        emit(BookingError(
          'Цуцлах хугацаа дууссан. Захиалга эхлэхээс 24 цагийн өмнө цуцлах боломжтой. (Үлдсэн: $hoursLeft цаг)',
          type: BookingErrorType.cancellationDeadlinePassed,
        ));
        return;
      }

      // 4. Check if booking is in the past
      if (booking.scheduledAt.isBefore(now)) {
        emit(const BookingError(
          'Өнгөрсөн захиалгыг цуцлах боломжгүй',
          type: BookingErrorType.pastBooking,
        ));
        return;
      }

      // 5. Cancel the booking
      await repository.cancelBooking(event.bookingId);
      emit(BookingCancelled(event.bookingId));
      add(LoadBookings()); // Reload bookings
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onRescheduleBooking(
      RescheduleBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      // 1. Get the current booking
      final bookings = await repository.getBookings();
      final currentBooking = bookings.firstWhere(
        (b) => b.id == event.bookingId,
        orElse: () => throw Exception('Захиалга олдсонгүй'),
      );

      // 2. Check if booking can be rescheduled (same rules as cancellation)
      final now = DateTime.now();
      final deadline = currentBooking.scheduledAt.subtract(cancellationDeadline);

      if (now.isAfter(deadline)) {
        emit(const BookingError(
          'Цаг өөрчлөх хугацаа дууссан. Захиалга эхлэхээс 24 цагийн өмнө өөрчлөх боломжтой.',
          type: BookingErrorType.cancellationDeadlinePassed,
        ));
        return;
      }

      // 3. Check if new slot is available
      final isAvailable = await _isSlotAvailable(
        currentBooking.trainerId,
        event.newSlot,
      );

      if (!isAvailable) {
        emit(const BookingError(
          'Сонгосон цаг аль хэдийн захиалагдсан байна',
          type: BookingErrorType.slotUnavailable,
        ));
        return;
      }

      // 4. Cancel old booking and create new one
      await repository.cancelBooking(event.bookingId);

      // Get trainer info
      final trainer = await repository.getTrainerByIdAsync(currentBooking.trainerId);
      if (trainer == null) {
        emit(const BookingError('Дасгалжуулагч олдсонгүй'));
        return;
      }

      final newBooking = await repository.createBooking(
        trainer: trainer,
        slot: event.newSlot,
        userId: _userId,
        notes: currentBooking.notes,
      );

      emit(BookingRescheduled(newBooking));
      add(LoadBookings()); // Reload bookings
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCheckSlotAvailability(
      CheckSlotAvailability event, Emitter<BookingState> emit) async {
    try {
      final isAvailable = await _isSlotAvailable(event.trainerId, event.slot);
      emit(SlotAvailabilityChecked(
        isAvailable: isAvailable,
        message: isAvailable ? null : 'Энэ цаг аль хэдийн захиалагдсан',
      ));
    } catch (e) {
      emit(SlotAvailabilityChecked(
        isAvailable: false,
        message: 'Боломжгүй шалгах үед алдаа гарлаа',
      ));
    }
  }

  /// Check if a time slot is available for booking
  Future<bool> _isSlotAvailable(String trainerId, TimeSlot slot) async {
    // Check if the slot is marked as available
    if (!slot.isAvailable) {
      return false;
    }

    // Check against existing bookings
    final bookings = await repository.getBookings();
    final hasConflict = bookings.any((booking) {
      if (booking.trainerId != trainerId) return false;
      if (booking.status == BookingStatus.cancelled) return false;

      // Check for time overlap
      final bookingEnd = booking.scheduledAt
          .add(Duration(minutes: booking.durationMinutes));
      final slotEnd = slot.dateTime.add(Duration(minutes: slot.durationMinutes));

      // Two time ranges overlap if one starts before the other ends
      return booking.scheduledAt.isBefore(slotEnd) &&
          bookingEnd.isAfter(slot.dateTime);
    });

    return !hasConflict;
  }

  /// Check if a booking can be cancelled (within deadline)
  bool canCancelBooking(Booking booking) {
    if (booking.status == BookingStatus.cancelled) return false;

    final now = DateTime.now();
    if (booking.scheduledAt.isBefore(now)) return false;

    final deadline = booking.scheduledAt.subtract(cancellationDeadline);
    return now.isBefore(deadline);
  }

  /// Get time remaining until cancellation deadline
  Duration? getTimeUntilCancellationDeadline(Booking booking) {
    if (!canCancelBooking(booking)) return null;

    final deadline = booking.scheduledAt.subtract(cancellationDeadline);
    return deadline.difference(DateTime.now());
  }
}
