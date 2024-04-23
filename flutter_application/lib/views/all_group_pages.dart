import 'package:flutter/material.dart';
import 'package:flutter_application/models/group.dart';


class AllGroupsPage extends StatefulWidget {
  const AllGroupsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AllGroupsPageState createState() => _AllGroupsPageState();
}

class _AllGroupsPageState extends State<AllGroupsPage> {
  
  // List of groups
  final List<Group> _groups = [
    const Group(name: 'Lace up!', description: 'blabla', id: 3, isPublic: true),
    const Group(name: 'DVK Runners', description: 'bla', id: 2, isPublic: false),
    const Group(id: 4, name: 'Kista Runners', description: 'Best runners!', isPublic: true),
  
    //Can add more groups 
  ];

  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Filtered and searched groups
    List<Group> filteredGroups = _groups.where((group) {
      final name = group.name.toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) &&
          (_selectedFilter == 'All' /*|| will add filtering condition function here */);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Groups'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Filter dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField(
              value: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value.toString();
                });
              },
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                
              ],
            ),
          ),
          

          Expanded(
            child: ListView.builder(
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                final group = filteredGroups[index];
                return ListTile(
                  title: Text(group.name),
                  subtitle: Text(group.description),
                  // Add more details or actions as needed
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
