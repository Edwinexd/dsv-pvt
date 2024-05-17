import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';

class GroupInvitationsPage extends StatefulWidget {
  GroupInvitationsPage({super.key});

  @override
  _GroupInvitationsState createState() => _GroupInvitationsState();
}

class _GroupInvitationsState extends State<GroupInvitationsPage> {
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        title: 'Invitations', 
        context: context,
        showBackButton: true,
        ),

        body: DefaultBackground(
          children: [
            SingleChildScrollView(
              child: Column(

              ),
            )
          ],
        ),
    );


    
  }

}