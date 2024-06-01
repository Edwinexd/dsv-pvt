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
import 'package:flutter_application/friends_page.dart';
import 'package:flutter_application/home_page.dart';
import 'package:flutter_application/profile_page.dart';
import 'package:flutter_application/views/my_groups.dart';
import 'package:flutter_application/views/schedule_page.dart';
import 'package:flutter_application/controllers/backend_service.dart';

ValueNotifier<int> selectedIndexNotifier = ValueNotifier<int>(0);

AppBar buildAppBar({
  required String title,
  required BuildContext context,
  bool showBackButton = false,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: const Color.fromARGB(230, 60, 71, 133),
    leading: showBackButton
        ? const BackButton(color: Colors.white)
        : SizedBox.shrink(),
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.person, color: Colors.white),
        onPressed: () => goToProfilePage(context),
      ),
    ],
  );
}

void goToProfilePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage()
    ),
  );
}

Widget buildBottomNavigationBar({
  required BuildContext context,
}) {
  return ValueListenableBuilder<int>(
    valueListenable: selectedIndexNotifier,
    builder: (context, currentIndex, _) {
      return BottomNavigationBar(
        backgroundColor: const Color.fromARGB(230, 60, 71, 133),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: currentIndex == 0 ? Colors.deepOrange : Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: currentIndex == 1 ? Colors.deepOrange : Colors.white),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: currentIndex == 2 ? Colors.deepOrange : Colors.white),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, color: currentIndex == 3 ? Colors.deepOrange : Colors.white),
            label: 'My Activity',
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          if (selectedIndexNotifier.value == index) {
            return; 
          }
          selectedIndexNotifier.value = index;

          if (index == 0) {
            goToHomePage(context);
          } else if (index == 1) {
            goToGroupPage(context);
          } else if (index == 2) {
            goToFriendsPage(context);
          } else if (index == 3) {
            goToSchedulePage(context);
          }
        },
      );
    },
  );
}

void goToHomePage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomePage()),
  );
}

void goToGroupPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => MyGroups()),
  );
}

void goToFriendsPage(BuildContext context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => FriendsPage()),
  );
}

void goToSchedulePage(BuildContext context) async {
  final user = await BackendService().getMyUser();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SchedulePage(userId: user.id)),
  );
}
