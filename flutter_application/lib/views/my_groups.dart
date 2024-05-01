import "package:flutter/material.dart";
import "package:flutter_application/views/all_group_pages.dart";
import "package:flutter_application/views/group_creation_page.dart";
import "package:flutter_application/views/group_page.dart";
import "package:google_fonts/google_fonts.dart";


class MyGroups extends StatefulWidget {
  const MyGroups({super.key});

  @override 
  _MyGroupsState createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
  final String appName = 'Lace Up & Lead The Way';
  final List<String> myGroups = [
    "Group 1",
    "Group 2",
    "Group 3",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appName,
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(230, 60, 71, 133),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "My Groups",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: myGroups.length, 
              itemBuilder:  (context, index) {
                final groupName = myGroups[index];
                return ListTile(
                  title: Text(groupName),
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(
                        builder: ((context) => GroupPage(groupName: groupName, isPrivate: true))
                        ),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const GroupCreation()
                  ),
                );
                //Navigate to creation

              },
              icon: const Icon(Icons.add),
              tooltip: 'Create a group',
            ),  
            IconButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const AllGroupsPage()),
                );
                //Navigate to search
              }, icon: const Icon(Icons.search),
              tooltip: 'Search groups',
              ),  
          ],
        ),
      ),
    );
    
  }
}