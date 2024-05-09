import 'package:flutter/material.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/background_for_pages.dart'; // Ensure this import is here

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _interestsController = TextEditingController();
  int _skillLevel = 0;

  String imageUrl = 'https://example.com/new_profile.jpg'; 

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile Saved!'))
      );
    }
  }

  void _pickImage() {
    setState(() {
      // Placeholder image change functionality
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Edit Profile', style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white,),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: <Widget>[
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    Positioned(
                      right: -10,
                      top: 95,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 255, 92, 00)),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => !value!.contains('@') ? 'Please enter a valid email' : null,
              ),
              TextFormField(
                controller: _interestsController,
                decoration: const InputDecoration(labelText: 'Interests'),
                validator: (value) => value!.isEmpty ? 'Interests cannot be empty' : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SkillLevelSlider(
                  initialSkillLevel: _skillLevel,
                  onSkillLevelChanged: (int newLevel) {
                    setState(() {
                      _skillLevel = newLevel;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
