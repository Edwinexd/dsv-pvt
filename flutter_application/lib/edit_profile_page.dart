import 'package:flutter/material.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/my_textfield.dart';
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
  String? selectedLocation;
  List<String> locations = ['Stockholm', 'Malmö', 'Göteborg'];
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
        body: SingleChildScrollView(
          // Ensures the whole page content is scrollable
          child: Form(
            key: _formKey,
            child: Padding(
              padding:
                  EdgeInsets.all(16.0), // Consistent padding around the content
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Username',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Theme.of(context).primaryColor),
                        onPressed: () {
                          // Add functionality to edit username
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                              icon: const Icon(Icons.camera_alt,
                                  color: Color.fromARGB(255, 255, 92, 00)),
                              onPressed: () {
                                // Add functionality to edit profile image
                              }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  const MyTextField(hintText: 'Name', obscureText: false),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Location',
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade400, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400,),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Select location',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                    ),
                    value: selectedLocation,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedLocation = newValue;
                      });
                    },
                    items:
                        locations.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Bio'),
                  ),
                  SizedBox(height: 20),
                  SkillLevelSlider(
                    initialSkillLevel: _skillLevel,
                    onSkillLevelChanged: (newLevel) {
                      setState(() {
                        _skillLevel = newLevel;
                      });
                    },
                  ),
                  SizedBox(height: 20),
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
