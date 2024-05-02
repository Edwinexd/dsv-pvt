import 'package:flutter/material.dart';
import 'package:flutter_application/drawer.dart';
import 'package:flutter_application/profile_page.dart';
import 'package:flutter_application/settings.dart';
import 'package:flutter_application/views/all_group_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  final bool darkModeEnabled;
  final ValueChanged<bool> onToggleDarkMode;

  const MainPage({
    super.key,
    required this.darkModeEnabled,
    required this.onToggleDarkMode,
  });

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  static const List<Widget> widgetOptions = <Widget>[
    Text('Group Page',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text(
      '',
    ),
    Text('Start Activity Page',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Placeholder Page',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  void onItemtapped(int index) {
    setState(() {
      selectedIndex = index;
      if (index == 1) {
        // Check if "Profile" bottom navigation bar item is tapped
        goToProfilePage(context); // Navigate to the profile page
      }
      //Kommer ändras när vi har en homepage
      if (index == 0) {
        goToGroupPage(
            context); // Nu har vi ingen home-page och indexen av grupp-ikonen är 0
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Midnattsloppet Now'),
      ),
      drawer: MyDrawer(
        onSignoutTap: () {},
        onSettingsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SettingsPage(
                      onToggleDarkMode: widget.onToggleDarkMode,
                      initialDarkMode: widget.darkModeEnabled,
                    )),
          );
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CountdownWidget(),
            SignupButton(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFCFBAEA), 
              ),
              onPressed: () {},
              child: Text('Challenges'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_mark),
            label: 'Placeholder',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.deepPurple[900],
        onTap: onItemtapped,
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
}

class CountdownWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final raceDate = DateTime(2024, 8, 17);
    final currentDate = DateTime.now();
    final difference = raceDate.difference(currentDate).inDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90.0), 
      child: Container(
        width: double.infinity,
        color: Colors.deepOrange,
        padding: const EdgeInsets.all(10),
        child: Text(
          '$difference DAYS TO RACE',
          textAlign: TextAlign.center, 
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class SignupButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 90.0), 
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, 
            ),
          ),
          onPressed: () async {
            const url = 'https://midnattsloppet.com/midnattsloppet-stockholm/';
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: const Text(
            'Sign up for midnattsloppet now!',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}