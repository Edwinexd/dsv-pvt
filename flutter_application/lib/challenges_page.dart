import 'package:flutter/material.dart';

class ChallengesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Challenges Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}