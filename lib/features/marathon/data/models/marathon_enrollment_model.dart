import '../../domain/entities/marathon_enrollment.dart';
import '../../domain/entities/marathon_milestone.dart';

class MarathonEnrollmentModel extends MarathonEnrollment {
  const MarathonEnrollmentModel({
    required super.id,
    required super.classId,
    required super.userId,
    required super.userName,
    super.userPhotoUrl,
    required super.enrolledAt,
    super.totalAttendance,
    super.status,
    super.currentStreak,
    super.longestStreak,
    super.lastAttendedAt,
    super.unlockedMilestones,
  });

  factory MarathonEnrollmentModel.fromJson(Map<String, dynamic> json) {
    // Parse unlocked milestones from JSON
    List<MilestoneType> unlockedMilestones = [];
    if (json['unlocked_milestones'] != null) {
      unlockedMilestones = (json['unlocked_milestones'] as List<dynamic>)
          .map((e) => MilestoneType.values.firstWhere(
                (m) => m.name == e,
                orElse: () => MilestoneType.attendance7,
              ))
          .toList();
    }

    return MarathonEnrollmentModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhotoUrl: json['user_photo_url'] as String?,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      totalAttendance: json['total_attendance'] as int? ?? 0,
      status: EnrollmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EnrollmentStatus.active,
      ),
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastAttendedAt: json['last_attended_at'] != null
          ? DateTime.parse(json['last_attended_at'] as String)
          : null,
      unlockedMilestones: unlockedMilestones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'enrolled_at': enrolledAt.toIso8601String(),
      'total_attendance': totalAttendance,
      'status': status.name,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_attended_at': lastAttendedAt?.toIso8601String(),
      'unlocked_milestones': unlockedMilestones.map((m) => m.name).toList(),
    };
  }

  factory MarathonEnrollmentModel.fromEntity(MarathonEnrollment entity) {
    return MarathonEnrollmentModel(
      id: entity.id,
      classId: entity.classId,
      userId: entity.userId,
      userName: entity.userName,
      userPhotoUrl: entity.userPhotoUrl,
      enrolledAt: entity.enrolledAt,
      totalAttendance: entity.totalAttendance,
      status: entity.status,
      currentStreak: entity.currentStreak,
      longestStreak: entity.longestStreak,
      lastAttendedAt: entity.lastAttendedAt,
      unlockedMilestones: entity.unlockedMilestones,
    );
  }
}
