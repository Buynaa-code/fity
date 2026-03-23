import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_typography.dart';
import '../../../../core/ui/theme/app_spacing.dart';

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
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
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
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary, AppColors.secondaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PatternPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.levelUp,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Идэвхтэй',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          widget.activeWorkoutType ?? 'Workout',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    widget.activeWorkoutName ?? 'Workout',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildWorkoutStat(
                        Icons.access_time_rounded,
                        '${widget.minutesRemaining} мин',
                      ),
                      const SizedBox(width: AppSpacing.md),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Үргэлжлүүлэх',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: AppColors.secondary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    child: Stack(
                      children: [
                        Container(
                          height: 4,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        FractionallySizedBox(
                          widthFactor: widget.progress ?? 0.5,
                          child: Container(
                            height: 4,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white,
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
    final hasCompletedToday = todayWorkouts > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Өнөөдрийн дасгал',
              style: AppTypography.headlineSmall.copyWith(
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            if (hasCompletedToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$todayWorkouts хийсэн',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // Progress section - simplified
        _buildProgressSection(),

        const SizedBox(height: AppSpacing.md),

        // Main recommendation card
        _buildMainRecommendation(recommendation),

        const SizedBox(height: AppSpacing.sm),

        // Quick options
        Row(
          children: [
            Expanded(
              child: _buildQuickOption(
                icon: Icons.flash_on_rounded,
                label: '15 мин',
                subtitle: 'Хурдан',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildQuickOption(
                icon: Icons.self_improvement_rounded,
                label: '30 мин',
                subtitle: 'Стандарт',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildQuickOption(
                icon: Icons.fitness_center_rounded,
                label: '45+ мин',
                subtitle: 'Бүрэн',
                color: AppColors.flexibility,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildProgressItem(
              icon: Icons.fitness_center_rounded,
              iconColor: AppColors.flexibility,
              label: 'Өнөөдөр',
              value: '$todayWorkouts',
              subtitle: 'дасгал',
              showCheck: todayWorkouts > 0,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDarkMode ? AppColors.darkBorder : AppColors.divider,
          ),
          Expanded(
            child: _buildProgressItem(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.streak,
              label: 'Streak',
              value: '$currentStreak',
              subtitle: 'хоног',
              showFire: currentStreak >= 7,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDarkMode ? AppColors.darkBorder : AppColors.divider,
          ),
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
    final hasValue = int.tryParse(value) != null && int.parse(value) > 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: hasValue ? iconColor : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
              size: 18,
            ),
            if (showFire) ...[
              const SizedBox(width: 2),
              const Text('🔥', style: TextStyle(fontSize: 10)),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: hasValue
                ? (isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary)
                : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
          ),
        ),
        Text(
          subtitle,
          style: AppTypography.labelSmall.copyWith(
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressItem(double progress) {
    return Column(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 3,
                backgroundColor: isDarkMode ? AppColors.darkBorder : AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$weeklyCompleted/$weeklyGoal',
          style: AppTypography.titleMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        Text(
          '7 хоног',
          style: AppTypography.labelSmall.copyWith(
            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMainRecommendation(_WorkoutRecommendation recommendation) {
    if (todayWorkouts >= 3) {
      return _buildCompletedCard();
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onStartWorkout();
      },
      child: Container(
        height: 175,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: recommendation.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: recommendation.color.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ModernPatternPainter(recommendation.color),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
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
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                recommendation.icon,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recommendation.timeLabel,
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
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
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.badge, size: 12),
                              const SizedBox(width: 3),
                              Text(
                                '+${recommendation.xpReward} XP',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      recommendation.title,
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      recommendation.subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Bottom row
                    Row(
                      children: [
                        _buildStat(Icons.access_time_rounded, recommendation.duration),
                        const SizedBox(width: AppSpacing.md),
                        _buildStat(Icons.local_fire_department_rounded, '${recommendation.calories}'),

                        const Spacer(),

                        ScaleTransition(
                          scale: pulseAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Эхлэх',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: recommendation.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: recommendation.color,
                                  size: 16,
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
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onStartWorkout();
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          gradient: AppColors.successGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ModernPatternPainter(AppColors.success),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Баяр хүргэе!',
                              style: AppTypography.headlineMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Өнөөдөр $todayWorkouts дасгал хийлээ',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      if (currentStreak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(
                                '$currentStreak хоног',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: AppColors.success, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Нэмэх',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDarkMode ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.15 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.labelSmall.copyWith(
                color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary,
                fontSize: 10,
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
        subtitle: 'Биеэ сэргээж, өдрөө эхлүүлээрэй',
        icon: Icons.wb_sunny_rounded,
        color: AppColors.primary,
        gradientColors: [AppColors.primary, AppColors.primaryLight],
        duration: '20 мин',
        calories: 150,
        exercises: 8,
        xpReward: 30,
        timeLabel: 'Өглөө',
      );
    } else if (hour >= 10 && hour < 14) {
      return _WorkoutRecommendation(
        title: 'Идэвхтэй завсарлага',
        subtitle: 'Завсарлагаандаа биеэ хөдөлгөөрэй',
        icon: Icons.coffee_rounded,
        color: AppColors.info,
        gradientColors: [AppColors.info, const Color(0xFF5DADE2)],
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
        color: AppColors.flexibility,
        gradientColors: [AppColors.flexibility, const Color(0xFFBB8FCE)],
        duration: '35 мин',
        calories: 280,
        exercises: 12,
        xpReward: 50,
        timeLabel: 'Өдөр',
      );
    } else if (hour >= 18 && hour < 21) {
      return _WorkoutRecommendation(
        title: 'Оройн тайвшруулалт',
        subtitle: 'Стрессээ тайлж, сайн нойрсоорой',
        icon: Icons.nightlight_round,
        color: AppColors.levelUp,
        gradientColors: [AppColors.levelUp, const Color(0xFF48C9B0)],
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
        color: AppColors.secondary,
        gradientColors: [AppColors.secondary, AppColors.secondaryLight],
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
