import 'package:flutter/material.dart';
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
      description: 'Дасгал тамир, прогрессоо дэлгэрэнгүй дүн шинжилгээ болон мэдээллээр хянаж байгаарай',
      image: 'assets/png/icon.png',
      icon: '🏃‍♂️',
      color: const Color(0xFF4CAF50),
    ),
    OnboardingData(
      title: 'Зорилго биелүүлэх',
      description: 'Хувийн зорилго тавиад амжилт руу дагалдах замыг хянаж байгаарай',
      image: 'assets/png/icon.png',
      icon: '🎯',
      color: const Color(0xFF2196F3),
    ),
    OnboardingData(
      title: 'Сэтгэл хөдлөл барих',
      description: 'Бидний нийгэмлэгт нэгдэж, сорилт шагнал авч урам зориг барьцгаана уу',
      image: 'assets/png/icon.png',
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
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
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
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
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      const Spacer(),
                      
                      // Image section with sports theme
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _onboardingData[index].color,
                              _onboardingData[index].color.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _onboardingData[index].color.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background pattern
                            Positioned.fill(
                              child: CustomPaint(
                                painter: SportsPatternPainter(),
                              ),
                            ),
                            // Main content
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Large emoji icon
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _onboardingData[index].icon,
                                        style: const TextStyle(
                                          fontSize: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // App logo
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Image.asset(
                                        _onboardingData[index].image,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Title
                      Text(
                        _onboardingData[index].title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        _onboardingData[index].description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const Spacer(),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Bottom section
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? primaryColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentIndex == _onboardingData.length - 1 
                          ? 'Эхлэх' 
                          : 'Дараах',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
    final paint = Paint()
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