import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/map_screen.dart';
import 'package:flutter_application/components/skill_level_slider.dart';
import 'package:flutter_application/views/group_page.dart';

class EditGroupPage extends StatefulWidget {
  final Group group;

  const EditGroupPage({super.key, required this.group});

  @override
  EditGroupPageState createState() => EditGroupPageState();
}

class EditGroupPageState extends State<EditGroupPage> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = false;
  int _memberLimit = 10; // Default member limit, we have to get the current member limit maybe?
  int _skillLevel = 0; // Default skill level, we have to get the current skill level.
  String _errorMessage = '';


  void saveChanges() async {
    String name = _nameController.text.trim();
    String description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      setState(() {
        _errorMessage = 'Group name and description cannot be empty!';
      });
      return;
      // Method to save changes
      // If it saved successfully it will redirect to the group page
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Group Saved!')));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  GroupPage(group: widget.group, isMember: true)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Edit Group',
        context: context,
        showBackButton: true,
      ),
      body: DefaultBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MapScreen(
                        onLocationSelected: (location) {
                          setState(() {
                            _locationController.text = location.address;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      suffixIcon: Icon(Icons.location_on),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Skill Level:',
                style: TextStyle(fontSize: 16),
              ),
              SkillLevelSlider(
                initialSkillLevel: _skillLevel,
                onSkillLevelChanged: (newLevel) {
                  setState(() {
                    _skillLevel = newLevel;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  const Text(
                    'Public',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() {
                        _isPublic = value;
                      });
                    },
                  ),
                  const Text(
                    'Private',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  const SizedBox(width: 16.0),
                  const Text(
                    'Member Limit:',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      initialValue: _memberLimit.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _memberLimit = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Group Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    saveChanges();
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
