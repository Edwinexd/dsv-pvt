import 'package:flutter_application/activity_create.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/my_achievements.dart';
import 'package:flutter_application/settings.dart';
import 'package:flutter_application/views/my_groups.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'profile_page.dart';
import 'drawer.dart';
import 'package:flutter_application/views/login_page.dart';
import 'package:flutter_application/home_page.dart';

// Page that fetches isLoggedIn from BackendService
// if true, shows MainPage, else LoginPage
// while fetching show a static image

class LaunchInjector extends StatelessWidget {
  const LaunchInjector({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: BackendService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color.fromARGB(255,180,188,149),
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
                    darkModeEnabled: false, onToggleDarkMode: (bool n) => {})
                : LoginPage(
                    darkModeEnabled: false, onToggleDarkMode: (bool n) => {});
          }
        }
      },
    );
  }
}
