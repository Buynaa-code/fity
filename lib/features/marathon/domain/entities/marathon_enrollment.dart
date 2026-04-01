import 'package:equatable/equatable.dart';
import 'marathon_milestone.dart';

/// Марафон бүртгэлийн төлөв
enum EnrollmentStatus {
  active,
  completed,
  dropped;

  String get displayName {
    switch (this) {
      case EnrollmentStatus.active:
        return 'Идэвхтэй';
      case EnrollmentStatus.completed:
        return 'Дуусгасан';
      case EnrollmentStatus.dropped:
        return 'Орхисон';
    }
  }
}

/// Гишүүний оролцооны түвшин
enum EngagementLevel {
  excellent,
  active,
  atRisk,
  inactive;

  String get displayName {
    switch (this) {
      case EngagementLevel.excellent:
        return 'Маш сайн';
      case EngagementLevel.active:
        return 'Идэвхтэй';
      case EngagementLevel.atRisk:
        return 'Анхааруулга';
      case EngagementLevel.inactive:
        return 'Идэвхгүй';
    }
  }

  String get emoji {
    switch (this) {
      case EngagementLevel.excellent:
        return '🔥';
      case EngagementLevel.active:
        return '✅';
      case EngagementLevel.atRisk:
        return '⚠️';
      case EngagementLevel.inactive:
        return '😴';
    }
  }
}

/// Хэрэглэгчийн марафон ангид элссэн бүртгэл
class MarathonEnrollment extends Equatable {
  final String id;
  final String classId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final DateTime enrolledAt;
  final int totalAttendance;
  final EnrollmentStatus status;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastAttendedAt;
  final List<MilestoneType> unlockedMilestones;

  const MarathonEnrollment({
    required this.id,
    required this.classId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.enrolledAt,
    this.totalAttendance = 0,
    this.status = EnrollmentStatus.active,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastAttendedAt,
    this.unlockedMilestones = const [],
  });

  /// Ирцийн хувийг тооцоолох (элссэн өдрөөс хойш)
  double get attendanceRate {
    final daysSinceEnrollment = DateTime.now().difference(enrolledAt).inDays + 1;
    if (daysSinceEnrollment <= 0) return 0;
    // Долоо хоногийн 5 өдөр (ажлын өдөр) бүртгэлтэй гэж тооцно
    final expectedAttendance = (daysSinceEnrollment / 7 * 5).ceil();
    if (expectedAttendance <= 0) return 0;
    return (totalAttendance / expectedAttendance * 100).clamp(0, 100);
  }

  /// Сүүлийн ирц хэдэн өдрийн өмнө
  int? get daysSinceLastAttendance {
    if (lastAttendedAt == null) return null;
    return DateTime.now().difference(lastAttendedAt!).inDays;
  }

  /// Оролцооны түвшинг тооцоолох
  EngagementLevel get engagementLevel {
    final days = daysSinceLastAttendance;

    // Хэзээ ч ирээгүй бол
    if (days == null) {
      return EngagementLevel.inactive;
    }

    // Streak-тэй бол маш сайн
    if (currentStreak >= 3) {
      return EngagementLevel.excellent;
    }

    // Сүүлийн 2 өдөрт ирсэн бол идэвхтэй
    if (days <= 2) {
      return EngagementLevel.active;
    }

    // 3-5 өдөр ирээгүй бол анхааруулга
    if (days <= 5) {
      return EngagementLevel.atRisk;
    }

    // 5 өдрөөс дээш ирээгүй бол идэвхгүй
    return EngagementLevel.inactive;
  }

  /// Сүүлд ирсэн огноог текст болгох
  String get lastAttendedDisplay {
    if (lastAttendedAt == null) return 'Хараахан ирээгүй';

    final days = daysSinceLastAttendance!;
    if (days == 0) return 'Өнөөдөр';
    if (days == 1) return 'Өчигдөр';
    if (days < 7) return '$days өдрийн өмнө';
    if (days < 30) return '${days ~/ 7} долоо хоногийн өмнө';
    return '${days ~/ 30} сарын өмнө';
  }

  MarathonEnrollment copyWith({
    String? id,
    String? classId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    DateTime? enrolledAt,
    int? totalAttendance,
    EnrollmentStatus? status,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastAttendedAt,
    List<MilestoneType>? unlockedMilestones,
  }) {
    return MarathonEnrollment(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      totalAttendance: totalAttendance ?? this.totalAttendance,
      status: status ?? this.status,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastAttendedAt: lastAttendedAt ?? this.lastAttendedAt,
      unlockedMilestones: unlockedMilestones ?? this.unlockedMilestones,
    );
  }

  @override
  List<Object?> get props => [
        id,
        classId,
        userId,
        userName,
        userPhotoUrl,
        enrolledAt,
        totalAttendance,
        status,
        currentStreak,
        longestStreak,
        lastAttendedAt,
        unlockedMilestones,
      ];
}
