import 'package:flutter/material.dart';

AppBar buildAppBar({required Function onPressed, required String title}) {
  return AppBar(
    title: Text(title),
    backgroundColor: const Color.fromARGB(230, 60, 71, 133),
    actions: <Widget>[
      IconButton(
        icon: const Icon(Icons.person),
        onPressed: onPressed as void Function()?,
      ),
    ],
  );
}

BottomNavigationBar buildBottomNavigationBar({
  required int selectedIndex,
  required Function onItemTapped,
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
    currentIndex: selectedIndex,
    selectedItemColor: Colors.amber[800],
    unselectedItemColor: Colors.deepPurple[900],
    onTap: onItemTapped as void Function(int)?,
  );
}