import 'package:flutter/material.dart';

class ReviewInputWidget extends StatefulWidget {
  final double initialRating;
  final String initialComment;
  final ValueChanged<double> onRatingChanged;
  final ValueChanged<String> onCommentChanged;
  final bool enabled;

  const ReviewInputWidget({
    super.key,
    this.initialRating = 0,
    this.initialComment = '',
    required this.onRatingChanged,
    required this.onCommentChanged,
    this.enabled = true,
  });

  @override
  State<ReviewInputWidget> createState() => _ReviewInputWidgetState();
}

class _ReviewInputWidgetState extends State<ReviewInputWidget> {
  late double _rating;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _commentController = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _setRating(double rating) {
    setState(() {
      _rating = rating;
    });
    widget.onRatingChanged(rating);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Үнэлгээ өгөх',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1.0;
              return GestureDetector(
                onTap: widget.enabled ? () => _setRating(starValue) : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    _rating >= starValue
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 48,
                    color: _rating >= starValue
                        ? Colors.amber
                        : Colors.grey[300],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _getRatingText(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _rating > 0 ? const Color(0xFFF72928) : Colors.grey[500],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Сэтгэгдэл',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          enabled: widget.enabled,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Таны туршлагын талаар бичнэ үү...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFF72928),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: widget.onCommentChanged,
        ),
      ],
    );
  }

  String _getRatingText() {
    if (_rating == 0) return 'Од сонгоно уу';
    if (_rating == 1) return 'Муу';
    if (_rating == 2) return 'Дунд';
    if (_rating == 3) return 'Сайн';
    if (_rating == 4) return 'Маш сайн';
    return 'Гайхалтай!';
  }
}
