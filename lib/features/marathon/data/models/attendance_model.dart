import '../../domain/entities/attendance.dart';

class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.id,
    required super.classId,
    required super.userId,
    required super.userName,
    super.userPhotoUrl,
    required super.date,
    required super.checkedInAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userPhotoUrl: json['user_photo_url'] as String?,
      date: DateTime.parse(json['date'] as String),
      checkedInAt: DateTime.parse(json['checked_in_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'date': date.toIso8601String(),
      'checked_in_at': checkedInAt.toIso8601String(),
    };
  }

  factory AttendanceModel.fromEntity(Attendance entity) {
    return AttendanceModel(
      id: entity.id,
      classId: entity.classId,
      userId: entity.userId,
      userName: entity.userName,
      userPhotoUrl: entity.userPhotoUrl,
      date: entity.date,
      checkedInAt: entity.checkedInAt,
    );
  }
}
