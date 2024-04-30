import 'package:flutter/material.dart';
import 'package:flutter_application/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  final String name;
  final String biography;
  final String imageUrl;

  const ProfilePage({
    super.key,
    required this.name,
    required this.biography,
    required this.imageUrl,
  });

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
                height: 220.0,
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                radius: 70.0,
                backgroundImage: NetworkImage(imageUrl),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(biography, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => EditProfilePage(),
          ),
        ],
      ),
    );
  }
  void goToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) => EditProfilePage()),
      ),
    );
  }
}
