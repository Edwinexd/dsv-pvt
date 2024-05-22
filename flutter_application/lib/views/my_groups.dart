import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/all_group_pages.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter_application/views/group_page.dart';
import 'package:flutter_application/views/group_invitations_page.dart';

class MyGroups extends StatefulWidget {
  MyGroups({super.key});

  @override
  State<MyGroups> createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  List<Group> myGroups = [];
  Map<String, ImageProvider> groupImages = {};

  @override
  void initState() {
    super.initState();
    fetchMyGroups();
  }

  void refreshMyGroups() {
    fetchMyGroups();
  }

  void fetchMyGroups() async {
    List<Group> groups = await BackendService().getMyGroups();
    Map<String, ImageProvider> images = {};
    for (var group in groups) {
      if (group.imageId != null) {
        ImageProvider image = await BackendService().getImage(group.imageId!);
        images[group.id.toString()] = image;
      } else {
        images[group.id.toString()] = const AssetImage('lib/images/splash.png'); 
      }
    }
    setState(() {
      myGroups = groups;
      groupImages = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        showBackButton: false,
        title: 'Groups',
      ),
      body: DefaultBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllGroupsPage(
                              refreshMyGroups: refreshMyGroups,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Search groups'),
                          Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupCreation(
                              onGroupCreatedCallBacks: [refreshMyGroups],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Create a group'),
                          Icon(Icons.add),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupInvitationsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invitations'),
                          Icon(Icons.insert_invitation),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('My Groups',
                  style: TextStyle(
                    fontSize: 20,
                  )),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ListView.builder(
                itemCount: myGroups.length,
                itemBuilder: (context, index) {
                  final group = myGroups[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 254, 192, 173),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: groupImages[group.id.toString()] ?? const AssetImage('lib/images/splash.png'),
                        ),
                        title: Text(group.name),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => GroupPage(group: group, isMember: true)),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
