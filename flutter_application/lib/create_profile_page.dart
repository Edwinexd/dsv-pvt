import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application/home_page.dart';
import 'controllers/backend_service.dart';
import 'package:flutter_application/components/custom_divider.dart';
import 'package:flutter_application/age_data.dart';
import 'package:flutter_application/cities.dart';
import 'package:flutter_application/components/custom_dropdown.dart';
import 'package:flutter_application/components/custom_text_field.dart';
import 'package:flutter_application/components/interests_grid.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/background_for_pages.dart';

class CreateProfilePage extends StatefulWidget {
  final bool forced;

  CreateProfilePage({this.forced = false});

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  int _skillLevel = 0;
  ImageProvider profileImage = const AssetImage('lib/images/splash.png');
  String? selectedLocation;
  String? age;
  String? bio;
  bool signedUpToMidnattsloppet = false;
  Map<String, bool> interests = {
    'Running': false,
    'Yoga': false,
    'Walking': false,
    'Swimming': false,
    'Workout': false,
    'Cycling': false,
  };
  bool ageEntered = false;
  bool bioEntered = false;
  bool idEntered = false;
  final BackendService _backendService = BackendService();

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = await _backendService.getMe();
      final interests = <String>[];
      for (final interest in this.interests.keys) {
        if (this.interests[interest]!) {
          interests.add(interest);
        }
      }
      // TODO This boolean is hardcoded, switch needed
      await _backendService.createProfile(user.id, bio!, int.parse(age!),
          const JsonEncoder().convert(interests), _skillLevel, false);
      // TODO: Need image bindings to also set the users profile image if they uploaded one
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile Created!')));
      if (widget.forced) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    // TODO: Image picker
    ImageProvider image = await _backendService.getImage("404");
    setState(() {
      profileImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Create Profile',
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: !widget.forced,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage,
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            child: Icon(Icons.camera_alt,
                                color: Colors.blue, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: CustomDropdown<int>(
                          items: AgeData.ageList,
                          selectedValue:
                              age != null ? int.tryParse(age!) : null,
                          onChanged: (newValue) {
                            setState(() {
                              age = newValue.toString();
                              ageEntered = true;
                            });
                          },
                          labelText: ageEntered ? null : 'Age',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: CustomDropdown<String>(
                          items: CityData.swedenCities,
                          selectedValue: selectedLocation,
                          onChanged: (newValue) {
                            setState(() {
                              selectedLocation = newValue;
                            });
                          },
                          labelText:
                              selectedLocation == null ? 'Location' : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    labelText: bioEntered ? null : 'About Me',
                    onChanged: (text) {
                      setState(() {
                        bioEntered = text.isNotEmpty;
                        bio = text;
                      });
                    },
                    maxLines: null,
                    minLines: 3,
                    filled: true,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    labelText: idEntered ? null : 'Runner ID(Optional)',
                    onChanged: (text) {
                      setState(() {
                        idEntered = text.isNotEmpty;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        child: CustomDivider(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Interests',
                            style: TextStyle(
                                color: Color.fromARGB(255, 16, 14, 99),
                                fontSize: 16)),
                      ),
                      Expanded(
                        child: CustomDivider(),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  InterestsGrid(
                    interests: interests,
                    onInterestChanged: (String interest, bool value) {
                      setState(() {
                        interests[interest] = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  const Row(
                    children: [
                      Expanded(
                        child: CustomDivider(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Skill Level',
                            style: TextStyle(
                                color: Color.fromARGB(255, 16, 14, 99),
                                fontSize: 16)),
                      ),
                      Expanded(
                        child: CustomDivider(),
                      ),
                    ],
                  ),
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
