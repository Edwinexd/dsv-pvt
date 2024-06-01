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
