import 'dart:async';
import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  static const List<HealthDataType> _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  Timer? _watchTimer;
  final StreamController<int> _stepsController = StreamController<int>.broadcast();

  Future<bool> requestPermissions() async {
    try {
      final hasPermissions = await _health.hasPermissions(_readTypes);
      if (hasPermissions == true) {
        return true;
      }

      final granted = await _health.requestAuthorization(_readTypes);
      return granted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    try {
      final result = await _health.hasPermissions(_readTypes);
      return result == true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getTodaySteps() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getTodayActiveCalories() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: now,
      );

      double totalCalories = 0;
      for (final data in healthData) {
        if (data.value is NumericHealthValue) {
          totalCalories += (data.value as NumericHealthValue).numericValue;
        }
      }

      return totalCalories;
    } catch (e) {
      return 0;
    }
  }

  Stream<int> watchSteps({Duration interval = const Duration(seconds: 30)}) {
    _startWatching(interval);
    return _stepsController.stream;
  }

  void _startWatching(Duration interval) {
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(interval, (_) async {
      final steps = await getTodaySteps();
      if (!_stepsController.isClosed) {
        _stepsController.add(steps);
      }
    });
  }

  void stopWatching() {
    _watchTimer?.cancel();
    _watchTimer = null;
  }

  void dispose() {
    stopWatching();
    _stepsController.close();
  }
}
