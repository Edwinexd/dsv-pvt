import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'bars.dart'; 

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
        context: context,
        showBackButton: true,
        title: 'Midnatsloppet Activity',
      ),
      body: DefaultBackground(
        child: ListView.builder(
          itemCount: selectedActivities.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Activity ${index + 1}'),
              trailing: ElevatedButton(
                child: Text(selectedActivities[index] ? 'Leave' : 'Join'),
                onPressed: () {
                  setState(() {
                    selectedActivities[index] = !selectedActivities[index];
                  });
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}


