/*
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
import 'dart:async';
import 'dart:convert';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application/components/custom_divider.dart';
import 'package:flutter_application/components/profile_avatar.dart';
import 'package:flutter_application/age_data.dart';
import 'package:flutter_application/cities.dart';
import 'package:flutter_application/components/custom_dropdown.dart';
import 'package:flutter_application/components/custom_text_field.dart';
import 'package:flutter_application/components/interests_grid.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/checkbox_animation.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application/components/scroll_button.dart'; // Import the ScrollButton

class EditProfilePage extends StatefulWidget {
  final Profile initialProfile;

  EditProfilePage({
    required this.initialProfile,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollButton = true;
  ImageProvider profileImage = const AssetImage('lib/images/splash.png');
  XFile? newProfileImage;
  String age = '';
  String selectedLocation = '';
  String bio = '';
  bool bioEntered = true;
  bool _showCheck = false;
  String? runnerId;
  Map<String, bool> interests = {
    'Running': false,
    'Yoga': false,
    'Walking': false,
    'Swimming': false,
    'Workout': false,
    'Cycling': false,
  };
  int _skillLevel = 0;
  bool isPrivate = false;

  Future<void> setProfileImageFromId(String imageId) async {
    final image = await BackendService().getImage(imageId);
    setState(() {
      profileImage = image;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile.imageId != null) {
      unawaited(setProfileImageFromId(widget.initialProfile.imageId!));
    }
    selectedLocation = widget.initialProfile.location; // TODO: profile is incomplete
    age = widget.initialProfile.age.toString();
    bio = widget.initialProfile.description;
    bioEntered = true;
    runnerId = widget.initialProfile.runnerId;
    _skillLevel = widget.initialProfile.skillLevel;
    for (String interest in JsonDecoder().convert(widget.initialProfile.interests)) {
      interests[interest] = true;
    }
    isPrivate = widget.initialProfile.isPrivate;

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showScrollButton) {
          setState(() {
            _showScrollButton = false;
          });
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_showScrollButton) {
          setState(() {
            _showScrollButton = true;
          });
        }
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!bioEntered) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all the fields')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final user = await BackendService().getMe();

    final interests = <String>[];
    for (final interest in this.interests.keys) {
      if (this.interests[interest]!) {
        interests.add(interest);
      }
    }

    await BackendService().updateProfile(user.id, description: bio, age: int.parse(age),
        interests: const JsonEncoder().convert(interests), skillLevel: _skillLevel, isPrivate: isPrivate, runnerId: runnerId == null || runnerId!.isEmpty ? null : runnerId);

    if (newProfileImage != null) {
      await BackendService().uploadProfilePicture(newProfileImage!);
    }

    Navigator.pop(context);
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              AnimatedCheckIcon(),
              SizedBox(width: 10),
              Text('Profile Saved!'),
            ],
          ),
        ),
      );
      setState(() {
        _showCheck = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _showCheck = false;
        });
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final ImageSource? source = await showDialog<ImageSource?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) {
      return;
    }
    final XFile? image = await picker.pickImage(
      source: source,
      requestFullMetadata: false,
    );
    if (image == null) {
      return;
    }

    newProfileImage = image;

    ImageProvider temp = MemoryImage(await image.readAsBytes());
    setState(() {
      profileImage = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
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
                      ProfileAvatar(
                        image: profileImage,
                        iconButtonConfig: IconButtonConfig(
                          icon: Icons.camera_alt,
                          onPressed: () {
                            _pickImage();
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: CustomDropdown<int>(
                              items: AgeData.ageList,
                              selectedValue: int.tryParse(age),
                              onChanged: (newValue) {
                                setState(() {
                                  age = newValue.toString();
                                });
                              },
                              labelText: 'Age',
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
                                  if (newValue != null) {
                                    selectedLocation = newValue;
                                  }
                                });
                              },
                              labelText: 'Location',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        labelText: 'About Me',
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
                        labelText: 'Runner ID (Optional)',
                        onChanged: (text) {
                          setState(() {
                            runnerId = text.isNotEmpty ? text : null;
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
                      ListTile(
                        title: const Text('Private Profile'),
                        trailing: Switch(
                          value: isPrivate,
                          onChanged: (value) {
                            setState(() {
                              isPrivate = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
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
            ScrollButton(
              scrollController: _scrollController,
              isVisible: _showScrollButton,
            ),
          ],
        ),
      ),
    );
  }
}
