import 'package:flutter/material.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Гишүүнчлэл'),
      ),
      body: const Center(
        child: Text('Гишүүнчлэлийн хуудас'),
      ),
    );
  }
}