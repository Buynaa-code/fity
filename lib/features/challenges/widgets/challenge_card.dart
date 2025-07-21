import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('Challenge нэр'),
            SizedBox(height: 8),
            Text('Challenge тайлбар'),
            SizedBox(height: 8),
            LinearProgressIndicator(value: 0.7),
          ],
        ),
      ),
    );
  }
}