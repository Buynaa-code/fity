import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../features/gamification/presentation/bloc/badge_bloc.dart';
import '../../../features/gamification/presentation/pages/badges_screen.dart' as gamification;

/// Wrapper to provide BLoC and redirect to the new badges screen
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<BadgeBloc>(),
      child: const gamification.BadgesScreen(),
    );
  }
}
