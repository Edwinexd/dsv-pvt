import 'package:flutter_application/activity_create.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/launch_injector.dart';
import 'package:flutter_application/my_achievements.dart';
import 'package:flutter_application/settings.dart';
import 'package:flutter_application/views/my_groups.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'package:flutter_application/views/login_page.dart';
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
      home: LaunchInjector(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePage(),
    );
  }
}