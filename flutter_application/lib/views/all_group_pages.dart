import 'package:flutter/material.dart';
import 'package:flutter_application/models/group.dart';


class AllGroupsPage extends StatefulWidget {
  const AllGroupsPage({Key? key}) : super(key: key);

  @override
  _AllGroupsPageState createState() => _AllGroupsPageState();
}

class _AllGroupsPageState extends State<AllGroupsPage> {
  
  // List of groups
  final List<Group> _groups = [
    Group('Group 1', 'Description of Group 1'),
    Group('Group 2', 'Description of Group 2'),
    Group('Group 3', 'Description of Group 3'),
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
          (_selectedFilter == 'All' || /*will add filtering condition function here */);
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
              decoration: InputDecoration(
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
              items: [
                DropdownMenuItem(value: 'All', child: const Text('All')),
                
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
