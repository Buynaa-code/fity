import 'dart:async';
import 'dart:math';

/// Gym occupancy level enum
enum OccupancyLevel {
  low,      // 0-40%
  moderate, // 40-70%
  busy,     // 70-90%
  full,     // 90-100%
}

/// Gym occupancy data model
class GymOccupancy {
  final int currentCount;
  final int maxCapacity;
  final DateTime lastUpdated;
  final String gymId;
  final String gymName;
  final Map<String, int>? areaBreakdown; // Optional breakdown by area

  GymOccupancy({
    required this.currentCount,
    required this.maxCapacity,
    required this.lastUpdated,
    this.gymId = 'fitzone_main',
    this.gymName = 'FitZone Gym',
    this.areaBreakdown,
  });

  double get percentage => maxCapacity > 0 ? (currentCount / maxCapacity).clamp(0.0, 1.0) : 0.0;

  int get percentageInt => (percentage * 100).round();

  OccupancyLevel get level {
    if (percentage < 0.4) return OccupancyLevel.low;
    if (percentage < 0.7) return OccupancyLevel.moderate;
    if (percentage < 0.9) return OccupancyLevel.busy;
    return OccupancyLevel.full;
  }

  String get levelText {
    switch (level) {
      case OccupancyLevel.low:
        return 'Сул';
      case OccupancyLevel.moderate:
        return 'Дунд';
      case OccupancyLevel.busy:
        return 'Түгжрэлтэй';
      case OccupancyLevel.full:
        return 'Дүүрсэн';
    }
  }

  String get recommendation {
    switch (level) {
      case OccupancyLevel.low:
        return 'Одоо очвол сайн!';
      case OccupancyLevel.moderate:
        return 'Хэвийн ачаалалтай';
      case OccupancyLevel.busy:
        return 'Хүлээх магадлалтай';
      case OccupancyLevel.full:
        return 'Дараа очихыг санал болгоно';
    }
  }

  int get availableSpots => maxCapacity - currentCount;

  String get timeSinceUpdate {
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inSeconds < 60) return 'Дөнгөж сая';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин өмнө';
    return '${diff.inHours} цагийн өмнө';
  }

  GymOccupancy copyWith({
    int? currentCount,
    int? maxCapacity,
    DateTime? lastUpdated,
    String? gymId,
    String? gymName,
    Map<String, int>? areaBreakdown,
  }) {
    return GymOccupancy(
      currentCount: currentCount ?? this.currentCount,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      areaBreakdown: areaBreakdown ?? this.areaBreakdown,
    );
  }
}

/// Gym occupancy service - manages real-time gym capacity data
class GymOccupancyService {
  static GymOccupancyService? _instance;
  static GymOccupancyService get instance => _instance ??= GymOccupancyService._();

  GymOccupancyService._();

  final _controller = StreamController<GymOccupancy>.broadcast();
  Stream<GymOccupancy> get occupancyStream => _controller.stream;

  Timer? _updateTimer;
  GymOccupancy? _currentOccupancy;

  GymOccupancy? get currentOccupancy => _currentOccupancy;

  /// Start listening to occupancy updates
  void startListening() {
    // Initial fetch
    _fetchOccupancy();

    // Set up periodic updates (every 30 seconds)
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchOccupancy();
    });
  }

  /// Stop listening to updates
  void stopListening() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Fetch current occupancy (simulated for now)
  Future<GymOccupancy> _fetchOccupancy() async {
    // TODO: Replace with actual API call
    // Simulating realistic gym occupancy based on time of day
    final now = DateTime.now();
    final hour = now.hour;

    int baseCount;
    if (hour >= 6 && hour < 9) {
      // Morning rush
      baseCount = 45 + Random().nextInt(25);
    } else if (hour >= 9 && hour < 12) {
      // Late morning
      baseCount = 30 + Random().nextInt(20);
    } else if (hour >= 12 && hour < 14) {
      // Lunch time
      baseCount = 40 + Random().nextInt(20);
    } else if (hour >= 17 && hour < 20) {
      // Evening rush
      baseCount = 60 + Random().nextInt(30);
    } else if (hour >= 20 && hour < 22) {
      // Late evening
      baseCount = 35 + Random().nextInt(20);
    } else if (hour >= 22 || hour < 6) {
      // Night/closed
      baseCount = 5 + Random().nextInt(10);
    } else {
      // Afternoon
      baseCount = 25 + Random().nextInt(15);
    }

    _currentOccupancy = GymOccupancy(
      currentCount: baseCount,
      maxCapacity: 100,
      lastUpdated: now,
      areaBreakdown: {
        'Кардио': (baseCount * 0.3).round(),
        'Хүчний': (baseCount * 0.4).round(),
        'Чөлөөт': (baseCount * 0.2).round(),
        'Студи': (baseCount * 0.1).round(),
      },
    );

    _controller.add(_currentOccupancy!);
    return _currentOccupancy!;
  }

  /// Force refresh occupancy data
  Future<GymOccupancy> refresh() async {
    return _fetchOccupancy();
  }

  /// Get peak hours prediction for today
  List<Map<String, dynamic>> getPeakHoursPrediction() {
    final dayOfWeek = DateTime.now().weekday;
    final isWeekend = dayOfWeek == 6 || dayOfWeek == 7;

    if (isWeekend) {
      return [
        {'hour': '10:00', 'level': 0.5, 'label': 'Дунд'},
        {'hour': '11:00', 'level': 0.65, 'label': 'Дунд'},
        {'hour': '12:00', 'level': 0.55, 'label': 'Дунд'},
        {'hour': '14:00', 'level': 0.45, 'label': 'Сул'},
        {'hour': '16:00', 'level': 0.6, 'label': 'Дунд'},
      ];
    }

    return [
      {'hour': '06:00', 'level': 0.6, 'label': 'Дунд'},
      {'hour': '07:00', 'level': 0.75, 'label': 'Түгжрэл'},
      {'hour': '08:00', 'level': 0.8, 'label': 'Түгжрэл'},
      {'hour': '12:00', 'level': 0.65, 'label': 'Дунд'},
      {'hour': '17:00', 'level': 0.85, 'label': 'Түгжрэл'},
      {'hour': '18:00', 'level': 0.9, 'label': 'Дүүрсэн'},
      {'hour': '19:00', 'level': 0.85, 'label': 'Түгжрэл'},
    ];
  }

  /// Get best time to visit suggestion
  String getBestTimeToVisit() {
    final dayOfWeek = DateTime.now().weekday;
    final isWeekend = dayOfWeek == 6 || dayOfWeek == 7;
    final hour = DateTime.now().hour;

    if (isWeekend) {
      if (hour < 10) return '14:00 - 16:00';
      if (hour < 14) return '14:00 - 16:00';
      return 'Маргааш өглөө';
    }

    if (hour < 6) return '09:00 - 11:00';
    if (hour < 9) return '09:00 - 11:00';
    if (hour < 12) return '14:00 - 16:00';
    if (hour < 17) return 'Одоо очвол сайн!';
    if (hour < 20) return '20:00 - 21:00';
    return 'Маргааш өглөө';
  }

  void dispose() {
    stopListening();
    _controller.close();
  }
}
