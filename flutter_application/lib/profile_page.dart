import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
              radius: 50.0,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
            const SizedBox(height: 10),
            const Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Software Developer, Flutter Enthusiast.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Implement editing functionality here
              },
            ),
          ],
        ),
      ),
    );
  }
}
