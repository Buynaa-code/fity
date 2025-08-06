import 'package:equatable/equatable.dart';

abstract class QREntryEvent extends Equatable {
  const QREntryEvent();

  @override
  List<Object> get props => [];
}

class ScanQRCode extends QREntryEvent {}

class CheckIn extends QREntryEvent {
  final String qrCode;

  const CheckIn(this.qrCode);

  @override
  List<Object> get props => [qrCode];
}

class CheckOut extends QREntryEvent {}

class ResetQREntry extends QREntryEvent {}