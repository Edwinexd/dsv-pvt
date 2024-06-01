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
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_application/views/login_page.dart';

class LaunchInjector extends StatelessWidget {
  final bool darkModeEnabled;
  final ValueChanged<bool> onToggleDarkMode;

  const LaunchInjector(
      {super.key, required this.darkModeEnabled, required this.onToggleDarkMode});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: BackendService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color.fromARGB(255, 180, 188, 149),
            body: Center(
              child: Image(image: AssetImage('lib/images/splash.png')),
            ),
          );
        } else if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('An error occurred'),
            ),
          );
        } else {
          bool? isLoggedIn = snapshot.data;
          if (isLoggedIn == null) {
            return const Scaffold(
              body: Center(
                child: Text('An error occurred'),
              ),
            );
          } else {
            return isLoggedIn
                ? MainPage(
                    darkModeEnabled: darkModeEnabled, onToggleDarkMode: onToggleDarkMode)
                : LoginPage(
                    darkModeEnabled: darkModeEnabled, onToggleDarkMode: onToggleDarkMode);
          }
        }
      },
    );
  }
}
