import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/trainer_repository.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final TrainerRepository repository;

  ReviewBloc({required this.repository}) : super(ReviewInitial()) {
    on<LoadPendingReviews>(_onLoadPendingReviews);
    on<LoadTrainerReviews>(_onLoadTrainerReviews);
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onLoadPendingReviews(
    LoadPendingReviews event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final pendingReviews =
          await repository.getCompletedBookingsWithoutReview(event.userId);
      emit(PendingReviewsLoaded(pendingReviews));
    } catch (e) {
      emit(ReviewError('Үнэлгээгүй захиалга ачаалахад алдаа гарлаа: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTrainerReviews(
    LoadTrainerReviews event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());
    try {
      final reviews = await repository.getReviewsByTrainerId(event.trainerId);
      final averageRating = reviews.isEmpty
          ? 0.0
          : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

      emit(TrainerReviewsLoaded(
        reviews: reviews,
        averageRating: averageRating,
        totalReviews: reviews.length,
      ));
    } catch (e) {
      emit(ReviewError('Үнэлгээ ачаалахад алдаа гарлаа: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitReview(
    SubmitReview event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
      final review = await repository.createReview(
        trainerId: event.trainerId,
        bookingId: event.bookingId,
        userId: event.userId,
        userName: event.userName,
        userImageUrl: event.userImageUrl,
        rating: event.rating,
        comment: event.comment,
      );
      emit(ReviewSubmitted(review));
    } catch (e) {
      emit(ReviewError('Үнэлгээ илгээхэд алдаа гарлаа: ${e.toString()}'));
    }
  }
}
