import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_application/views/login_page.dart';

// Page that fetches isLoggedIn from BackendService
// if true, shows MainPage, else LoginPage
// while fetching show a static image

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
