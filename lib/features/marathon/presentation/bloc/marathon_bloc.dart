import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/marathon_repository.dart';
import '../../domain/entities/marathon_class.dart';
import 'marathon_event.dart';
import 'marathon_state.dart';

class MarathonBloc extends Bloc<MarathonEvent, MarathonState> {
  final MarathonRepository _repository;

  MarathonBloc(this._repository) : super(const MarathonState()) {
    on<LoadClasses>(_onLoadClasses);
    on<LoadCoachClasses>(_onLoadCoachClasses);
    on<LoadMyClasses>(_onLoadMyClasses);
    on<CreateClass>(_onCreateClass);
    on<UpdateClass>(_onUpdateClass);
    on<DeleteClass>(_onDeleteClass);
    on<JoinClass>(_onJoinClass);
    on<LeaveClass>(_onLeaveClass);
    on<CheckIn>(_onCheckIn);
    on<LoadClassDetail>(_onLoadClassDetail);
    on<LoadMemberDetail>(_onLoadMemberDetail);
    on<ClearMemberDetail>(_onClearMemberDetail);
    on<LoadUserProgress>(_onLoadUserProgress);
    on<LoadAttendanceHistory>(_onLoadAttendanceHistory);
    on<ClearMilestoneCelebration>(_onClearMilestoneCelebration);
  }

