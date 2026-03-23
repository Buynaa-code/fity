import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/login_screen.dart';
import '../home/home_screen_v2.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_spacing.dart';
import '../../../core/ui/theme/app_typography.dart';
import '../../../core/ui/components/app_button.dart';
import '../../../core/ui/components/inputs/goal_selector.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String? _selectedGoal;

  // Animation controllers
  late AnimationController _pageAnimationController;
  late AnimationController _backgroundController;
  late AnimationController _celebrationController;

  // Page data
  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Зорилгоо сонгоорой',
      subtitle: 'Танд хамгийн чухал юу вэ?',
      icon: '🎯',
      color: AppColors.primary,
      gradientColors: [const Color(0xFFFF6B35), AppColors.primary],
      isGoalPage: true,
    ),
    _OnboardingPageData(
      title: 'Дасгалаа хянах',
      subtitle: 'Бүх дасгал, прогрессоо нэг дороос хянаарай',
      icon: '📊',
      color: AppColors.success,
      gradientColors: [const Color(0xFF00E676), AppColors.success],
      features: [
        _Feature(icon: Icons.fitness_center_rounded, text: 'Дасгалын бүртгэл'),
        _Feature(icon: Icons.show_chart_rounded, text: 'Дэлгэрэнгүй статистик'),
        _Feature(icon: Icons.calendar_today_rounded, text: 'Хуваарь'),
      ],
    ),
    _OnboardingPageData(
      title: 'Амжилтаа тэмдэглэ',
      subtitle: 'Badge цуглуулж, streak-ээ хадгалаарай',
      icon: '🏆',
      color: AppColors.warning,
      gradientColors: [const Color(0xFFFFD54F), AppColors.warning],
      features: [
        _Feature(icon: Icons.emoji_events_rounded, text: 'Шагнал & Badge'),
        _Feature(icon: Icons.local_fire_department_rounded, text: 'Өдрийн streak'),
        _Feature(icon: Icons.people_rounded, text: 'Найзуудтай өрсөлдөх'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _pageAnimationController.forward();
  }

  void _setupAnimations() {
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageAnimationController.dispose();
    _backgroundController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageAnimationController.reset();
    _pageAnimationController.forward();
  }

  void _nextPage() {
    if (_currentIndex == 0 && _selectedGoal == null) {
      _showGoalRequiredSnackbar();
      return;
    }

    HapticFeedback.mediumImpact();

    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _showCelebrationAndNavigate();
    }
  }

  void _showGoalRequiredSnackbar() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Text('Зорилгоо сонгоно уу'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        margin: const EdgeInsets.all(AppSpacing.screenPadding),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCelebrationAndNavigate() async {
    HapticFeedback.heavyImpact();
    _celebrationController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _navigateToHome();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const HomeScreenV2(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _skipToHome() {
    HapticFeedback.lightImpact();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_currentIndex];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentPage.gradientColors[0].withValues(alpha: 0.1),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              _buildTopBar(),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(index);
                  },
                ),
              ),

              // Bottom section
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _currentIndex > 0 ? 1.0 : 0.0,
            child: IconButton(
              onPressed: _currentIndex > 0
                  ? () {
                      HapticFeedback.lightImpact();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOutCubic,
                      );
                    }
                  : null,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          // Page indicator in top bar
          _buildMiniPageIndicator(),
          // Skip button
          TextButton(
            onPressed: _skipToHome,
            child: Text(
              'Алгасах',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPageIndicator() {
    return Row(
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentIndex;
        final isPast = index < _currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? _pages[_currentIndex].color
                : isPast
                    ? _pages[_currentIndex].color.withValues(alpha: 0.5)
                    : AppColors.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildPage(int index) {
    final page = _pages[index];

    return AnimatedBuilder(
      animation: _pageAnimationController,
      builder: (context, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _pageAnimationController,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _pageAnimationController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: page.isGoalPage
                ? _buildGoalSelectionPage(page)
                : _buildFeaturePage(page),
          ),
        );
      },
    );
  }

  Widget _buildGoalSelectionPage(_OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Animated icon
          _buildAnimatedIcon(page),
          const SizedBox(height: AppSpacing.lg),
          // Title
          Text(
            page.title,
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            page.subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          // Goal selector
          Expanded(
            child: GoalSelector(
              options: FitnessGoals.defaults,
              selectedId: _selectedGoal,
              onSelected: (id) {
                HapticFeedback.selectionClick();
                setState(() => _selectedGoal = id);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePage(_OnboardingPageData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Hero illustration
          Expanded(
            flex: 5,
            child: _buildHeroIllustration(page),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Content
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    page.title,
                    style: AppTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: page.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    page.subtitle,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Feature list
                  if (page.features != null)
                    ...page.features!.map((feature) => _buildFeatureItem(feature, page.color)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(_OnboardingPageData page) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: page.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: Text(
                page.icon,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroIllustration(_OnboardingPageData page) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.gradientColors[0].withValues(alpha: 0.8),
                  page.gradientColors[1],
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                ..._buildDecorativeElements(page),
                // Center icon
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        page.icon,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          page.title,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDecorativeElements(_OnboardingPageData page) {
    return [
      // Top left circle
      Positioned(
        top: -30,
        left: -30,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      // Bottom right circle
      Positioned(
        bottom: -50,
        right: -50,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      // Small floating elements
      Positioned(
        top: 40,
        right: 40,
        child: _buildFloatingElement(Icons.star_rounded, 0.15),
      ),
      Positioned(
        bottom: 60,
        left: 30,
        child: _buildFloatingElement(Icons.favorite_rounded, 0.12),
      ),
    ];
  }

  Widget _buildFloatingElement(IconData icon, double opacity) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(value * math.pi * 2) * 5),
          child: Opacity(
            opacity: opacity,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(_Feature feature, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              feature.icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            feature.text,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    final isLastPage = _currentIndex == _pages.length - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          _buildProgressBar(),
          const SizedBox(height: AppSpacing.lg),
          // Action button
          AppButton(
            text: isLastPage ? 'Эхлэх' : 'Үргэлжлүүлэх',
            onPressed: _nextPage,
            isFullWidth: true,
            size: AppButtonSize.large,
            trailingIcon: isLastPage ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
          ),
          // Sign in link on last page
          if (isLastPage) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Бүртгэлтэй юу? ',
                  style: AppTypography.bodyMedium,
                ),
                GestureDetector(
                  onTap: _navigateToLogin,
                  child: Text(
                    'Нэвтрэх',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / _pages.length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Алхам ${_currentIndex + 1}/${_pages.length}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTypography.labelSmall.copyWith(
                color: _pages[_currentIndex].color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(3),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _pages[_currentIndex].gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: _pages[_currentIndex].color.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final List<Color> gradientColors;
  final bool isGoalPage;
  final List<_Feature>? features;

  _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientColors,
    this.isGoalPage = false,
    this.features,
  });
}

class _Feature {
  final IconData icon;
  final String text;

  _Feature({required this.icon, required this.text});
}
