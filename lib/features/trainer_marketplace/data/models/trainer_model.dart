import '../../domain/entities/trainer.dart';

class TrainerModel extends Trainer {
  const TrainerModel({
    required super.id,
    required super.name,
    required super.bio,
    required super.imageUrl,
    required super.specialties,
    required super.hourlyRate,
    required super.rating,
    required super.reviewCount,
    required super.experienceYears,
    required super.certifications,
    required super.availableSlots,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String,
      imageUrl: json['imageUrl'] as String,
      specialties: List<String>.from(json['specialties'] ?? []),
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      experienceYears: json['experienceYears'] as int,
      certifications: List<String>.from(json['certifications'] ?? []),
      availableSlots: (json['availableSlots'] as List?)
              ?.map((e) => TimeSlotModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'imageUrl': imageUrl,
      'specialties': specialties,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'reviewCount': reviewCount,
      'experienceYears': experienceYears,
      'certifications': certifications,
      'availableSlots':
          availableSlots.map((e) => (e as TimeSlotModel).toJson()).toList(),
    };
  }
}

class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.id,
    required super.dateTime,
    required super.durationMinutes,
    required super.isAvailable,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      durationMinutes: json['durationMinutes'] as int,
      isAvailable: json['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'isAvailable': isAvailable,
    };
  }
}

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.trainerId,
    required super.userId,
    required super.userName,
    required super.userImageUrl,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userImageUrl: json['userImageUrl'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
