import 'package:equatable/equatable.dart';
import 'trainer_subscription.dart';

enum TrainerStatus {
  pending,    // Хүлээгдэж байна
  approved,   // Зөвшөөрөгдсөн
  rejected,   // Татгалзсан
  suspended,  // Түр хаагдсан
}

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
  final String? userId;
  final String? phone;
  final bool isVerified;
  final bool isActive;
  final bool isFeatured;
  final List<String> photoUrls;
  final DateTime? registeredAt;
  final SubscriptionTier? subscriptionTier;
  final TrainerStatus status;
  final String? rejectionReason;
  final DateTime? approvedAt;
  final String? approvedBy;
  final List<String> certificationUrls;
  final String? email;

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
    this.userId,
    this.phone,
    this.isVerified = false,
    this.isActive = true,
    this.isFeatured = false,
    this.photoUrls = const [],
    this.registeredAt,
    this.subscriptionTier,
    this.status = TrainerStatus.approved,
    this.rejectionReason,
    this.approvedAt,
    this.approvedBy,
    this.certificationUrls = const [],
    this.email,
  });

  bool get hasAvailableSlots => availableSlots.any((s) => s.isAvailable);

  bool get isPremium => subscriptionTier == SubscriptionTier.premium;

  bool get isProfessional => subscriptionTier == SubscriptionTier.professional;

  bool get canBeFeatured =>
      isActive &&
      status == TrainerStatus.approved &&
      (subscriptionTier == SubscriptionTier.professional ||
          subscriptionTier == SubscriptionTier.premium);

  bool get isApproved => status == TrainerStatus.approved;
  bool get isPending => status == TrainerStatus.pending;
  bool get isRejected => status == TrainerStatus.rejected;
  bool get isSuspended => status == TrainerStatus.suspended;

  Trainer copyWith({
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
    return Trainer(
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
        userId,
        phone,
        isVerified,
        isActive,
        isFeatured,
        photoUrls,
        registeredAt,
        subscriptionTier,
        status,
        rejectionReason,
        approvedAt,
        approvedBy,
        certificationUrls,
        email,
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
