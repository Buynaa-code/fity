import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActiveWorkoutCard extends StatefulWidget {
  final String? activeWorkoutName;
  final String? activeWorkoutType;
  final int? minutesRemaining;
  final int? totalMinutes;
  final int? caloriesBurned;
  final double? progress;
  final bool isDarkMode;
  final VoidCallback onContinue;
  final VoidCallback onStartNew;
  final int todayWorkouts;
  final int currentStreak;
  final int weeklyGoal;
  final int weeklyCompleted;

  const ActiveWorkoutCard({
    super.key,
    this.activeWorkoutName,
    this.activeWorkoutType,
    this.minutesRemaining,
    this.totalMinutes,
    this.caloriesBurned,
    this.progress,
    required this.isDarkMode,
    required this.onContinue,
    required this.onStartNew,
    this.todayWorkouts = 0,
    this.currentStreak = 0,
    this.weeklyGoal = 5,
    this.weeklyCompleted = 0,
  });

  @override
  State<ActiveWorkoutCard> createState() => _ActiveWorkoutCardState();
}

class _ActiveWorkoutCardState extends State<ActiveWorkoutCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;

  bool get hasActiveWorkout => widget.activeWorkoutName != null;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: hasActiveWorkout
          ? _buildActiveWorkoutCard()
          : _TodayWorkoutSection(
              isDarkMode: widget.isDarkMode,
              onStartWorkout: widget.onStartNew,
              shimmerController: _shimmerController,
              pulseAnimation: _pulseAnimation,
              todayWorkouts: widget.todayWorkouts,
              currentStreak: widget.currentStreak,
              weeklyGoal: widget.weeklyGoal,
              weeklyCompleted: widget.weeklyCompleted,
            ),
    );
  }

  Widget _buildActiveWorkoutCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _PatternPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Идэвхтэй',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.activeWorkoutType ?? 'Workout',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.activeWorkoutName ?? 'Workout',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildWorkoutStat(
                        Icons.access_time_rounded,
                        '${widget.minutesRemaining} мин үлдсэн',
                      ),
                      const SizedBox(width: 20),
                      _buildWorkoutStat(
                        Icons.local_fire_department_rounded,
                        '${widget.caloriesBurned ?? 0} kcal',
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          widget.onContinue();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Үргэлжлүүлэх',
                                style: TextStyle(
                                  color: Color(0xFF6C5CE7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Color(0xFF6C5CE7),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: widget.progress ?? 0.5,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Өнөөдрийн дасгалын санал болгох хэсэг
class _TodayWorkoutSection extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onStartWorkout;
  final AnimationController shimmerController;
  final Animation<double> pulseAnimation;
  final int todayWorkouts;
  final int currentStreak;
  final int weeklyGoal;
  final int weeklyCompleted;

  const _TodayWorkoutSection({
    required this.isDarkMode,
    required this.onStartWorkout,
    required this.shimmerController,
    required this.pulseAnimation,
    this.todayWorkouts = 0,
    this.currentStreak = 0,
    this.weeklyGoal = 5,
    this.weeklyCompleted = 0,
  });

  @override
  Widget build(BuildContext context) {
    final recommendation = _getTimeBasedRecommendation();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Гарчиг
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  'Өнөөдрийн дасгал',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: recommendation.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    recommendation.timeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: recommendation.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Прогресс хэсэг
        _buildProgressSection(),

        const SizedBox(height: 16),

        // Үндсэн санал
        _buildMainRecommendation(recommendation),

        const SizedBox(height: 12),

        // Хурдан сонголтууд
        Row(
          children: [
            Expanded(
              child: _buildQuickOption(
                icon: Icons.flash_on_rounded,
                label: '15 мин',
                subtitle: 'Хурдан',
                color: const Color(0xFFF39C12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickOption(
                icon: Icons.self_improvement_rounded,
                label: '30 мин',
                subtitle: 'Стандарт',
                color: const Color(0xFF3498DB),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickOption(
                icon: Icons.fitness_center_rounded,
                label: '45+ мин',
                subtitle: 'Бүрэн',
                color: const Color(0xFF9B59B6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final weeklyProgress = weeklyGoal > 0 ? (weeklyCompleted / weeklyGoal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Өнөөдрийн дасгал
          Expanded(
            child: _buildProgressItem(
              icon: Icons.fitness_center_rounded,
              iconColor: const Color(0xFF9B59B6),
              label: 'Өнөөдөр',
              value: '$todayWorkouts',
              subtitle: todayWorkouts > 0 ? 'дасгал хийсэн' : 'дасгал хийгээгүй',
              showCheck: todayWorkouts > 0,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: isDarkMode ? Colors.white12 : Colors.grey[200],
          ),
          // Streak
          Expanded(
            child: _buildProgressItem(
              icon: Icons.local_fire_department_rounded,
              iconColor: const Color(0xFFFE7409),
              label: 'Streak',
              value: '$currentStreak',
              subtitle: 'хоног',
              showFire: currentStreak > 0,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: isDarkMode ? Colors.white12 : Colors.grey[200],
          ),
          // Долоо хоногийн зорилго
          Expanded(
            child: _buildWeeklyProgressItem(weeklyProgress),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
    bool showCheck = false,
    bool showFire = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            if (showCheck) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60), size: 14),
            ],
            if (showFire && int.tryParse(value) != null && int.parse(value) >= 7) ...[
              const SizedBox(width: 4),
              const Text('🔥', style: TextStyle(fontSize: 12)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressItem(double progress) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                backgroundColor: isDarkMode ? Colors.white12 : Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$weeklyCompleted/$weeklyGoal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          'долоо хоног',
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMainRecommendation(_WorkoutRecommendation recommendation) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onStartWorkout();
      },
      child: AnimatedBuilder(
        animation: shimmerController,
        builder: (context, child) {
          return Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: recommendation.color.withValues(alpha: 0.35),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: recommendation.gradientColors,
                      ),
                    ),
                  ),

                  // Animated shimmer effect
                  Positioned.fill(
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: [
                            shimmerController.value - 0.3,
                            shimmerController.value,
                            shimmerController.value + 0.3,
                          ].map((e) => e.clamp(0.0, 1.0)).toList(),
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(color: Colors.white),
                    ),
                  ),

                  // Pattern overlay
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ModernPatternPainter(recommendation.color),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    recommendation.icon,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Санал болгож байна',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${recommendation.xpReward} XP',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Workout name
                        Text(
                          recommendation.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          recommendation.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),

                        const Spacer(),

                        // Bottom row with stats and button
                        Row(
                          children: [
                            // Stats
                            _buildStat(Icons.access_time_rounded, recommendation.duration),
                            const SizedBox(width: 16),
                            _buildStat(Icons.local_fire_department_rounded, '${recommendation.calories} kcal'),
                            const SizedBox(width: 16),
                            _buildStat(Icons.fitness_center_rounded, '${recommendation.exercises} дасгал'),

                            const Spacer(),

                            // Start button
                            ScaleTransition(
                              scale: pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Эхлэх',
                                      style: TextStyle(
                                        color: recommendation.color,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: recommendation.color,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onStartWorkout();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _WorkoutRecommendation _getTimeBasedRecommendation() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 10) {
      return _WorkoutRecommendation(
        title: 'Өглөөний идэвхжүүлэлт',
        subtitle: 'Биеэ сэргээж, өдрөө эрчтэй эхлүүлээрэй',
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFFE7409),
        gradientColors: [const Color(0xFFFE7409), const Color(0xFFFF9149)],
        duration: '20 мин',
        calories: 150,
        exercises: 8,
        xpReward: 30,
        timeLabel: 'Өглөө',
      );
    } else if (hour >= 10 && hour < 14) {
      return _WorkoutRecommendation(
        title: 'Идэвхтэй завсарлага',
        subtitle: 'Ажлын завсарлагаандаа биеэ хөдөлгөө',
        icon: Icons.coffee_rounded,
        color: const Color(0xFF3498DB),
        gradientColors: [const Color(0xFF3498DB), const Color(0xFF5DADE2)],
        duration: '15 мин',
        calories: 100,
        exercises: 6,
        xpReward: 20,
        timeLabel: 'Үд дунд',
      );
    } else if (hour >= 14 && hour < 18) {
      return _WorkoutRecommendation(
        title: 'Бүрэн биеийн дасгал',
        subtitle: 'Эрч хүч авч, зорилгодоо хүрээрэй',
        icon: Icons.fitness_center_rounded,
        color: const Color(0xFF9B59B6),
        gradientColors: [const Color(0xFF9B59B6), const Color(0xFFBB8FCE)],
        duration: '35 мин',
        calories: 280,
        exercises: 12,
        xpReward: 50,
        timeLabel: 'Үдээс хойш',
      );
    } else if (hour >= 18 && hour < 21) {
      return _WorkoutRecommendation(
        title: 'Оройн тайвшруулалт',
        subtitle: 'Стрессээ тайлж, сайн нойрсоорой',
        icon: Icons.nightlight_round,
        color: const Color(0xFF1ABC9C),
        gradientColors: [const Color(0xFF1ABC9C), const Color(0xFF48C9B0)],
        duration: '25 мин',
        calories: 120,
        exercises: 10,
        xpReward: 35,
        timeLabel: 'Орой',
      );
    } else {
      return _WorkoutRecommendation(
        title: 'Сунгалт & Тайвшрал',
        subtitle: 'Унтахын өмнө биеэ сулруулаарай',
        icon: Icons.self_improvement_rounded,
        color: const Color(0xFF6C5CE7),
        gradientColors: [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)],
        duration: '15 мин',
        calories: 50,
        exercises: 5,
        xpReward: 15,
        timeLabel: 'Шөнө',
      );
    }
  }
}

class _WorkoutRecommendation {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final String duration;
  final int calories;
  final int exercises;
  final int xpReward;
  final String timeLabel;

  const _WorkoutRecommendation({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.duration,
    required this.calories,
    required this.exercises,
    required this.xpReward,
    required this.timeLabel,
  });
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.2), size.height * 0.3),
        30 + i * 10,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ModernPatternPainter extends CustomPainter {
  final Color baseColor;

  _ModernPatternPainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Геометр хэлбэрүүд
    final path = Path();

    // Баруун дээд буланд тойрог
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.15),
      60,
      paint,
    );

    // Зүүн доод буланд тойрог
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.85),
      40,
      paint,
    );

    // Баруун доод буланд хагас тойрог
    path.moveTo(size.width, size.height * 0.6);
    path.arcToPoint(
      Offset(size.width, size.height),
      radius: const Radius.circular(80),
      clockwise: false,
    );
    path.lineTo(size.width, size.height * 0.6);
    canvas.drawPath(path, paint);

    // Нарийн шугамууд
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(0, size.height * (0.3 + i * 0.2)),
        Offset(size.width * 0.3, size.height * (0.2 + i * 0.15)),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ModernPatternPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor;
  }
}
