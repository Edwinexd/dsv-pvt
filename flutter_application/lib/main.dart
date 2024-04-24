import 'package:flutter/material.dart';
import 'create-profile-page.dart';  
import 'package:flutter_application/controllers/group_controller.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter/widgets.dart';
import 'profile_page.dart'; // Import the ProfilePage
import 'drawer.dart';
import 'settings_page.dart'; // Import the SettingsPage

void main() {
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
      title: 'Profile Page Demo',
      home: MainPage(
        darkModeEnabled: _darkModeEnabled,
        onToggleDarkMode: _toggleDarkMode,
      ),
      debugShowCheckedModeBanner: false,
      theme: _darkModeEnabled ? ThemeData.dark() : ThemeData.light(),
    );
  }
}

class MainPage extends StatelessWidget {
  final bool darkModeEnabled;
  final ValueChanged<bool> onToggleDarkMode;

  const MainPage({
    Key? key,
    required this.darkModeEnabled,
    required this.onToggleDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfilePage(context),
        onSignoutTap: () {},
        onSettingsTap: () {
          // Navigate to the SettingsPage when settings is tapped
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage(
              onToggleDarkMode: onToggleDarkMode,
            )),
          );
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 200.0,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.teal[900],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                  child: Center(
                    // Centers the Column within the Container
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Makes the column take the size of its children
                      children: [
                        Transform.rotate(
                          angle: 315 * (3.1415926535897932 / 180), // Rotating 90 degrees, expressed in radians
                          child: const Icon(
                            Icons.arrow_upward, // Arrow icon
                            color: Colors.white,
                            size: 24, // Icon size
                          ),
                        ),
                        SizedBox(height: 10), // Spacing between icon and text
                        const Text(
                          'Press the \nmenu button',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontSize: 16, // Font size
                            fontWeight: FontWeight.bold, // Font weight
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  //navigate to profile page
  void goToProfilePage(BuildContext context) {
    Navigator.pop(context);

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
}