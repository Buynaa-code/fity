import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingReviews extends ReviewEvent {
  final String userId;

  const LoadPendingReviews(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SubmitReview extends ReviewEvent {
  final String trainerId;
  final String bookingId;
  final String userId;
  final String userName;
  final String userImageUrl;
  final double rating;
  final String comment;

  const SubmitReview({
    required this.trainerId,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [
        trainerId,
        bookingId,
        userId,
        userName,
        userImageUrl,
        rating,
        comment,
      ];
}

class LoadTrainerReviews extends ReviewEvent {
  final String trainerId;

  const LoadTrainerReviews(this.trainerId);

  @override
  List<Object?> get props => [trainerId];
}
