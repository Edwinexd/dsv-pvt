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
  String? age;
  bool ageEntered = false;
  bool bioEntered = false;
  bool idEntered = false;

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile Saved!')));
    }
  }

  Widget buildInterestCheckbox(String interest) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: interests[interest],
          onChanged: (bool? newValue) {
            setState(() {
              interests[interest] = newValue ?? false;
            });
          },
        ),
        Text(interest),
      ],
    );
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
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(16.0),
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
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
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
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          onChanged: (text) {
                            setState(() {
                              ageEntered = text
                                  .isNotEmpty; // Update state based on input
                            });
                          },
                          decoration: InputDecoration(
                            labelText: ageEntered
                                ? null
                                : 'Age', 
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: selectedLocation == null
                                ? 'Location'
                                : null,
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          value: selectedLocation,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedLocation = newValue;
                            });
                          },
                          items: locations
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    onChanged: (text) {
                      setState(() {
                        bioEntered = text.isNotEmpty;
                      });
                    },
                    maxLines: null,
                    minLines: 3,
                    decoration: InputDecoration(
                      labelText: bioEntered ? null : 'About Me',
                      alignLabelWithHint: true,
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  
                  SizedBox(height: 20),

                  TextFormField(
                    onChanged: (text) {
                      setState(() {
                        idEntered = text.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: idEntered ? null : 'Runner ID(Optional)',
                      alignLabelWithHint: true,
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  
                  SizedBox(height: 20),

                  const Row(
                    children: [
                      Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Color.fromARGB(255, 16, 14, 99),
                            ),
                          ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Interests',
                            style: TextStyle(color: Color.fromARGB(255, 16, 14, 99),fontSize: 16)),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromARGB(255, 16, 14, 99),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 5),

                  GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    shrinkWrap: true,
                    crossAxisCount: 2, //No. of boxes per row
                    childAspectRatio: 4, //space vertically
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 2,
                    physics:
                      NeverScrollableScrollPhysics(),
                    children: interests.keys.map((String key) {
                      return buildInterestCheckbox(key);
                    }).toList(),
                  ),
                  
                  SizedBox(height: 20),

                  const Row(
                    children: [
                      Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Color.fromARGB(255, 16, 14, 99),
                            ),
                          ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Skill Level',
                            style: TextStyle(color: Color.fromARGB(255, 16, 14, 99),fontSize: 16)),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromARGB(255, 16, 14, 99),
                        ),
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

                  SizedBox(height: 20,),

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
