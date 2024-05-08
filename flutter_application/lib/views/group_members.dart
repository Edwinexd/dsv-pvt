import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';

class GroupMembersPage extends StatelessWidget {
  const GroupMembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
      ),
      body: DefaultBackground(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search members...',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _membersList.length,
              itemBuilder: (context, index) {
                final member = _membersList[index];
                return ListTile(
                  leading: const CircleAvatar(
                    //placeholder for users profile picture
                    child: Icon(Icons.person),
                  ),
                  title: Text(member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//Instance members list
final List<String> _membersList = [
  'Anthony Edwards',
  'LeBron James',
  'Nikola Jokic',
  'Luka Doncic',
];
