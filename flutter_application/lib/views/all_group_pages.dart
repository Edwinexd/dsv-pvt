import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter_application/background_for_pages.dart';

class AllGroupsPage extends StatefulWidget {
  final Function refreshMyGroups;
  const AllGroupsPage({
    super.key,
    required this.refreshMyGroups,
  });

  @override
  AllGroupsPageState createState() => AllGroupsPageState();
}

class AllGroupsPageState extends State<AllGroupsPage>  {
  List<Group> _groups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  void refreshAllGroups() async {
    fetchGroups();
  }

  void fetchGroups() async {
    var fetchedGroups = await BackendService().getGroups(0, 100);
    setState(() {
      _groups = fetchedGroups;
    });
  }


  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    List<Group> filteredGroups = _groups.where((group) {
      final name = group.name.toLowerCase();
      final isPrivate = group.isPrivate;

      //Filter system will be 'changed'
      bool matchesSearchQuery = name.contains(_searchQuery.toLowerCase());
      bool isPublicMatch = (_selectedFilter == 'All') ||
          (_selectedFilter == 'Public' && !isPrivate) ||
          (_selectedFilter == 'Private' && isPrivate);
      return matchesSearchQuery && isPublicMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Groups',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
            )
          ),
        ),
        backgroundColor: const Color.fromARGB(230, 60, 71, 133),
      ),
      body: DefaultBackground(
        children: [
          Container(
            color: const Color(0xFFAA6CFC),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search groups',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonFormField(
                    value: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value.toString();
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'Public',
                          child: Text('Show only public groups')),
                      DropdownMenuItem(
                          value: 'Private',
                          child: Text('Show only private groups')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                final group = filteredGroups[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.group), // Placeholder icon
                  ),
                  title: Text(
                    group.name,
                    style: const TextStyle(
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.description),
                      Text(group.isPrivate ? 'Private' : 'Public'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => GroupCreation(onGroupCreatedCallBacks: [refreshAllGroups, widget.refreshMyGroups],)), 
          );
        },
        style: TextButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 233, 159, 73),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Create a group'),
      ),
    );
  }
}
