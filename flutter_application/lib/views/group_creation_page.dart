import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
//member invites?

class GroupCreation extends StatefulWidget {
  const GroupCreation({super.key});

  @override
  GroupCreationState createState() => GroupCreationState();
}

class GroupCreationState extends State<GroupCreation> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = false;
  bool _isGroupCreated = false;
  String _errorMessage = '';

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
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(
                height: 16.0,
              ),
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
                ],
              ),
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
