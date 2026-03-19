import 'package:equatable/equatable.dart';
import '../../domain/entities/water_intake.dart';

enum WaterStatus { initial, loading, loaded, error }

class WaterState extends Equatable {
  final WaterStatus status;
  final DailyWaterSummary? dailySummary;
  final List<DailyWaterSummary> weeklySummary;
  final String? errorMessage;

  const WaterState({
    this.status = WaterStatus.initial,
    this.dailySummary,
    this.weeklySummary = const [],
    this.errorMessage,
  });

  WaterState copyWith({
    WaterStatus? status,
    DailyWaterSummary? dailySummary,
    List<DailyWaterSummary>? weeklySummary,
    String? errorMessage,
  }) {
    return WaterState(
      status: status ?? this.status,
      dailySummary: dailySummary ?? this.dailySummary,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, dailySummary, weeklySummary, errorMessage];
}
