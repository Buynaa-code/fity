import 'package:equatable/equatable.dart';
import '../../domain/entities/marathon_class.dart';
import '../../domain/entities/marathon_enrollment.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/marathon_milestone.dart';

enum MarathonStatus {
  initial,
  loading,
  loaded,
  error,
  success,
}

/// Ангийн аналитик өгөгдөл
class ClassAnalytics extends Equatable {
  final Map<int, int> weeklyAttendance; // 0=өнөөдөр, 6=7 хоногийн өмнө
  final double averageAttendanceRate;
  final double todayAttendanceRate;
  final Map<EngagementLevel, int> engagementBreakdown;

  const ClassAnalytics({
    this.weeklyAttendance = const {},
    this.averageAttendanceRate = 0,
    this.todayAttendanceRate = 0,
    this.engagementBreakdown = const {},
  });

  @override
  List<Object?> get props => [
        weeklyAttendance,
        averageAttendanceRate,
        todayAttendanceRate,
        engagementBreakdown,
      ];
}

/// Гишүүний дэлгэрэнгүй мэдээлэл
class MemberDetail extends Equatable {
  final MarathonEnrollment enrollment;
  final List<DateTime> attendanceDates;

  const MemberDetail({
    required this.enrollment,
    this.attendanceDates = const [],
  });

  @override
  List<Object?> get props => [enrollment, attendanceDates];
}

/// Хэрэглэгчийн progress өгөгдөл
class UserProgress extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int totalAttendance;
  final double attendanceRate;
  final Map<DateTime, String> weeklyAttendance; // 7 хоногийн ирцийн статус
  final List<MarathonMilestone> milestones;

  const UserProgress({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalAttendance = 0,
    this.attendanceRate = 0,
    this.weeklyAttendance = const {},
    this.milestones = const [],
  });

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        totalAttendance,
        attendanceRate,
        weeklyAttendance,
        milestones,
      ];
}

class MarathonState extends Equatable {
  final MarathonStatus status;
  final List<MarathonClass> classes;
  final List<MarathonClass> myClasses;
  final List<MarathonClass> coachClasses;
  final MarathonClass? selectedClass;
  final List<MarathonEnrollment> enrollments;
  final List<Attendance> todayAttendance;
  final bool hasCheckedInToday;
  final String? errorMessage;
  final String? successMessage;
  final ClassAnalytics? analytics;
  final MemberDetail? selectedMember;
  final UserProgress? userProgress;
  final List<Attendance> attendanceHistory;
  final List<MilestoneType> newlyUnlockedMilestones; // For celebration
  final Map<String, Map<DateTime, String>> memberWeeklyAttendance; // userId -> 7 хоногийн ирц

  const MarathonState({
    this.status = MarathonStatus.initial,
    this.classes = const [],
    this.myClasses = const [],
    this.coachClasses = const [],
    this.selectedClass,
    this.enrollments = const [],
    this.todayAttendance = const [],
    this.hasCheckedInToday = false,
    this.errorMessage,
    this.successMessage,
    this.analytics,
    this.selectedMember,
    this.userProgress,
    this.attendanceHistory = const [],
    this.newlyUnlockedMilestones = const [],
    this.memberWeeklyAttendance = const {},
  });

  MarathonState copyWith({
    MarathonStatus? status,
    List<MarathonClass>? classes,
    List<MarathonClass>? myClasses,
    List<MarathonClass>? coachClasses,
    MarathonClass? selectedClass,
    List<MarathonEnrollment>? enrollments,
    List<Attendance>? todayAttendance,
    bool? hasCheckedInToday,
    String? errorMessage,
    String? successMessage,
    ClassAnalytics? analytics,
    MemberDetail? selectedMember,
    UserProgress? userProgress,
    List<Attendance>? attendanceHistory,
    List<MilestoneType>? newlyUnlockedMilestones,
    Map<String, Map<DateTime, String>>? memberWeeklyAttendance,
  }) {
    return MarathonState(
      status: status ?? this.status,
      classes: classes ?? this.classes,
      myClasses: myClasses ?? this.myClasses,
      coachClasses: coachClasses ?? this.coachClasses,
      selectedClass: selectedClass ?? this.selectedClass,
      enrollments: enrollments ?? this.enrollments,
      todayAttendance: todayAttendance ?? this.todayAttendance,
      hasCheckedInToday: hasCheckedInToday ?? this.hasCheckedInToday,
      errorMessage: errorMessage,
      successMessage: successMessage,
      analytics: analytics ?? this.analytics,
      selectedMember: selectedMember,
      userProgress: userProgress ?? this.userProgress,
      attendanceHistory: attendanceHistory ?? this.attendanceHistory,
      newlyUnlockedMilestones: newlyUnlockedMilestones ?? const [],
      memberWeeklyAttendance: memberWeeklyAttendance ?? this.memberWeeklyAttendance,
    );
  }

  @override
  List<Object?> get props => [
        status,
        classes,
        myClasses,
        coachClasses,
        selectedClass,
        enrollments,
        todayAttendance,
        hasCheckedInToday,
        errorMessage,
        successMessage,
        analytics,
        selectedMember,
        userProgress,
        attendanceHistory,
        newlyUnlockedMilestones,
        memberWeeklyAttendance,
      ];
}
