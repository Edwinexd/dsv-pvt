import 'package:flutter_application/my_achievements.dart';
import 'package:flutter_application/settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/views/all_group_pages.dart';
import 'profile_page.dart'; // Import the ProfilePage
import 'drawer.dart';
import 'create-profile-page.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application/home_page.dart';

//Uppdaterad från PC.
void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkModeEnabled = false;

  void _toggleDarkMode(bool enabled) {
    setState(() {
      _darkModeEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Midnattsloppet Now',
      home: MainPage(
        darkModeEnabled: _darkModeEnabled,
        onToggleDarkMode: _toggleDarkMode,
      ),
      debugShowCheckedModeBanner: false,
      theme: _darkModeEnabled ? ThemeData.dark() : ThemeData.light(),
    );
  }
}

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
        onAchievementsTap: () => goToMyAchievementsPage(context),
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
      body: HomePage(),
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
//navigate to myAchievements
void goToMyAchievementsPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MyAchievements(),
    ),
  );
}
