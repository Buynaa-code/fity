import 'package:flutter/material.dart';

class CalorieScreen extends StatelessWidget {
  const CalorieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калори'),
      ),
      body: const Center(
        child: Text('Калорийн хяналт хуудас'),
      ),
    );
  }
}