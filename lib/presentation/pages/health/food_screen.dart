import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хоол'),
      ),
      body: const Center(
        child: Text('Хоолны хяналт хуудас'),
      ),
    );
  }
}