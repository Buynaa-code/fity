import 'package:equatable/equatable.dart';
import '../../domain/entities/marathon_class.dart';
import '../../domain/entities/marathon_enrollment.dart';
import '../../domain/entities/attendance.dart';

enum MarathonStatus {
  initial,
  loading,
  loaded,
  error,
  success,
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
      ];
}
