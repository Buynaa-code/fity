import 'package:flutter/material.dart';

/// Badge categories based on Octalysis gamification framework
enum BadgeCategory {
  streak,      // Consistency achievements
  workout,     // Workout volume achievements
  challenge,   // Challenge completion
  water,       // Hydration achievements
  social,      // Community engagement
  milestone,   // Special milestones
  seasonal,    // Limited-time achievements
}

/// Badge rarity levels
enum BadgeRarity {
  common,      // Easy to obtain
  uncommon,    // Moderate effort
  rare,        // Significant achievement
  epic,        // Major milestone
  legendary,   // Exceptional achievement
}

/// Badge definition - static data about available badges
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final IconData iconData;
  final BadgeCategory category;
  final BadgeRarity rarity;
  final Color color;
  final int requiredValue;
  final String unit;
  final int xpReward;
  final bool isSecret;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
    this.iconAsset = '',
    required this.category,
    required this.rarity,
    required this.color,
    required this.requiredValue,
    this.unit = '',
    required this.xpReward,
    this.isSecret = false,
  });

  /// Get gradient colors based on rarity
  List<Color> get rarityGradient {
    switch (rarity) {
      case BadgeRarity.common:
        return [Colors.grey.shade400, Colors.grey.shade600];
      case BadgeRarity.uncommon:
        return [Colors.green.shade400, Colors.green.shade700];
      case BadgeRarity.rare:
        return [Colors.blue.shade400, Colors.blue.shade700];
      case BadgeRarity.epic:
        return [Colors.purple.shade400, Colors.purple.shade700];
      case BadgeRarity.legendary:
        return [Colors.orange.shade400, Colors.amber.shade700];
    }
  }

  String get rarityName {
    switch (rarity) {
      case BadgeRarity.common:
        return 'Энгийн';
      case BadgeRarity.uncommon:
        return 'Ховор биш';
      case BadgeRarity.rare:
        return 'Ховор';
      case BadgeRarity.epic:
        return 'Эпик';
      case BadgeRarity.legendary:
        return 'Домог';
    }
  }

  String get categoryName {
    switch (category) {
      case BadgeCategory.streak:
        return 'Тогтмол байдал';
      case BadgeCategory.workout:
        return 'Дасгал';
      case BadgeCategory.challenge:
        return 'Сорилцоон';
      case BadgeCategory.water:
        return 'Усны хэрэглээ';
      case BadgeCategory.social:
        return 'Нийгэмлэг';
      case BadgeCategory.milestone:
        return 'Чухал үе';
      case BadgeCategory.seasonal:
        return 'Улирлын';
    }
  }
}

/// User's earned badge - tracks when and how badge was earned
class UserBadge {
  final String id;
  final String badgeId;
  final DateTime earnedAt;
  final int currentProgress;
  final bool isNew;

  const UserBadge({
    required this.id,
    required this.badgeId,
    required this.earnedAt,
    required this.currentProgress,
    this.isNew = false,
  });

  UserBadge copyWith({
    String? id,
    String? badgeId,
    DateTime? earnedAt,
    int? currentProgress,
    bool? isNew,
  }) {
    return UserBadge(
      id: id ?? this.id,
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      isNew: isNew ?? this.isNew,
    );
  }
}

/// Badge progress for badges not yet earned
class BadgeProgress {
  final String badgeId;
  final int currentValue;
  final int requiredValue;

  const BadgeProgress({
    required this.badgeId,
    required this.currentValue,
    required this.requiredValue,
  });

  double get progressPercent =>
      requiredValue > 0 ? (currentValue / requiredValue).clamp(0.0, 1.0) : 0.0;

  bool get isComplete => currentValue >= requiredValue;
}
