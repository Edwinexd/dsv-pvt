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
import 'package:flutter_application/launch_injector.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
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
