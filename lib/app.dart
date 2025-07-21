import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/home/screens/home_screen.dart';
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
        title: 'Fity',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}