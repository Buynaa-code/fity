import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Check-in record model
class CheckInRecord {
  final String id;
  final String oderId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String gymId;
  final String gymName;
  final int? xpEarned;

  CheckInRecord({
    required this.id,
    required this.oderId,
    required this.checkInTime,
    this.checkOutTime,
    this.gymId = 'fitzone_main',
    this.gymName = 'FitZone Gym',
    this.xpEarned,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': oderId,
    'checkInTime': checkInTime.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'gymId': gymId,
    'gymName': gymName,
    'xpEarned': xpEarned,
  };

  factory CheckInRecord.fromJson(Map<String, dynamic> json) => CheckInRecord(
    id: json['id'],
    oderId: json['userId'],
    checkInTime: DateTime.parse(json['checkInTime']),
    checkOutTime: json['checkOutTime'] != null
        ? DateTime.parse(json['checkOutTime'])
        : null,
    gymId: json['gymId'] ?? 'fitzone_main',
    gymName: json['gymName'] ?? 'FitZone Gym',
    xpEarned: json['xpEarned'],
  );

  Duration? get duration {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
  }

  Duration get currentDuration => DateTime.now().difference(checkInTime);

  bool get isActive => checkOutTime == null;

  CheckInRecord copyWith({
    String? id,
    String? oderId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? gymId,
    String? gymName,
    int? xpEarned,
  }) {
    return CheckInRecord(
      id: id ?? this.id,
      oderId: oderId ?? this.oderId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }
}

/// Token-based QR code data for secure check-in
class QRTokenData {
  final String oderId;
  final String userName;
  final String token;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final int validitySeconds;

  QRTokenData({
    required this.oderId,
    required this.userName,
    required this.token,
    required this.generatedAt,
    required this.expiresAt,
    this.validitySeconds = 30,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  double get remainingProgress => remainingSeconds / validitySeconds;

  String toQRString() {
    final data = {
      'v': 2, // version
      'u': oderId,
      'n': userName,
      't': token,
      'ts': generatedAt.millisecondsSinceEpoch,
      'exp': expiresAt.millisecondsSinceEpoch,
    };
    return jsonEncode(data);
  }
}

/// Check-in statistics
class CheckInStats {
  final int totalCheckIns;
  final int currentStreak;
  final int bestStreak;
  final int thisMonthCheckIns;
  final int thisWeekCheckIns;
  final Duration totalDuration;
  final Duration averageDuration;
  final DateTime? lastCheckIn;

  CheckInStats({
    this.totalCheckIns = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.thisMonthCheckIns = 0,
    this.thisWeekCheckIns = 0,
    this.totalDuration = Duration.zero,
    this.averageDuration = Duration.zero,
    this.lastCheckIn,
  });
}

/// CheckInService - manages gym check-ins with secure token-based QR codes
class CheckInService {
  static const String _checkInsKey = 'gym_checkins';
  static const String _activeCheckInKey = 'active_checkin';
  static const String _statsKey = 'checkin_stats';
  static const String _streakKey = 'checkin_streak';
  static const int _tokenValiditySeconds = 30;

  // Secret key for token generation
  static const String _secretKey = 'FitZone_Secure_2024_CheckIn_Key';

  static CheckInService? _instance;
  static CheckInService get instance => _instance ??= CheckInService._();

  CheckInService._();

  /// Generate a secure time-based token for QR code
  QRTokenData generateSecureQRToken(String oderId, String? userName) {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(seconds: _tokenValiditySeconds));

    // Create simple hash-based token (without external crypto dependency)
    final tokenData = '$oderId:${now.millisecondsSinceEpoch}:$_secretKey';
    final token = _simpleHash(tokenData);

    return QRTokenData(
      oderId: oderId,
      userName: userName ?? 'User',
      token: token,
      generatedAt: now,
      expiresAt: expiresAt,
      validitySeconds: _tokenValiditySeconds,
    );
  }

  /// Simple hash function for token generation
  String _simpleHash(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      final char = input.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & 0xFFFFFFFF; // Convert to 32bit integer
    }
    // Convert to hex string and take first 16 chars
    final hexString = hash.abs().toRadixString(16).padLeft(16, '0');
    return hexString.substring(0, 16);
  }

  /// Get all check-in history
  Future<List<CheckInRecord>> getCheckInHistory({int? limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_checkInsKey);

    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    var records = jsonList
        .map((json) => CheckInRecord.fromJson(json))
        .toList()
      ..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

    if (limit != null && records.length > limit) {
      records = records.take(limit).toList();
    }

    return records;
  }

  /// Get active check-in if exists
  Future<CheckInRecord?> getActiveCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_activeCheckInKey);

    if (data == null) return null;
    return CheckInRecord.fromJson(jsonDecode(data));
  }

  /// Get active check-in by user ID (to prevent duplicate check-ins)
  Future<CheckInRecord?> getActiveCheckInByUserId(String userId) async {
    final history = await getCheckInHistory();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Find active check-in for this user from today
    for (final record in history) {
      if (record.oderId == userId &&
          record.isActive &&
          record.checkInTime.isAfter(todayStart)) {
        return record;
      }
    }
    return null;
  }

