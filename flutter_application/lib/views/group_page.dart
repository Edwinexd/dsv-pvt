import 'package:flutter/material.dart';
import 'package:flutter_application/activity_create.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/views/group_members.dart';

class GroupPage extends StatefulWidget {
  final String groupName;
  final bool isPrivate;

  const GroupPage(
      {super.key, required this.groupName, required this.isPrivate});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late List<String> activities = [
    'April 7th Kista at 17:00',
    'May 3rd Kungsträdgården at 13:00',
    'June 15th Skansen at 10:00',
    //Instances of activities
    //Will be removed later
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(250, 60, 71, 133),
        title: const Text(
          'Groups',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: DefaultBackground(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                widget.groupName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Group Activities',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(activities[index]),
                      trailing: Checkbox(
                        value: false,
                        onChanged: (value) {
                          //Will handle checkbox change, it has no function rn
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActivityCreatePage(groupId: '1234')),
              );
            },
            icon: const Icon(Icons.create),
            label: const Text('Create an activity'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              //Will handle invite new members button later
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Invite new members'),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GroupMembersPage(),                    
                ),
              );
            },
            icon: const Icon(Icons.group),
            label: const Text('Members'),
          ),
        ],
      ),
    );
  }
}
