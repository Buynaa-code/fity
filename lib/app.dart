import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/pages/splash/splash_screen.dart';
import 'presentation/pages/onboarding/onboarding_screen.dart';
import 'presentation/pages/home/home_screen.dart';
import 'presentation/pages/auth/login_screen.dart';
import 'presentation/pages/auth/register_screen.dart';
import 'presentation/pages/profile/profile_screen.dart';
import 'presentation/bloc/home/bloc.dart';
import 'presentation/bloc/workout/bloc.dart';
import 'presentation/bloc/qr_entry/bloc.dart';

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