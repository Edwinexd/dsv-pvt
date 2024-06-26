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
import 'package:flutter_application/components/optional_image.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/all_group_pages.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter_application/views/group_page.dart';
import 'package:flutter_application/views/group_invitations_page.dart';

class MyGroups extends StatefulWidget {
  MyGroups({super.key});

  @override
  State<MyGroups> createState() => _MyGroupsState();
}

class _MyGroupsState extends State<MyGroups> {
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
      appBar: buildAppBar(
        context: context,
        showBackButton: false,
        title: 'Groups',
      ),
      body: DefaultBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllGroupsPage(
                              refreshMyGroups: refreshMyGroups,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Search groups'),
                          Icon(Icons.search),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupCreation(
                              onGroupCreatedCallBacks: [refreshMyGroups],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Create a group'),
                          Icon(Icons.add),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GroupInvitationsPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Invitations'),
                          Icon(Icons.insert_invitation),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text('My Groups',
                  style: TextStyle(
                    fontSize: 20,
                  )),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: ListView.builder(
                itemCount: myGroups.length,
                itemBuilder: (context, index) {
                  final group = myGroups[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 254, 192, 173),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: ListTile(
                        leading: OptionalImage(imageId: group.imageId),
                        title: Text(group.name),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: ((context) => GroupPage(group: group, isMember: true)),
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
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
