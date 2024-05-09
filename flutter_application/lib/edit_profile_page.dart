import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/background_for_pages.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  int _skillLevel = 0;
  String imageUrl = 'https://example.com/profile_placeholder.png';
  bool signedUpToMidnattsloppet = false;
  Map<String, bool> interests = {
    'Running': false,
    'Yoga': false,
    'Walking': false,
    'Swimming': false,
    'Workout': false,
    'Cycling': false,
  };

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile Saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Edit Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Username',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                          onPressed: () {
                            // Implement the functionality to edit the username
                          },
                        ),
                      ],
                    ),
                  ),
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
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color.fromARGB(255, 255, 92, 00)),
                              onPressed: () {
                                // Implement functionality to edit profile image
                              }),
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Bio'),
                  ),
                  SkillLevelSlider(
                    initialSkillLevel: _skillLevel,
                    onSkillLevelChanged: (newLevel) {
                      setState(() {
                        _skillLevel = newLevel;
                      });
                    },
                  ),
                  MyButton(
                    buttonText: 'Save Profile',
                    onTap: _saveProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
