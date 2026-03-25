import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../checkin/user_qr_code_screen.dart';
import '../workout/workout_list_screen.dart';
import '../health/calorie_screen.dart';
import '../challenges/challenges_screen.dart';
import '../profile/profile_screen.dart';
import '../receptionist/receptionist_scanner_screen.dart';
import '../receptionist/checkins_list_screen.dart';
import '../receptionist/member_search_screen.dart';
import '../../../features/water_tracker/presentation/bloc/water_bloc.dart';
import '../../../features/water_tracker/presentation/bloc/water_event.dart';
import '../../../features/water_tracker/presentation/bloc/water_state.dart';
import '../../../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../../../features/statistics/presentation/bloc/statistics_event.dart';
import '../../../features/statistics/presentation/bloc/statistics_state.dart';
import '../../../features/gamification/presentation/bloc/badge_bloc.dart';
import '../../../features/gamification/presentation/bloc/badge_event.dart';
import '../../../features/gamification/presentation/bloc/badge_state.dart';
import '../../../features/trainer_marketplace/presentation/pages/trainer_list_screen.dart';
import '../../../features/ai_coach/presentation/pages/ai_coach_screen.dart';
import '../../../features/supplement_shop/presentation/screens/product_list_screen.dart';
import '../../../features/user/presentation/bloc/user_bloc.dart';
import '../../../features/user/presentation/bloc/user_state.dart';
import '../../../features/user/domain/enums/user_role.dart';

import 'widgets/home_header.dart';
import 'widgets/today_stats_card.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/active_workout_card.dart';
import 'widgets/weekly_progress_chart.dart';
import 'widgets/gym_occupancy_card.dart';

class HomeScreenV2 extends StatefulWidget {
  const HomeScreenV2({super.key});

  @override
  State<HomeScreenV2> createState() => _HomeScreenV2State();
}

