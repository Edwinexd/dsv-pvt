import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

class GroupCreation extends StatefulWidget {
  const GroupCreation({super.key});

  @override
  GroupCreationState createState() => GroupCreationState();
}

class GroupCreationState extends State<GroupCreation> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = false;
  int _memberLimit = 10; //Default member limit
  int _skillLevel = 0; 
  bool _isGroupCreated = false;
  String _errorMessage = '';

  List<String> skillLevels = [
    'Beginner: 10 - 8 min/km',
    'Intermediate: 8 - 6 min/km',
    'Advanced: 6 - 5 min/km',
    'Professional: 5 - 4 min/km',
    'Elite: < 4 min/km'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a group'),
        backgroundColor: const Color.fromARGB(230, 60, 71, 133),
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        suffixIcon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Skill Level:',
                style: TextStyle(fontSize: 16),
              ),
              Slider(
                value: _skillLevel.toDouble(),
                min: 0,
                max: 4,
                divisions: 4,
                onChanged: (double value) {
                  setState(() {
                    _skillLevel = value.round();
                  });
                },
              ),
              Center(
                child: Text(
                  skillLevels[_skillLevel],
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Text(
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
                  Text(
                    'Private',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
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
              ElevatedButton(
                onPressed: () {
                  createGroup();
                },
                child: const Text('Create Group'),
              ),
              if (_isGroupCreated)
                const Text(
                  'Your group has been created!',
                  style: TextStyle(color: Colors.green),
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

  void createGroup() {
    String name = _nameController.text;

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Group name can not be empty!';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
    });

    setState(() {
      _isGroupCreated = true;
    });
  }
}
