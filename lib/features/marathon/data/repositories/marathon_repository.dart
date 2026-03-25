import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/marathon_class_model.dart';
import '../models/marathon_enrollment_model.dart';
import '../models/attendance_model.dart';
import '../../domain/entities/marathon_class.dart';
import '../../domain/entities/marathon_enrollment.dart';
import '../../domain/entities/attendance.dart';

class MarathonRepository {
  static const String _classesKey = 'marathon_classes';
  static const String _enrollmentsKey = 'marathon_enrollments';
  static const String _attendanceKey = 'marathon_attendance';

  final SharedPreferences _prefs;

  MarathonRepository(this._prefs);

  // ============================================
  // MARATHON CLASSES
  // ============================================

  /// Бүх ангиудыг авах
  Future<List<MarathonClass>> getAllClasses() async {
    final jsonString = _prefs.getString(_classesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((json) => MarathonClassModel.fromJson(json))
        .where((c) => c.status == MarathonClassStatus.active)
        .toList();
  }

  /// Багшийн ангиудыг авах
  Future<List<MarathonClass>> getClassesByCoach(String coachId) async {
    final classes = await getAllClasses();
    return classes.where((c) => c.coachId == coachId).toList();
  }

  /// Тодорхой ангийг авах
  Future<MarathonClass?> getClassById(String classId) async {
    final classes = await getAllClasses();
    try {
      return classes.firstWhere((c) => c.id == classId);
    } catch (_) {
      return null;
    }
  }

  /// Шинэ анги үүсгэх
  Future<MarathonClass> createClass(MarathonClass marathonClass) async {
    final classes = await _getAllClassesRaw();
    final model = MarathonClassModel.fromEntity(marathonClass);
    classes.add(model);
    await _saveClasses(classes);
    return marathonClass;
  }

  /// Анги засах
  Future<MarathonClass> updateClass(MarathonClass marathonClass) async {
    final classes = await _getAllClassesRaw();
    final index = classes.indexWhere((c) => c.id == marathonClass.id);
    if (index != -1) {
      classes[index] = MarathonClassModel.fromEntity(marathonClass);
      await _saveClasses(classes);
    }
    return marathonClass;
  }

  /// Анги устгах (статусыг cancelled болгох)
  Future<void> deleteClass(String classId) async {
    final classes = await _getAllClassesRaw();
    final index = classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      final updated = classes[index].copyWith(
        status: MarathonClassStatus.cancelled,
      );
      classes[index] = MarathonClassModel.fromEntity(updated);
      await _saveClasses(classes);
    }
  }

  // ============================================
  // ENROLLMENTS
  // ============================================

  /// Хэрэглэгчийн элссэн ангиудыг авах
  Future<List<MarathonEnrollment>> getEnrollmentsByUser(String userId) async {
    final enrollments = await _getAllEnrollments();
    return enrollments
        .where((e) => e.userId == userId && e.status == EnrollmentStatus.active)
        .toList();
  }

  /// Ангийн оролцогчдыг авах
  Future<List<MarathonEnrollment>> getEnrollmentsByClass(String classId) async {
    final enrollments = await _getAllEnrollments();
    return enrollments
        .where((e) => e.classId == classId && e.status == EnrollmentStatus.active)
        .toList();
  }

  /// Анги руу элсэх
  Future<MarathonEnrollment> joinClass({
    required String classId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
  }) async {
    // Check if already enrolled
    final existing = await _getAllEnrollments();
    final alreadyEnrolled = existing.any(
      (e) =>
          e.classId == classId &&
          e.userId == userId &&
          e.status == EnrollmentStatus.active,
    );
    if (alreadyEnrolled) {
      throw Exception('Та аль хэдийн энэ анги руу бүртгүүлсэн байна');
    }

    // Check class capacity
    final marathonClass = await getClassById(classId);
    if (marathonClass == null) {
      throw Exception('Анги олдсонгүй');
    }
    if (!marathonClass.hasAvailableSpots) {
      throw Exception('Ангийн багтаамж дүүрсэн байна');
    }

    final enrollment = MarathonEnrollmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      classId: classId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      enrolledAt: DateTime.now(),
    );

    existing.add(enrollment);
    await _saveEnrollments(existing);

    // Update class participant count
    final updatedClass = marathonClass.copyWith(
      participantIds: [...marathonClass.participantIds, userId],
    );
    await updateClass(updatedClass);

