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

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/components/my_button.dart';
import 'package:flutter_application/components/profile_avatar.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/edit_profile_page.dart';
import 'package:flutter_application/models/profile.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/my_achievements.dart';
import 'package:flutter_application/settings.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;

  const ProfilePage({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  User? me;
  Profile? profile;
  ImageProvider? profileImage;
  bool _isPrivateProfile = false;

  Future<void> _fetchProfile() async {
    try {
      final meObj = await BackendService().getMe();
      final userObj = await BackendService().getUser(widget.userId ?? meObj.id);
      final profile = await BackendService().getProfile(userObj.id);
      setState(() {
        this.me = meObj;
        this.user = userObj;
        this.profile = profile;
      });
      ImageProvider image =
          await BackendService().getImage(profile.imageId ?? '404');
      setState(() {
        profileImage = image;
      });
    } catch (e) {
      setState(() {
        _isPrivateProfile = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(_fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    if (_isPrivateProfile) {
      return DefaultBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Profile Page', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Center(
            child: Text(
              'This profile is private',
              style: TextStyle(fontSize: 26),
            ),
          ),
        ),
      );
    }

    if (user == null || profile == null) {
      return DefaultBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Profile Page', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: me != null && user != null && me!.id == user!.id
              ? <Widget>[
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
                          ),
                        ),
                      );
                    },
                  ),
                ]
              : null,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(user!.userName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                profileImage == null
                    ? const CircularProgressIndicator()
                    : ProfileAvatar(
                        image: profileImage!,
                        iconButtonConfig: me != null &&
                                user != null &&
                                me!.id == user!.id
                            ? IconButtonConfig(
                                icon: Icons.edit,
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => EditProfilePage(
                                          initialProfile: profile!)));
                                },
                              )
                            : null,
                      ),
                const SizedBox(height: 10),
                Text(user!.fullName, style: const TextStyle(fontSize: 20)),
                Text(
                    'Joined: ${DateFormat('EEEE dd MMMM y').format(user!.dateCreated)}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                // Interests, profile.interests is a json encoded array
                Text(
                    'Interests: ${JsonDecoder().convert(profile!.interests).join(', ')}',
                    style: const TextStyle(fontSize: 16)),
                // I'm sorry UX / Edwin
                profile!.runnerId != null
                    ? Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 10),
                        width: 300,
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blue, Colors.green],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Midnattsloppet Runner',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),

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
                    profile!.description,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(height: 20),
                SkillLevelSlider(
                  initialSkillLevel: profile!.skillLevel,
                  isSliderLocked: true,
                ),
                const SizedBox(height: 20),
                MyButton(
                  buttonText: 'Achievements',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyAchievements()));
                  },
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
