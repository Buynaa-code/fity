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
      await _repository.checkIn(
        classId: event.classId,
        userId: event.userId,
        userName: event.userName,
        userPhotoUrl: event.userPhotoUrl,
      );

      final todayAttendance = await _repository.getTodayAttendance(event.classId);

      emit(state.copyWith(
        status: MarathonStatus.success,
        todayAttendance: todayAttendance,
        hasCheckedInToday: true,
        successMessage: 'Ирц амжилттай бүртгэгдлээ!',
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

      emit(state.copyWith(
        status: MarathonStatus.loaded,
        selectedClass: marathonClass,
        enrollments: enrollments,
        todayAttendance: todayAttendance,
        hasCheckedInToday: hasCheckedInToday,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MarathonStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