    return enrollment;
  }

  /// Ангиас гарах
  Future<void> leaveClass(String classId, String userId) async {
    final enrollments = await _getAllEnrollments();
    final index = enrollments.indexWhere(
      (e) =>
          e.classId == classId &&
          e.userId == userId &&
          e.status == EnrollmentStatus.active,
    );

    if (index != -1) {
      final updated = enrollments[index].copyWith(status: EnrollmentStatus.dropped);
      enrollments[index] = MarathonEnrollmentModel.fromEntity(updated);
      await _saveEnrollments(enrollments);

      // Update class participant count
      final marathonClass = await getClassById(classId);
      if (marathonClass != null) {
        final updatedParticipants =
            marathonClass.participantIds.where((id) => id != userId).toList();
        await updateClass(marathonClass.copyWith(participantIds: updatedParticipants));
      }
    }
  }

  // ============================================
  // ATTENDANCE
  // ============================================

  /// Өнөөдрийн ирцийг авах
  Future<List<Attendance>> getTodayAttendance(String classId) async {
    final attendance = await _getAllAttendance();
    final now = DateTime.now();
    return attendance
        .where((a) =>
            a.classId == classId &&
            a.date.year == now.year &&
            a.date.month == now.month &&
            a.date.day == now.day)
        .toList();
  }

  /// Хэрэглэгчийн ирцийн түүхийг авах
  Future<List<Attendance>> getUserAttendance(String userId, String classId) async {
    final attendance = await _getAllAttendance();
    return attendance
        .where((a) => a.userId == userId && a.classId == classId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Өнөөдөр check-in хийсэн эсэх
  Future<bool> hasCheckedInToday(String userId, String classId) async {
    final todayAttendance = await getTodayAttendance(classId);
    return todayAttendance.any((a) => a.userId == userId);
  }

  /// Check-in хийх
  Future<Attendance> checkIn({
    required String classId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
  }) async {
    // Check if already checked in today
    final alreadyCheckedIn = await hasCheckedInToday(userId, classId);
    if (alreadyCheckedIn) {
      throw Exception('Та өнөөдөр аль хэдийн ирцээ бүртгүүлсэн байна');
    }

    final now = DateTime.now();
    final attendance = AttendanceModel(
      id: now.millisecondsSinceEpoch.toString(),
      classId: classId,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      date: DateTime(now.year, now.month, now.day),
      checkedInAt: now,
    );

    final allAttendance = await _getAllAttendance();
    allAttendance.add(attendance);
    await _saveAttendance(allAttendance);

    // Update enrollment attendance count
    await _incrementAttendanceCount(classId, userId);

    return attendance;
  }

  /// Ирцийн тоог нэмэх
  Future<void> _incrementAttendanceCount(String classId, String userId) async {
    final enrollments = await _getAllEnrollments();
    final index = enrollments.indexWhere(
      (e) =>
          e.classId == classId &&
          e.userId == userId &&
          e.status == EnrollmentStatus.active,
    );

    if (index != -1) {
      final updated = enrollments[index].copyWith(
        totalAttendance: enrollments[index].totalAttendance + 1,
      );
      enrollments[index] = MarathonEnrollmentModel.fromEntity(updated);
      await _saveEnrollments(enrollments);
    }
  }

  // ============================================
  // PRIVATE HELPERS
  // ============================================

  Future<List<MarathonClassModel>> _getAllClassesRaw() async {
    final jsonString = _prefs.getString(_classesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => MarathonClassModel.fromJson(json)).toList();
  }

  Future<void> _saveClasses(List<MarathonClassModel> classes) async {
    final jsonList = classes.map((c) => c.toJson()).toList();
    await _prefs.setString(_classesKey, json.encode(jsonList));
  }

  Future<List<MarathonEnrollmentModel>> _getAllEnrollments() async {
    final jsonString = _prefs.getString(_enrollmentsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => MarathonEnrollmentModel.fromJson(json)).toList();
  }

  Future<void> _saveEnrollments(List<MarathonEnrollmentModel> enrollments) async {
    final jsonList = enrollments.map((e) => e.toJson()).toList();
    await _prefs.setString(_enrollmentsKey, json.encode(jsonList));
  }

  Future<List<AttendanceModel>> _getAllAttendance() async {
    final jsonString = _prefs.getString(_attendanceKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => AttendanceModel.fromJson(json)).toList();
  }

  Future<void> _saveAttendance(List<AttendanceModel> attendance) async {
    final jsonList = attendance.map((a) => a.toJson()).toList();
    await _prefs.setString(_attendanceKey, json.encode(jsonList));
  }
}
