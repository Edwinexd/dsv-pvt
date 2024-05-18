import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/models/group.dart';

class GroupInvitationsPage extends StatefulWidget {
  GroupInvitationsPage({super.key});

  @override
  _GroupInvitationsState createState() => _GroupInvitationsState();
}

class _GroupInvitationsState extends State<GroupInvitationsPage> {
  List<Group> invitations = [
    Group(
      id: 1,
      name: "Group A",
      description: "Description for Group A",
      isPrivate: false,
      ownerId: "owner1",
    ),
    Group(
      id: 2,
      name: "Group B",
      description: "Description for Group B",
      isPrivate: true,
      ownerId: "owner2",
    ),
    Group(
      id: 3,
      name: "Group C",
      description: "Description for Group C",
      isPrivate: false,
      ownerId: "owner3",
    ),
  ];

  void acceptInvitation(Group group) {
    setState(() {
      invitations.remove(group);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You have accepted the invitation to ${group.name}')),
    );
  }

  void rejectInvitation(Group group) {
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
    );
  }
}
