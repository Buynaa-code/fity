import 'package:flutter/material.dart';

class FityApp extends StatelessWidget {
  const FityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fity',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Fity App'),
        ),
      ),
    );
  }
}