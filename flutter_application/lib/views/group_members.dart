import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupMembersPage extends StatefulWidget {
  const GroupMembersPage({super.key});

  @override
  _GroupMembersPageState createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _filteredMembersList = [];

  @override
  void initState() {
    super.initState();
    _filteredMembersList.addAll(_membersList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Members',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20.0,
            ),
          ),
        ),
      ),
      body: DefaultBackground(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Group Members 4/20', /*Will be displayed total number of members and max members*/
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchTextChanged,
                  decoration: const InputDecoration(
                    labelText: 'Search members...',
                    suffixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredMembersList.length,
              itemBuilder: (context, index) {
                final member = _filteredMembersList[index];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2.0),
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      //placeholder for users profile picture
                      child: Icon(Icons.person),
                    ),
                    title: Text(member),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchTextChanged(String value) {
    setState(() {
      _filteredMembersList = _membersList
          .where((member) => 
          member.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }
}

//Instance members list
final List<String> _membersList = [
  'Anthony Edwards',
  'LeBron James',
  'Nikola Jokic',
  'Luka Doncic',
];
