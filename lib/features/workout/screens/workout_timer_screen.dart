import 'package:flutter/material.dart';

class WorkoutTimerScreen extends StatelessWidget {
  const WorkoutTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дасгалын таймер'),
      ),
      body: const Center(
        child: Text('Дасгалын таймер хуудас'),
      ),
    );
  }
}