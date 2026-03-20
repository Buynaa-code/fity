import 'package:flutter/material.dart';
import 'presentation/pages/splash/splash_screen.dart';
import 'presentation/pages/onboarding/onboarding_screen.dart';
import 'presentation/pages/home/home_screen_v2.dart';
import 'presentation/pages/auth/login_screen.dart';
import 'presentation/pages/auth/register_screen.dart';
import 'presentation/pages/profile/profile_screen.dart';
import 'presentation/pages/challenges/badges_screen.dart';
import 'features/water_tracker/presentation/pages/water_tracker_screen.dart';
import 'features/statistics/presentation/pages/statistics_screen.dart';
import 'features/supplement_shop/presentation/screens/product_list_screen.dart';
import 'features/supplement_shop/presentation/screens/order_history_screen.dart';

class FityMaterialApp extends StatelessWidget {
  const FityMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: const Color(0xFFFE7409),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFE7409),
        ),
        fontFamily: 'Rubik',
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreenV2(),
        '/profile': (context) => const ProfileScreen(),
        '/water-tracker': (context) => const WaterTrackerScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/shop': (context) => const ProductListScreen(),
        '/order-history': (context) => const OrderHistoryScreen(),
        '/badges': (context) => const BadgesScreen(),
      },
    );
  }
}
