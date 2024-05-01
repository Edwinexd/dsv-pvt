import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class GroupPage extends StatefulWidget {
  final String groupName = "Group Name";
  final bool isPrivate = true;

  const GroupPage({super.key, required String groupName, required bool isPrivate});

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
          // Header Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  groupName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    //If the group is private "join the group"
                    //Otherwise "send a request to join"
                  },
                  child: Text(isPrivate ? "Send a request to join" : "Join the group"),
                ),
              ],
            ),
          ),
          const Divider(),
          //Search Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Search members...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                //Will handle search query here later
              },
            ),
          ),
          const Divider(),
          //Members section
          Expanded(
            child: ListView.builder(
              itemCount: 20, //Example number of members
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
  
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
