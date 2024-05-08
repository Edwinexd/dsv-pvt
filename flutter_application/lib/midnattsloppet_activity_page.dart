import 'package:flutter/material.dart';

class MidnattsloppetActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Midnattsloppet Activity'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Midnattsloppet Activity Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}