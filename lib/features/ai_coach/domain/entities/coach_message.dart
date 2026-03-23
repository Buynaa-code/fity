import 'package:flutter/material.dart';

enum MessageType { user, coach, tip, workout, motivation }

class CoachMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const CoachMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.metadata,
  });

  IconData get icon {
    switch (type) {
      case MessageType.user:
        return Icons.person_rounded;
      case MessageType.coach:
        return Icons.smart_toy_rounded;
      case MessageType.tip:
        return Icons.lightbulb_rounded;
      case MessageType.workout:
        return Icons.fitness_center_rounded;
      case MessageType.motivation:
        return Icons.emoji_events_rounded;
    }
  }

  Color get color {
    switch (type) {
      case MessageType.user:
        return const Color(0xFF6C5CE7);
      case MessageType.coach:
        return const Color(0xFFFE7409);
      case MessageType.tip:
        return const Color(0xFF3498DB);
      case MessageType.workout:
        return const Color(0xFF9B59B6);
      case MessageType.motivation:
        return const Color(0xFF1ABC9C);
    }
  }
}

class WorkoutSuggestion {
  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final int calories;
  final String difficulty;
  final List<String> exercises;
  final String reason;

  const WorkoutSuggestion({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.calories,
    required this.difficulty,
    required this.exercises,
    required this.reason,
  });
}

class DailyTip {
  final String id;
  final String title;
  final String content;
  final String category;
  final IconData icon;
  final Color color;

  const DailyTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.icon,
    required this.color,
  });
}
