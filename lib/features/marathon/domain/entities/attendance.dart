import 'package:equatable/equatable.dart';

/// Өдрийн ирцийн бүртгэл
class Attendance extends Equatable {
  final String id;
  final String classId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final DateTime date;
  final DateTime checkedInAt;

  const Attendance({
    required this.id,
    required this.classId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.date,
    required this.checkedInAt,
  });

  /// Өнөөдрийн ирц эсэх
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Цагийн форматтай текст
  String get timeDisplay {
    final hour = checkedInAt.hour.toString().padLeft(2, '0');
    final minute = checkedInAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Огнооны форматтай текст
  String get dateDisplay {
    final months = [
      'нэгдүгээр сар',
      'хоёрдугаар сар',
      'гуравдугаар сар',
      'дөрөвдүгээр сар',
      'тавдугаар сар',
      'зургаадугаар сар',
      'долдугаар сар',
      'наймдугаар сар',
      'есдүгээр сар',
      'аравдугаар сар',
      'арван нэгдүгээр сар',
      'арван хоёрдугаар сар',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  Attendance copyWith({
    String? id,
    String? classId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    DateTime? date,
    DateTime? checkedInAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      date: date ?? this.date,
      checkedInAt: checkedInAt ?? this.checkedInAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        classId,
        userId,
        userName,
        userPhotoUrl,
        date,
        checkedInAt,
      ];
}
