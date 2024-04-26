import 'package:flutter/material.dart';
import 'package:flutter_application/main.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter_application/drawer.dart';
import '../profile_page.dart';


class AllGroupsPage extends StatefulWidget {
  const AllGroupsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AllGroupsPageState createState() => _AllGroupsPageState();
}

class _AllGroupsPageState extends State<AllGroupsPage> {
  //List of instance groups
  final List<Group> _groups = [
    const Group(id: 3, name: 'Lace up!', description: 'Lace up and lead the way', isPublic: true),
    const Group(id: 2, name: 'DVK Runners', description: 'Join us!', isPublic: false),
    const Group(id: 4, name: 'Kista Runners', description: 'Best runners!', isPublic: true),
  ];

  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    List<Group> filteredGroups = _groups.where((group) {
      final name = group.name.toLowerCase();
      final isPublic = group.isPublic;

      bool matchesSearchQuery = name.contains(_searchQuery.toLowerCase());
      bool isPublicMatch = _selectedFilter == 'All' || (_selectedFilter == 'Public' && isPublic);
      return matchesSearchQuery && isPublicMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Groups'),
        backgroundColor: const Color.fromARGB(230, 60, 71, 133),
      ),

      drawer: MyDrawer(
        onProfileTap: () => goToProfilePage(context),
        onGroupTap: () => goToGroupPage(context),
        onSignoutTap: () {},
        onSettingsTap: () {},
        
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100], // Background color of the box
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 8), 
                
                DropdownButtonFormField(
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
                    DropdownMenuItem(value: 'Public', child: Text('Public groups')),
                  ],
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
                      Text(group.isPublic ? 'Public' : 'Private'),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      
      floatingActionButton: FloatingActionButton(
        onPressed:() {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => GroupCreation()), 
            );
        },
        backgroundColor: Colors.grey[150],
        child: const Icon(Icons.add),
        ),
    );
  }
 

  //same code from the main class, will be changed later since we do not need to write the same code one more time
  void goToProfilePage(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(
          name: 'Jeb Jebson',
          biography: "Let's go running!",
          imageUrl: 'https://via.placeholder.com/150',
        ),
      ),
    );
  }

  void goToGroupPage(BuildContext context) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) => const AllGroupsPage()),
      ),
    );
  }

}