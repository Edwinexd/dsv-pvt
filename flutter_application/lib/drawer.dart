import 'package:flutter/material.dart';
import 'package:flutter_application/my_list_tile.dart';
import 'profile_page.dart';
import 'views/all_group_pages.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onSettingsTap;
  final void Function()? onSignoutTap;
  

  const MyDrawer({
    super.key,
    required this.onSettingsTap,
    required this.onSignoutTap,
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
                )
              ),
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
                onTap: () => goToProfilePage(context),
              ),

              MyListTile(
                icon: Icons.group, 
                text: 'GROUP', 
                onTap: () => goToGroupPage(context),
                ),
            ],
          ),
          
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

  void goToProfilePage(BuildContext context) {
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) => const AllGroupsPage()),
      ),
    );
  }
  //Setting and signout will also be here
}
