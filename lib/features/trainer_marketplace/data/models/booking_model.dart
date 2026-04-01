import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.trainerId,
    required super.trainerName,
    required super.trainerImageUrl,
    required super.userId,
    required super.scheduledAt,
    required super.durationMinutes,
    required super.price,
    required super.status,
    super.notes,
    required super.createdAt,
    super.hasReview,
    super.reviewId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      trainerName: json['trainerName'] as String,
      trainerImageUrl: json['trainerImageUrl'] as String,
      userId: json['userId'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      durationMinutes: json['durationMinutes'] as int,
      price: (json['price'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      hasReview: json['hasReview'] as bool? ?? false,
      reviewId: json['reviewId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'trainerImageUrl': trainerImageUrl,
      'userId': userId,
      'scheduledAt': scheduledAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'price': price,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'hasReview': hasReview,
      'reviewId': reviewId,
    };
  }

  @override
  BookingModel copyWith({
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
    bool? hasReview,
    String? reviewId,
  }) {
    return BookingModel(
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
      hasReview: hasReview ?? this.hasReview,
      reviewId: reviewId ?? this.reviewId,
    );
  }
}
