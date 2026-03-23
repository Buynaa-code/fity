import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

class WorkoutTimerScreen extends StatefulWidget {
  final String? exerciseName;
  final int? targetSets;
  final int? targetReps;
  final int? restSeconds;

  const WorkoutTimerScreen({
    super.key,
    this.exerciseName,
    this.targetSets,
    this.targetReps,
    this.restSeconds,
  });

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  int _seconds = 0;
  int _currentSet = 1;
  int _totalSets = 3;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _isResting = false;
  int _restCountdown = 0;

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  // Урам зоригийн үгс
  final List<String> _motivationalQuotes = [
    '💪 Чамд хүч байна!',
    '🔥 Шатаж байна!',
    '⚡ Зогсолтгүй!',
    '🎯 Зорилгодоо ойртож байна!',
    '🏆 Champion mindset!',
    '💯 Бүх зүйл боломжтой!',
  ];

  String _currentQuote = '';

  @override
  void initState() {
    super.initState();
    _totalSets = widget.targetSets ?? 3;
    _currentQuote = _motivationalQuotes[0];

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        // Урам зоригийн үг солих
        if (_seconds % 30 == 0) {
          _currentQuote = _motivationalQuotes[
              math.Random().nextInt(_motivationalQuotes.length)];
        }
      });
    });
  }

  void _pauseTimer() {
    HapticFeedback.lightImpact();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _resumeTimer() {
    HapticFeedback.lightImpact();
    _startTimer();
  }

  void _startRest() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isResting = true;
      _restCountdown = widget.restSeconds ?? 60;
    });
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restCountdown--;
        if (_restCountdown <= 0) {
          _isResting = false;
          _currentSet++;
          if (_currentSet <= _totalSets) {
            _startTimer();
          } else {
            _finishWorkout();
          }
          timer.cancel();
        }
      });
    });
  }

  void _completeSet() {
    HapticFeedback.heavyImpact();
    _timer?.cancel();

    if (_currentSet < _totalSets) {
      _startRest();
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    HapticFeedback.heavyImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) => _buildCompletionSheet(),
    );
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    setState(() {
      _seconds = 0;
      _currentSet = 1;
      _isRunning = false;
      _isPaused = false;
      _isResting = false;
    });
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isResting ? _buildRestView() : _buildWorkoutView(),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exerciseName ?? 'Дасгал',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Багц $_currentSet / $_totalSets',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Set progress indicator
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _currentSet / _totalSets,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFFFE7409)),
                  strokeWidth: 4,
                ),
                Text(
                  '$_currentSet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Урам зориг
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _currentQuote,
            key: ValueKey(_currentQuote),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 40),

        // Timer circle
        ScaleTransition(
          scale: _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isRunning
                    ? [const Color(0xFF1ABC9C), const Color(0xFF16A085)]
                    : _isPaused
                        ? [const Color(0xFFF39C12), const Color(0xFFE67E22)]
                        : [const Color(0xFF6C5CE7), const Color(0xFF5B4ED6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isRunning
                          ? const Color(0xFF1ABC9C)
                          : _isPaused
                              ? const Color(0xFFF39C12)
                              : const Color(0xFF6C5CE7))
                      .withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                ),
                // Inner content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_seconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Rubik',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _isRunning
                            ? 'Идэвхтэй'
                            : _isPaused
                                ? 'Түр зогссон'
                                : 'Бэлэн',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 50),

        // Stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem(
              Icons.local_fire_department_rounded,
              '${(_seconds * 0.15).toInt()}',
              'kcal',
              const Color(0xFFE74C3C),
            ),
            const SizedBox(width: 40),
            _buildStatItem(
              Icons.favorite_rounded,
              '${120 + (_isRunning ? 30 : 0)}',
              'bpm',
              const Color(0xFFE91E63),
            ),
            const SizedBox(width: 40),
            _buildStatItem(
              Icons.timer_rounded,
              '$_currentSet/$_totalSets',
              'багц',
              const Color(0xFFFE7409),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRestView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '😮‍💨 Амраарай',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Дараагийн багц: ${_currentSet + 1}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 40),

        // Rest countdown
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3498DB).withValues(alpha: 0.4),
                blurRadius: 40,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _restCountdown / (widget.restSeconds ?? 60),
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_restCountdown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'секунд',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Skip rest button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _timer?.cancel();
            setState(() {
              _isResting = false;
              _currentSet++;
              if (_currentSet <= _totalSets) {
                _startTimer();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.skip_next_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Алгасах',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    if (_isResting) return const SizedBox(height: 100);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Main controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Reset button
              GestureDetector(
                onTap: _resetTimer,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              // Main play/pause button
              GestureDetector(
                onTap: () {
                  if (!_isRunning && !_isPaused) {
                    _startTimer();
                  } else if (_isRunning) {
                    _pauseTimer();
                  } else {
                    _resumeTimer();
                  }
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isRunning
                          ? [const Color(0xFFF39C12), const Color(0xFFE67E22)]
                          : [const Color(0xFF1ABC9C), const Color(0xFF16A085)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (_isRunning
                                ? const Color(0xFFF39C12)
                                : const Color(0xFF1ABC9C))
                            .withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
              ),

              // Complete set button
              GestureDetector(
                onTap: _seconds > 0 ? _completeSet : null,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _seconds > 0
                        ? const Color(0xFFFE7409).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _seconds > 0
                          ? const Color(0xFFFE7409)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: _seconds > 0
                        ? const Color(0xFFFE7409)
                        : Colors.white.withValues(alpha: 0.3),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Complete workout button
          if (_seconds > 0)
            GestureDetector(
              onTap: _finishWorkout,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFE7409), Color(0xFFFF9149)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFE7409).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Дасгал дуусгах',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionSheet() {
    final caloriesBurned = (_seconds * 0.15).toInt();

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Trophy icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Баяр хүргэе! 🎉',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '${widget.exerciseName ?? 'Дасгал'} амжилттай дууслаа',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCompletionStat(
                  Icons.timer_rounded,
                  _formatTime(_seconds),
                  'Хугацаа',
                ),
                _buildCompletionStat(
                  Icons.fitness_center_rounded,
                  '$_currentSet',
                  'Багц',
                ),
                _buildCompletionStat(
                  Icons.local_fire_department_rounded,
                  '$caloriesBurned',
                  'Калори',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // XP earned
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+${_currentSet * 10 + (_seconds ~/ 60) * 2} XP',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Done button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFE7409), Color(0xFFFF9149)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'Дуусгах',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFFE7409), size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
