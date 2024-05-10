import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'bars.dart'; // Import the file where AppBar and BottomNavigationBar are defined

class MidnatsloppetActivity extends StatefulWidget {
  @override
  _MidnatsloppetActivityState createState() => _MidnatsloppetActivityState();
}

class _MidnatsloppetActivityState extends State<MidnatsloppetActivity> {
  List<bool> selectedActivities = List.generate(20, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        onPressed: () {
          //Here we define what happens when the AppBar button is pressed
        },
        title: 'Midnatsloppet Activity',
      ),
      body: DefaultBackground(
        child: ListView.builder(
          itemCount: selectedActivities.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text('Activity ${index + 1}'),
              value: selectedActivities[index],
              onChanged: (bool? value) {
                setState(() {
                  selectedActivities[index] = value!;
                });
              },
            );
          },
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        selectedIndex: 3, 
        onItemTapped: (index) {
        },
      ),
    );
  }
}