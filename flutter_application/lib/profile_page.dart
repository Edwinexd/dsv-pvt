import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
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
                          onPressed: () => goToEditProfile(context),
                        ),
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
                const SkillLevelSlider(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // View achievements
                  },
                  child: const Text('View Achievements'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
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

class SkillLevelSlider extends StatefulWidget {
  const SkillLevelSlider({super.key});

  @override
  SkillLevelSliderState createState() => SkillLevelSliderState();
}

class SkillLevelSliderState extends State<SkillLevelSlider> {
  int _skillLevel = 0;
  final List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
    'Master'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 400,
          child: Slider(
            value: _skillLevel.toDouble(),
            min: 0,
            max: 4,
            divisions: 4,
            label: skillLevels[_skillLevel],
            onChanged: (double value) {
              setState(() {
                _skillLevel = value.round();
              });
            },
            activeColor: const Color.fromARGB(255, 255, 92, 00),
            inactiveColor: const Color.fromARGB(255, 206, 150, 118),
          ),
        ),
        Text(skillLevels[_skillLevel], style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
