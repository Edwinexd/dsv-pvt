import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupPage extends StatelessWidget {
  final String groupName = "Group Name";
  final bool isPrivate = true;

  const GroupPage({super.key, required String groupName, required bool isPrivate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lace Up & Lead The Way',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: const Color.fromARGB(230, 60, 71, 133),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    //Will handle create activity button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  label: const Text("Create an activity"),
                  icon: const Icon(Icons.run_circle_sharp), //Can change later 
                ),
                
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    //Will handle invite friend button press
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  label: const Text("Invite a friend"),
                  icon: const Icon(Icons.person_add),
                  
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Members",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search members...",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                //Will handle search query
              },
            ),
          ),
          const Divider(),
          //Members section
          Expanded(
            child: ListView.builder(
              itemCount: 20, //Number of members here
              itemBuilder: (context, index) {
                //Will replace this with actual member info/data
                return ListTile(
                  title: Text("Member $index"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
