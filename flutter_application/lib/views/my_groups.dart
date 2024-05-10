import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/all_group_pages.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter_application/views/group_page.dart';
import 'package:google_fonts/google_fonts.dart';

class MyGroups extends StatefulWidget {
  MyGroups({super.key});

  @override
  State<MyGroups> createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  List<Group> myGroups = [];

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
    setState(() {
      myGroups = groups;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Groups',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(230, 60, 71, 133),
      ),
      body: DefaultBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Text(
                    'Groups',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {},
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
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text(
                'My Groups',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: myGroups.length,
                itemBuilder: (context, index) {
                  final group = myGroups[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 254, 192, 173),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: ListTile(
                        title: Text(group.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => GroupPage(group: group)),
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
    );
  }
}
