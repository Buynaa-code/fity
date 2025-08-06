import 'package:flutter/material.dart';

class GymInfoScreen extends StatelessWidget {
  const GymInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заалны мэдээлэл'),
      ),
      body: const Center(
        child: Text('Заалны мэдээлэл хуудас'),
      ),
    );
  }
}