import 'package:flutter/material.dart';
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
      appBar : AppBar(
        title: const Text('Create a group'),
      ),
      body: Padding(
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

            const SizedBox(height: 16.0,),
            Row(
              children: <Widget>[
                const Text('Public'),
                Switch(value: _isPublic, onChanged: (value) {
                  setState(() {
                    _isPublic = value;
                  });
                },
                ),
                const Text('Private'),
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
              Text(_errorMessage, 
              style: const TextStyle(color: Colors.red),)

          ],
        )
      )
    );
  }

  void createGroup() {
    String name = _nameController.text;
    String description = _descriptionController.text;

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