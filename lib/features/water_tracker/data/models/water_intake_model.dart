import '../../domain/entities/water_intake.dart';

class WaterIntakeModel extends WaterIntake {
  const WaterIntakeModel({
    required super.id,
    required super.amountMl,
    required super.timestamp,
  });

  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['id'] as String,
      amountMl: json['amountMl'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountMl': amountMl,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WaterIntakeModel.fromEntity(WaterIntake entity) {
    return WaterIntakeModel(
      id: entity.id,
      amountMl: entity.amountMl,
      timestamp: entity.timestamp,
    );
  }
}

class DailyWaterSummaryModel extends DailyWaterSummary {
  const DailyWaterSummaryModel({
    required super.date,
    required super.totalMl,
    required super.goalMl,
    required super.intakes,
  });

  factory DailyWaterSummaryModel.fromJson(Map<String, dynamic> json) {
    final intakesList = (json['intakes'] as List<dynamic>?)
            ?.map((e) => WaterIntakeModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DailyWaterSummaryModel(
      date: DateTime.parse(json['date'] as String),
      totalMl: json['totalMl'] as int? ?? 0,
      goalMl: json['goalMl'] as int? ?? 2000,
      intakes: intakesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': _dateOnly(date).toIso8601String(),
      'totalMl': totalMl,
      'goalMl': goalMl,
      'intakes': intakes
          .map((e) => WaterIntakeModel.fromEntity(e).toJson())
          .toList(),
    };
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
