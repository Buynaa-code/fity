import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/home/bloc/bloc.dart';
import 'features/workout/bloc/bloc.dart';
import 'features/qr_entry/bloc/bloc.dart';

class FityApp extends StatelessWidget {
  const FityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeBloc()..add(LoadHomeData()),
        ),
        BlocProvider(
          create: (context) => WorkoutBloc()..add(LoadWorkouts()),
        ),
        BlocProvider(
          create: (context) => QREntryBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'FitZone',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryColor: const Color(0xFFFE7409),
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFE7409),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}