import 'package:equatable/equatable.dart';

/// Milestone төрлүүд
enum MilestoneType {
  // Streak milestones
  streak7,
  streak14,
  streak30,
  streak60,
  streak90,
  // Attendance milestones
  attendance7,
  attendance30,
  attendance60,
  attendance100;

  String get title {
    switch (this) {
      case MilestoneType.streak7:
        return '7 хоногийн streak';
      case MilestoneType.streak14:
        return '14 хоногийн streak';
      case MilestoneType.streak30:
        return 'Сарын аварга';
      case MilestoneType.streak60:
        return 'Хос сарын аварга';
      case MilestoneType.streak90:
        return 'Улирлын аварга';
      case MilestoneType.attendance7:
        return 'Эхлэл';
      case MilestoneType.attendance30:
        return 'Тогтвортой';
      case MilestoneType.attendance60:
        return 'Тууштай';
      case MilestoneType.attendance100:
        return 'Зуутын гишүүн';
    }
  }

  String get description {
    switch (this) {
      case MilestoneType.streak7:
        return '7 дараалсан өдөр ирц бүртгүүлсэн';
      case MilestoneType.streak14:
        return '14 дараалсан өдөр ирц бүртгүүлсэн';
      case MilestoneType.streak30:
        return '30 дараалсан өдөр ирц бүртгүүлсэн';
      case MilestoneType.streak60:
        return '60 дараалсан өдөр ирц бүртгүүлсэн';
      case MilestoneType.streak90:
        return '90 дараалсан өдөр ирц бүртгүүлсэн';
      case MilestoneType.attendance7:
        return 'Нийт 7 удаа ирц бүртгүүлсэн';
      case MilestoneType.attendance30:
        return 'Нийт 30 удаа ирц бүртгүүлсэн';
      case MilestoneType.attendance60:
        return 'Нийт 60 удаа ирц бүртгүүлсэн';
      case MilestoneType.attendance100:
        return 'Нийт 100 удаа ирц бүртгүүлсэн';
    }
  }

  int get xp {
    switch (this) {
      case MilestoneType.streak7:
        return 100;
      case MilestoneType.streak14:
        return 200;
      case MilestoneType.streak30:
        return 500;
      case MilestoneType.streak60:
        return 800;
      case MilestoneType.streak90:
        return 1500;
      case MilestoneType.attendance7:
        return 50;
      case MilestoneType.attendance30:
        return 300;
      case MilestoneType.attendance60:
        return 600;
      case MilestoneType.attendance100:
        return 1000;
    }
  }

  String get icon {
    switch (this) {
      case MilestoneType.streak7:
        return '🔥';
      case MilestoneType.streak14:
        return '💪';
      case MilestoneType.streak30:
        return '🏆';
      case MilestoneType.streak60:
        return '⭐';
      case MilestoneType.streak90:
        return '👑';
      case MilestoneType.attendance7:
        return '🌱';
      case MilestoneType.attendance30:
        return '🌿';
      case MilestoneType.attendance60:
        return '🌳';
      case MilestoneType.attendance100:
        return '💎';
    }
  }

  /// Streak milestone-д шаардлагатай streak тоо
  int? get requiredStreak {
    switch (this) {
      case MilestoneType.streak7:
        return 7;
      case MilestoneType.streak14:
        return 14;
      case MilestoneType.streak30:
        return 30;
      case MilestoneType.streak60:
        return 60;
      case MilestoneType.streak90:
        return 90;
      default:
        return null;
    }
  }

  /// Attendance milestone-д шаардлагатай ирцийн тоо
  int? get requiredAttendance {
    switch (this) {
      case MilestoneType.attendance7:
        return 7;
      case MilestoneType.attendance30:
        return 30;
      case MilestoneType.attendance60:
        return 60;
      case MilestoneType.attendance100:
        return 100;
      default:
        return null;
    }
  }

  bool get isStreakMilestone => requiredStreak != null;
  bool get isAttendanceMilestone => requiredAttendance != null;
}

/// Марафон milestone entity
class MarathonMilestone extends Equatable {
  final MilestoneType type;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0

  const MarathonMilestone({
    required this.type,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
  });

  String get title => type.title;
  String get description => type.description;
  int get xp => type.xp;
  String get icon => type.icon;

  MarathonMilestone copyWith({
    MilestoneType? type,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
  }) {
    return MarathonMilestone(
      type: type ?? this.type,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [type, isUnlocked, unlockedAt, progress];
}
