import 'package:flutter/material.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Жин'),
      ),
      body: const Center(
        child: Text('Жингийн хяналт хуудас'),
      ),
    );
  }
}