import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/marathon_class_model.dart';
import '../models/marathon_enrollment_model.dart';
import '../models/attendance_model.dart';
import '../../domain/entities/marathon_class.dart';
import '../../domain/entities/marathon_enrollment.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/marathon_milestone.dart';

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
  /// Returns: (Attendance, List<MilestoneType>) - Ирц ба шинээр unlock хийгдсэн milestone-ууд
  Future<(Attendance, List<MilestoneType>)> checkIn({
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

    // Update enrollment with attendance count, streak, and last attended
    // Also check for newly unlocked milestones
    final newlyUnlockedMilestones = await _updateEnrollmentOnCheckIn(classId, userId, now);

    return (attendance, newlyUnlockedMilestones);
  }

  /// Ирцийн тоо, streak, сүүлд ирсэн огноог шинэчлэх ба milestone шалгах
  /// Returns: Шинээр unlock хийгдсэн milestone-уудын жагсаалт
  Future<List<MilestoneType>> _updateEnrollmentOnCheckIn(
    String classId,
    String userId,
    DateTime checkInDate,
  ) async {
    final enrollments = await _getAllEnrollments();
    final index = enrollments.indexWhere(
      (e) =>
          e.classId == classId &&
          e.userId == userId &&
          e.status == EnrollmentStatus.active,
    );

    if (index != -1) {
      final enrollment = enrollments[index];

      // Streak тооцоолох (ангийн хуваарьт өдрүүдийг харгалзан)
      final marathonClass = await getClassById(classId);
      int newStreak = 1;

      if (enrollment.lastAttendedAt != null && marathonClass != null) {
        final scheduledWeekdays = marathonClass.weekdays;

        // Сүүлд ирсэн өдрөөс өнөөдрийн хоорондох хуваарьт өдрүүдийг тооцоолох
        DateTime checkDate = enrollment.lastAttendedAt!.add(const Duration(days: 1));
        final today = _dateOnly(checkInDate);
        bool missedScheduledDay = false;

        while (_dateOnly(checkDate).isBefore(today)) {
          if (scheduledWeekdays.contains(checkDate.weekday)) {
            // Хуваарьт өдөр байсан бол streak тасарна
            missedScheduledDay = true;
            break;
          }
          checkDate = checkDate.add(const Duration(days: 1));
        }

        if (!missedScheduledDay) {
          newStreak = enrollment.currentStreak + 1;
        }
      }

      // Хамгийн урт streak шинэчлэх
      final newLongestStreak = newStreak > enrollment.longestStreak
          ? newStreak
          : enrollment.longestStreak;

      final newTotalAttendance = enrollment.totalAttendance + 1;

      // Milestone шалгах
      final newlyUnlocked = await checkMilestones(
        userId,
        classId,
        newStreak,
        newTotalAttendance,
        enrollment.unlockedMilestones,
      );

      final updatedMilestones = [
        ...enrollment.unlockedMilestones,
        ...newlyUnlocked,
      ];

      final updated = enrollment.copyWith(
        totalAttendance: newTotalAttendance,
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
        lastAttendedAt: checkInDate,
        unlockedMilestones: updatedMilestones,
      );
      enrollments[index] = MarathonEnrollmentModel.fromEntity(updated);
      await _saveEnrollments(enrollments);

      return newlyUnlocked;
    }

    return [];
  }

  // ============================================
  // ANALYTICS
  // ============================================

  /// Долоо хоногийн ирцийн статистик
  Future<Map<int, int>> getWeeklyAttendanceStats(String classId) async {
    final attendance = await _getAllAttendance();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // 7 өдрийн ирцийг тоолох (өдөр бүрээр)
    final Map<int, int> dailyStats = {};
    for (int i = 0; i < 7; i++) {
      dailyStats[i] = 0;
    }

    for (final a in attendance) {
      if (a.classId == classId && a.date.isAfter(weekAgo)) {
        final daysAgo = now.difference(a.date).inDays;
        if (daysAgo >= 0 && daysAgo < 7) {
          dailyStats[daysAgo] = (dailyStats[daysAgo] ?? 0) + 1;
        }
      }
    }

    return dailyStats;
  }

  /// Ангийн дундаж ирцийн хувь
  Future<double> getClassAverageAttendanceRate(String classId) async {
    final enrollments = await getEnrollmentsByClass(classId);
    if (enrollments.isEmpty) return 0;

    double totalRate = 0;
    for (final e in enrollments) {
      totalRate += e.attendanceRate;
    }
    return totalRate / enrollments.length;
  }

  /// Хэрэглэгчийн ирцийн түүхийг бүрэн авах (сүүлийн 30 өдөр)
  Future<List<DateTime>> getMemberAttendanceDates(
    String userId,
    String classId,
  ) async {
    final attendance = await _getAllAttendance();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    return attendance
        .where((a) =>
            a.userId == userId &&
            a.classId == classId &&
            a.date.isAfter(thirtyDaysAgo))
        .map((a) => a.date)
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  /// Өнөөдрийн ирцийн хувь
  Future<double> getTodayAttendanceRate(String classId) async {
    final todayAttendance = await getTodayAttendance(classId);
    final enrollments = await getEnrollmentsByClass(classId);
    if (enrollments.isEmpty) return 0;
    return (todayAttendance.length / enrollments.length * 100);
  }

  /// Engagement түвшингээр ангилах
  Future<Map<EngagementLevel, int>> getEngagementBreakdown(String classId) async {
    final enrollments = await getEnrollmentsByClass(classId);
    final Map<EngagementLevel, int> breakdown = {
      EngagementLevel.excellent: 0,
      EngagementLevel.active: 0,
      EngagementLevel.atRisk: 0,
      EngagementLevel.inactive: 0,
    };

    for (final e in enrollments) {
      breakdown[e.engagementLevel] = (breakdown[e.engagementLevel] ?? 0) + 1;
    }

    return breakdown;
  }

  // ============================================
  // STREAK & MILESTONES
  // ============================================

  /// Streak тооцоолох (ангийн хуваарьт өдрүүдэд үндэслэсэн)
  Future<int> calculateStreak(String userId, String classId) async {
    final marathonClass = await getClassById(classId);
    if (marathonClass == null) return 0;

    final scheduledWeekdays = marathonClass.weekdays;
    final attendance = await getUserAttendance(userId, classId);
    if (attendance.isEmpty) return 0;

    // Ирцийн огноог set болгон хөрвүүлэх
    final attendedDates = attendance.map((a) => _dateOnly(a.date)).toSet();

    int streak = 0;
    DateTime checkDate = _dateOnly(DateTime.now());

    // Өнөөдрөөс эхлэн буцаан тооцоолох
    while (true) {
      final weekday = checkDate.weekday;

      // Хуваарьт өдөр мөн эсэх
      if (scheduledWeekdays.contains(weekday)) {
        if (attendedDates.contains(checkDate)) {
          streak++;
        } else {
          // Өнөөдөр бол алгасаж болно (дараа нь ирэх боломжтой)
          if (checkDate == _dateOnly(DateTime.now())) {
            checkDate = checkDate.subtract(const Duration(days: 1));
            continue;
          }
          break; // Алдсан хуваарьт өдөр
        }
      }

      checkDate = checkDate.subtract(const Duration(days: 1));

      // 120 өдрөөс илүү буцахгүй
      if (DateTime.now().difference(checkDate).inDays > 120) break;
    }

    return streak;
  }

  /// 7 хоногийн хэрэглэгчийн ирцийн харагдац (dots)
  /// Returns: Map<DateTime, AttendanceStatus> where:
  /// - 'attended' = ирсэн
  /// - 'missed' = алдсан (хуваарьт өдөр байсан)
  /// - 'future' = ирээдүй
  /// - 'not_scheduled' = хуваарьт бус өдөр
  Future<Map<DateTime, String>> getWeeklyAttendanceForUser(
    String userId,
    String classId,
  ) async {
    final marathonClass = await getClassById(classId);
    if (marathonClass == null) return {};

    final scheduledWeekdays = marathonClass.weekdays;
    final attendance = await getUserAttendance(userId, classId);
    final attendedDates = attendance.map((a) => _dateOnly(a.date)).toSet();

    final today = _dateOnly(DateTime.now());
    final Map<DateTime, String> weeklyStatus = {};

    // 7 өдрийг авах (өнөөдрөөс 3 өдрийн өмнө + өнөөдөр + 3 өдрийн дараа)
    for (int i = -3; i <= 3; i++) {
      final date = today.add(Duration(days: i));
      final weekday = date.weekday;

      if (!scheduledWeekdays.contains(weekday)) {
        weeklyStatus[date] = 'not_scheduled';
      } else if (date.isAfter(today)) {
        weeklyStatus[date] = 'future';
      } else if (attendedDates.contains(date)) {
        weeklyStatus[date] = 'attended';
      } else {
        weeklyStatus[date] = 'missed';
      }
    }

    return weeklyStatus;
  }

  /// Хэрэглэгчийн ирцийн бүрэн түүх (paginated)
  Future<List<Attendance>> getAttendanceHistory(
    String userId,
    String classId, {
    int limit = 30,
    int offset = 0,
  }) async {
    final attendance = await _getAllAttendance();
    final filtered = attendance
        .where((a) => a.userId == userId && a.classId == classId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (offset >= filtered.length) return [];
    final end = (offset + limit) > filtered.length ? filtered.length : offset + limit;
    return filtered.sublist(offset, end);
  }

  /// Milestone-уудыг шалгах ба шинээр unlock хийх
  Future<List<MilestoneType>> checkMilestones(
    String userId,
    String classId,
    int currentStreak,
    int totalAttendance,
    List<MilestoneType> alreadyUnlocked,
  ) async {
    final List<MilestoneType> newlyUnlocked = [];

    for (final milestone in MilestoneType.values) {
      // Аль хэдийн unlock хийгдсэн бол алгасах
      if (alreadyUnlocked.contains(milestone)) continue;

      bool shouldUnlock = false;

      if (milestone.isStreakMilestone) {
        shouldUnlock = currentStreak >= milestone.requiredStreak!;
      } else if (milestone.isAttendanceMilestone) {
        shouldUnlock = totalAttendance >= milestone.requiredAttendance!;
      }

      if (shouldUnlock) {
        newlyUnlocked.add(milestone);
      }
    }

    return newlyUnlocked;
  }

  /// Бүх milestone-уудыг progress-тэйгээр авах
  Future<List<MarathonMilestone>> getMilestones(
    String userId,
    String classId,
  ) async {
    final enrollments = await _getAllEnrollments();
    final enrollment = enrollments.firstWhere(
      (e) => e.userId == userId && e.classId == classId && e.status == EnrollmentStatus.active,
      orElse: () => throw Exception('Enrollment not found'),
    );

    final List<MarathonMilestone> milestones = [];

    for (final type in MilestoneType.values) {
      final isUnlocked = enrollment.unlockedMilestones.contains(type);
      double progress = 0.0;

      if (type.isStreakMilestone) {
        progress = (enrollment.currentStreak / type.requiredStreak!).clamp(0.0, 1.0);
      } else if (type.isAttendanceMilestone) {
        progress = (enrollment.totalAttendance / type.requiredAttendance!).clamp(0.0, 1.0);
      }

      milestones.add(MarathonMilestone(
        type: type,
        isUnlocked: isUnlocked,
        progress: isUnlocked ? 1.0 : progress,
      ));
    }

    return milestones;
  }

  /// Огноог цаг, минут, секундгүй болгох
  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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
