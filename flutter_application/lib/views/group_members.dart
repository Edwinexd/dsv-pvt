/*
Lace Up & Lead The Way - A pre-race training app and social platform for runners.
Copyright (C) 2024 Group 71 (PVT 7.5) Stockholm University

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/profile_page.dart';

class GroupMembersPage extends StatefulWidget {
  final Group group;
  const GroupMembersPage({super.key, required this.group});

  @override
  _GroupMembersPageState createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends State<GroupMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _membersList = [];
  List<User> _filteredMembersList = [];


  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  void _fetchMembers() async {
    var members = await BackendService().getGroupMembers(widget.group.id);
    setState(() {
      _membersList = members;
      _filteredMembersList = members;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        showBackButton: true,
        title: 'Members',
      ),
      body: DefaultBackground(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.group.name,
                  /*Will be displayed total number of members and max members*/
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
                      // TODO: We can't feasibly get every users profile image as their avatar is in the profile obj and not user
                      child: Icon(Icons.person),
                    ),
                    title: Text(member.fullName),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(userId: member.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }

  void _onSearchTextChanged(String value) {
    setState(() {
      _filteredMembersList = _membersList
          .where((member) => member.fullName.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }
}
