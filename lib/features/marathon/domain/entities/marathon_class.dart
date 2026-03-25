import 'package:equatable/equatable.dart';

/// Марафон ангийн төлөв
enum MarathonClassStatus {
  active,
  cancelled,
  completed;

  String get displayName {
    switch (this) {
      case MarathonClassStatus.active:
        return 'Идэвхтэй';
      case MarathonClassStatus.cancelled:
        return 'Цуцлагдсан';
      case MarathonClassStatus.completed:
        return 'Дууссан';
    }
  }
}

/// Марафон анги - Багшийн үүсгэсэн бэлтгэл
class MarathonClass extends Equatable {
  final String id;
  final String coachId;
  final String coachName;
  final String? coachPhotoUrl;
  final String title;
  final String? description;
  final String startTime; // "06:00"
  final String endTime; // "08:00"
  final int maxParticipants;
  final List<String> participantIds;
  final MarathonClassStatus status;
  final DateTime createdAt;
  final List<int> weekdays; // 1=Monday, 7=Sunday

  const MarathonClass({
    required this.id,
    required this.coachId,
    required this.coachName,
    this.coachPhotoUrl,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    required this.maxParticipants,
    this.participantIds = const [],
    this.status = MarathonClassStatus.active,
    required this.createdAt,
    this.weekdays = const [1, 2, 3, 4, 5], // Default: Mon-Fri
  });

  /// Одоогийн оролцогчдын тоо
  int get currentParticipants => participantIds.length;

  /// Сул орон байгаа эсэх
  bool get hasAvailableSpots => currentParticipants < maxParticipants;

  /// Сул орны тоо
  int get availableSpots => maxParticipants - currentParticipants;

  /// Хэрэглэгч бүртгэлтэй эсэх
  bool isUserEnrolled(String userId) => participantIds.contains(userId);

  /// Цагийн форматтай текст
  String get timeDisplay => '$startTime - $endTime';

  /// Долоо хоногийн өдрүүдийн нэр
  String get weekdaysDisplay {
    const dayNames = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];
    return weekdays.map((d) => dayNames[d - 1]).join(', ');
  }

  MarathonClass copyWith({
    String? id,
    String? coachId,
    String? coachName,
    String? coachPhotoUrl,
    String? title,
    String? description,
    String? startTime,
    String? endTime,
    int? maxParticipants,
    List<String>? participantIds,
    MarathonClassStatus? status,
    DateTime? createdAt,
    List<int>? weekdays,
  }) {
    return MarathonClass(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      coachPhotoUrl: coachPhotoUrl ?? this.coachPhotoUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      weekdays: weekdays ?? this.weekdays,
    );
  }

  @override
  List<Object?> get props => [
        id,
        coachId,
        coachName,
        coachPhotoUrl,
        title,
        description,
        startTime,
        endTime,
        maxParticipants,
        participantIds,
        status,
        createdAt,
        weekdays,
      ];
}
