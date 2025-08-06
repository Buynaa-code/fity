import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Хувийн мэдээлэл'),
      ),
      body: const Center(
        child: Text('Хувийн мэдээллийн хуудас'),
      ),
    );
  }
}