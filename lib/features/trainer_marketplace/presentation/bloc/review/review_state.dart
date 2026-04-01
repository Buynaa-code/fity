import 'package:equatable/equatable.dart';
import '../../../domain/entities/trainer.dart';
import '../../../domain/entities/booking.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class PendingReviewsLoaded extends ReviewState {
  final List<Booking> pendingReviews;

  const PendingReviewsLoaded(this.pendingReviews);

  @override
  List<Object?> get props => [pendingReviews];
}

class TrainerReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  final double averageRating;
  final int totalReviews;

  const TrainerReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  List<Object?> get props => [reviews, averageRating, totalReviews];
}

class ReviewSubmitting extends ReviewState {}

class ReviewSubmitted extends ReviewState {
  final Review review;

  const ReviewSubmitted(this.review);

  @override
  List<Object?> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
