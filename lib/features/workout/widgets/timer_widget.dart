import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            Text('00:00', style: TextStyle(fontSize: 32)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: null,
                  child: Text('Эхлэх'),
                ),
                ElevatedButton(
                  onPressed: null,
                  child: Text('Зогсоох'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}