import 'package:equatable/equatable.dart';

class Trainer extends Equatable {
  final String id;
  final String name;
  final String bio;
  final String imageUrl;
  final List<String> specialties;
  final double hourlyRate;
  final double rating;
  final int reviewCount;
  final int experienceYears;
  final List<String> certifications;
  final List<TimeSlot> availableSlots;

  const Trainer({
    required this.id,
    required this.name,
    required this.bio,
    required this.imageUrl,
    required this.specialties,
    required this.hourlyRate,
    required this.rating,
    required this.reviewCount,
    required this.experienceYears,
    required this.certifications,
    required this.availableSlots,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        bio,
        imageUrl,
        specialties,
        hourlyRate,
        rating,
        reviewCount,
        experienceYears,
        certifications,
        availableSlots,
      ];
}

class TimeSlot extends Equatable {
  final String id;
  final DateTime dateTime;
  final int durationMinutes;
  final bool isAvailable;

  const TimeSlot({
    required this.id,
    required this.dateTime,
    required this.durationMinutes,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [id, dateTime, durationMinutes, isAvailable];
}

class Review extends Equatable {
  final String id;
  final String trainerId;
  final String userId;
  final String userName;
  final String userImageUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.trainerId,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        trainerId,
        userId,
        userName,
        userImageUrl,
        rating,
        comment,
        createdAt,
      ];
}
