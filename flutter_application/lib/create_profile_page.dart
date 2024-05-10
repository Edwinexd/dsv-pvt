import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application/home_page.dart';

import 'controllers/backend_service.dart';

//test Mac

class CreateProfilePage extends StatefulWidget {
  final bool forced;

  CreateProfilePage({this.forced = false});

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _interestsController = TextEditingController();
  int _skillLevel = 0;  // Manage skill level as an integer
  ImageProvider _imageProvider = AssetImage('');
  final BackendService _backendService = BackendService();

  // Updated skill levels with pace descriptions
  List<String> skillLevels = [
    'Beginner: 10 - 8 min/km',
    'Intermediate: 8 - 6 min/km',
    'Advanced: 6 - 5 min/km',
    'Professional: 5 - 4 min/km',
    'Elite: < 4 min/km'
  ];

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = await _backendService.getMe();
      // TODO: Frontend pending change of fields
      await _backendService.createProfile(user.id, "description", 18, _interestsController.text, _skillLevel, false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile Created!'))
      );
      if (widget.forced) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  }

  void _pickImage() {
    setState(() {
      _imageProvider = NetworkImage('https://example.com/new_profile.jpg'); // Simulate image change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Profile'), automaticallyImplyLeading: !widget.forced),
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
                  backgroundImage: _imageProvider,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Skill Level:' /*${skillLevels[_skillLevel]}*/, style: TextStyle(fontSize: 16)),
                  Slider(
                    value: _skillLevel.toDouble(),  // Convert to double for the Slider
                    min: 0,
                    max: 4,
                    divisions: 4,
                    //label:skillLevels[_skillLevel],
                    onChanged: (double value) {
                      setState(() {
                        _skillLevel = value.round();  // Convert back to int after change
                      });
                    },
                  ),
                  Container(
                        alignment: Alignment.center,
                        child: Text('${skillLevels[_skillLevel]}', style: TextStyle(fontSize: 12)),
                  )
                ],
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
