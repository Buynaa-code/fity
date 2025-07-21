import 'package:flutter/material.dart';

class WorkoutListScreen extends StatelessWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дасгал хөтөлбөр'),
      ),
      body: const Center(
        child: Text('Дасгал хөтөлбөрийн жагсаалт'),
      ),
    );
  }
}