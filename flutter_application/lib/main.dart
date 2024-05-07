import 'package:flutter_application/activity_create.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/my_achievements.dart';
import 'package:flutter_application/settings.dart';
import 'package:flutter_application/views/my_groups.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'drawer.dart';
import 'package:flutter_application/views/login_page.dart';
import 'create_profile_page.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/home_page.dart';

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
      title: 'Lace up & lead the way',
      home: MainPage(
        darkModeEnabled: _darkModeEnabled,
        onToggleDarkMode: _toggleDarkMode,
      ),
      debugShowCheckedModeBanner: false,
      theme: _darkModeEnabled
          ? ThemeData.dark().copyWith(
              canvasColor: const Color.fromARGB(230, 60, 71, 133),
            )
          : ThemeData.light().copyWith(
              canvasColor: const Color.fromARGB(230, 60, 71, 133),
            ),
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
    Text('Create Activity Page',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Placeholder Page',
        style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  void onItemtapped(int index) {
    setState(() {
      selectedIndex = index;
      if (index == 0) {
        goToHomePage(context);
      }

      if (index == 1) {
        goToGroupPage(context);
      }

      if (index == 2) {
        // Go to Friends page
      }

      if (index == 3) {
        // Go to My Activity page
      }
    });
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: buildAppBar( 
        onPressed: () {
          goToProfilePage(context);
        },
        title: 'Lace up & lead the way',
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
      bottomNavigationBar: buildBottomNavigationBar( 
        selectedIndex: selectedIndex,
        onItemTapped: onItemtapped,
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
    ).then((_) {
      setState(() {
        selectedIndex = 0;
      });
    });
  }

  void goToGroupPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) => MyGroups()),
      ),
    ).then((_) {
      setState(() {
        selectedIndex = 0;
      });
    });
  }

  void goToMyAchievementsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyAchievements()),
    ).then((_) {
      setState(() {
        selectedIndex = 0;
      });
    });
  }

  void goToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyAchievements()),
    ).then((_) {
      setState(() {
        selectedIndex = 0;
      });
    });
  }
}
