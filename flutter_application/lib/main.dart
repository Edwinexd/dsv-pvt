import 'package:flutter/material.dart';
import 'profile_page.dart'; // Import the ProfilePage
import 'drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page Demo',
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Page'),
        //backgroundColor: Colors.deepPurple[700],
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfilePage(context),
        onSignoutTap: () {},
        onSettingsTap: () {},
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
          name: 'Axel Andersson',
          biography: 'Älskar godis och andra goda grejer',
          imageUrl: 'https://via.placeholder.com/150',
        ),
      ),
    );
  }
}
