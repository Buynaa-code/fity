import '../../domain/entities/badge.dart';

class UserBadgeModel {
  final String id;
  final String badgeId;
  final DateTime earnedAt;
  final int currentProgress;
  final bool isNew;

  UserBadgeModel({
    required this.id,
    required this.badgeId,
    required this.earnedAt,
    required this.currentProgress,
    this.isNew = false,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      id: json['id'] as String,
      badgeId: json['badgeId'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      currentProgress: json['currentProgress'] as int? ?? 0,
      isNew: json['isNew'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'badgeId': badgeId,
      'earnedAt': earnedAt.toIso8601String(),
      'currentProgress': currentProgress,
      'isNew': isNew,
    };
  }

  UserBadge toEntity() {
    return UserBadge(
      id: id,
      badgeId: badgeId,
      earnedAt: earnedAt,
      currentProgress: currentProgress,
      isNew: isNew,
    );
  }

  factory UserBadgeModel.fromEntity(UserBadge entity) {
    return UserBadgeModel(
      id: entity.id,
      badgeId: entity.badgeId,
      earnedAt: entity.earnedAt,
      currentProgress: entity.currentProgress,
      isNew: entity.isNew,
    );
  }

  UserBadgeModel copyWith({
    String? id,
    String? badgeId,
    DateTime? earnedAt,
    int? currentProgress,
    bool? isNew,
  }) {
    return UserBadgeModel(
      id: id ?? this.id,
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      isNew: isNew ?? this.isNew,
    );
  }
}

class BadgeProgressModel {
  final String badgeId;
  final int currentValue;
  final int requiredValue;

  BadgeProgressModel({
    required this.badgeId,
    required this.currentValue,
    required this.requiredValue,
  });

  factory BadgeProgressModel.fromJson(Map<String, dynamic> json) {
    return BadgeProgressModel(
      badgeId: json['badgeId'] as String,
      currentValue: json['currentValue'] as int? ?? 0,
      requiredValue: json['requiredValue'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badgeId': badgeId,
      'currentValue': currentValue,
      'requiredValue': requiredValue,
    };
  }

  BadgeProgress toEntity() {
    return BadgeProgress(
      badgeId: badgeId,
      currentValue: currentValue,
      requiredValue: requiredValue,
    );
  }
}
