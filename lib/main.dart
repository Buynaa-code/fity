import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'features/water_tracker/presentation/bloc/water_bloc.dart';
import 'features/water_tracker/presentation/bloc/water_event.dart';
import 'features/statistics/presentation/bloc/statistics_bloc.dart';
import 'features/statistics/presentation/bloc/statistics_event.dart';
import 'features/gamification/presentation/bloc/badge_bloc.dart';
import 'features/gamification/presentation/bloc/badge_event.dart';
import 'features/health/presentation/bloc/health_bloc.dart';
import 'features/health/presentation/bloc/health_event.dart';
import 'features/user/presentation/bloc/user_bloc.dart';
import 'features/user/presentation/bloc/user_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const FityApp());
}

class FityApp extends StatelessWidget {
  const FityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WaterBloc>(
          create: (context) => di.sl<WaterBloc>()..add(const LoadWeeklySummary()),
        ),
        BlocProvider<StatisticsBloc>(
          create: (context) => di.sl<StatisticsBloc>()..add(const LoadStatistics()),
        ),
        BlocProvider<BadgeBloc>(
          create: (context) => di.sl<BadgeBloc>()..add(const LoadBadges()),
        ),
        BlocProvider<HealthBloc>(
          create: (context) => di.sl<HealthBloc>()..add(const LoadHealthData()),
        ),
        BlocProvider<UserBloc>(
          create: (context) => di.sl<UserBloc>()..add(const LoadUser()),
        ),
      ],
      child: const FityMaterialApp(),
    );
  }
}
