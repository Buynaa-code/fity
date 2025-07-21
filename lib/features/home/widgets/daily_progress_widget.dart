import 'package:flutter/material.dart';

class DailyProgressWidget extends StatelessWidget {
  const DailyProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('Өдрийн дүүргэлт'),
            SizedBox(height: 8),
            LinearProgressIndicator(value: 0.6),
          ],
        ),
      ),
    );
  }
}