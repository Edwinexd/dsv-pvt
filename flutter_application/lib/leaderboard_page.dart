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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/background_for_pages.dart';
import 'package:flutter_application/bars.dart';
import 'package:flutter_application/controllers/backend_service.dart';
import 'package:flutter_application/home_page.dart';
import 'package:flutter_application/models/group.dart';
import 'package:flutter_application/views/group_page.dart';

class LeaderboardPage extends StatefulWidget {

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Group> leaderboardEntries = [];
  List<Group> myGroups = [];

  @override
  void initState() {
    super.initState();
    unawaited(BackendService().getGroups(0, 50, GroupOrderType.POINTS, true).then((groups) async {
      groups.sort((a, b) => b.points.compareTo(a.points));
      setState(() {
        leaderboardEntries = groups;
      });
    }));
    unawaited(BackendService().getMyGroups().then((groups) {
      setState(() {
        myGroups = groups;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        title: 'Leaderboard',
        showBackButton: true,
      ),
      body: DefaultBackground(
        child: Column(
          children: [
            // Create copy of leaderboard as it modifies the internal list
            Leaderboard(leaderboardEntries: List<Group>.of(leaderboardEntries), showCrown: true),
            Expanded(
              child: ListView.builder(
                itemCount: leaderboardEntries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(leaderboardEntries[index].name),
                    trailing:
                        Text('${leaderboardEntries[index].points} points'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupPage(
                            group: leaderboardEntries[index],
                            isMember: myGroups.any((group) => group.id == leaderboardEntries[index].id),
                          ),
                        ),
                      );
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(
        context: context,
      ),
    );
  }
}
