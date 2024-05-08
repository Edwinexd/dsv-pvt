import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/edit_profile_page.dart';
import 'package:flutter_application/settings.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final String name;
  final String biography;
  final String imageUrl;
  final int joinedYear;

  const ProfilePage({
    super.key,
    required this.username,
    required this.name,
    required this.biography,
    required this.imageUrl,
    required this.joinedYear,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title:
              const Text('Profile Page', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                bool initialDarkMode = false;
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => SettingsPage(
                            onToggleDarkMode: (bool isDarkMode) {
                              print("Dark mode toggled: $isDarkMode");
                            },
                            initialDarkMode: initialDarkMode,
                          )),
                );
              },
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(username,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 70.0,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    Positioned(
                      right: -10,
                      top: 95,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color.fromARGB(255, 255, 92, 00)),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditProfilePage()));
                            }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(name, style: const TextStyle(fontSize: 20)),
                Text('Joined: $joinedYear',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    biography,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                SkillLevelSlider(
                  initialSkillLevel: 2,
                  onSkillLevelChanged: (newLevel) {
                    print("Skill level updated to: $newLevel");
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // View achievements
                  },
                  child: const Text('Trophies'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
