import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/profile_avatar.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/my_achievements.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatelessWidget {
  final String username;
  final String name;
  final String biography;
  final String imageUrl;
  final DateTime joinedDate;
  final List<String> userInterests;

  const UserProfilePage({
    super.key,
    required this.username,
    required this.name,
    required this.biography,
    required this.imageUrl,
    required this.joinedDate,
    required this.userInterests,
  });

  @override
  Widget build(BuildContext context) {
    final interestsString = userInterests.join(', ');

    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                const SizedBox(height: 30),
                ProfileAvatar(
                  imageUrl: imageUrl,
                  iconButtonConfig: IconButtonConfig(
                    icon: Icons.abc,
                    onPressed: () {},
                    showIcon: false,
                  ),
                ),
                const SizedBox(height: 10),
                Text(name, style: const TextStyle(fontSize: 20)),
                Text(
                    'Joined: ${DateFormat('EEEE dd MMMM y').format(joinedDate)}',
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
                const SizedBox(height: 10),
                Text('Interests: $interestsString',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                const SkillLevelSlider(
                  initialSkillLevel: 2,
                  isSliderLocked: true,
                ),
                const SizedBox(height: 40),
                MyButton(
                  buttonText: '$username\'s Trophies',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyAchievements()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
