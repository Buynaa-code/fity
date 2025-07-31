import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const primaryColor = Color(0xFFFE7409);

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Дасгал тамираа бичлэг хийх',
      description:
          'Дасгал тамир, прогрессоо дэлгэрэнгүй дүн шинжилгээ болон мэдээллээр хянаж байгаарай',
      image:
          'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop&q=90',
      icon: '🏃‍♂️',
      color: const Color(0xFF4CAF50),
    ),
    OnboardingData(
      title: 'Зорилго биелүүлэх',
      description:
          'Хувийн зорилго тавиад амжилт руу дагалдах замыг хянаж байгаарай',
      image:
          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=600&fit=crop&q=90',
      icon: '🎯',
      color: const Color(0xFF2196F3),
    ),
    OnboardingData(
      title: 'Сэтгэл хөдлөл барих',
      description:
          'Бидний нийгэмлэгт нэгдэж, сорилт шагнал авч урам зориг барьцгаана уу',
      image:
          'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&h=600&fit=crop&q=90',
      icon: '💪',
      color: const Color(0xFFF44336),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _skipOnboarding() {
    _navigateToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text(
              'Алгасах',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Hero Image Section - Much larger and prominent
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: _onboardingData[index].color.withOpacity(0.4),
                                blurRadius: 25,
                                offset: const Offset(0, 15),
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Background image - full size
                                Image.network(
                                  _onboardingData[index].image,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _onboardingData[index].color.withOpacity(0.3),
                                            _onboardingData[index].color.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(color: Colors.white),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            _onboardingData[index].color,
                                            _onboardingData[index].color.withOpacity(0.8),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.fitness_center, size: 60, color: Colors.white),
                                      ),
                                    );
                                  },
                                ),
                                // Gradient overlay for better text visibility
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.3),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                      stops: const [0.0, 0.7, 1.0],
                                    ),
                                  ),
                                ),
                                // Icon overlay
                                Positioned(
                                  bottom: 30,
                                  right: 30,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(40),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _onboardingData[index].icon,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Content Section
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // Title with animation
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 800),
                              child: Text(
                                _onboardingData[index].title,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: _onboardingData[index].color,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Description with better styling
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: const Duration(milliseconds: 1000),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  _onboardingData[index].description,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    height: 1.6,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Enhanced Bottom section
          Container(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 40),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Enhanced Page indicators
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: _currentIndex == index ? 30 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentIndex == index 
                              ? primaryColor 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: _currentIndex == index 
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ] 
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Navigation buttons row
                Row(
                  children: [
                    // Back button (if not first page)
                    if (_currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _previousPage();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Буцах',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    
                    if (_currentIndex > 0) const SizedBox(width: 15),
                    
                    // Main action button
                    Expanded(
                      flex: _currentIndex > 0 ? 2 : 1,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _nextPage();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            shadowColor: primaryColor.withOpacity(0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentIndex == _onboardingData.length - 1
                                    ? 'Эхлэх'
                                    : 'Дараах',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentIndex == _onboardingData.length - 1
                                    ? Icons.rocket_launch
                                    : Icons.arrow_forward,
                                size: 20,
                              ),
                            ],
                          ),
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
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final String icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
    required this.color,
  });
}

// Custom painter for sports-themed background pattern
class SportsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw some sports-themed geometric patterns
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final center = Offset(
          size.width * (0.2 + i * 0.3),
          size.height * (0.2 + j * 0.3),
        );

        // Draw circles
        canvas.drawCircle(center, 15, paint);

        // Draw lines
        canvas.drawLine(
          Offset(center.dx - 10, center.dy),
          Offset(center.dx + 10, center.dy),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - 10),
          Offset(center.dx, center.dy + 10),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
