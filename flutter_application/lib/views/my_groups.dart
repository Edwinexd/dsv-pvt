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
  // final List<String> myGroups = [
  //   "Group 1",
  //   "Group 2",
  //   "Group 3",
  // ];
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
                  Text(
                    'Groups',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllGroupsPage(refreshMyGroups: refreshMyGroups,),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search groups'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupCreation(onGroupCreatedCallBacks: [refreshMyGroups]),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create a group'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text(
                "My Groups",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: myGroups.length,
                itemBuilder: (context, index) {
                  final group = myGroups[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 254, 192, 173),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Text(group.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => 
                                GroupPage(group: group)),
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
