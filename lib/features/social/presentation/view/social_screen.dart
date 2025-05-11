import 'package:flutter/material.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Social'),
      ),
      body: Center(
        child: Text(
          'Interacciones sociales y logros.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
