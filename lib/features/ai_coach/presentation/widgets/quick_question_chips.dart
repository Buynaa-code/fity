import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickQuestionChips extends StatelessWidget {
  final List<String> questions;
  final Function(String) onQuestionTap;

  const QuickQuestionChips({
    super.key,
    required this.questions,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < questions.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onQuestionTap(questions[index]);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getQuestionIcon(questions[index]),
                      size: 14,
                      color: const Color(0xFFFE7409),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      questions[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getQuestionIcon(String question) {
    if (question.contains('дасгал')) {
      return Icons.fitness_center_rounded;
    } else if (question.contains('жин')) {
      return Icons.monitor_weight_rounded;
    } else if (question.contains('булчин')) {
      return Icons.sports_gymnastics_rounded;
    } else if (question.contains('сунгалт')) {
      return Icons.self_improvement_rounded;
    } else if (question.contains('өглөө')) {
      return Icons.wb_sunny_rounded;
    }
    return Icons.help_outline_rounded;
  }
}
