import 'package:flutter/material.dart';
import 'package:flutter_application/my_list_tile.dart';
import 'package:flutter_application/profile_page.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onSettingsTap;
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;
  
  MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onSignoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.deepOrange,
      child: Column(
        children: <Widget>[
          //header
          const DrawerHeader(
              child: Icon(
            Icons.person,
            color: Colors.white,
            size: 64,
            )
          ),
          //Home list title
          MyListTile(
            icon: Icons.home,
            text: 'HOME',
            onTap:() => Navigator.pop(context),
          ),

          //Settings list title
          MyListTile(
            icon: Icons.settings,
            text: 'SETTINGS',
            onTap: onSettingsTap,
          ),
          //profile list title
          MyListTile(
            icon: Icons.person,
            text: 'PROFILE',
            onTap: onProfileTap,
          ),
          //logout list title
           MyListTile(
            icon: Icons.logout_sharp,
            text: 'SIGN OUT',
            onTap: onSignoutTap,
          ),
        ],
      ),
    );
  }
}
