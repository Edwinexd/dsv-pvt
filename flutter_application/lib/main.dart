import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'create-profile-page.dart';  
import 'package:flutter_application/controllers/group_controller.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/group_creation_page.dart';
import 'package:flutter/widgets.dart';
import 'profile_page.dart'; // Import the ProfilePage
import 'drawer.dart';

//Uppdaterad från PC.
void main() {
  runApp(const MainPage());
}

class MainPage extends StatefulWidget{
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage>{
  int selectedIndex = 0;

  static const List<Widget> widgetOptions = <Widget>[
    Text('Group Page', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Friends Page', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Start Activity Page', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Placeholder Page', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  void onItemtapped(int index){
    setState((){
      selectedIndex = index;
    });
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Midnattsloppet Now'),
        //backgroundColor: Colors.deepPurple[900],
      ),
      drawer: MyDrawer(
        onProfileTap: () => goToProfilePage(context),
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
              label: 'Friends',
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

  void goToProfilePage(BuildContext context){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(
          name: 'Jeb', 
          biography: 'Lets go running', 
          imageUrl: 'https://via.placeholder.com/150')
        ),
    );
  }
}


