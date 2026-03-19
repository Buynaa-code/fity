import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, completed, cancelled }

class Booking extends Equatable {
  final String id;
  final String trainerId;
  final String trainerName;
  final String trainerImageUrl;
  final String userId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final double price;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.trainerId,
    required this.trainerName,
    required this.trainerImageUrl,
    required this.userId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.price,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  Booking copyWith({
    String? id,
    String? trainerId,
    String? trainerName,
    String? trainerImageUrl,
    String? userId,
    DateTime? scheduledAt,
    int? durationMinutes,
    double? price,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      trainerImageUrl: trainerImageUrl ?? this.trainerImageUrl,
      userId: userId ?? this.userId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trainerId,
        trainerName,
        trainerImageUrl,
        userId,
        scheduledAt,
        durationMinutes,
        price,
        status,
        notes,
        createdAt,
      ];
}
