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
