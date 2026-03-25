import 'package:equatable/equatable.dart';

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

  const MarathonEnrollment({
    required this.id,
    required this.classId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.enrolledAt,
    this.totalAttendance = 0,
    this.status = EnrollmentStatus.active,
  });

  MarathonEnrollment copyWith({
    String? id,
    String? classId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    DateTime? enrolledAt,
    int? totalAttendance,
    EnrollmentStatus? status,
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
      ];
}
