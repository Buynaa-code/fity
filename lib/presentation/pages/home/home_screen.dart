import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../qr_scanner/qr_scanner_screen.dart';
import '../workout/workout_list_screen.dart';
import '../health/calorie_screen.dart';
import '../challenges/challenges_screen.dart';
import '../profile/profile_screen.dart';
import '../../../features/water_tracker/presentation/pages/water_tracker_screen.dart';
import '../../../features/water_tracker/presentation/bloc/water_bloc.dart';
import '../../../features/water_tracker/presentation/bloc/water_state.dart';
import '../../../features/statistics/presentation/pages/statistics_screen.dart';
import '../../../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../../../features/statistics/presentation/bloc/statistics_state.dart';
import '../../../features/trainer_marketplace/presentation/pages/trainer_list_screen.dart';

// Simple theme notifier for dark mode
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

final themeNotifier = ThemeNotifier();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabAnimation;
  bool _isDarkMode = false;

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.isDarkMode;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _animationController.forward();
    _updateScreens();

    // Listen to theme changes
    themeNotifier.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) {
      setState(() {
        _isDarkMode = themeNotifier.isDarkMode;
      });
      _updateScreens();
    }
  }

  void _toggleTheme() {
    HapticFeedback.lightImpact();
    themeNotifier.toggleTheme();
  }

  void _updateScreens() {
    _screens = [
      _HomeContent(isDarkMode: _isDarkMode, onThemeToggle: _toggleTheme),
      const WorkoutListScreen(),
      const CalorieScreen(),
      const ChallengesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    themeNotifier.removeListener(_onThemeChanged);
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data:
          _isDarkMode
              ? ThemeData.dark().copyWith(
                primaryColor: const Color(0xFFF72928),
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
              )
              : ThemeData.light().copyWith(
                primaryColor: const Color(0xFFF72928),
                scaffoldBackgroundColor: Colors.grey[50],
              ),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              _currentIndex == 0
                  ? _HomeContent(
                    isDarkMode: _isDarkMode,
                    onThemeToggle: _toggleTheme,
                    key: ValueKey(_isDarkMode),
                  )
                  : _screens[_currentIndex],
        ),
        floatingActionButton:
            _currentIndex == 0
                ? ScaleTransition(
                  scale: _fabAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Color(0xFFF72928), Color(0xFFFF9500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFF72928).withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.small(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, _) =>
                                    const QRScannerScreen(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                                  child: child,
                                ),
                              );
                            },
                          ),
                        );
                      },
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      heroTag: "qr_fab",
                      child: Icon(Icons.qr_code_scanner_rounded, size: 24),
                    ),
                  ),
                )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: (_isDarkMode ? Colors.black : Colors.grey).withOpacity(
                  0.15,
                ),
                blurRadius: 25,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                });
                if (index == 0) {
                  _fabAnimationController.forward();
                } else {
                  _fabAnimationController.reverse();
                }
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor:
                  _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              selectedItemColor: const Color(0xFFF72928),
              unselectedItemColor:
                  _isDarkMode ? Colors.grey[500] : Colors.grey[600],
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Нүүр',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_outlined),
                  activeIcon: Icon(Icons.fitness_center_rounded),
                  label: 'Дасгал',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline_rounded),
                  activeIcon: Icon(Icons.favorite_rounded),
                  label: 'Эрүүл мэнд',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events_outlined),
                  activeIcon: Icon(Icons.emoji_events_rounded),
                  label: 'Challenge',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Профайл',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const _HomeContent({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;
  DateTime _currentTime = DateTime.now();
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.65).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _pulseController.repeat(reverse: true);
    _slideController.forward();
    _progressController.forward();
    _updateGreeting();

    // Update time every minute
    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
          _updateGreeting();
        });
      }
    });
  }

  void _updateGreeting() {
    final hour = _currentTime.hour;
    if (hour < 12) {
      _greeting = 'Өглөөний мэнд! 🌅';
    } else if (hour < 18) {
      _greeting = 'Өдрийн мэнд! ☀️';
    } else {
      _greeting = 'Орой мэнд! 🌙';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color:
                        widget.isDarkMode
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
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
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Мэдэгдэл',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        widget.isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildNotificationItem(
                              'Дасгалын цаг боллоо! 💪',
                              'Энэ үед дасгал хийх нь хамгийн тохиромжтой',
                              '5 минутын өмнө',
                              Icons.fitness_center,
                              const Color(0xFF6C5CE7),
                            ),
                            _buildNotificationItem(
                              'Шинэ challenge нэмэгдлээ! 🏆',
                              '30 хоногийн буцлага challenge-д оролцоорой',
                              '1 цагийн өмнө',
                              Icons.emoji_events,
                              const Color(0xFFF39C12),
                            ),
                            _buildNotificationItem(
                              'Долоо хоногийн тайлан бэлэн ✨',
                              'Таны энэ долоо хоногийн ахиц гайхалтай байна!',
                              '2 цагийн өмнө',
                              Icons.analytics,
                              const Color(0xFF16A085),
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

  Widget _buildNotificationItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color:
                        widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
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

  void _showTimerDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => _TimerDialog(isDarkMode: widget.isDarkMode),
    );
  }

  void _startWorkout() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const WorkoutListScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          widget.isDarkMode ? const Color(0xFF121212) : Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Enhanced header with dark mode support
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                color:
                    widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isDarkMode ? Colors.black : Colors.grey)
                        .withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildUserHeader(),
                  const SizedBox(height: 30),
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildWorkoutProgressCard(),
                  ),
                ],
              ),
            ),
          ),

          // Content sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildSectionTitle('Өнөөдрийн ахиц 📊'),
                  const SizedBox(height: 4),
                  const SizedBox(height: 16),
                  _buildDailyProgressCards(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),
                  _buildWorkoutScheduleSection(),
                  const SizedBox(height: 24),
                  _buildGymOccupancyCard(),
                  const SizedBox(height: 16),
                  _buildRecentWorkoutsSection(),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        // Profile image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF72928).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF72928), Color(0xFFFF9500)],
                    ),
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Буянаа! 💪',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF72928).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF72928).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text(
                            '7d',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFFF72928),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🏆', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text(
                            'L3',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
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
        Row(
          children: [
            // Theme toggle button
            GestureDetector(
              onTap: widget.onThemeToggle,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey(widget.isDarkMode),
                    size: 20,
                    color: widget.isDarkMode ? Colors.yellow : Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Notification button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _showNotifications();
              },
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            widget.isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color:
                                widget.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF72928),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Profile avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF72928), Color(0xFFFF8A33)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF72928).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 26),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.more_horiz,
            size: 20,
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutProgressCard() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1534258936925-c58bed479fcb?w=800&h=400&fit=crop&crop=center&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Enhanced gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF72928).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF72928).withOpacity(0.4),
                      ),
                    ),
                    child: const Text(
                      '🔥 Progress',
                      style: TextStyle(
                        color: Color(0xFFF72928),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Workout info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'Cardio',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Workout title
                  const Text(
                    'Lower Body Blast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Details and progress
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '30/45 мин',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '210/320 kcal',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                _startWorkout();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Үргэлжлүүлэх',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6C5CE7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Animated progress circle
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 75,
                                height: 75,
                                child: CircularProgressIndicator(
                                  value: _progressAnimation.value,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.2,
                                  ),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '15 мин',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'үлдсэн',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
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

  Widget _buildDailyProgressCards() {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, waterState) {
        return BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, statsState) {
            final waterSummary = waterState.dailySummary;
            final waterProgress = waterSummary?.progress ?? 0.0;
            final waterMl = waterSummary?.totalMl ?? 0;
            final waterGoal = waterSummary?.goalMl ?? 2000;

            final stats = statsState.workoutStats;
            final totalWorkouts = stats?.totalWorkouts ?? 0;
            final streak = stats?.currentStreak ?? 0;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WaterTrackerScreen(),
                            ),
                          );
                        },
                        child: _buildProgressCard(
                          icon: Icons.water_drop_rounded,
                          iconColor: const Color(0xFF3498DB),
                          title: 'Ус',
                          value: '$waterMl',
                          subtitle: '/ $waterGoalмл',
                          target: '$waterGoal',
                          progress: waterProgress,
                          progressColor: const Color(0xFF3498DB),
                          showProgress: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StatisticsScreen(),
                            ),
                          );
                        },
                        child: _buildProgressCard(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFF39C12),
                          title: 'Streak',
                          value: '$streak',
                          subtitle: 'хоног дараалан',
                          showProgress: false,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StatisticsScreen(),
                            ),
                          );
                        },
                        child: _buildProgressCard(
                          icon: Icons.fitness_center_rounded,
                          iconColor: const Color(0xFF16A085),
                          title: 'Дасгал',
                          value: '$totalWorkouts',
                          subtitle: 'нийт хийсэн',
                          showProgress: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressCard(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFFE74C3C),
                        title: 'Зүрхний цохилт',
                        value: '84',
                        subtitle: 'bpm',
                        showProgress: false,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProgressCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    bool showProgress = false,
    double progress = 0.0,
    String target = '',
    Color progressColor = Colors.blue,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showProgressCardDetails(
          title,
          value,
          subtitle,
          showProgress,
          progress,
          iconColor,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (widget.isDarkMode ? Colors.black : Colors.grey)
                  .withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border:
              widget.isDarkMode
                  ? Border.all(color: Colors.grey[800]!, width: 0.5)
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const Spacer(),
                if (showProgress)
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 4,
                            backgroundColor:
                                widget.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressColor,
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Center(
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: progressColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressCardDetails(
    String title,
    String value,
    String subtitle,
    bool showProgress,
    double progress,
    Color iconColor,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => _ProgressCardDialog(
            title: title,
            value: value,
            subtitle: subtitle,
            showProgress: showProgress,
            progress: progress,
            iconColor: iconColor,
            isDarkMode: widget.isDarkMode,
          ),
    );
  }

  Widget _buildGymOccupancyCard() {
    final currentOccupancy = 28;
    final maxCapacity = 40;
    final occupancyRate = currentOccupancy / maxCapacity;

    // Determine status color and message based on occupancy
    Color statusColor;
    String statusMessage;
    String statusEmoji;

    if (occupancyRate < 0.5) {
      statusColor = Colors.green;
      statusMessage = 'Тохиромжтой 👌';
      statusEmoji = '🟢';
    } else if (occupancyRate < 0.8) {
      statusColor = Colors.orange;
      statusMessage = 'Дунд зэрэг 🤔';
      statusEmoji = '🟡';
    } else {
      statusColor = Colors.red;
      statusMessage = 'Дүүрэн 😅';
      statusEmoji = '🔴';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (widget.isDarkMode ? Colors.black : Colors.grey).withOpacity(
              0.15,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background image
            Container(
              height: 280,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=400&fit=crop&crop=center&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Заалны дүүргэлт',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    statusEmoji,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusMessage,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Main occupancy display
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '$currentOccupancy',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '/ $maxCapacity хүн',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'одоо зааланд байна',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Circular progress indicator
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: Stack(
                            children: [
                              // Background circle
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 4,
                                  ),
                                ),
                              ),
                              // Progress circle
                              SizedBox(
                                width: 90,
                                height: 90,
                                child: CircularProgressIndicator(
                                  value: occupancyRate,
                                  strokeWidth: 4,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    statusColor,
                                  ),
                                ),
                              ),
                              // Percentage text
                              Positioned.fill(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${(occupancyRate * 100).round()}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'дүүрэн',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Enhanced progress bar
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: LinearProgressIndicator(
                              value: occupancyRate,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Өглөөний цаг: 6:00-10:00',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                'Шинэчлэгдсэн: 2 мин өмнө',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Хурдан үйлдэл ⚡'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.play_circle_fill_rounded,
                iconColor: const Color(0xFF6C5CE7),
                title: 'Дасгал эхлэх',
                subtitle: 'Шинэ дасгал',
                onTap: _startWorkout,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.water_drop_rounded,
                iconColor: const Color(0xFF3498DB),
                title: 'Ус уух',
                subtitle: 'Хэмжээ бүртгэх',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WaterTrackerScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFFF39C12),
                title: 'Статистик',
                subtitle: 'Ахиц дэвшил',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.emoji_events_rounded,
                iconColor: const Color(0xFFE74C3C),
                title: 'Challenge',
                subtitle: 'Шинэ сорилт',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChallengesScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.sports_gymnastics_rounded,
                iconColor: const Color(0xFF00B894),
                title: 'Дасгалжуулагч',
                subtitle: 'Захиалга өгөх',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrainerListScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.shopping_bag_rounded,
                iconColor: const Color(0xFFF72928),
                title: 'Дэлгүүр',
                subtitle: 'Тэжээлийн нэмэлт',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/shop');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutScheduleSection() {
    final today = DateTime.now();
    final weekDays = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionTitle('Дасгалын хуваарь 📅')),
            GestureDetector(
              onTap: _showWorkoutScheduleSettings,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF72928).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF72928).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings_rounded,
                      color: const Color(0xFFF72928),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Тохиргоо',
                      style: TextStyle(
                        color: const Color(0xFFF72928),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (widget.isDarkMode ? Colors.black : Colors.grey)
                    .withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border:
                widget.isDarkMode
                    ? Border.all(color: Colors.grey[800]!, width: 0.5)
                    : null,
          ),
          child: Column(
            children: [
              // Week days header
              Row(
                children:
                    weekDays.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final isToday = index == (today.weekday - 1);

                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration:
                              isToday
                                  ? BoxDecoration(
                                    color: const Color(
                                      0xFFF72928,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                  : null,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.w500,
                              color:
                                  isToday
                                      ? const Color(0xFFF72928)
                                      : (widget.isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600]),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              // Workout schedule for the week
              Row(
                children: List.generate(7, (index) {
                  final hasWorkout = _getWorkoutForDay(index);
                  final workoutProgram = _getWorkoutProgramForDay(index);
                  final isToday = index == (today.weekday - 1);

                  // Get program details if there's a workout
                  final programIcon =
                      workoutProgram.isNotEmpty
                          ? _getWorkoutProgramIcon(workoutProgram)
                          : (hasWorkout
                              ? Icons.fitness_center_rounded
                              : Icons.hotel_rounded);
                  final programColor =
                      workoutProgram.isNotEmpty
                          ? _getWorkoutProgramColor(workoutProgram)
                          : const Color(0xFFF72928);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _toggleWorkoutDay(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 70,
                        decoration: BoxDecoration(
                          color:
                              hasWorkout
                                  ? programColor
                                  : (widget.isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              isToday
                                  ? Border.all(
                                    color:
                                        hasWorkout
                                            ? Colors.white
                                            : const Color(0xFFF72928),
                                    width: 2,
                                  )
                                  : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                programIcon,
                                color:
                                    hasWorkout
                                        ? Colors.white
                                        : (widget.isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[500]),
                                size: 18,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasWorkout
                                    ? (workoutProgram.isNotEmpty
                                        ? workoutProgram
                                        : 'Дасгал')
                                    : 'Амралт',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:
                                      hasWorkout
                                          ? Colors.white
                                          : (widget.isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[500]),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Weekly summary with today's program
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScheduleStat(
                    'Долоо хоногт',
                    '4 өдөр',
                    Icons.calendar_today_rounded,
                  ),
                  _buildScheduleStat(
                    'Дараагийн',
                    _getNextWorkoutInfo(),
                    Icons.schedule_rounded,
                  ),
                  _buildTodayWorkoutStat(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF72928), size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[600],
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  bool _getWorkoutForDay(int dayIndex) {
    // Mock data - in a real app, this would come from user preferences
    final scheduledDays = [1, 2, 4, 6]; // Monday, Tuesday, Friday, Sunday
    return scheduledDays.contains(dayIndex);
  }

  String _getWorkoutProgramForDay(int dayIndex) {
    // Mock data - in a real app, this would come from user preferences
    final workoutPrograms = {
      0: '', // Monday - Rest
      1: 'Цээж', // Tuesday - Chest
      2: '', // Wednesday - Rest
      3: 'Гар', // Thursday - Arms
      4: '', // Friday - Rest
      5: 'Хөл', // Saturday - Legs
      6: 'Нуруу', // Sunday - Back
    };
    return workoutPrograms[dayIndex] ?? '';
  }

  IconData _getWorkoutProgramIcon(String program) {
    final programIcons = {
      'Цээж': Icons.fitness_center_rounded,
      'Нуруу': Icons.accessibility_new_rounded,
      'Гар': Icons.sports_gymnastics_rounded,
      'Хөл': Icons.directions_run_rounded,
      'Мөр': Icons.sports_martial_arts_rounded,
      'Хэвлий': Icons.self_improvement_rounded,
      'Кардио': Icons.favorite_rounded,
      'Бүх бие': Icons.person_rounded,
    };
    return programIcons[program] ?? Icons.fitness_center_rounded;
  }

  Color _getWorkoutProgramColor(String program) {
    final programColors = {
      'Цээж': const Color(0xFF6C5CE7),
      'Нуруу': const Color(0xFF16A085),
      'Гар': const Color(0xFFF39C12),
      'Хөл': const Color(0xFFE74C3C),
      'Мөр': const Color(0xFF9B59B6),
      'Хэвлий': const Color(0xFF2ECC71),
      'Кардио': const Color(0xFFE91E63),
      'Бүх бие': const Color(0xFF34495E),
    };
    return programColors[program] ?? const Color(0xFFF72928);
  }

  String _getNextWorkoutInfo() {
    final today = DateTime.now().weekday - 1; // Convert to 0-6 format

    // Find next workout day
    for (int i = 1; i <= 7; i++) {
      final dayIndex = (today + i) % 7;
      if (_getWorkoutForDay(dayIndex)) {
        final program = _getWorkoutProgramForDay(dayIndex);
        final dayNames = [
          'Даваа',
          'Мягмар',
          'Лхагва',
          'Пүрэв',
          'Баасан',
          'Бямба',
          'Ням',
        ];
        final dayName = i == 1 ? 'Маргааш' : dayNames[dayIndex];
        return program.isNotEmpty ? '$dayName ($program)' : dayName;
      }
    }
    return 'Байхгүй';
  }

  Widget _buildTodayWorkoutStat() {
    final today = DateTime.now().weekday - 1; // Convert to 0-6 format
    final hasWorkout = _getWorkoutForDay(today);
    final program = _getWorkoutProgramForDay(today);

    return Column(
      children: [
        Icon(
          hasWorkout ? _getWorkoutProgramIcon(program) : Icons.hotel_rounded,
          color:
              hasWorkout
                  ? _getWorkoutProgramColor(program)
                  : const Color(0xFFF72928),
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          'Өнөөдөр',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[600],
            fontSize: 11,
          ),
        ),
        Text(
          hasWorkout
              ? (program.isNotEmpty ? program : 'Дасгал ✅')
              : 'Амралт 😴',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _toggleWorkoutDay(int dayIndex) {
    HapticFeedback.selectionClick();
    // TODO: Toggle workout day in user preferences
    setState(() {
      // This would update the user's workout schedule
    });
  }

  void _showWorkoutScheduleSettings() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) =>
              _WorkoutScheduleSettingsSheet(isDarkMode: widget.isDarkMode),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (widget.isDarkMode ? Colors.black : Colors.grey)
                  .withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border:
              widget.isDarkMode
                  ? Border.all(color: Colors.grey[800]!, width: 0.5)
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: widget.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentWorkoutsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Сүүлийн дасгал 📝'),
        const SizedBox(height: 16),
        _buildRecentWorkoutCard(
          'Upper Body Power',
          'Өчигдөр',
          '45 мин',
          0.85,
          const Color(0xFF6C5CE7),
          Icons.fitness_center_rounded,
        ),
        const SizedBox(height: 12),
        _buildRecentWorkoutCard(
          'Cardio Blast',
          '2 хоногийн өмнө',
          '30 мин',
          1.0,
          const Color(0xFF16A085),
          Icons.directions_run_rounded,
        ),
        const SizedBox(height: 12),
        _buildRecentWorkoutCard(
          'Yoga Flow',
          '3 хоногийн өмнө',
          '25 мин',
          1.0,
          const Color(0xFFF39C12),
          Icons.self_improvement_rounded,
        ),
      ],
    );
  }

  Widget _buildRecentWorkoutCard(
    String title,
    String date,
    String duration,
    double completion,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (widget.isDarkMode ? Colors.black : Colors.grey).withOpacity(
              0.1,
            ),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border:
            widget.isDarkMode
                ? Border.all(color: Colors.grey[800]!, width: 0.5)
                : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color:
                          widget.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color:
                          widget.isDarkMode
                              ? Colors.grey[500]
                              : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: completion,
                  backgroundColor:
                      widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 6,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(completion * 100).toInt()}% дууссан',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            completion == 1.0
                ? Icons.check_circle_rounded
                : Icons.play_circle_outline_rounded,
            color: completion == 1.0 ? Colors.green : color,
            size: 32,
          ),
        ],
      ),
    );
  }
}

// Custom Timer Dialog
class _TimerDialog extends StatefulWidget {
  final bool isDarkMode;

  const _TimerDialog({required this.isDarkMode});

  @override
  State<_TimerDialog> createState() => __TimerDialogState();
}

class __TimerDialogState extends State<_TimerDialog>
    with TickerProviderStateMixin {
  int _selectedMinutes = 5;
  int _selectedSeconds = 0;
  bool _isRunning = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _pulseController.repeat(reverse: true);
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor:
          widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  color: const Color(0xFF16A085),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Workout Timer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeSelector('мин', _selectedMinutes, (value) {
                  setState(() => _selectedMinutes = value);
                }),
                const SizedBox(width: 20),
                Text(
                  ':',
                  style: TextStyle(
                    fontSize: 24,
                    color: widget.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 20),
                _buildTimeSelector('сек', _selectedSeconds, (value) {
                  setState(() => _selectedSeconds = value);
                }),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Цуцлах',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isRunning ? _pulseAnimation.value : 1.0,
                        child: ElevatedButton(
                          onPressed: _isRunning ? null : _startTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A085),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isRunning ? 'Ажиллаж байна...' : 'Эхлэх',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String label, int value, Function(int) onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          height: 100,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final isSelected = index == value;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: isSelected ? 24 : 18,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected
                              ? const Color(0xFF16A085)
                              : (widget.isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600]),
                    ),
                  ),
                );
              },
              childCount: label == 'мин' ? 60 : 60,
            ),
          ),
        ),
      ],
    );
  }
}

