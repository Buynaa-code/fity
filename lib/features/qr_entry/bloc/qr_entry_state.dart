import 'package:equatable/equatable.dart';

enum QREntryStatus { initial, scanning, checkedIn, checkedOut, error }

abstract class QREntryState extends Equatable {
  const QREntryState();

  @override
  List<Object> get props => [];
}

class QREntryInitial extends QREntryState {}

class QREntryScanning extends QREntryState {}

class QREntryCheckedIn extends QREntryState {
  final DateTime checkInTime;
  final String? gymName;

  const QREntryCheckedIn({
    required this.checkInTime,
    this.gymName,
  });

  @override
  List<Object> get props => [checkInTime, gymName ?? ''];
}

class QREntryCheckedOut extends QREntryState {
  final DateTime checkOutTime;
  final Duration sessionDuration;

  const QREntryCheckedOut({
    required this.checkOutTime,
    required this.sessionDuration,
  });

  @override
  List<Object> get props => [checkOutTime, sessionDuration];
}

class QREntryError extends QREntryState {
  final String message;

  const QREntryError(this.message);

  @override
  List<Object> get props => [message];
}