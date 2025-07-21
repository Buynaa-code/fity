import 'package:flutter_bloc/flutter_bloc.dart';
import 'qr_entry_event.dart';
import 'qr_entry_state.dart';

class QREntryBloc extends Bloc<QREntryEvent, QREntryState> {
  DateTime? _checkInTime;

  QREntryBloc() : super(QREntryInitial()) {
    on<ScanQRCode>(_onScanQRCode);
    on<CheckIn>(_onCheckIn);
    on<CheckOut>(_onCheckOut);
    on<ResetQREntry>(_onResetQREntry);
  }

  Future<void> _onScanQRCode(ScanQRCode event, Emitter<QREntryState> emit) async {
    emit(QREntryScanning());
    
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      const mockQRCode = 'GYM_001_FLOOR_1';
      add(CheckIn(mockQRCode));
      
    } catch (e) {
      emit(QREntryError('Failed to scan QR code: $e'));
    }
  }

  Future<void> _onCheckIn(CheckIn event, Emitter<QREntryState> emit) async {
    try {
      _checkInTime = DateTime.now();
      
      emit(QREntryCheckedIn(
        checkInTime: _checkInTime!,
        gymName: 'Fity Gym',
      ));
      
    } catch (e) {
      emit(QREntryError('Failed to check in: $e'));
    }
  }

  Future<void> _onCheckOut(CheckOut event, Emitter<QREntryState> emit) async {
    try {
      final checkOutTime = DateTime.now();
      final sessionDuration = _checkInTime != null 
        ? checkOutTime.difference(_checkInTime!)
        : Duration.zero;
      
      emit(QREntryCheckedOut(
        checkOutTime: checkOutTime,
        sessionDuration: sessionDuration,
      ));
      
      _checkInTime = null;
      
    } catch (e) {
      emit(QREntryError('Failed to check out: $e'));
    }
  }

  Future<void> _onResetQREntry(ResetQREntry event, Emitter<QREntryState> emit) async {
    _checkInTime = null;
    emit(QREntryInitial());
  }
}