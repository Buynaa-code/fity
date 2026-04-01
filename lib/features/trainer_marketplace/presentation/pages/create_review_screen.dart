import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trainer_repository.dart';
import '../../domain/entities/booking.dart';
import '../bloc/review/review_bloc.dart';
import '../bloc/review/review_event.dart';
import '../bloc/review/review_state.dart';
import '../widgets/review_input_widget.dart';

class CreateReviewScreen extends StatelessWidget {
  final Booking booking;
  final String userId;
  final String userName;
  final String userImageUrl;

  const CreateReviewScreen({
    super.key,
    required this.booking,
    required this.userId,
    required this.userName,
    this.userImageUrl = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(repository: TrainerRepository()),
      child: _CreateReviewView(
        booking: booking,
        userId: userId,
        userName: userName,
        userImageUrl: userImageUrl,
      ),
    );
  }
}

class _CreateReviewView extends StatefulWidget {
  final Booking booking;
  final String userId;
  final String userName;
  final String userImageUrl;

  const _CreateReviewView({
    required this.booking,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
  });

  @override
  State<_CreateReviewView> createState() => _CreateReviewViewState();
}

class _CreateReviewViewState extends State<_CreateReviewView> {
  double _rating = 0;
  String _comment = '';

  bool get _canSubmit => _rating > 0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          HapticFeedback.mediumImpact();
          _showSuccessDialog(context);
        } else if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is ReviewSubmitting;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Үнэлгээ өгөх'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trainer info card
                _buildTrainerCard(),
                const SizedBox(height: 32),
                // Review input
                ReviewInputWidget(
                  initialRating: _rating,
                  initialComment: _comment,
                  enabled: !isSubmitting,
                  onRatingChanged: (rating) {
                    setState(() => _rating = rating);
                  },
                  onCommentChanged: (comment) {
                    setState(() => _comment = comment);
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: isSubmitting || !_canSubmit
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        context.read<ReviewBloc>().add(SubmitReview(
                              trainerId: widget.booking.trainerId,
                              bookingId: widget.booking.id,
                              userId: widget.userId,
                              userName: widget.userName,
                              userImageUrl: widget.userImageUrl,
                              rating: _rating,
                              comment: _comment,
                            ));
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF72928),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Үнэлгээ илгээх',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrainerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.booking.trainerImageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: Icon(Icons.person, color: Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.booking.trainerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(widget.booking.scheduledAt),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${widget.booking.durationMinutes} минут',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'нэгдүгээр сар',
      'хоёрдугаар сар',
      'гуравдугаар сар',
      'дөрөвдүгээр сар',
      'тавдугаар сар',
      'зургадугаар сар',
      'долоодугаар сар',
      'наймдугаар сар',
      'есдүгээр сар',
      'аравдугаар сар',
      'арван нэгдүгээр сар',
      'арван хоёрдугаар сар',
    ];
    return '${date.year} оны ${months[date.month - 1]}ийн ${date.day}';
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Баярлалаа!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Таны үнэлгээ амжилттай илгээгдлээ. Энэ нь бусад гишүүдэд тусална.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF72928),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Дуусгах'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
