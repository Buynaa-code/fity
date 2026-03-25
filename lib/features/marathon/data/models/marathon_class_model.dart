import '../../domain/entities/marathon_class.dart';

class MarathonClassModel extends MarathonClass {
  const MarathonClassModel({
    required super.id,
    required super.coachId,
    required super.coachName,
    super.coachPhotoUrl,
    required super.title,
    super.description,
    required super.startTime,
    required super.endTime,
    required super.maxParticipants,
    super.participantIds,
    super.status,
    required super.createdAt,
    super.weekdays,
  });

  factory MarathonClassModel.fromJson(Map<String, dynamic> json) {
    return MarathonClassModel(
      id: json['id'] as String,
      coachId: json['coach_id'] as String,
      coachName: json['coach_name'] as String,
      coachPhotoUrl: json['coach_photo_url'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      maxParticipants: json['max_participants'] as int,
      participantIds: (json['participant_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: MarathonClassStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MarathonClassStatus.active,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      weekdays: (json['weekdays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coach_id': coachId,
      'coach_name': coachName,
      'coach_photo_url': coachPhotoUrl,
      'title': title,
      'description': description,
      'start_time': startTime,
      'end_time': endTime,
      'max_participants': maxParticipants,
      'participant_ids': participantIds,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'weekdays': weekdays,
    };
  }

  factory MarathonClassModel.fromEntity(MarathonClass entity) {
    return MarathonClassModel(
      id: entity.id,
      coachId: entity.coachId,
      coachName: entity.coachName,
      coachPhotoUrl: entity.coachPhotoUrl,
      title: entity.title,
      description: entity.description,
      startTime: entity.startTime,
      endTime: entity.endTime,
      maxParticipants: entity.maxParticipants,
      participantIds: entity.participantIds,
      status: entity.status,
      createdAt: entity.createdAt,
      weekdays: entity.weekdays,
    );
  }
}
