import 'package:equatable/equatable.dart';
import '../../domain/entities/marathon_class.dart';

abstract class MarathonEvent extends Equatable {
  const MarathonEvent();

  @override
  List<Object?> get props => [];
}

/// Бүх ангиудыг ачаалах
class LoadClasses extends MarathonEvent {
  const LoadClasses();
}

/// Багшийн ангиудыг ачаалах
class LoadCoachClasses extends MarathonEvent {
  final String coachId;

  const LoadCoachClasses(this.coachId);

  @override
  List<Object?> get props => [coachId];
}

/// Хэрэглэгчийн элссэн ангиудыг ачаалах
class LoadMyClasses extends MarathonEvent {
  final String userId;

  const LoadMyClasses(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Шинэ анги үүсгэх
class CreateClass extends MarathonEvent {
  final String coachId;
  final String coachName;
  final String? coachPhotoUrl;
  final String title;
  final String? description;
  final String startTime;
  final String endTime;
  final int maxParticipants;
  final List<int> weekdays;

  const CreateClass({
    required this.coachId,
    required this.coachName,
    this.coachPhotoUrl,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.maxParticipants,
    this.weekdays = const [1, 2, 3, 4, 5],
  });

  @override
  List<Object?> get props => [
        coachId,
        coachName,
        coachPhotoUrl,
        title,
        description,
        startTime,
        endTime,
        maxParticipants,
        weekdays,
      ];
}

/// Анги засах
class UpdateClass extends MarathonEvent {
  final MarathonClass marathonClass;

  const UpdateClass(this.marathonClass);

  @override
  List<Object?> get props => [marathonClass];
}

/// Анги устгах
class DeleteClass extends MarathonEvent {
  final String classId;

  const DeleteClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

/// Анги руу элсэх
class JoinClass extends MarathonEvent {
  final String classId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;

  const JoinClass({
    required this.classId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
  });

  @override
  List<Object?> get props => [classId, userId, userName, userPhotoUrl];
}

/// Ангиас гарах
class LeaveClass extends MarathonEvent {
  final String classId;
  final String userId;

  const LeaveClass({
    required this.classId,
    required this.userId,
  });

  @override
  List<Object?> get props => [classId, userId];
}

/// Check-in хийх
class CheckIn extends MarathonEvent {
  final String classId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;

  const CheckIn({
    required this.classId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
  });

  @override
  List<Object?> get props => [classId, userId, userName, userPhotoUrl];
}

/// Ангийн дэлгэрэнгүй мэдээллийг ачаалах
class LoadClassDetail extends MarathonEvent {
  final String classId;
  final String? currentUserId;

  const LoadClassDetail({
    required this.classId,
    this.currentUserId,
  });

  @override
  List<Object?> get props => [classId, currentUserId];
}
