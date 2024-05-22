import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';

class GroupInvitationsPage extends StatefulWidget {
  GroupInvitationsPage({super.key});

  @override
  _GroupInvitationsState createState() => _GroupInvitationsState();
}

class _GroupInvitationsState extends State<GroupInvitationsPage> {
  List<Group> invitations = [];

  @override
  void initState() {
    super.initState();
    unawaited(BackendService().getGroupsInvitedTo().then((groups) {
      setState(() {
        invitations = groups;
      });
    }));
  }

  Future<void> acceptInvitation(Group group) async {
    await BackendService().joinGroup((await BackendService().getMe()).id, group.id);
    setState(() {
      invitations.remove(group);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have accepted the invitation to ${group.name}')),
    );
  }

  Future<void> rejectInvitation(Group group) async {
    await BackendService().declineGroupInvite(group.id);
    setState(() {
      invitations.remove(group);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have rejected the invitation to ${group.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Invitations',
        context: context,
        showBackButton: true,
      ),
      body: DefaultBackground(
        child: invitations.isEmpty
            ? Center(child: Text('No invitations'))
            : SingleChildScrollView(
                child: Column(
                  children: invitations.map((group) {
                    SizedBox(height: 12);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 254, 192, 173),
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: ListTile(
                          title: Text(group.name),
                          subtitle: Text(group.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => acceptInvitation(group),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => rejectInvitation(group),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
