import 'package:flutter/material.dart';
import 'package:flutter_application/components/skill_level_slider.dart';

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

  List<String> skillLevels = [
    'Beginner: 10 - 8 min/km',
    'Intermediate: 8 - 6 min/km',
    'Advanced: 6 - 5 min/km',
    'Professional: 5 - 4 min/km',
    'Elite: < 4 min/km'
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  // Use a placeholder image if no image is selected
                  backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                  child: const Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 15,
                      child: Icon(Icons.camera_alt, color: Colors.blue, size: 22),
                    ),
                  ),
                ),
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
              decoration: InputDecoration(labelText: 'Interests'),
              validator: (value) => value!.isEmpty ? 'Interests cannot be empty' : null,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
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
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
