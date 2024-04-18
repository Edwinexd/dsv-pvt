import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                height: 220.0, // Height of the rectangle
                decoration: BoxDecoration(
                  color: Colors.deepOrange, // Color of the rectangle
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Shadow color with some transparency
                      spreadRadius: 0, // No spread radius
                      blurRadius: 10, // Blur radius
                      offset: Offset(0, 5), // Shadow position
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 70.0,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Axel Andersson', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
    );
  }
}
