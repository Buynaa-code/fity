import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/login_screen.dart';
import '../home/home_screen_v2.dart';
import '../../../core/ui/ui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String? _selectedGoal;

  // Onboarding data following UX best practices
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      type: OnboardingPageType.content,
      title: 'Зорилгоо сонгоорой',
      description: 'Танд хамгийн чухал юу вэ?',
      icon: '🎯',
      color: AppColors.primary,
    ),
    OnboardingPage(
      type: OnboardingPageType.content,
      title: 'Дасгалаа хянах',
      description:
          'Дасгал тамир, прогрессоо дэлгэрэнгүй дүн шинжилгээ болон мэдээллээр хянаж байгаарай',
      image:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop&q=90',
      icon: '🏃‍♂️',
      color: AppColors.success,
    ),
    OnboardingPage(
      type: OnboardingPageType.content,
      title: 'Урам зориг',
      description:
          'Challenge-д оролцож, badge цуглуулж, streak-ээ үргэлжлүүлээрэй',
      image:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=600&fit=crop&q=90',
      icon: '🏆',
      color: AppColors.warning,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validation for goal selection page
    if (_currentIndex == 0 && _selectedGoal == null) {
      _showGoalRequiredSnackbar();
      return;
    }

    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToHome();
    }
  }

  void _showGoalRequiredSnackbar() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Зорилгоо сонгоно уу'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToHome() {
    // Skip login for faster onboarding (60-second rule)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const HomeScreenV2(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _skipToHome() {
    HapticFeedback.lightImpact();
    _navigateToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with skip button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (if not first page)
                  if (_currentIndex > 0)
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(
                          AppSpacing.minTouchTarget,
                          AppSpacing.minTouchTarget,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: AppSpacing.minTouchTarget),
                  // Skip button - allows skipping to home directly
                  TextButton(
                    onPressed: _skipToHome,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(
                        AppSpacing.minTouchTarget,
                        AppSpacing.minTouchTarget,
                      ),
                    ),
                    child: Text(
                      'Алгасах',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  if (index == 0) {
                    return _buildGoalSelectionPage(page);
                  }
                  return _buildContentPage(page);
                },
              ),
            ),
            // Bottom section
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelectionPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Title
          Text(page.title, style: AppTypography.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            page.description,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          // Goal selector grid
          Expanded(
            child: GoalSelector(
              options: FitnessGoals.defaults,
              selectedId: _selectedGoal,
              onSelected: (id) {
                setState(() {
                  _selectedGoal = id;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Hero Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: page.color.withValues(alpha: 0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (page.image != null)
                      Image.network(
                        page.image!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  page.color.withValues(alpha: 0.3),
                                  page.color.withValues(alpha: 0.1),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  page.color,
                                  page.color.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                page.icon,
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              page.color,
                              page.color.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            page.icon,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.5),
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                    // Icon badge
                    Positioned(
                      bottom: AppSpacing.lg,
                      right: AppSpacing.lg,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            page.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Content section
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  page.title,
                  style: AppTypography.displaySmall.copyWith(
                    color: page.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Text(
                    page.description,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Action button
          AppButton(
            text: _currentIndex == _pages.length - 1 ? 'Эхлэх' : 'Үргэлжлүүлэх',
            onPressed: _nextPage,
            isFullWidth: true,
            size: AppButtonSize.large,
            trailingIcon: _currentIndex == _pages.length - 1
                ? Icons.rocket_launch
                : Icons.arrow_forward,
          ),
          // Sign in link
          if (_currentIndex == _pages.length - 1) ...[
            const SizedBox(height: AppSpacing.md),
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
}

enum OnboardingPageType { content, goalSelection }

class OnboardingPage {
  final OnboardingPageType type;
  final String title;
  final String description;
  final String? image;
  final String icon;
  final Color color;

  OnboardingPage({
    this.type = OnboardingPageType.content,
    required this.title,
    required this.description,
    this.image,
    required this.icon,
    required this.color,
  });
}
