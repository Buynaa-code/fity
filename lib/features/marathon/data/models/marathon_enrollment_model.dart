import '../../domain/entities/marathon_enrollment.dart';

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
  });

  factory MarathonEnrollmentModel.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