// Progress Card Details Dialog
class _ProgressCardDialog extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool showProgress;
  final double progress;
  final Color iconColor;
  final bool isDarkMode;

  const _ProgressCardDialog({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.showProgress,
    required this.progress,
    required this.iconColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_getIconForTitle(title), color: iconColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value $subtitle',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: iconColor,
              ),
            ),
            if (showProgress) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor:
                            isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Алхам':
        return Icons.directions_walk_rounded;
      case 'Калори':
        return Icons.local_fire_department_rounded;
      case 'Жин':
        return Icons.fitness_center_rounded;
      case 'Зүрхний цохилт':
        return Icons.favorite_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

// Workout Stats Bottom Sheet
class _WorkoutStatsSheet extends StatelessWidget {
  final bool isDarkMode;

  const _WorkoutStatsSheet({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Өнөөдрийн статистик',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatRow('🔥', 'Шатаасан калори', '1,247 kcal', Colors.red),
            const SizedBox(height: 16),
            _buildStatRow('👣', 'Алхсан алхам', '8,247 алхам', Colors.blue),
            const SizedBox(height: 16),
            _buildStatRow('⏱️', 'Дасгалын хугацаа', '45 минут', Colors.green),
            const SizedBox(height: 16),
            _buildStatRow('💪', 'Хийсэн дасгал', '3 дасгал', Colors.purple),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF72928),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Дэлгэрэнгүй үзэх',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String emoji, String title, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Workout Program Data Model
class WorkoutProgram {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  WorkoutProgram(this.name, this.description, this.icon, this.color);
}

// Workout Schedule Settings Bottom Sheet
class _WorkoutScheduleSettingsSheet extends StatefulWidget {
  final bool isDarkMode;

  const _WorkoutScheduleSettingsSheet({required this.isDarkMode});

  @override
  State<_WorkoutScheduleSettingsSheet> createState() =>
      _WorkoutScheduleSettingsSheetState();
}

class _WorkoutScheduleSettingsSheetState
    extends State<_WorkoutScheduleSettingsSheet> {
  final Map<int, bool> _workoutDays = {
    0: false, // Monday
    1: true, // Tuesday
    2: false, // Wednesday
    3: true, // Thursday
    4: false, // Friday
    5: true, // Saturday
    6: true, // Sunday
  };

  // Workout programs assigned to each day
  final Map<int, String> _workoutPrograms = {
    0: '', // Monday
    1: 'Цээж', // Tuesday - Chest
    2: '', // Wednesday
    3: 'Гар', // Thursday - Arms
    4: '', // Friday
    5: 'Хөл', // Saturday - Legs
    6: 'Нуруу', // Sunday - Back
  };

  TimeOfDay _workoutTime = const TimeOfDay(hour: 18, minute: 0);
  int _workoutDuration = 60; // minutes
  String _workoutIntensity = 'Medium';

  final List<String> _weekDays = [
    'Даваа',
    'Мягмар',
    'Лхагва',
    'Пүрэв',
    'Баасан',
    'Бямба',
    'Ням',
  ];
  final List<String> _intensityLevels = [
    'Бага',
    'Дунд',
    'Хүчтэй',
    'Маш хүчтэй',
  ];
  final List<int> _durationOptions = [30, 45, 60, 75, 90, 120];

  // Available workout programs
  final List<WorkoutProgram> _availablePrograms = [
    WorkoutProgram('', 'Амралтын өдөр', Icons.hotel_rounded, Colors.grey),
    WorkoutProgram(
      'Цээж',
      'Цээжний булчин',
      Icons.fitness_center_rounded,
      const Color(0xFF6C5CE7),
    ),
    WorkoutProgram(
      'Нуруу',
      'Нурууны булчин',
      Icons.accessibility_new_rounded,
      const Color(0xFF16A085),
    ),
    WorkoutProgram(
      'Гар',
      'Гарын булчин',
      Icons.sports_gymnastics_rounded,
      const Color(0xFFF39C12),
    ),
    WorkoutProgram(
      'Хөл',
      'Хөлний булчин',
      Icons.directions_run_rounded,
      const Color(0xFFE74C3C),
    ),
    WorkoutProgram(
      'Мөр',
      'Мөрний булчин',
      Icons.sports_martial_arts_rounded,
      const Color(0xFF9B59B6),
    ),
    WorkoutProgram(
      'Хэвлий',
      'Хэвлийн булчин',
      Icons.self_improvement_rounded,
      const Color(0xFF2ECC71),
    ),
    WorkoutProgram(
      'Кардио',
      'Зүрхний дасгал',
      Icons.favorite_rounded,
      const Color(0xFFE91E63),
    ),
    WorkoutProgram(
      'Бүх бие',
      'Бүх биеийн дасгал',
      Icons.person_rounded,
      const Color(0xFF34495E),
    ),
  ];

  WorkoutProgram _getSelectedProgram(String programName) {
    return _availablePrograms.firstWhere(
      (program) => program.name == programName,
      orElse: () => _availablePrograms.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: widget.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: const Color(0xFFF72928),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Дасгалын хуваарь тохируулах',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Days and workout program selection
                          _buildSectionTitle('Долоо хоногийн хуваарь'),
                          const SizedBox(height: 16),
                          Column(
                            children:
                                _weekDays.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final day = entry.value;
                                  final hasWorkout =
                                      _workoutDays[index] ?? false;
                                  final workoutProgram =
                                      _workoutPrograms[index] ?? '';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color:
                                          widget.isDarkMode
                                              ? const Color(0xFF1E1E1E)
                                              : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          widget.isDarkMode
                                              ? Border.all(
                                                color: Colors.grey[800]!,
                                                width: 0.5,
                                              )
                                              : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Day header with switch
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              day,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    widget.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                            ),
                                            Switch(
                                              value: hasWorkout,
                                              onChanged: (value) {
                                                setState(() {
                                                  _workoutDays[index] = value;
                                                  if (!value) {
                                                    _workoutPrograms[index] =
                                                        '';
                                                  }
                                                });
                                                HapticFeedback.selectionClick();
                                              },
                                              activeThumbColor: const Color(
                                                0xFFF72928,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Workout program selection (show only if workout enabled)
                                        if (hasWorkout) ...[
                                          const SizedBox(height: 16),
                                          Text(
                                            'Дасгалын төрөл:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  widget.isDarkMode
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children:
                                                _availablePrograms.map((
                                                  program,
                                                ) {
                                                  final isSelected =
                                                      workoutProgram ==
                                                      program.name;
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _workoutPrograms[index] =
                                                            program.name;
                                                      });
                                                      HapticFeedback.selectionClick();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            isSelected
                                                                ? program.color
                                                                : (widget
                                                                        .isDarkMode
                                                                    ? Colors
                                                                        .grey[800]
                                                                    : Colors
                                                                        .grey[200]),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            program.icon,
                                                            size: 16,
                                                            color:
                                                                isSelected
                                                                    ? Colors
                                                                        .white
                                                                    : program
                                                                        .color,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Text(
                                                            program.name.isEmpty
                                                                ? 'Амралт'
                                                                : program.name,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  isSelected
                                                                      ? Colors
                                                                          .white
                                                                      : (widget
                                                                              .isDarkMode
                                                                          ? Colors
                                                                              .grey[400]
                                                                          : Colors
                                                                              .grey[700]),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),

                                          // Show selected program details
                                          if (workoutProgram.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: _getSelectedProgram(
                                                  workoutProgram,
                                                ).color.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: _getSelectedProgram(
                                                    workoutProgram,
                                                  ).color.withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    _getSelectedProgram(
                                                      workoutProgram,
                                                    ).icon,
                                                    color:
                                                        _getSelectedProgram(
                                                          workoutProgram,
                                                        ).color,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    _getSelectedProgram(
                                                      workoutProgram,
                                                    ).description,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          _getSelectedProgram(
                                                            workoutProgram,
                                                          ).color,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Time selection
                          _buildSectionTitle('Цаг тохируулах'),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _selectTime,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color:
                                    widget.isDarkMode
                                        ? const Color(0xFF1E1E1E)
                                        : Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    widget.isDarkMode
                                        ? Border.all(
                                          color: Colors.grey[800]!,
                                          width: 0.5,
                                        )
                                        : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFF72928,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.access_time_rounded,
                                      color: Color(0xFFF72928),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Дасгалын цаг',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                widget.isDarkMode
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600],
                                          ),
                                        ),
                                        Text(
                                          _workoutTime.format(context),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                widget.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Duration selection
                          _buildSectionTitle('Үргэлжлэх хугацаа'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  widget.isDarkMode
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  widget.isDarkMode
                                      ? Border.all(
                                        color: Colors.grey[800]!,
                                        width: 0.5,
                                      )
                                      : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_workoutDuration минут',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFF72928),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children:
                                      _durationOptions.map((duration) {
                                        final isSelected =
                                            duration == _workoutDuration;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _workoutDuration = duration;
                                            });
                                            HapticFeedback.selectionClick();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? const Color(0xFFF72928)
                                                      : (widget.isDarkMode
                                                          ? Colors.grey[800]
                                                          : Colors.grey[200]),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '$durationмин',
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : (widget.isDarkMode
                                                            ? Colors.grey[400]
                                                            : Colors.grey[600]),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Intensity selection
                          _buildSectionTitle('Эрч хүчний түвшин'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color:
                                  widget.isDarkMode
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  widget.isDarkMode
                                      ? Border.all(
                                        color: Colors.grey[800]!,
                                        width: 0.5,
                                      )
                                      : null,
                            ),
                            child: Column(
                              children:
                                  _intensityLevels.map((intensity) {
                                    final isSelected =
                                        intensity == _workoutIntensity;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: RadioListTile<String>(
                                        title: Text(
                                          intensity,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                widget.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                        value: intensity,
                                        groupValue: _workoutIntensity,
                                        onChanged: (value) {
                                          setState(() {
                                            _workoutIntensity = value!;
                                          });
                                          HapticFeedback.selectionClick();
                                        },
                                        activeColor: const Color(0xFFF72928),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF72928),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Хадгалах',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: widget.isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _workoutTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFF72928),
            colorScheme: const ColorScheme.light(primary: Color(0xFFF72928)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _workoutTime) {
      setState(() {
        _workoutTime = picked;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _saveSchedule() {
    HapticFeedback.mediumImpact();

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '✅ Дасгалын хуваарь амжилттай хадгалагдлаа!',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFF72928),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }
}
