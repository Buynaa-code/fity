import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Water Tracker
import '../../features/water_tracker/data/datasources/water_local_datasource.dart';
import '../../features/water_tracker/data/repositories/water_repository_impl.dart';
import '../../features/water_tracker/domain/repositories/water_repository.dart';
import '../../features/water_tracker/presentation/bloc/water_bloc.dart';

// Statistics
import '../../features/statistics/data/datasources/statistics_local_datasource.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/domain/repositories/statistics_repository.dart';
import '../../features/statistics/presentation/bloc/statistics_bloc.dart';

// Gamification (Badges)
import '../../features/gamification/data/datasources/badge_local_datasource.dart';
import '../../features/gamification/data/repositories/badge_repository_impl.dart';
import '../../features/gamification/domain/repositories/badge_repository.dart';
import '../../features/gamification/presentation/bloc/badge_bloc.dart';

// Health
import '../services/health_service.dart';
import '../../features/health/presentation/bloc/health_bloc.dart';

// User
import '../services/user_preferences_service.dart';
import '../../features/user/presentation/bloc/user_bloc.dart';

// Marathon
import '../../features/marathon/data/repositories/marathon_repository.dart';
import '../../features/marathon/presentation/bloc/marathon_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // === Water Tracker Feature ===
  // Data sources
  sl.registerLazySingleton<WaterLocalDatasource>(
    () => WaterLocalDatasourceImpl(prefs: sl()),
  );

  // Repositories
  sl.registerLazySingleton<WaterRepository>(
    () => WaterRepositoryImpl(localDatasource: sl()),
  );

  // BLoC
  sl.registerFactory(
    () => WaterBloc(repository: sl()),
  );

  // === Statistics Feature ===
  // Data sources
  sl.registerLazySingleton<StatisticsLocalDatasource>(
    () => StatisticsLocalDatasourceImpl(prefs: sl()),
  );

  // Repositories
  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(localDatasource: sl()),
  );

  // BLoC
  sl.registerFactory(
    () => StatisticsBloc(repository: sl()),
  );

  // === Gamification (Badges) Feature ===
  // Data sources
  sl.registerLazySingleton<BadgeLocalDatasource>(
    () => BadgeLocalDatasource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<BadgeRepository>(
    () => BadgeRepositoryImpl(sl()),
  );

  // BLoC
  sl.registerFactory(
    () => BadgeBloc(repository: sl()),
  );

  // === Health Feature ===
  // Services
  sl.registerLazySingleton<HealthService>(
    () => HealthService(),
  );

  // BLoC
  sl.registerFactory(
    () => HealthBloc(
      healthService: sl(),
      preferencesService: sl(),
    ),
  );

  // === User Feature ===
  // Services
  sl.registerLazySingleton<UserPreferencesService>(
    () => UserPreferencesService(prefs: sl()),
  );

  // BLoC
  sl.registerFactory(
    () => UserBloc(prefs: sl()),
  );

  // === Marathon Feature ===
  // Repositories
  sl.registerLazySingleton<MarathonRepository>(
    () => MarathonRepository(sl()),
  );

  // BLoC
  sl.registerFactory(
    () => MarathonBloc(sl()),
  );
}
