import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/activity_create.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/components/checkered_background.dart';
import 'package:flutter_application/components/user_selector.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/activity.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/views/group_members.dart';
import 'package:flutter_application/views/my_groups.dart';


class GroupPage extends StatefulWidget {
  final Group group;
  bool isMember;

  GroupPage({super.key, required this.group, required this.isMember});
    
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  TextEditingController searchController = TextEditingController();
  List<User> allMembers = [];
  List<User> displayedMembers = [];
  List<Activity> allActivities = [];
  Set<int> joinedActivityIds = {};
  bool isPublic = false;
  String skillLevel = '';
  String location = '';
  int skip = 0; // TODO: Pagination?
  int limit = 100; // TODO: Pagination?

  @override
  void initState() {
    super.initState();
    unawaited(fetchAllActivities());
    unawaited(fetchJoinedActivities());
    unawaited(fetchMyGroups());
    unawaited(fetchMembers().then((_) {
      setState(() {
        displayedMembers = allMembers;
      });
    }));
    
    //added listener to search text field
    searchController.addListener(_searchMembers);
  }

  Future<void> fetchAllActivities() async {
    allActivities = await BackendService().getActivities(widget.group.id, skip, limit);
    if (mounted) setState(() {});
  }

  Future<void> fetchJoinedActivities() async {
    User me = await BackendService().getMe();
    var joinedActivities = await BackendService().getUserActivities(me.id, skip, limit);
    joinedActivityIds = joinedActivities.map((a) => a.id).toSet();
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

  Future<void> toggleActivityParticipation(Activity activity, bool join) async {
    User me = await BackendService().getMe();
    if (join) {
      await BackendService().joinActivity(widget.group.id, activity.id, me.id);
      setState(() {
        joinedActivityIds.add(activity.id);
      });
    } else {
      await BackendService().leaveActivity(widget.group.id, activity.id, me.id);
      setState(() {
        joinedActivityIds.remove(activity.id);
      });
    }
  }

  void joinGroup() async {
    User me = await BackendService().getMe();
    await BackendService().joinGroup(me.id, widget.group.id);
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => GroupPage(group: widget.group, isMember: true)
      ),
    );
  }

  Future<void> leaveGroup() async {
    User me = await BackendService().getMe();
    await BackendService().leaveGroup(me.id, widget.group.id);
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: ((context) => MyGroups())
      ),
    ); 
  }

  void confirmLeaveGroup() {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Leave"),
              onPressed: () {
                Navigator.of(context).pop();
                leaveGroup();
              },
            ),
          ],
        );
      });
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

  void _inviteMembers() {
    // Render user_selector
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSelector(
          finishSelectionText: 'Invite members',
          onUserSelected: (User u) => {},
          onCompleted: (List<User> users) async {
            if (users.isEmpty) {
              return;
            }
            // Loading icon
            showDialog(
              context: context,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            int failed = 0;
            for (User user in users) {
              try {
                await BackendService().inviteUserToGroup(user.id, widget.group.id);
              } catch (e) {
                failed++;
              }
            }

            // Close loading icon
            Navigator.pop(context);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  failed == 0
                      ? 'Invitations sent successfully'
                      : 'Failed to send $failed invitations',)
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        showBackButton: true,
        title: 'Groups',
      ),
      body: DefaultBackground(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                CheckeredPatternBackground(
                    color1: Colors.orange[200]!,
                    color2: Colors.orange[400]!,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          widget.group.name,
                          style: const TextStyle(
                            color: Color(0xFF8134CE),
                            //fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
          if (widget.isMember) ...[
            //Display group for members
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
                        fontSize: 20,
                        color: Color(0xFF8134CE),
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: allActivities.length,
                    itemBuilder: (context, index) {
                      var activity = allActivities[index];
                      bool isJoined = joinedActivityIds.contains(activity.id);
                      return ListTile(
                        title: Text(activity.name),
                        trailing: Wrap(
                          spacing: 8,
                          children: <Widget>[
                            TextButton(
                              onPressed: () => toggleActivityParticipation(activity, !isJoined),
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.black),
                              ),
                              child: Text(
                                isJoined ? 'Leave' : 'Join',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => ActvityPage(activity: activity),
                                //   ),
                                // );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.black),
                              ),
                              child: const Text('View'),
                            ),

                          ]
                        )
                        
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
                        groupId: widget.group.id,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Create an activity'),
                    Icon(Icons.create),
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
                  _inviteMembers();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Invite members'),
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
                      builder: (context) => GroupMembersPage(group: widget.group),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
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
                onPressed: confirmLeaveGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
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
                          fontSize: 20,
                          color: Color(0xFF8134CE),
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(2, 2),
                              blurRadius: 1,
                            )
                          ]),
                    ),
                  ),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.group.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //Non-functional buttons, no need to add any functionalities
                        ElevatedButton(
                          onPressed: () {
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFDEBB4),
                          ),
                          child: Text(
                              widget.group.isPrivate ? 'Private' : 'Public'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFF9F2D),
                          ),
                          child:
                              Text('Beginner' /*${widget.group.skillLevel}*/),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFEC0AD),
                          ),
                          child: Text('Kista' /*${widget.group.location}*/),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupMembersPage(group: widget.group),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
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

            SizedBox(height: 12),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => joinGroup(),
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
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
