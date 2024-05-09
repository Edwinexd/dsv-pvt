import 'package:flutter/material.dart';
import 'package:flutter_application/activity_create.dart';
import 'package:flutter_application/models/group.dart';

class GroupPage extends StatefulWidget {
  final Group group;

  const GroupPage({super.key, required this.group});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late List<String> allMembers;
  late List<String> displayedMembers;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //List of members(just an example)
    allMembers = List.generate(20, (index) => 'Member $index');
    displayedMembers = List.from(allMembers);
    //added listener to search text field
    searchController.addListener(_searchMembers);
  }

  @override
  void dispose() {
    //cleans up the controller when the widget is disposed
    searchController.dispose();
    super.dispose();
  }

  void _searchMembers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      // TODO: Replace with fuzzy search
      displayedMembers = allMembers.where((member) => member.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(250, 60, 71, 133),
        title: Text(
          // widget.groupName,
          widget.group.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ), 
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityCreatePage(groupId: widget.group.id,),
                  ),
                );
              },
              label: const Text('Create an activity'),
              icon: const Icon(Icons.run_circle_sharp),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                //Will handle invite friend button later
              },
              icon: const Icon(Icons.add),
              label: const Text('Invite a friend'),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search members...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: displayedMembers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    //will add user profile picture here
                    child: Icon(Icons.photo), //Placeholder for profile picture
                  ),
                  title: Text(displayedMembers[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