  Future<void> _onLoadClasses(
    LoadClasses event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      final classes = await _repository.getAllClasses();
      emit(state.copyWith(
        status: MarathonStatus.loaded,
        classes: classes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadCoachClasses(
    LoadCoachClasses event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      final classes = await _repository.getClassesByCoach(event.coachId);
      emit(state.copyWith(
        status: MarathonStatus.loaded,
        coachClasses: classes,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMyClasses(
    LoadMyClasses event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      final enrollments = await _repository.getEnrollmentsByUser(event.userId);
      final allClasses = await _repository.getAllClasses();

      final myClasses = allClasses.where((c) {
        return enrollments.any((e) => e.classId == c.id);
      }).toList();

      emit(state.copyWith(
        status: MarathonStatus.loaded,
        myClasses: myClasses,
        enrollments: enrollments,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateClass(
    CreateClass event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      final newClass = MarathonClass(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        coachId: event.coachId,
        coachName: event.coachName,
        coachPhotoUrl: event.coachPhotoUrl,
        title: event.title,
        description: event.description,
        startTime: event.startTime,
        endTime: event.endTime,
        maxParticipants: event.maxParticipants,
        weekdays: event.weekdays,
        createdAt: DateTime.now(),
      );

      await _repository.createClass(newClass);
      final classes = await _repository.getClassesByCoach(event.coachId);

      emit(state.copyWith(
        status: MarathonStatus.success,
        coachClasses: classes,
        successMessage: 'Анги амжилттай үүслээ!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateClass(
    UpdateClass event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      await _repository.updateClass(event.marathonClass);
      final classes = await _repository.getClassesByCoach(event.marathonClass.coachId);

      emit(state.copyWith(
        status: MarathonStatus.success,
        coachClasses: classes,
        successMessage: 'Анги амжилттай шинэчлэгдлээ!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteClass(
    DeleteClass event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      await _repository.deleteClass(event.classId);

      final updatedClasses =
          state.coachClasses.where((c) => c.id != event.classId).toList();

      emit(state.copyWith(
        status: MarathonStatus.success,
        coachClasses: updatedClasses,
        successMessage: 'Анги амжилттай устгагдлаа!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onJoinClass(
    JoinClass event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      await _repository.joinClass(
        classId: event.classId,
        userId: event.userId,
        userName: event.userName,
        userPhotoUrl: event.userPhotoUrl,
      );

      // Reload all classes and my classes
      final allClasses = await _repository.getAllClasses();
      final enrollments = await _repository.getEnrollmentsByUser(event.userId);
      final myClasses = allClasses.where((c) {
        return enrollments.any((e) => e.classId == c.id);
      }).toList();

      emit(state.copyWith(
        status: MarathonStatus.success,
        classes: allClasses,
        myClasses: myClasses,
        enrollments: enrollments,
        successMessage: 'Анги руу амжилттай элслээ!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLeaveClass(
    LeaveClass event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      await _repository.leaveClass(event.classId, event.userId);

      // Reload my classes
      final enrollments = await _repository.getEnrollmentsByUser(event.userId);
      final allClasses = await _repository.getAllClasses();
      final myClasses = allClasses.where((c) {
        return enrollments.any((e) => e.classId == c.id);
      }).toList();

      emit(state.copyWith(
        status: MarathonStatus.success,
        classes: allClasses,
        myClasses: myClasses,
        enrollments: enrollments,
        successMessage: 'Ангиас амжилттай гарлаа!',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCheckIn(
    CheckIn event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      final (_, newlyUnlockedMilestones) = await _repository.checkIn(
        classId: event.classId,
        userId: event.userId,
        userName: event.userName,
        userPhotoUrl: event.userPhotoUrl,
      );

      final todayAttendance = await _repository.getTodayAttendance(event.classId);

      // User progress-ийг шинэчлэх
      final enrollments = await _repository.getEnrollmentsByClass(event.classId);
      final userEnrollment = enrollments.firstWhere(
        (e) => e.userId == event.userId,
        orElse: () => enrollments.first,
      );

      final weeklyAttendance = await _repository.getWeeklyAttendanceForUser(
        event.userId,
        event.classId,
      );
      final milestones = await _repository.getMilestones(event.userId, event.classId);

      final userProgress = UserProgress(
        currentStreak: userEnrollment.currentStreak,
        longestStreak: userEnrollment.longestStreak,
        totalAttendance: userEnrollment.totalAttendance,
        attendanceRate: userEnrollment.attendanceRate,
        weeklyAttendance: weeklyAttendance,
        milestones: milestones,
      );

      String successMessage = 'Ирц амжилттай бүртгэгдлээ!';
      if (newlyUnlockedMilestones.isNotEmpty) {
        successMessage = 'Ирц бүртгэгдлээ! Шинэ milestone: ${newlyUnlockedMilestones.first.title}';
      }

      emit(state.copyWith(
        status: MarathonStatus.success,
        todayAttendance: todayAttendance,
        hasCheckedInToday: true,
        enrollments: enrollments,
        userProgress: userProgress,
        newlyUnlockedMilestones: newlyUnlockedMilestones,
        successMessage: successMessage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadClassDetail(
    LoadClassDetail event,
    Emitter<MarathonState> emit,
  ) async {
    emit(state.copyWith(status: MarathonStatus.loading));
    try {
      final marathonClass = await _repository.getClassById(event.classId);
      final enrollments = await _repository.getEnrollmentsByClass(event.classId);
      final todayAttendance = await _repository.getTodayAttendance(event.classId);

      bool hasCheckedInToday = false;
      if (event.currentUserId != null) {
        hasCheckedInToday = await _repository.hasCheckedInToday(
          event.currentUserId!,
          event.classId,
        );
      }

      // Аналитик өгөгдлийг ачаалах
      final weeklyAttendance = await _repository.getWeeklyAttendanceStats(event.classId);
      final averageRate = await _repository.getClassAverageAttendanceRate(event.classId);
      final todayRate = await _repository.getTodayAttendanceRate(event.classId);
      final engagementBreakdown = await _repository.getEngagementBreakdown(event.classId);

      final analytics = ClassAnalytics(
        weeklyAttendance: weeklyAttendance,
        averageAttendanceRate: averageRate,
        todayAttendanceRate: todayRate,
        engagementBreakdown: engagementBreakdown,
      );

      // Гишүүн бүрийн 7 хоногийн ирцийг татах
      final memberWeeklyAttendance = <String, Map<DateTime, String>>{};
      for (final enrollment in enrollments) {
        final weekly = await _repository.getWeeklyAttendanceForUser(
          enrollment.userId,
          event.classId,
        );
        memberWeeklyAttendance[enrollment.userId] = weekly;
      }

      emit(state.copyWith(
        status: MarathonStatus.loaded,
        selectedClass: marathonClass,
        enrollments: enrollments,
        todayAttendance: todayAttendance,
        hasCheckedInToday: hasCheckedInToday,
        analytics: analytics,
        memberWeeklyAttendance: memberWeeklyAttendance,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMemberDetail(
    LoadMemberDetail event,
    Emitter<MarathonState> emit,
  ) async {
    try {
      // Гишүүний бүртгэлийг олох
      final enrollment = state.enrollments.firstWhere(
        (e) => e.userId == event.userId,
      );

      // Ирцийн түүхийг авах
      final attendanceDates = await _repository.getMemberAttendanceDates(
        event.userId,
        event.classId,
      );

      emit(state.copyWith(
        selectedMember: MemberDetail(
          enrollment: enrollment,
          attendanceDates: attendanceDates,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearMemberDetail(
    ClearMemberDetail event,
    Emitter<MarathonState> emit,
  ) {
    emit(state.copyWith(selectedMember: null));
  }

  Future<void> _onLoadUserProgress(
    LoadUserProgress event,
    Emitter<MarathonState> emit,
  ) async {
    try {
      final enrollments = await _repository.getEnrollmentsByUser(event.userId);
      final enrollment = enrollments.firstWhere(
        (e) => e.classId == event.classId,
        orElse: () => throw Exception('Enrollment not found'),
      );

      final weeklyAttendance = await _repository.getWeeklyAttendanceForUser(
        event.userId,
        event.classId,
      );
      final milestones = await _repository.getMilestones(event.userId, event.classId);

      final userProgress = UserProgress(
        currentStreak: enrollment.currentStreak,
        longestStreak: enrollment.longestStreak,
        totalAttendance: enrollment.totalAttendance,
        attendanceRate: enrollment.attendanceRate,
        weeklyAttendance: weeklyAttendance,
        milestones: milestones,
      );

      emit(state.copyWith(userProgress: userProgress));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadAttendanceHistory(
    LoadAttendanceHistory event,
    Emitter<MarathonState> emit,
  ) async {
    try {
      final history = await _repository.getAttendanceHistory(
        event.userId,
        event.classId,
        limit: event.limit,
        offset: event.offset,
      );

      emit(state.copyWith(
        attendanceHistory: event.offset == 0
            ? history
            : [...state.attendanceHistory, ...history],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClearMilestoneCelebration(
    ClearMilestoneCelebration event,
    Emitter<MarathonState> emit,
  ) {
    emit(state.copyWith(newlyUnlockedMilestones: const []));
  }
}
