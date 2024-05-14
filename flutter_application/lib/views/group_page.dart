import 'package:flutter/material.dart';
import 'package:flutter_application/activity_create.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/views/group_members.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupPage extends StatefulWidget {
  final Group group;
  bool isMember;

  GroupPage({Key? key, required this.group, required this.isMember})
      : super(key: key);

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<User> allMembers = [];
  List<User> displayedMembers = [];
  TextEditingController searchController = TextEditingController();
  List<bool> joinedActivities = List.generate(5, (index) => false);
  bool isPublic = false;
  String skillLevel = '';
  String location = '';

  @override
  void initState() {
    super.initState();
    fetchMyGroups();
    fetchMembers().then((_) {
      setState(() {
        displayedMembers = allMembers;
      });
    });
    //added listener to search text field
    searchController.addListener(_searchMembers);
  }

  Future<void> fetchMyGroups() async {
    List<Group> allMyGroups = await BackendService().getMyGroups();
    if (!widget.isMember) {
      isPublic = widget.group.isPrivate;
      widget.isMember =
          allMyGroups.any((myGroup) => myGroup.id == widget.group.id);
      //skillLevel = widget.group.skillLevel;
      //location = widget.group.location;
    }
  }

  Future<void> fetchMembers() async {
    allMembers = await BackendService().getGroupMembers(widget.group.id);
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
      displayedMembers = allMembers
          .where((member) => member.userName.toLowerCase().contains(query))
          .toList();
    });
  }

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
        title: Text(
          'Groups',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ),
      body: DefaultBackground(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.orange[200]!,
                Colors.orange[200]!,
                Colors.orange[400]!,
                Colors.orange[400]!,
              ], stops: [
                0.25,
                0.25,
                0.75,
                0.75
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Center(
              child: Text(
                widget.group.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          if (widget.isMember) ...[
            //Display activities list for members
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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        trailing: TextButton(
                          onPressed: () {
                            setState(() {
                              joinedActivities[index] =
                                  !joinedActivities[index];
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.black),
                          ),
                          child: Text(
                            joinedActivities[index] ? 'Leave' : 'Join',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              width: 150,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityCreatePage(
                        groupId: 1,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button color
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Create an activity'),
                    const Icon(Icons.create),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  //Will handle invite new members button later
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, //Button color
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Invite new members'),
                    Icon(Icons.person_add),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GroupMembersPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button color
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Members'),
                    Icon(Icons.group),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              width: 250,
              child: ElevatedButton(
                onPressed: () {
                  //Will handle leaving the group
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Button color
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Leave the group'),
                    Icon(Icons.exit_to_app),
                  ],
                ),
              ),
            ),
          ] else ...[
            //Display group details for non-members
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'About Us',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.group.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Handle displaying group privacy
                          },
                          child: Text(
                              widget.group.isPrivate ? 'Private' : 'Public'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //Handle displaying group skill level
                          },
                          child:
                              Text('Beginner' /*${widget.group.skillLevel}*/),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //Handle displaying group location
                          },
                          child: Text('Kista' /*${widget.group.location}*/),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GroupMembersPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Button color
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Members'),
                        Icon(Icons.group),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8.0),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                //Will handle joining the group
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text(
                'Join Group',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