  /// Check in to gym
  Future<CheckInRecord> checkIn(
    String oderId, {
    String gymId = 'fitzone_main',
    String gymName = 'FitZone Gym',
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Calculate XP based on streak
    final stats = await getCheckInStats();
    int xpEarned = 10; // Base XP
    if (stats.currentStreak >= 7) xpEarned += 5;
    if (stats.currentStreak >= 30) xpEarned += 10;

    final record = CheckInRecord(
      id: '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}',
      oderId: oderId,
      checkInTime: DateTime.now(),
      gymId: gymId,
      gymName: gymName,
      xpEarned: xpEarned,
    );

    // Save as active check-in
    await prefs.setString(_activeCheckInKey, jsonEncode(record.toJson()));

    // Add to history
    final history = await getCheckInHistory();
    history.insert(0, record);
    await prefs.setString(
      _checkInsKey,
      jsonEncode(history.map((r) => r.toJson()).toList()),
    );

    // Update streak
    await _updateStreak();

    return record;
  }

  /// Check out from gym (current user's active session)
  Future<CheckInRecord?> checkOut() async {
    final prefs = await SharedPreferences.getInstance();
    final active = await getActiveCheckIn();

    if (active == null) return null;

    final updatedRecord = active.copyWith(
      checkOutTime: DateTime.now(),
    );

    // Clear active check-in
    await prefs.remove(_activeCheckInKey);

    // Update in history
    final history = await getCheckInHistory();
    final index = history.indexWhere((r) => r.id == active.id);
    if (index != -1) {
      history[index] = updatedRecord;
      await prefs.setString(
        _checkInsKey,
        jsonEncode(history.map((r) => r.toJson()).toList()),
      );
    }

    return updatedRecord;
  }

  /// Check out by record ID (for receptionist use)
  Future<CheckInRecord?> checkOutById(String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getCheckInHistory();

    final index = history.indexWhere((r) => r.id == recordId);
    if (index == -1) return null;

    final record = history[index];
    if (!record.isActive) return null; // Already checked out

    final updatedRecord = record.copyWith(
      checkOutTime: DateTime.now(),
    );

    history[index] = updatedRecord;
    await prefs.setString(
      _checkInsKey,
      jsonEncode(history.map((r) => r.toJson()).toList()),
    );

    // Also clear active check-in if this was the active one
    final active = await getActiveCheckIn();
    if (active?.id == recordId) {
      await prefs.remove(_activeCheckInKey);
    }

    return updatedRecord;
  }

  /// Calculate check-in statistics
  Future<CheckInStats> getCheckInStats() async {
    final history = await getCheckInHistory();

    if (history.isEmpty) {
      return CheckInStats();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    final startOfMonth = DateTime(now.year, now.month, 1);

    // Get unique check-in days
    final uniqueDays = <DateTime>{};
    for (final record in history) {
      uniqueDays.add(DateTime(
        record.checkInTime.year,
        record.checkInTime.month,
        record.checkInTime.day,
      ));
    }

    // Sort days descending (newest first)
    final sortedDays = uniqueDays.toList()..sort((a, b) => b.compareTo(a));

    // Calculate current streak
    int currentStreak = 0;
    int bestStreak = 0;

    if (sortedDays.isNotEmpty) {
      // Check if the most recent check-in was today or yesterday
      final mostRecentDay = sortedDays.first;

      if (mostRecentDay == today || mostRecentDay == yesterday) {
        // Start counting the streak from the most recent day
        currentStreak = 1;
        DateTime expectedDay = mostRecentDay.subtract(const Duration(days: 1));

        for (int i = 1; i < sortedDays.length; i++) {
          if (sortedDays[i] == expectedDay) {
            currentStreak++;
            expectedDay = expectedDay.subtract(const Duration(days: 1));
          } else if (sortedDays[i].isBefore(expectedDay)) {
            // Gap found, streak broken
            break;
          }
          // Skip duplicate days (same day)
        }
      }

      // Calculate best streak
      int tempStreak = 1;
      for (int i = 1; i < sortedDays.length; i++) {
        final diff = sortedDays[i - 1].difference(sortedDays[i]).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff > 1) {
          if (tempStreak > bestStreak) bestStreak = tempStreak;
          tempStreak = 1;
        }
        // diff == 0 means same day, skip
      }
      if (tempStreak > bestStreak) bestStreak = tempStreak;
    }

    // Ensure bestStreak is at least as high as currentStreak
    if (currentStreak > bestStreak) bestStreak = currentStreak;

    // Calculate durations
    Duration totalDuration = Duration.zero;
    int completedSessions = 0;
    for (final record in history) {
      if (record.duration != null) {
        totalDuration += record.duration!;
        completedSessions++;
      }
    }

    final averageDuration = completedSessions > 0
        ? Duration(milliseconds: totalDuration.inMilliseconds ~/ completedSessions)
        : Duration.zero;

    // Count by period
    final thisWeekCheckIns = history.where((r) =>
      r.checkInTime.isAfter(startOfWeek)).length;
    final thisMonthCheckIns = history.where((r) =>
      r.checkInTime.isAfter(startOfMonth)).length;

    return CheckInStats(
      totalCheckIns: history.length,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      thisMonthCheckIns: thisMonthCheckIns,
      thisWeekCheckIns: thisWeekCheckIns,
      totalDuration: totalDuration,
      averageDuration: averageDuration,
      lastCheckIn: history.isNotEmpty ? history.first.checkInTime : null,
    );
  }

  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = await getCheckInStats();
    await prefs.setInt(_streakKey, stats.currentStreak);
  }

  /// Clear all check-in data (for testing)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkInsKey);
    await prefs.remove(_activeCheckInKey);
    await prefs.remove(_statsKey);
    await prefs.remove(_streakKey);
  }
}
