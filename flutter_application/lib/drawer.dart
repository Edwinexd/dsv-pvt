import 'package:flutter/material.dart';
import 'package:flutter_application/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onSettingsTap;
  final void Function()? onProfileTap;
  final void Function()? onSignoutTap;
  final void Function()? onGroupTap;

  MyDrawer({
    super.key,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.onSignoutTap,
    required this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.teal[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //header
              const DrawerHeader(
                  child: Icon(
                Icons.person,
                color: Colors.white,
                size: 64,
              )),
              //Home list title
              MyListTile(
                icon: Icons.home,
                text: 'HOME',
                onTap: () => Navigator.pop(context),
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

              MyListTile(
                icon: Icons.group, 
                text: 'GROUP', 
                onTap: onGroupTap,
                ),
            ],
          ),
          //logout list title
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: MyListTile(
              icon: Icons.logout_sharp,
              text: 'SIGN OUT',
              onTap: onSignoutTap,
            ),
          ),
        ],
      ),
    );
  }
}
