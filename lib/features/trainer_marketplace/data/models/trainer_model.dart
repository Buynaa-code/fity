import '../../domain/entities/trainer.dart';
import '../../domain/entities/trainer_subscription.dart';

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
    super.userId,
    super.phone,
    super.isVerified,
    super.isActive,
    super.isFeatured,
    super.photoUrls,
    super.registeredAt,
    super.subscriptionTier,
    super.status,
    super.rejectionReason,
    super.approvedAt,
    super.approvedBy,
    super.certificationUrls,
    super.email,
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
      userId: json['userId'] as String?,
      phone: json['phone'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      photoUrls: List<String>.from(json['photoUrls'] ?? []),
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : null,
      subscriptionTier: json['subscriptionTier'] != null
          ? SubscriptionTier.values.firstWhere(
              (e) => e.name == json['subscriptionTier'],
              orElse: () => SubscriptionTier.basic,
            )
          : null,
      status: json['status'] != null
          ? TrainerStatus.values.firstWhere(
              (e) => e.name == json['status'],
              orElse: () => TrainerStatus.approved,
            )
          : TrainerStatus.approved,
      rejectionReason: json['rejectionReason'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
      certificationUrls: List<String>.from(json['certificationUrls'] ?? []),
      email: json['email'] as String?,
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
      'availableSlots': availableSlots.map((e) {
        if (e is TimeSlotModel) {
          return e.toJson();
        }
        return {
          'id': e.id,
          'dateTime': e.dateTime.toIso8601String(),
          'durationMinutes': e.durationMinutes,
          'isAvailable': e.isAvailable,
        };
      }).toList(),
      'userId': userId,
      'phone': phone,
      'isVerified': isVerified,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'photoUrls': photoUrls,
      'registeredAt': registeredAt?.toIso8601String(),
      'subscriptionTier': subscriptionTier?.name,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'certificationUrls': certificationUrls,
      'email': email,
    };
  }

  factory TrainerModel.fromEntity(Trainer entity) {
    return TrainerModel(
      id: entity.id,
      name: entity.name,
      bio: entity.bio,
      imageUrl: entity.imageUrl,
      specialties: entity.specialties,
      hourlyRate: entity.hourlyRate,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      experienceYears: entity.experienceYears,
      certifications: entity.certifications,
      availableSlots: entity.availableSlots,
      userId: entity.userId,
      phone: entity.phone,
      isVerified: entity.isVerified,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      photoUrls: entity.photoUrls,
      registeredAt: entity.registeredAt,
      subscriptionTier: entity.subscriptionTier,
      status: entity.status,
      rejectionReason: entity.rejectionReason,
      approvedAt: entity.approvedAt,
      approvedBy: entity.approvedBy,
      certificationUrls: entity.certificationUrls,
      email: entity.email,
    );
  }

  @override
  TrainerModel copyWith({
    String? id,
    String? name,
    String? bio,
    String? imageUrl,
    List<String>? specialties,
    double? hourlyRate,
    double? rating,
    int? reviewCount,
    int? experienceYears,
    List<String>? certifications,
    List<TimeSlot>? availableSlots,
    String? userId,
    String? phone,
    bool? isVerified,
    bool? isActive,
    bool? isFeatured,
    List<String>? photoUrls,
    DateTime? registeredAt,
    SubscriptionTier? subscriptionTier,
    TrainerStatus? status,
    String? rejectionReason,
    DateTime? approvedAt,
    String? approvedBy,
    List<String>? certificationUrls,
    String? email,
  }) {
    return TrainerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      specialties: specialties ?? this.specialties,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      experienceYears: experienceYears ?? this.experienceYears,
      certifications: certifications ?? this.certifications,
      availableSlots: availableSlots ?? this.availableSlots,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      photoUrls: photoUrls ?? this.photoUrls,
      registeredAt: registeredAt ?? this.registeredAt,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      certificationUrls: certificationUrls ?? this.certificationUrls,
      email: email ?? this.email,
    );
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