class _HomeScreenV2State extends State<HomeScreenV2> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  UserRole? _previousRole;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    _fabController.forward();

    // Load initial data
    _loadData();
  }

  void _loadData() {
    context.read<WaterBloc>().add(const LoadWeeklySummary());
    context.read<StatisticsBloc>().add(const LoadStatistics());
    context.read<BadgeBloc>().add(const LoadBadges());
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    HapticFeedback.lightImpact();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  List<Widget> _getMemberScreens() {
    return [
      _HomeContent(
        isDarkMode: _isDarkMode,
        onThemeToggle: _toggleTheme,
        onRefresh: _loadData,
      ),
      const WorkoutListScreen(),
      const CalorieScreen(),
      const ChallengesScreen(),
      const ProfileScreen(),
    ];
  }

  List<Widget> _getReceptionistScreens() {
    return [
      const ReceptionistScannerScreen(),
      const CheckinsListScreen(),
      const MemberSearchScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final role = userState.role;

        // Reset tab index when role changes
        if (_previousRole != null && _previousRole != role) {
          _currentIndex = 0;
        }
        _previousRole = role;

        final isMember = role == UserRole.member;
        final screens = isMember ? _getMemberScreens() : _getReceptionistScreens();

        return Theme(
          data: _isDarkMode
              ? ThemeData.dark().copyWith(
                  primaryColor: const Color(0xFFF72928),
                  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
                )
              : ThemeData.light().copyWith(
                  primaryColor: const Color(0xFFF72928),
                  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
                ),
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
            floatingActionButton: isMember && _currentIndex == 0
                ? ScaleTransition(
                    scale: _fabAnimation,
                    child: _buildQRFab(),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            bottomNavigationBar: isMember ? _buildMemberBottomNav() : _buildReceptionistBottomNav(),
          ),
        );
      },
    );
  }

  Widget _buildQRFab() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFF72928), Color(0xFFFF9149)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF72928).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserQRCodeScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.qr_code_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildMemberBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Нүүр'),
              _buildNavItem(1, Icons.fitness_center_rounded, Icons.fitness_center_outlined, 'Дасгал'),
              const SizedBox(width: 56), // Space for FAB
              _buildNavItem(3, Icons.directions_run_rounded, Icons.directions_run_outlined, 'Марафон'),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Профайл'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceptionistBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_outlined, 'Скан'),
              _buildNavItem(1, Icons.fact_check_rounded, Icons.fact_check_outlined, 'Check-ins'),
              _buildNavItem(2, Icons.people_rounded, Icons.people_outlined, 'Гишүүд'),
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Профайл'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentIndex = index);
        if (index == 0) {
          _fabController.forward();
        } else {
          _fabController.reverse();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF72928).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected
                  ? const Color(0xFFF72928)
                  : (_isDarkMode ? Colors.grey[500] : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFF72928)
                    : (_isDarkMode ? Colors.grey[500] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onRefresh;

  const _HomeContent({
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: const Color(0xFFF72928),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, statsState) {
                return BlocBuilder<BadgeBloc, BadgeState>(
                  builder: (context, badgeState) {
                    final stats = statsState.workoutStats;
                    return HomeHeader(
                      userName: 'Буянаа',
                      streakDays: stats?.currentStreak ?? 0,
                      level: _calculateLevel(badgeState.totalXp),
                      totalXp: badgeState.totalXp,
                      isDarkMode: isDarkMode,
                      onThemeToggle: onThemeToggle,
                      onNotificationTap: () => _showNotifications(context),
                      onProfileTap: () => Navigator.pushNamed(context, '/profile'),
                      notificationCount: badgeState.newBadgeCount,
                    );
                  },
                );
              },
            ),
          ),

          // Gym Occupancy Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: GymOccupancyCard(
                isDarkMode: isDarkMode,
              ),
            ),
          ),

          // Active Workout Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: BlocBuilder<StatisticsBloc, StatisticsState>(
                builder: (context, statsState) {
                  final stats = statsState.workoutStats;
                  return ActiveWorkoutCard(
                    isDarkMode: isDarkMode,
                    onContinue: () => _navigateToWorkout(context),
                    onStartNew: () => _navigateToWorkout(context),
                    todayWorkouts: stats?.todayWorkouts ?? 0,
                    currentStreak: stats?.currentStreak ?? 0,
                    weeklyGoal: 5,
                    weeklyCompleted: stats?.weeklyWorkouts.where((w) => w > 0).length ?? 0,
                  );
                },
              ),
            ),
          ),

          // Today's Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: BlocBuilder<WaterBloc, WaterState>(
                builder: (context, waterState) {
                  return BlocBuilder<StatisticsBloc, StatisticsState>(
                    builder: (context, statsState) {
                      final water = waterState.dailySummary;
                      final stats = statsState.workoutStats;
                      return TodayStatsCard(
                        waterMl: water?.totalMl ?? 0,
                        waterGoalMl: water?.goalMl ?? 2500,
                        caloriesBurned: 320,
                        caloriesGoal: 500,
                        workoutsToday: stats?.todayWorkouts ?? 0,
                        stepsToday: 6500,
                        stepsGoal: 10000,
                        isDarkMode: isDarkMode,
                        onWaterTap: () => Navigator.pushNamed(context, '/water-tracker'),
                        onCaloriesTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CalorieScreen()),
                        ),
                        onWorkoutTap: () => _navigateToWorkout(context),
                        onStepsTap: () => Navigator.pushNamed(context, '/statistics'),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Quick Actions - Enhanced with progress & gamification
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: BlocBuilder<WaterBloc, WaterState>(
                builder: (context, waterState) {
                  return BlocBuilder<StatisticsBloc, StatisticsState>(
                    builder: (context, statsState) {
                      return BlocBuilder<BadgeBloc, BadgeState>(
                        builder: (context, badgeState) {
                          // Calculate progress values
                          final waterMl = waterState.dailySummary?.totalMl ?? 0;
                          final waterGoal = waterState.dailySummary?.goalMl ?? 2500;
                          final waterProgress = (waterMl / waterGoal).clamp(0.0, 1.0);

                          final todayWorkouts = statsState.todayWorkouts;
                          final currentStreak = statsState.workoutStats?.currentStreak ?? 0;

                          // Determine priorities based on context
                          final waterPriority = QuickActionContextHelper.getWaterPriority(waterMl, waterGoal);
                          final workoutPriority = QuickActionContextHelper.getWorkoutPriority(todayWorkouts, currentStreak);

                          return QuickActionsSection(
                            isDarkMode: isDarkMode,
                            contextMessage: QuickActionContextHelper.getContextMessage(),
                            actions: [
                              QuickAction(
                                id: 'ai_coach',
                                title: 'AI Coach',
                                icon: Icons.smart_toy_rounded,
                                color: const Color(0xFFFF6B6B),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AICoachScreen()),
                                ),
                                xpReward: 15,
                                priority: ActionPriority.high,
                                badge: 'Шинэ',
                              ),
                              QuickAction(
                                id: 'checkin',
                                title: 'Check-In',
                                icon: Icons.qr_code_rounded,
                                color: const Color(0xFFF72928),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const UserQRCodeScreen()),
                                ),
                                xpReward: 10,
                                priority: ActionPriority.high,
                              ),
                              QuickAction(
                                id: 'water',
                                title: 'Ус',
                                icon: Icons.water_drop_rounded,
                                color: const Color(0xFF3498DB),
                                onTap: () => _quickAddWater(context),
                                progress: waterProgress,
                                progressLabel: '${(waterMl / 1000).toStringAsFixed(1)}L',
                                xpReward: 5,
                                priority: waterPriority,
                              ),
                              QuickAction(
                                id: 'workout',
                                title: 'Дасгал',
                                icon: Icons.fitness_center_rounded,
                                color: const Color(0xFF9B59B6),
                                onTap: () => _navigateToWorkout(context),
                                progress: todayWorkouts > 0 ? 1.0 : 0.0,
                                progressLabel: todayWorkouts > 0 ? 'Хийсэн' : 'Эхлэх',
                                xpReward: 25,
                                hasStreak: currentStreak > 0,
                                priority: workoutPriority,
                              ),
                              QuickAction(
                                id: 'badges',
                                title: 'Шагнал',
                                icon: Icons.emoji_events_rounded,
                                color: const Color(0xFFF39C12),
                                onTap: () => Navigator.pushNamed(context, '/badges'),
                                badge: badgeState.newBadgeCount > 0
                                    ? '${badgeState.newBadgeCount}'
                                    : null,
                                xpReward: badgeState.newBadgeCount > 0 ? 50 : null,
                                isBonus: badgeState.newBadgeCount > 0,
                                priority: badgeState.newBadgeCount > 0
                                    ? ActionPriority.high
                                    : ActionPriority.normal,
                              ),
                              QuickAction(
                                id: 'trainer',
                                title: 'Дасгалжуулагч',
                                icon: Icons.person_search_rounded,
                                color: const Color(0xFF1ABC9C),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TrainerListScreen()),
                                ),
                                priority: ActionPriority.normal,
                              ),
                              QuickAction(
                                id: 'shop',
                                title: 'Дэлгүүр',
                                icon: Icons.shopping_bag_rounded,
                                color: const Color(0xFFE91E63),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ProductListScreen()),
                                ),
                                priority: ActionPriority.normal,
                              ),
                              QuickAction(
                                id: 'statistics',
                                title: 'Статистик',
                                icon: Icons.analytics_rounded,
                                color: const Color(0xFF6C5CE7),
                                onTap: () => Navigator.pushNamed(context, '/statistics'),
                                priority: ActionPriority.normal,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Weekly Progress
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: BlocBuilder<StatisticsBloc, StatisticsState>(
                builder: (context, state) {
                  final stats = state.workoutStats;
                  return WeeklyProgressChart(
                    weeklyWorkouts: stats?.weeklyWorkouts ?? [0, 1, 1, 0, 1, 0, 0],
                    weeklyCalories: stats?.weeklyCalories ?? [0.0, 320.0, 280.0, 0.0, 450.0, 0.0, 0.0],
                    currentStreak: stats?.currentStreak ?? 0,
                    isDarkMode: isDarkMode,
                  );
                },
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }

  int _calculateLevel(int xp) {
    if (xp < 100) return 1;
    if (xp < 300) return 2;
    if (xp < 600) return 3;
    if (xp < 1000) return 4;
    if (xp < 1500) return 5;
    if (xp < 2500) return 6;
    if (xp < 4000) return 7;
    if (xp < 6000) return 8;
    if (xp < 10000) return 9;
    return 10;
  }

  void _navigateToWorkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutListScreen()),
    );
  }

  void _quickAddWater(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.read<WaterBloc>().add(const AddWaterIntake(250));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.water_drop_rounded, color: Colors.white),
            SizedBox(width: 12),
            Text('250мл ус нэмэгдлээ!'),
          ],
        ),
        backgroundColor: const Color(0xFF3498DB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _NotificationsSheet(isDarkMode: isDarkMode),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  final bool isDarkMode;

  const _NotificationsSheet({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Мэдэгдэл',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  _buildNotificationItem(
                    'Шинэ шагнал авлаа! 🏆',
                    'Та "7 хоногийн streak" шагнал авлаа',
                    '2 минутын өмнө',
                    Icons.emoji_events_rounded,
                    Colors.amber,
                    true,
                  ),
                  _buildNotificationItem(
                    'Дасгалын цаг боллоо! 💪',
                    'Өдрийн дасгалаа хийх цаг боллоо',
                    '1 цагийн өмнө',
                    Icons.fitness_center_rounded,
                    const Color(0xFF6C5CE7),
                    false,
                  ),
                  _buildNotificationItem(
                    'Ус уухаа мартуузай 💧',
                    'Өнөөдрийн зорилгын 60% биеллээ',
                    '3 цагийн өмнө',
                    Icons.water_drop_rounded,
                    const Color(0xFF3498DB),
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
    bool isNew,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: isNew
            ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    if (isNew)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
