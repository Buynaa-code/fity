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
}
