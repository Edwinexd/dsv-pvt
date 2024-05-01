import 'package:flutter_application/sign_in_page.dart';
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

//Uppdaterad från PC.
void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Midnattsloppet Now',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SignInPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

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
        goToGroupPage(context); // Nu har vi ingen home-page och indexen av grupp-ikonen är 0
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
        onSettingsTap: () {},
        
      ),
      body: Center(
        child: widgetOptions.elementAt(selectedIndex),
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
