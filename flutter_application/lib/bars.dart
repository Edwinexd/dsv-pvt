import 'package:flutter/material.dart';
import 'package:flutter_application/home_page.dart';
import 'package:flutter_application/profile_page.dart';
import 'package:flutter_application/views/my_groups.dart';
import 'package:flutter_application/views/schedule_page.dart';

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
    leading: showBackButton ? const BackButton(color: Colors.white) : SizedBox.shrink(),
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.person, color: Colors.white),
        onPressed: () => goToProfilePage(context),
      ),
    ],
  );
}

void goToProfilePage(BuildContext context) {
  DateTime joinedDate = DateTime(2021, 4, 12);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(
        name: 'Axel Andersson',
        biography: "Let's go running!",
        imageUrl: 'https://via.placeholder.com/150',
        username: 'Olt53',
        joinedDate: joinedDate,
      ),
    ),
  );
}

BottomNavigationBar buildBottomNavigationBar({
  required BuildContext context,
  int currentIndex = 0,
}) {
  return BottomNavigationBar(
    backgroundColor: const Color.fromARGB(230, 60, 71, 133),
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.group),
        label: 'Groups',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.favorite),
        label: 'Friends',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month),
        label: 'My Activity',
      ),
    ],
    currentIndex: currentIndex,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white,
    onTap: (index) {
      if (index == 0) {
        goToHomePage(context);
      } else if (index == 1) {
        goToGroupPage(context);
      } else if (index == 2) {
        // Go to Friends page
      } else if (index == 3) {
        goToSchedulePage(context);
      }
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

void goToSchedulePage(BuildContext context) {
  Navigator.pushReplacement(
    context, 
    MaterialPageRoute(builder: (context) => SchedulePage()),
    );
}